package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AddPartnerRoom")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class AddPartnerRoom extends HttpServlet {
    
    private static final String UPLOAD_DIR = "uploads";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String hotelIdStr = request.getParameter("hotelId");
        String roomNumber = request.getParameter("roomNumber");
        String roomType = request.getParameter("roomType");
        String bedType = request.getParameter("bedType");
        String priceStr = request.getParameter("price");
        String capacityStr = request.getParameter("capacity");
        String amenities = request.getParameter("amenities");
        
        // Extra amenities with prices
        String[] extraAmenities = request.getParameterValues("extraAmenities");
        String[] extraPrices = request.getParameterValues("extraPrice");
        
        if (hotelIdStr == null || roomNumber == null || roomType == null || bedType == null) {
            response.getWriter().println("Error: Missing required fields");
            return;
        }
        
        int hotelId = Integer.parseInt(hotelIdStr);
        double price = Double.parseDouble(priceStr);
        int capacity = Integer.parseInt(capacityStr);
        
        String fileName = null;
        String imageUrl = null;
        
        Part filePart = request.getPart("roomImage");
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
        }
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            con.setAutoCommit(false);
            
            // Insert room
            ps = con.prepareStatement(
                "INSERT INTO partner_rooms (room_id, hotel_id, room_number, room_type, bed_type, price, capacity, amenities, image_url, status, created_date) VALUES (partner_room_seq.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, 'Available', SYSDATE)",
                new String[]{"room_id"}
            );
            
            ps.setInt(1, hotelId);
            ps.setString(2, roomNumber);
            ps.setString(3, roomType);
            ps.setString(4, bedType);
            ps.setDouble(5, price);
            ps.setInt(6, capacity);
            ps.setString(7, amenities);
            ps.setString(8, imageUrl);
            
            ps.executeUpdate();
            
            // Get the generated room_id
            rs = ps.getGeneratedKeys();
            int roomId = 0;
            if (rs.next()) {
                roomId = rs.getInt(1);
            }
            rs.close();
            ps.close();
            
            // Insert extra amenities for this room
            if (extraAmenities != null && extraPrices != null) {
                ps = con.prepareStatement(
                    "INSERT INTO partner_room_amenities (amenity_id, room_id, amenity_name, extra_charge) VALUES (partner_amenity_seq.NEXTVAL, ?, ?, ?)"
                );
                
                for (int i = 0; i < extraAmenities.length && i < extraPrices.length; i++) {
                    if (extraAmenities[i] != null && !extraAmenities[i].trim().isEmpty() && 
                        extraPrices[i] != null && !extraPrices[i].trim().isEmpty()) {
                        try {
                            double extraPrice = Double.parseDouble(extraPrices[i]);
                            if (extraPrice > 0) {
                                ps.setInt(1, roomId);
                                ps.setString(2, extraAmenities[i]);
                                ps.setDouble(3, extraPrice);
                                ps.executeUpdate();
                            }
                        } catch (NumberFormatException e) {
                            // Skip invalid price
                        }
                    }
                }
                ps.close();
            }
            
            con.commit();
            response.sendRedirect("Dashboard.jsp?tab=myhotel&success=Room added successfully!");
            
        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {}
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
    
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return null;
    }
}