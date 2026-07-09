package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/CancelBooking")
public class CancelBooking extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String bookingIdStr = request.getParameter("bookingId");
        String roomNo = request.getParameter("roomNo");
        
        if (bookingIdStr == null || bookingIdStr.isEmpty() || roomNo == null || roomNo.isEmpty()) {
            String jsonResponse = "{\"success\": false, \"message\": \"Missing booking information\"}";
            out.print(jsonResponse);
            out.flush();
            return;
        }
        
        int bookingId = 0;
        try {
            bookingId = Integer.parseInt(bookingIdStr);
        } catch (NumberFormatException e) {
            String jsonResponse = "{\"success\": false, \"message\": \"Invalid booking ID\"}";
            out.print(jsonResponse);
            out.flush();
            return;
        }
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            con.setAutoCommit(false);
            
            // Check if booking exists
            ps = con.prepareStatement("SELECT status FROM bookings WHERE booking_id = ?");
            ps.setInt(1, bookingId);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                String jsonResponse = "{\"success\": false, \"message\": \"Booking not found\"}";
                out.print(jsonResponse);
                out.flush();
                return;
            }
            
            String currentStatus = rs.getString("status");
            if ("Cancelled".equals(currentStatus)) {
                String jsonResponse = "{\"success\": false, \"message\": \"Booking is already cancelled\"}";
                out.print(jsonResponse);
                out.flush();
                return;
            }
            rs.close();
            ps.close();
            
            // Update booking status to Cancelled
            ps = con.prepareStatement("UPDATE bookings SET status = 'Cancelled' WHERE booking_id = ?");
            ps.setInt(1, bookingId);
            int updated = ps.executeUpdate();
            ps.close();
            
            if (updated > 0) {
                // IMPORTANT: DO NOT update room status back to Available
                // Room should remain as is since other bookings may exist for different dates
                
                con.commit();
                String jsonResponse = "{\"success\": true, \"message\": \"Booking cancelled successfully\"}";
                out.print(jsonResponse);
                System.out.println("Booking " + bookingId + " cancelled successfully");
            } else {
                con.rollback();
                String jsonResponse = "{\"success\": false, \"message\": \"Failed to update booking\"}";
                out.print(jsonResponse);
            }
            
        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            String jsonResponse = "{\"success\": false, \"message\": \"" + e.getMessage().replace("\"", "\\\"") + "\"}";
            out.print(jsonResponse);
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
        
        out.flush();
    }
}