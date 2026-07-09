package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String mobile = request.getParameter("mobile");
        String uname = request.getParameter("username");
        String upass = request.getParameter("password");
        String paymentPass = request.getParameter("paymentPassword");
        String isHotelPartner = request.getParameter("isHotelPartner");
        
        String hotelName = request.getParameter("hotelName");
        String hotelLocation = request.getParameter("hotelLocation");
        String hotelPhone = request.getParameter("hotelPhone");
        String hotelDescription = request.getParameter("hotelDescription");

        String url = "jdbc:oracle:thin:@localhost:1522:xe";
        String dbUser = "system";
        String dbPass = "system";

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection(url, dbUser, dbPass);

            // CHECK USER EXISTS
            PreparedStatement check = con.prepareStatement(
                    "SELECT * FROM userdata WHERE username=? OR email=? OR mobile=?");
            check.setString(1, uname);
            check.setString(2, email);
            check.setString(3, mobile);
            ResultSet rs = check.executeQuery();

            if (rs.next()) {
                response.sendRedirect("UserExists.jsp");
            } else {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO userdata (name, email, mobile, username, password, payment_password, is_hotel_partner, hotel_name, hotel_location, hotel_phone, hotel_description, registration_date) VALUES(?,?,?,?,?,?,?,?,?,?,?,SYSDATE)");

                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, mobile);
                ps.setString(4, uname);
                ps.setString(5, upass);
                ps.setString(6, paymentPass);
                
                if (isHotelPartner != null && isHotelPartner.equals("true")) {
                    ps.setString(7, "PENDING");
                    ps.setString(8, hotelName);
                    ps.setString(9, hotelLocation);
                    ps.setString(10, hotelPhone);
                    ps.setString(11, hotelDescription);
                } else {
                    ps.setString(7, "NO");
                    ps.setString(8, null);
                    ps.setString(9, null);
                    ps.setString(10, null);
                    ps.setString(11, null);
                }

                int i = ps.executeUpdate();

                if (i > 0 && isHotelPartner != null && isHotelPartner.equals("true")) {
                    try {
                        PreparedStatement psHotel = con.prepareStatement(
                            "INSERT INTO partner_hotels (hotel_id, partner_username, hotel_name, hotel_location, hotel_description, hotel_phone, hotel_email, status, created_date) VALUES (hotel_seq.NEXTVAL, ?, ?, ?, ?, ?, ?, 'Pending', SYSDATE)");
                        psHotel.setString(1, uname);
                        psHotel.setString(2, hotelName);
                        psHotel.setString(3, hotelLocation);
                        psHotel.setString(4, hotelDescription);
                        psHotel.setString(5, hotelPhone);
                        psHotel.setString(6, email);
                        psHotel.executeUpdate();
                        psHotel.close();
                    } catch (SQLException e) {
                        System.out.println("Note: partner_hotels table may not exist yet");
                    }
                }
                
                ps.close();
                response.sendRedirect("Login.jsp?registered=true");
            }

            rs.close();
            check.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}