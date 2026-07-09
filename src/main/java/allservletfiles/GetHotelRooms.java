package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/GetHotelRooms")
public class GetHotelRooms extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String hotelIdStr = request.getParameter("hotelId");
        
        if (hotelIdStr == null || hotelIdStr.isEmpty()) {
            out.print("[]");
            out.flush();
            return;
        }
        
        int hotelId = Integer.parseInt(hotelIdStr);
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            ps = con.prepareStatement("SELECT room_id, room_number, room_type, bed_type, price, capacity, amenities, status FROM partner_rooms WHERE hotel_id = ? ORDER BY room_number");
            ps.setInt(1, hotelId);
            rs = ps.executeQuery();
            
            StringBuilder json = new StringBuilder();
            json.append("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{");
                json.append("\"room_id\":").append(rs.getInt("room_id")).append(",");
                json.append("\"room_number\":\"").append(escapeJson(rs.getString("room_number"))).append("\",");
                json.append("\"room_type\":\"").append(escapeJson(rs.getString("room_type"))).append("\",");
                json.append("\"bed_type\":\"").append(escapeJson(rs.getString("bed_type"))).append("\",");
                json.append("\"price\":").append(rs.getDouble("price")).append(",");
                json.append("\"capacity\":").append(rs.getInt("capacity")).append(",");
                json.append("\"amenities\":\"").append(escapeJson(rs.getString("amenities") != null ? rs.getString("amenities") : "")).append("\",");
                json.append("\"status\":\"").append(escapeJson(rs.getString("status"))).append("\"");
                json.append("}");
                first = false;
            }
            json.append("]");
            
            out.print(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
        
        out.flush();
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}