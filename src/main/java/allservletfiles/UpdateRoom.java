package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/UpdateRoom")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class UpdateRoom extends HttpServlet {
    
    private static final String UPLOAD_DIR = "uploads";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String roomNo = request.getParameter("roomno");
        String roomType = request.getParameter("roomType");
        String bedType = request.getParameter("bedType");
        String priceStr = request.getParameter("price");
        String capacityStr = request.getParameter("capacity");
        String amenities = request.getParameter("amenities");
        String status = request.getParameter("status");
        
        System.out.println("Updating room: " + roomNo);
        
        double price = 0;
        int capacity = 0;
        
        try {
            price = Double.parseDouble(priceStr);
            capacity = Integer.parseInt(capacityStr);
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            // Handle image upload if new image is provided
            Part filePart = request.getPart("roomImage");
            String fileName = null;
            String imageUrl = null;
            
            if (filePart != null && filePart.getSize() > 0) {
                fileName = extractFileName(filePart);
                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdir();
                }
                String filePath = uploadPath + File.separator + fileName;
                filePart.write(filePath);
                imageUrl = UPLOAD_DIR + "/" + fileName;
                
                // Update with new image - 8 parameters
                String sql = "UPDATE room SET roomtype=?, bedtype=?, price=?, capacity=?, amenities=?, status=?, image_url=?, image_filename=? WHERE roomno=?";
                ps = con.prepareStatement(sql);
                ps.setString(1, roomType);
                ps.setString(2, bedType);
                ps.setDouble(3, price);
                ps.setInt(4, capacity);
                ps.setString(5, amenities);
                ps.setString(6, status);
                ps.setString(7, imageUrl);
                ps.setString(8, fileName);
                ps.setString(9, roomNo);
                
                System.out.println("Updating with new image");
            } else {
                // Update without changing image - 7 parameters
                String sql = "UPDATE room SET roomtype=?, bedtype=?, price=?, capacity=?, amenities=?, status=? WHERE roomno=?";
                ps = con.prepareStatement(sql);
                ps.setString(1, roomType);
                ps.setString(2, bedType);
                ps.setDouble(3, price);
                ps.setInt(4, capacity);
                ps.setString(5, amenities);
                ps.setString(6, status);
                ps.setString(7, roomNo);
                
                System.out.println("Updating without new image");
            }
            
            int updated = ps.executeUpdate();
            ps.close();
            
            if (updated > 0) {
                System.out.println("Room updated successfully");
                response.sendRedirect("EditRoom.jsp?roomno=" + roomNo + "&success=true");
            } else {
                response.getWriter().println("<h2>Error updating room - No rows affected</h2>");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<h2>Error: " + e.getMessage() + "</h2>");
            response.getWriter().println("<a href='ViewRoom.jsp'>Back to Rooms</a>");
        } finally {
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
    
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                String fileName = s.substring(s.indexOf("=") + 2, s.length() - 1);
                return System.currentTimeMillis() + "_" + fileName;
            }
        }
        return null;
    }
}