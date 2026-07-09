package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/DeleteUser")
public class DeleteUser extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String username = request.getParameter("username");
        
        if (username == null || username.isEmpty()) {
            out.print("ERROR: Username is required");
            out.flush();
            return;
        }
        
        // Prevent deleting admin account
        if ("admin".equalsIgnoreCase(username)) {
            out.print("ERROR: Cannot delete the main admin account");
            out.flush();
            return;
        }
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            // Start transaction
            con.setAutoCommit(false);
            
            // Check if user exists
            ps = con.prepareStatement("SELECT username FROM userdata WHERE username = ?");
            ps.setString(1, username);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                out.print("ERROR: User not found");
                con.rollback();
                out.flush();
                return;
            }
            rs.close();
            ps.close();
            
            // First, delete payments related to user's bookings
            ps = con.prepareStatement(
                "DELETE FROM payments WHERE booking_id IN (SELECT booking_id FROM bookings WHERE username = ?)"
            );
            ps.setString(1, username);
            int paymentsDeleted = ps.executeUpdate();
            System.out.println("Deleted " + paymentsDeleted + " payments for user " + username);
            ps.close();
            
            // Delete user's bookings
            ps = con.prepareStatement("DELETE FROM bookings WHERE username = ?");
            ps.setString(1, username);
            int bookingsDeleted = ps.executeUpdate();
            System.out.println("Deleted " + bookingsDeleted + " bookings for user " + username);
            ps.close();
            
            // Finally, delete the user
            ps = con.prepareStatement("DELETE FROM userdata WHERE username = ?");
            ps.setString(1, username);
            int deleted = ps.executeUpdate();
            ps.close();
            
            if (deleted > 0) {
                con.commit();
                out.print("SUCCESS: User " + username + " deleted successfully");
                System.out.println("User " + username + " deleted successfully");
            } else {
                con.rollback();
                out.print("ERROR: Failed to delete user");
            }
            
        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
                System.out.println("Transaction rolled back due to error");
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            out.print("ERROR: " + e.getMessage().replace("\n", " ").replace("\r", " "));
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
        
        out.flush();
    }
}