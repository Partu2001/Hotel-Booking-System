package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/BookRoom")
public class BookRoom extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("========== BOOKROOM SERVLET CALLED ==========");
        
        // Get parameters safely
        String roomNo = request.getParameter("roomno");
        String checkIn = request.getParameter("checkin");
        String checkOut = request.getParameter("checkout");
        String totalAmountStr = request.getParameter("totalAmount");
        String roomTotalStr = request.getParameter("roomTotal");
        String extraTotalStr = request.getParameter("extraTotal");
        String amenitiesJson = request.getParameter("amenities");
        String roomType = request.getParameter("type");
        String partnerHotelId = request.getParameter("hotelId");
        String partnerHotelName = request.getParameter("hotelName");
        
        boolean isPartnerRoom = "partner".equals(roomType);
        
        System.out.println("Room No: " + roomNo);
        System.out.println("Check In: " + checkIn);
        System.out.println("Check Out: " + checkOut);
        System.out.println("Is Partner Room: " + isPartnerRoom);
        
        double totalAmount = 0;
        double roomTotal = 0;
        double extraTotal = 0;
        
        try {
            if (totalAmountStr != null && !totalAmountStr.isEmpty()) {
                totalAmount = Double.parseDouble(totalAmountStr);
            }
            if (roomTotalStr != null && !roomTotalStr.isEmpty()) {
                roomTotal = Double.parseDouble(roomTotalStr);
            }
            if (extraTotalStr != null && !extraTotalStr.isEmpty()) {
                extraTotal = Double.parseDouble(extraTotalStr);
            }
        } catch (NumberFormatException e) {
            System.out.println("Number format error: " + e.getMessage());
        }
        
        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;

        if (username == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // Validate dates
        if (!validateDates(checkIn, checkOut)) {
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("<h2 style='color:red;'>Invalid Date Range!</h2>");
            out.println("<p>Check-in date must be today or later, and check-out must be after check-in.</p>");
            out.println("<a href='BookRoom.jsp?roomno=" + roomNo + "'>Go Back</a>");
            return;
        }

        String url = "jdbc:oracle:thin:@localhost:1522:xe";
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(url, "system", "system");
            
            // Start transaction
            con.setAutoCommit(false);

            if (isPartnerRoom && partnerHotelId != null) {
                // ========== PARTNER ROOM BOOKING ==========
                System.out.println("Processing PARTNER room booking");
                
                // Check if partner room exists
                pstmt = con.prepareStatement("SELECT room_id FROM partner_rooms WHERE room_id = ? AND room_number = ?");
                pstmt.setInt(1, Integer.parseInt(partnerHotelId));
                pstmt.setString(2, roomNo);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    int roomId = rs.getInt("room_id");
                    rs.close();
                    pstmt.close();
                    
                    // Check if dates are available (no overlapping bookings)
                    if (!arePartnerDatesAvailable(con, roomId, checkIn, checkOut)) {
                        response.setContentType("text/html");
                        PrintWriter out = response.getWriter();
                        out.println("<h2 style='color:red;'>Selected dates are not available for this room!</h2>");
                        out.println("<p>The room is already booked for some of the selected dates.</p>");
                        out.println("<a href='BookRoom.jsp?roomno=" + roomNo + "&type=partner&hotelId=" + partnerHotelId + "&hotelName=" + partnerHotelName + "'>Go Back</a>");
                        con.rollback();
                        return;
                    }
                    
                    // Create booking in partner_bookings table
                    PreparedStatement bookingStmt = con.prepareStatement(
                        "INSERT INTO partner_bookings (booking_id, room_id, room_number, username, check_in, check_out, total_amount, status, booking_date) VALUES (partner_booking_seq.NEXTVAL, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?, 'Confirmed', SYSDATE)"
                    );
                    
                    bookingStmt.setInt(1, roomId);
                    bookingStmt.setString(2, roomNo);
                    bookingStmt.setString(3, username);
                    bookingStmt.setString(4, checkIn);
                    bookingStmt.setString(5, checkOut);
                    bookingStmt.setDouble(6, totalAmount);
                    bookingStmt.executeUpdate();
                    bookingStmt.close();
                    
                    // Get the generated booking_id
                    PreparedStatement getIdStmt = con.prepareStatement("SELECT partner_booking_seq.CURRVAL FROM dual");
                    ResultSet idRs = getIdStmt.executeQuery();
                    int bookingId = 0;
                    if (idRs.next()) {
                        bookingId = idRs.getInt(1);
                    }
                    idRs.close();
                    getIdStmt.close();
                    
                    // IMPORTANT: DO NOT update room status to Booked
                    // Room remains Available for other dates
                    
                    con.commit();
                    
                    // Store booking info in session
                    session.setAttribute("bookingId", bookingId);
                    session.setAttribute("totalAmount", totalAmount);
                    session.setAttribute("roomTotal", roomTotal);
                    session.setAttribute("extraTotal", extraTotal);
                    session.setAttribute("roomNo", roomNo);
                    session.setAttribute("hotelName", partnerHotelName);
                    session.setAttribute("checkIn", checkIn);
                    session.setAttribute("checkOut", checkOut);
                    session.setAttribute("isPartnerBooking", true);
                    session.setAttribute("amenities", amenitiesJson);
                    
                    System.out.println("Partner booking created successfully! Room remains available for other dates.");
                    System.out.println("Booking ID: " + bookingId);
                    
                    response.sendRedirect("Payment.jsp");
                    
                } else {
                    response.setContentType("text/html");
                    PrintWriter out = response.getWriter();
                    out.println("<h2 style='color:red;'>Partner Room Not Found</h2>");
                    out.println("<a href='ViewRoom.jsp'>Go Back</a>");
                }
                
            } else {
                // ========== MAIN HOTEL ROOM BOOKING ==========
                System.out.println("Processing MAIN hotel room booking");
                
                // Check if room exists
                pstmt = con.prepareStatement("SELECT roomno FROM room WHERE roomno=?");
                pstmt.setString(1, roomNo);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    rs.close();
                    pstmt.close();
                    
                    // Check if selected dates overlap with existing bookings
                    if (!areDatesAvailable(con, roomNo, checkIn, checkOut)) {
                        response.setContentType("text/html");
                        PrintWriter out = response.getWriter();
                        out.println("<h2 style='color:red;'>Selected dates are not available for this room!</h2>");
                        out.println("<p>The room is already booked for some of the selected dates.</p>");
                        out.println("<a href='BookRoom.jsp?roomno=" + roomNo + "'>Go Back</a>");
                        con.rollback();
                        return;
                    }
                    
                    // Create booking
                    PreparedStatement bookingStmt = con.prepareStatement(
                        "INSERT INTO bookings (booking_id, roomno, username, check_in, check_out, total_amount, status) VALUES (booking_seq.NEXTVAL, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?, 'Confirmed')"
                    );
                    
                    bookingStmt.setString(1, roomNo);
                    bookingStmt.setString(2, username);
                    bookingStmt.setString(3, checkIn);
                    bookingStmt.setString(4, checkOut);
                    bookingStmt.setDouble(5, totalAmount);
                    bookingStmt.executeUpdate();
                    bookingStmt.close();

                    // Get the generated booking_id
                    PreparedStatement getIdStmt = con.prepareStatement("SELECT booking_seq.CURRVAL FROM dual");
                    ResultSet idRs = getIdStmt.executeQuery();
                    int bookingId = 0;
                    if (idRs.next()) {
                        bookingId = idRs.getInt(1);
                    }
                    idRs.close();
                    getIdStmt.close();
                    
                    // IMPORTANT: DO NOT update room status to Booked
                    // Room remains Available for other dates
                    
                    con.commit();
                    
                    // Store booking info in session
                    session.setAttribute("bookingId", bookingId);
                    session.setAttribute("totalAmount", totalAmount);
                    session.setAttribute("roomTotal", roomTotal);
                    session.setAttribute("extraTotal", extraTotal);
                    session.setAttribute("roomNo", roomNo);
                    session.setAttribute("checkIn", checkIn);
                    session.setAttribute("checkOut", checkOut);
                    session.setAttribute("isPartnerBooking", false);
                    session.setAttribute("amenities", amenitiesJson);
                    
                    System.out.println("Main booking created successfully! Room remains available for other dates.");
                    System.out.println("Booking ID: " + bookingId);
                    
                    response.sendRedirect("Payment.jsp");
                    
                } else {
                    response.setContentType("text/html");
                    PrintWriter out = response.getWriter();
                    out.println("<h2 style='color:red;'>Room Not Found</h2>");
                    out.println("<a href='ViewRoom.jsp'>Go Back</a>");
                }
            }

        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("<h2 style='color:red;'>Error: " + e.getMessage() + "</h2>");
            out.println("<a href='ViewRoom.jsp'>Go Back</a>");
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
    
    private boolean validateDates(String checkIn, String checkOut) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date checkInDate = sdf.parse(checkIn);
            Date checkOutDate = sdf.parse(checkOut);
            Date today = new Date();
            today = sdf.parse(sdf.format(today));
            
            return !checkInDate.before(today) && checkOutDate.after(checkInDate);
        } catch (Exception e) {
            return false;
        }
    }
    
    // Check if dates are available for main hotel room
    private boolean areDatesAvailable(Connection con, String roomNo, String checkIn, String checkOut) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE roomno = ? AND status = 'Confirmed' AND " +
                     "((check_in <= TO_DATE(?, 'YYYY-MM-DD') AND check_out > TO_DATE(?, 'YYYY-MM-DD')) " +
                     "OR (check_in < TO_DATE(?, 'YYYY-MM-DD') AND check_out >= TO_DATE(?, 'YYYY-MM-DD')) " +
                     "OR (check_in >= TO_DATE(?, 'YYYY-MM-DD') AND check_out <= TO_DATE(?, 'YYYY-MM-DD')))";
        
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, roomNo);
        ps.setString(2, checkOut);
        ps.setString(3, checkIn);
        ps.setString(4, checkIn);
        ps.setString(5, checkOut);
        ps.setString(6, checkIn);
        ps.setString(7, checkOut);
        
        ResultSet rs = ps.executeQuery();
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        ps.close();
        
        System.out.println("Overlapping bookings count for room " + roomNo + ": " + count);
        return count == 0;
    }
    
    // Check if dates are available for partner room
    private boolean arePartnerDatesAvailable(Connection con, int roomId, String checkIn, String checkOut) throws SQLException {
        String sql = "SELECT COUNT(*) FROM partner_bookings WHERE room_id = ? AND status = 'Confirmed' AND " +
                     "((check_in <= TO_DATE(?, 'YYYY-MM-DD') AND check_out > TO_DATE(?, 'YYYY-MM-DD')) " +
                     "OR (check_in < TO_DATE(?, 'YYYY-MM-DD') AND check_out >= TO_DATE(?, 'YYYY-MM-DD')) " +
                     "OR (check_in >= TO_DATE(?, 'YYYY-MM-DD') AND check_out <= TO_DATE(?, 'YYYY-MM-DD')))";
        
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, roomId);
        ps.setString(2, checkOut);
        ps.setString(3, checkIn);
        ps.setString(4, checkIn);
        ps.setString(5, checkOut);
        ps.setString(6, checkIn);
        ps.setString(7, checkOut);
        
        ResultSet rs = ps.executeQuery();
        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        ps.close();
        
        System.out.println("Overlapping bookings count for partner room: " + count);
        return count == 0;
    }
}