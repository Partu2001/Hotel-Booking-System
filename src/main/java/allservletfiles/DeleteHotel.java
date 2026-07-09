package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/DeleteHotel")
public class DeleteHotel extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;
        
        if (username == null) {
            out.print("ERROR: Not logged in");
            out.flush();
            return;
        }
        
        int hotelId = Integer.parseInt(request.getParameter("hotelId"));
        
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            con.setAutoCommit(false);
            
            // Verify ownership
            ps = con.prepareStatement("SELECT partner_username FROM partner_hotels WHERE hotel_id = ?");
            ps.setInt(1, hotelId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next() || !rs.getString("partner_username").equals(username)) {
                out.print("ERROR: Unauthorized");
                con.rollback();
                out.flush();
                return;
            }
            rs.close();
            ps.close();
            
            // Delete rooms first (due to foreign key)
            ps = con.prepareStatement("DELETE FROM partner_rooms WHERE hotel_id = ?");
            ps.setInt(1, hotelId);
            int roomsDeleted = ps.executeUpdate();
            ps.close();
            
            // Delete hotel
            ps = con.prepareStatement("DELETE FROM partner_hotels WHERE hotel_id = ?");
            ps.setInt(1, hotelId);
            int deleted = ps.executeUpdate();
            ps.close();
            
            if (deleted > 0) {
                con.commit();
                out.print("SUCCESS: Hotel and " + roomsDeleted + " rooms deleted successfully");
            } else {
                con.rollback();
                out.print("ERROR: Failed to delete hotel");
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