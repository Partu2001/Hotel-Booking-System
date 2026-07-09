package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/ApprovePartner")
public class ApprovePartner extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String hotelIdStr = request.getParameter("hotelId");
        String username = request.getParameter("username");
        String action = request.getParameter("action");
        
        System.out.println("ApprovePartner called - hotelId: " + hotelIdStr + ", username: " + username + ", action: " + action);
        
        if (hotelIdStr == null || username == null || action == null) {
            out.print("ERROR: Missing parameters");
            out.flush();
            return;
        }
        
        int hotelId = Integer.parseInt(hotelIdStr);
        
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            con.setAutoCommit(false);
            
            if ("approve".equals(action)) {
                // Update partner_hotels status
                ps = con.prepareStatement("UPDATE partner_hotels SET status = 'Approved', approved_date = SYSDATE WHERE hotel_id = ?");
                ps.setInt(1, hotelId);
                int updated = ps.executeUpdate();
                ps.close();
                
                if (updated > 0) {
                    // Update user's is_hotel_partner status
                    ps = con.prepareStatement("UPDATE userdata SET is_hotel_partner = 'APPROVED' WHERE username = ?");
                    ps.setString(1, username);
                    ps.executeUpdate();
                    
                    con.commit();
                    out.print("SUCCESS: Hotel approved successfully");
                    System.out.println("Hotel approved successfully");
                } else {
                    con.rollback();
                    out.print("ERROR: Failed to update hotel status");
                }
            } else if ("reject".equals(action)) {
                // Delete the hotel request
                ps = con.prepareStatement("DELETE FROM partner_hotels WHERE hotel_id = ?");
                ps.setInt(1, hotelId);
                int deleted = ps.executeUpdate();
                ps.close();
                
                if (deleted > 0) {
                    con.commit();
                    out.print("SUCCESS: Hotel request rejected");
                    System.out.println("Hotel request rejected");
                } else {
                    con.rollback();
                    out.print("ERROR: Failed to reject hotel");
                }
            } else {
                out.print("ERROR: Invalid action");
            }
            
        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {}
            e.printStackTrace();
            out.print("ERROR: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
        
        out.flush();
    }
}