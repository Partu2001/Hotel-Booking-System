package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("========== PAYMENT SERVLET CALLED ==========");

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String method = request.getParameter("method");
        String enteredPassword = request.getParameter("pass");
        String username = (String) session.getAttribute("username");
        
        // Get booking details from session
        Integer bookingId = (Integer) session.getAttribute("bookingId");
        Double totalAmount = (Double) session.getAttribute("totalAmount");
        String roomNo = (String) session.getAttribute("roomNo");
        String hotelName = (String) session.getAttribute("hotelName");
        Boolean isPartnerBooking = (Boolean) session.getAttribute("isPartnerBooking");
        Double roomTotal = (Double) session.getAttribute("roomTotal");
        Double extraTotal = (Double) session.getAttribute("extraTotal");
        String checkIn = (String) session.getAttribute("checkIn");
        String checkOut = (String) session.getAttribute("checkOut");
        
        System.out.println("Username: " + username);
        System.out.println("Booking ID: " + bookingId);
        System.out.println("Total Amount: " + totalAmount);
        System.out.println("Is Partner Booking: " + isPartnerBooking);
        System.out.println("Payment Method: " + method);

        // Validate payment method
        if (method == null || method.isEmpty()) {
            showErrorPage(out, "Please select a payment method.", "Payment.jsp");
            return;
        }

        if (enteredPassword == null || enteredPassword.isEmpty()) {
            showErrorPage(out, "Please enter your payment password.", "Payment.jsp");
            return;
        }

        if (bookingId == null || totalAmount == null) {
            showErrorPage(out, "Booking session expired. Please book again.", "Dashboard.jsp");
            return;
        }

        // Validate password from database
        if (!validatePaymentPassword(username, enteredPassword)) {
            showErrorPage(out, "Invalid payment password! Please enter the correct payment password.", "Payment.jsp");
            return;
        }

        String url = "jdbc:oracle:thin:@localhost:1522:xe";
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection(url, "system", "system");
            
            if (isPartnerBooking != null && isPartnerBooking) {
                // ========== PARTNER BOOKING PAYMENT ==========
                System.out.println("Processing PARTNER booking payment");
                
                // Insert payment record for partner booking
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO partner_payments (payment_id, booking_id, amount, payment_method, status, payment_date) " +
                    "VALUES (partner_payment_seq.NEXTVAL, ?, ?, ?, 'Completed', SYSDATE)"
                );
                ps.setInt(1, bookingId);
                ps.setDouble(2, totalAmount);
                ps.setString(3, method);
                ps.executeUpdate();
                ps.close();
                
                System.out.println("Partner payment recorded successfully!");
                
            } else {
                // ========== MAIN BOOKING PAYMENT ==========
                System.out.println("Processing MAIN booking payment");
                
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO payments (payment_id, booking_id, amount, payment_method, status, payment_date) " +
                    "VALUES (payment_seq.NEXTVAL, ?, ?, ?, 'Completed', SYSDATE)"
                );
                ps.setInt(1, bookingId);
                ps.setDouble(2, totalAmount);
                ps.setString(3, method);
                ps.executeUpdate();
                ps.close();
                
                System.out.println("Main payment recorded successfully!");
            }
            
            con.close();
            
            // Clear booking session attributes
            session.removeAttribute("bookingId");
            session.removeAttribute("totalAmount");
            session.removeAttribute("roomTotal");
            session.removeAttribute("extraTotal");
            session.removeAttribute("roomNo");
            session.removeAttribute("hotelName");
            session.removeAttribute("checkIn");
            session.removeAttribute("checkOut");
            session.removeAttribute("isPartnerBooking");
            session.removeAttribute("amenities");
            
            String displayRoom = roomNo;
            if (isPartnerBooking != null && isPartnerBooking && hotelName != null && !hotelName.isEmpty()) {
                displayRoom = hotelName + " - " + roomNo;
            }
            
            showSuccessPage(out, totalAmount, displayRoom, method, roomTotal, extraTotal, checkIn, checkOut);
            
        } catch (Exception e) {
            e.printStackTrace();
            showErrorPage(out, "Payment processing error: " + e.getMessage(), "Payment.jsp");
        }
    }
    
    private boolean validatePaymentPassword(String username, String enteredPassword) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            ps = con.prepareStatement("SELECT payment_password FROM userdata WHERE username = ?");
            ps.setString(1, username);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                String storedPassword = rs.getString("payment_password");
                return storedPassword != null && storedPassword.equals(enteredPassword);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
        
        return false;
    }
    
    private void showErrorPage(PrintWriter out, String message, String backPage) {
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Payment Failed</title>");
        out.println("<link href='https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap' rel='stylesheet'>");
        out.println("<style>");
        out.println("*{margin:0;padding:0;box-sizing:border-box;}");
        out.println("body{font-family:'Poppins',Arial,sans-serif;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);height:100vh;display:flex;justify-content:center;align-items:center;margin:0;}");
        out.println(".container{background:white;padding:40px;border-radius:20px;text-align:center;max-width:400px;box-shadow:0 20px 40px rgba(0,0,0,0.2);}");
        out.println("h2{color:#dc3545;margin-bottom:15px;}");
        out.println(".icon{font-size:60px;margin-bottom:20px;}");
        out.println(".btn{display:inline-block;margin-top:20px;padding:12px 30px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:white;text-decoration:none;border-radius:10px;font-weight:600;transition:all 0.3s;}");
        out.println(".btn:hover{transform:translateY(-2px);box-shadow:0 5px 15px rgba(0,0,0,0.2);}");
        out.println("</style></head><body>");
        out.println("<div class='container'>");
        out.println("<div class='icon'>❌</div>");
        out.println("<h2>Payment Failed</h2>");
        out.println("<p>" + message + "</p>");
        out.println("<a href='" + backPage + "' class='btn'>Try Again</a>");
        out.println("</div></body></html>");
    }
    
    private void showSuccessPage(PrintWriter out, double totalAmount, String roomDisplay, String method, 
                                  Double roomTotal, Double extraTotal, String checkIn, String checkOut) {
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Payment Success</title>");
        out.println("<link href='https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap' rel='stylesheet'>");
        out.println("<style>");
        out.println("*{margin:0;padding:0;box-sizing:border-box;}");
        out.println("body{font-family:'Poppins',Arial,sans-serif;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);min-height:100vh;display:flex;justify-content:center;align-items:center;margin:0;padding:20px;}");
        out.println(".container{background:white;padding:40px;border-radius:20px;text-align:center;max-width:500px;box-shadow:0 20px 40px rgba(0,0,0,0.2);animation:slideUp 0.5s ease-out;}");
        out.println("@keyframes slideUp{from{opacity:0;transform:translateY(30px);}to{opacity:1;transform:translateY(0);}}");
        out.println("h1{color:#28a745;margin-bottom:10px;font-size:28px;}");
        out.println(".success-icon{font-size:70px;margin-bottom:20px;}");
        out.println(".booking-details{background:#f8f9fa;border-radius:15px;padding:20px;margin:20px 0;text-align:left;}");
        out.println(".detail-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid #e0e0e0;}");
        out.println(".detail-label{color:#666;font-weight:500;}");
        out.println(".detail-value{color:#333;font-weight:600;}");
        out.println(".total-row{background:#e8f5e9;border-radius:10px;padding:15px;margin-top:15px;display:flex;justify-content:space-between;}");
        out.println(".total-label{font-size:18px;font-weight:bold;color:#2e7d32;}");
        out.println(".total-amount{font-size:22px;font-weight:bold;color:#28a745;}");
        out.println(".btn{display:inline-block;margin:10px;padding:12px 25px;background:linear-gradient(135deg,#28a745 0%,#20c997 100%);color:white;text-decoration:none;border-radius:10px;font-weight:600;transition:all 0.3s;}");
        out.println(".btn-secondary{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);}");
        out.println(".btn:hover{transform:translateY(-2px);box-shadow:0 5px 15px rgba(0,0,0,0.2);}");
        out.println("</style></head><body>");
        out.println("<div class='container'>");
        out.println("<div class='success-icon'>✅</div>");
        out.println("<h1>Payment Successful!</h1>");
        out.println("<p>Your booking has been confirmed</p>");
        
        out.println("<div class='booking-details'>");
        out.println("<div class='detail-row'><span class='detail-label'>Room:</span><span class='detail-value'>" + roomDisplay + "</span></div>");
        if (checkIn != null && checkOut != null) {
            out.println("<div class='detail-row'><span class='detail-label'>Check-in:</span><span class='detail-value'>" + checkIn + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Check-out:</span><span class='detail-value'>" + checkOut + "</span></div>");
        }
        if (roomTotal != null && roomTotal > 0) {
            out.println("<div class='detail-row'><span class='detail-label'>Room Charges:</span><span class='detail-value'>₹" + String.format("%,.2f", roomTotal) + "</span></div>");
        }
        if (extraTotal != null && extraTotal > 0) {
            out.println("<div class='detail-row'><span class='detail-label'>Extra Amenities:</span><span class='detail-value'>₹" + String.format("%,.2f", extraTotal) + "</span></div>");
        }
        out.println("<div class='detail-row'><span class='detail-label'>Payment Method:</span><span class='detail-value'>" + method + "</span></div>");
        out.println("<div class='total-row'><span class='total-label'>Total Amount:</span><span class='total-amount'>₹" + String.format("%,.2f", totalAmount) + "</span></div>");
        out.println("</div>");
        
        out.println("<a href='Dashboard.jsp' class='btn'>Go to Dashboard</a>");
        out.println("<a href='MyBookings.jsp' class='btn btn-secondary'>View My Bookings</a>");
        out.println("</div></body></html>");
    }
}