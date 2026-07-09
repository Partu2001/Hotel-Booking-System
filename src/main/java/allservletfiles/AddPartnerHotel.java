package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AddPartnerHotel")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class AddPartnerHotel extends HttpServlet {
    
    private static final String UPLOAD_DIR = "uploads";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;
        
        if (username == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        String hotelName = request.getParameter("hotelName");
        String hotelLocation = request.getParameter("hotelLocation");
        String hotelPhone = request.getParameter("hotelPhone");
        String hotelEmail = request.getParameter("hotelEmail");
        String hotelDescription = request.getParameter("hotelDescription");
        
        // Handle image upload
        String fileName = null;
        String imageUrl = null;
        
        Part filePart = request.getPart("hotelImage");
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
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            ps = con.prepareStatement(
                "INSERT INTO partner_hotels (hotel_id, partner_username, hotel_name, hotel_location, hotel_description, hotel_phone, hotel_email, hotel_image, status, created_date) VALUES (hotel_seq.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, 'Pending', SYSDATE)"
            );
            
            ps.setString(1, username);
            ps.setString(2, hotelName);
            ps.setString(3, hotelLocation);
            ps.setString(4, hotelDescription);
            ps.setString(5, hotelPhone);
            ps.setString(6, hotelEmail);
            ps.setString(7, imageUrl);
            
            ps.executeUpdate();
            
            response.sendRedirect("Dashboard.jsp?tab=myhotel&success=Hotel added successfully! Awaiting admin approval.");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
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
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return null;
    }
}