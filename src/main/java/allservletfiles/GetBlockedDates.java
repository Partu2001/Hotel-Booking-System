package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/GetBlockedDates")
public class GetBlockedDates extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String roomNo = request.getParameter("roomno");
        String type = request.getParameter("type");
        String hotelId = request.getParameter("hotelId");
        
        if (roomNo == null || roomNo.isEmpty()) {
            out.print("");
            out.flush();
            return;
        }
        
        List<String> blockedDatesList = new ArrayList<>();
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            if ("partner".equals(type) && hotelId != null) {
                // For partner rooms - get all future bookings
                String sql = "SELECT check_in, check_out FROM partner_bookings WHERE room_id = ? AND status = 'Confirmed' AND check_out >= TRUNC(SYSDATE)";
                ps = con.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(hotelId));
            } else {
                // For main hotel rooms - get all future bookings
                String sql = "SELECT check_in, check_out FROM bookings WHERE roomno = ? AND status = 'Confirmed' AND check_out >= TRUNC(SYSDATE)";
                ps = con.prepareStatement(sql);
                ps.setString(1, roomNo);
            }
            
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Date checkIn = rs.getDate("check_in");
                Date checkOut = rs.getDate("check_out");
                
                java.util.Calendar cal = java.util.Calendar.getInstance();
                cal.setTime(checkIn);
                java.util.Calendar endCal = java.util.Calendar.getInstance();
                endCal.setTime(checkOut);
                
                // Add all dates from check_in to check_out-1 as blocked
                while (cal.before(endCal)) {
                    String dateStr = new java.sql.Date(cal.getTimeInMillis()).toString();
                    blockedDatesList.add(dateStr);
                    cal.add(java.util.Calendar.DATE, 1);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
        
        // Send as comma-separated values
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < blockedDatesList.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(blockedDatesList.get(i));
        }
        out.print(sb.toString());
        out.flush();
    }
}