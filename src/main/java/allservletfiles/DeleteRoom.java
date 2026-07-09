package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/DeleteRoom")
public class DeleteRoom extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String roomNo = request.getParameter("roomno");
        
        if (roomNo == null || roomNo.isEmpty()) {
            out.print("ERROR: Room number is required");
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
            
            // Check if room exists and is not booked
            ps = con.prepareStatement("SELECT status FROM room WHERE roomno = ?");
            ps.setString(1, roomNo);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                out.print("ERROR: Room not found");
                con.rollback();
                out.flush();
                return;
            }
            
            String status = rs.getString("status");
            if ("Booked".equalsIgnoreCase(status)) {
                out.print("ERROR: Cannot delete room that is currently booked");
                con.rollback();
                out.flush();
                return;
            }
            rs.close();
            ps.close();
            
            // 1. Delete from room_amenities first
            ps = con.prepareStatement("DELETE FROM room_amenities WHERE roomno = ?");
            ps.setString(1, roomNo);
            int amenitiesDeleted = ps.executeUpdate();
            System.out.println("Deleted " + amenitiesDeleted + " amenities for room " + roomNo);
            ps.close();
            
            // 2. Update any bookings for this room (set roomno to NULL or delete cancelled ones)
            // First, check if there are any cancelled bookings for this room
            ps = con.prepareStatement("SELECT COUNT(*) FROM bookings WHERE roomno = ? AND status = 'Cancelled'");
            ps.setString(1, roomNo);
            rs = ps.executeQuery();
            int cancelledCount = 0;
            if (rs.next()) {
                cancelledCount = rs.getInt(1);
            }
            rs.close();
            ps.close();
            
            // Delete cancelled bookings for this room
            if (cancelledCount > 0) {
                ps = con.prepareStatement("DELETE FROM bookings WHERE roomno = ? AND status = 'Cancelled'");
                ps.setString(1, roomNo);
                int deletedBookings = ps.executeUpdate();
                System.out.println("Deleted " + deletedBookings + " cancelled bookings for room " + roomNo);
                ps.close();
            }
            
            // 3. Check if there are any active bookings for this room
            ps = con.prepareStatement("SELECT COUNT(*) FROM bookings WHERE roomno = ? AND status = 'Confirmed'");
            ps.setString(1, roomNo);
            rs = ps.executeQuery();
            int activeBookings = 0;
            if (rs.next()) {
                activeBookings = rs.getInt(1);
            }
            rs.close();
            ps.close();
            
            if (activeBookings > 0) {
                out.print("ERROR: Cannot delete room. There are " + activeBookings + " active booking(s) for this room.");
                con.rollback();
                out.flush();
                return;
            }
            
            // 4. Delete any payments related to cancelled bookings (if any)
            ps = con.prepareStatement(
                "DELETE FROM payments WHERE booking_id IN (SELECT booking_id FROM bookings WHERE roomno = ?)"
            );
            ps.setString(1, roomNo);
            int paymentsDeleted = ps.executeUpdate();
            System.out.println("Deleted " + paymentsDeleted + " payments for room " + roomNo);
            ps.close();
            
            // 5. Delete all remaining bookings for this room (should only be cancelled ones)
            ps = con.prepareStatement("DELETE FROM bookings WHERE roomno = ?");
            ps.setString(1, roomNo);
            int bookingsDeleted = ps.executeUpdate();
            System.out.println("Deleted " + bookingsDeleted + " bookings for room " + roomNo);
            ps.close();
            
            // 6. Finally, delete the room
            ps = con.prepareStatement("DELETE FROM room WHERE roomno = ?");
            ps.setString(1, roomNo);
            int deleted = ps.executeUpdate();
            ps.close();
            
            if (deleted > 0) {
                con.commit();
                out.print("SUCCESS: Room " + roomNo + " deleted successfully along with " + 
                         amenitiesDeleted + " amenities and " + bookingsDeleted + " bookings");
                System.out.println("Room " + roomNo + " deleted successfully");
            } else {
                con.rollback();
                out.print("ERROR: Failed to delete room");
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