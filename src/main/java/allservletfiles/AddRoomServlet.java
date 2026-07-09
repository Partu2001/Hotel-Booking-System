package allservletfiles;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import java.io.*;
import java.sql.*;

@WebServlet("/AddRoomServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class AddRoomServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String roomNo = request.getParameter("roomNumber");
        String roomType = request.getParameter("roomType");
        String bedType = request.getParameter("bedType");
        String priceStr = request.getParameter("price");
        String capacityStr = request.getParameter("capacity");
        String status = request.getParameter("status");
        
        // Validate room number
        if (roomNo == null || roomNo.trim().isEmpty()) {
            showError(response, "Room Number cannot be empty!", "AddRoom.jsp");
            return;
        }
        
        if (!roomNo.matches("\\d+")) {
            showError(response, "Room Number must contain only numbers!", "AddRoom.jsp");
            return;
        }
        
        String[] amenities = request.getParameterValues("amenities");
        String[] extraCharges = request.getParameterValues("extra_charge");
        
        double price = 0;
        int capacity = 0;
        
        try {
            price = Double.parseDouble(priceStr);
            capacity = Integer.parseInt(capacityStr);
        } catch (NumberFormatException e) {
            showError(response, "Invalid price or capacity value!", "AddRoom.jsp");
            return;
        }

        // Handle image upload
        Part filePart = request.getPart("roomImage");
        String fileName = extractFileName(filePart);
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }
        
        String imageUrl = UPLOAD_DIR + "/" + fileName;
        String filePath = uploadPath + File.separator + fileName;
        filePart.write(filePath);

        StringBuilder amenitiesStr = new StringBuilder();
        if (amenities != null) {
            for (String amenity : amenities) {
                if (amenitiesStr.length() > 0) amenitiesStr.append(", ");
                amenitiesStr.append(amenity);
            }
        }

        Connection con = null;
        PreparedStatement checkStmt = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1522:xe", "system", "system");

            // Check if room already exists
            checkStmt = con.prepareStatement("SELECT roomno FROM room WHERE roomno = ?");
            checkStmt.setString(1, roomNo);
            rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                showError(response, "Room " + roomNo + " already exists! Please use a different room number.", "AddRoom.jsp");
                return;
            }
            
            // Insert new room
            ps = con.prepareStatement(
                "INSERT INTO room(roomno, roomtype, bedtype, price, capacity, amenities, status, image_url, image_filename) VALUES(?,?,?,?,?,?,?,?,?)");

            ps.setString(1, roomNo);
            ps.setString(2, roomType);
            ps.setString(3, bedType);
            ps.setDouble(4, price);
            ps.setInt(5, capacity);
            ps.setString(6, amenitiesStr.toString());
            ps.setString(7, status);
            ps.setString(8, imageUrl);
            ps.setString(9, fileName);

            int i = ps.executeUpdate();

            if (i > 0) {
                // Insert amenities with extra charges
                if (amenities != null && extraCharges != null) {
                    PreparedStatement psAmenity = con.prepareStatement(
                        "INSERT INTO room_amenities(amenity_id, roomno, amenity_name, extra_charge) VALUES(amenity_seq.NEXTVAL, ?, ?, ?)");
                    
                    for (int j = 0; j < amenities.length && j < extraCharges.length; j++) {
                        if (extraCharges[j] != null && !extraCharges[j].isEmpty()) {
                            try {
                                double extraCharge = Double.parseDouble(extraCharges[j]);
                                if (extraCharge > 0) {
                                    psAmenity.setString(1, roomNo);
                                    psAmenity.setString(2, amenities[j]);
                                    psAmenity.setDouble(3, extraCharge);
                                    psAmenity.executeUpdate();
                                }
                            } catch (NumberFormatException e) {
                                // Skip invalid values
                            }
                        }
                    }
                    psAmenity.close();
                }
                
                // Success - redirect with message
                response.sendRedirect("Admin.jsp?success=Room " + roomNo + " added successfully!");
            } else {
                showError(response, "Failed to add room. Please try again.", "AddRoom.jsp");
            }

        } catch (SQLIntegrityConstraintViolationException e) {
            showError(response, "Room " + roomNo + " already exists! Please use a different room number.", "AddRoom.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            showError(response, "Database Error: " + e.getMessage(), "AddRoom.jsp");
            
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (checkStmt != null) checkStmt.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
    
    private void showError(HttpServletResponse response, String message, String backPage) 
            throws IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Error</title>");
        out.println("<style>");
        out.println("body { font-family: Arial; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); height: 100vh; display: flex; justify-content: center; align-items: center; margin: 0; }");
        out.println(".error-container { background: white; padding: 40px; border-radius: 15px; text-align: center; max-width: 500px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); }");
        out.println("h2 { color: #dc3545; margin-bottom: 20px; }");
        out.println("p { color: #333; margin-bottom: 20px; font-size: 16px; }");
        out.println(".btn { display: inline-block; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 5px; }");
        out.println(".btn:hover { background: #5a67d8; }");
        out.println("</style></head><body>");
        out.println("<div class='error-container'>");
        out.println("<h2>❌ Error</h2>");
        out.println("<p>" + message + "</p>");
        out.println("<a href='" + backPage + "' class='btn'>← Go Back</a>");
        out.println("<a href='Admin.jsp' class='btn'>Go to Dashboard</a>");
        out.println("</div></body></html>");
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
        return "default.jpg";
    }
}