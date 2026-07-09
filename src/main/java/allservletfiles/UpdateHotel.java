package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/UpdateHotel")
public class UpdateHotel extends HttpServlet {
    
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
        String hotelName = request.getParameter("hotelName");
        String hotelLocation = request.getParameter("hotelLocation");
        String hotelPhone = request.getParameter("hotelPhone");
        String hotelEmail = request.getParameter("hotelEmail");
        String hotelDescription = request.getParameter("hotelDescription");
        
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            // Verify ownership
            ps = con.prepareStatement("SELECT partner_username FROM partner_hotels WHERE hotel_id = ?");
            ps.setInt(1, hotelId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next() || !rs.getString("partner_username").equals(username)) {
                out.print("ERROR: Unauthorized");
                out.flush();
                return;
            }
            rs.close();
            ps.close();
            
            // Update hotel
            ps = con.prepareStatement(
                "UPDATE partner_hotels SET hotel_name=?, hotel_location=?, hotel_phone=?, hotel_email=?, hotel_description=? WHERE hotel_id=?"
            );
            ps.setString(1, hotelName);
            ps.setString(2, hotelLocation);
            ps.setString(3, hotelPhone);
            ps.setString(4, hotelEmail);
            ps.setString(5, hotelDescription);
            ps.setInt(6, hotelId);
            
            int updated = ps.executeUpdate();
            
            if (updated > 0) {
                out.print("SUCCESS: Hotel updated successfully");
            } else {
                out.print("ERROR: Failed to update hotel");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("ERROR: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
        
        out.flush();
    }
}