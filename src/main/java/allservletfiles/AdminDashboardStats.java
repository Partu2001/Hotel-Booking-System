package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;


@WebServlet("/AdminDashboardStats")
public class AdminDashboardStats extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            // Get total rooms
            ps = con.prepareStatement("SELECT COUNT(*) as count FROM room");
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("totalRooms", rs.getInt("count"));
            }
            rs.close();
            ps.close();
            
            // Get available rooms
            ps = con.prepareStatement("SELECT COUNT(*) as count FROM room WHERE status = 'Available'");
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("availableRooms", rs.getInt("count"));
            }
            rs.close();
            ps.close();
            
            // Get total bookings
            ps = con.prepareStatement("SELECT COUNT(*) as count FROM bookings");
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("totalBookings", rs.getInt("count"));
            }
            rs.close();
            ps.close();
            
            // Get total users
            ps = con.prepareStatement("SELECT COUNT(*) as count FROM userdata");
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("totalUsers", rs.getInt("count"));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            stats.put("error", e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print(stats.toString());
        out.flush();
    }
}