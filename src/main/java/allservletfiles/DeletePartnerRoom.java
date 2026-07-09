package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/DeletePartnerRoom")
public class DeletePartnerRoom extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String roomIdStr = request.getParameter("roomId");
        
        if (roomIdStr == null || roomIdStr.isEmpty()) {
            out.print("ERROR: Room ID is required");
            out.flush();
            return;
        }
        
        int roomId = Integer.parseInt(roomIdStr);
        
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            con.setAutoCommit(false);
            
            // Delete room amenities first
            ps = con.prepareStatement("DELETE FROM partner_room_amenities WHERE room_id = ?");
            ps.setInt(1, roomId);
            ps.executeUpdate();
            ps.close();
            
            // Delete the room
            ps = con.prepareStatement("DELETE FROM partner_rooms WHERE room_id = ?");
            ps.setInt(1, roomId);
            int deleted = ps.executeUpdate();
            ps.close();
            
            if (deleted > 0) {
                con.commit();
                out.print("SUCCESS: Room deleted successfully");
            } else {
                con.rollback();
                out.print("ERROR: Room not found");
            }
            
        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            out.print("ERROR: " + e.getMessage().replace("\n", " ").replace("\r", " "));
        } finally {
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
        
        out.flush();
    }
}