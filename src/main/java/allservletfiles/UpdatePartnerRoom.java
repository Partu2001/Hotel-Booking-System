package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/UpdatePartnerRoom")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class UpdatePartnerRoom extends HttpServlet {
    
    private static final String UPLOAD_DIR = "uploads";
    
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
        
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        String roomNumber = request.getParameter("roomNumber");
        String roomType = request.getParameter("roomType");
        String bedType = request.getParameter("bedType");
        double price = Double.parseDouble(request.getParameter("price"));
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        String amenities = request.getParameter("amenities");
        
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            // Verify ownership
            ps = con.prepareStatement(
                "SELECT ph.partner_username FROM partner_rooms pr JOIN partner_hotels ph ON pr.hotel_id = ph.hotel_id WHERE pr.room_id = ?"
            );
            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next() || !rs.getString("partner_username").equals(username)) {
                out.print("ERROR: Unauthorized");
                out.flush();
                return;
            }
            rs.close();
            ps.close();
            
            // Handle image upload
            Part filePart = request.getPart("roomImage");
            String fileName = null;
            String imageUrl = null;
            
            if (filePart != null && filePart.getSize() > 0) {
                fileName = System.currentTimeMillis() + "_" + extractFileName(filePart);
                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdir();
                }
                String filePath = uploadPath + File.separator + fileName;
                filePart.write(filePath);
                imageUrl = UPLOAD_DIR + "/" + fileName;
                
                // Update with new image
                ps = con.prepareStatement(
                    "UPDATE partner_rooms SET room_number=?, room_type=?, bed_type=?, price=?, capacity=?, amenities=?, image_url=? WHERE room_id=?"
                );
                ps.setString(1, roomNumber);
                ps.setString(2, roomType);
                ps.setString(3, bedType);
                ps.setDouble(4, price);
                ps.setInt(5, capacity);
                ps.setString(6, amenities);
                ps.setString(7, imageUrl);
                ps.setInt(8, roomId);
            } else {
                // Update without image
                ps = con.prepareStatement(
                    "UPDATE partner_rooms SET room_number=?, room_type=?, bed_type=?, price=?, capacity=?, amenities=? WHERE room_id=?"
                );
                ps.setString(1, roomNumber);
                ps.setString(2, roomType);
                ps.setString(3, bedType);
                ps.setDouble(4, price);
                ps.setInt(5, capacity);
                ps.setString(6, amenities);
                ps.setInt(7, roomId);
            }
            
            int updated = ps.executeUpdate();
            
            if (updated > 0) {
                out.print("SUCCESS: Room updated successfully");
            } else {
                out.print("ERROR: Failed to update room");
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
    
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                String fileName = s.substring(s.indexOf("=") + 2, s.length() - 1);
                return fileName;
            }
        }
        return null;
    }
}