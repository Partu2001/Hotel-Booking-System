package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uname = request.getParameter("username");
        String upass = request.getParameter("password");
        String remember = request.getParameter("remember");

        String url = "jdbc:oracle:thin:@localhost:1522:xe";
        String dbUser = "system";
        String dbPass = "system";

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection(url, dbUser, dbPass);

            PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM userdata WHERE username=? AND password=?");

            ps.setString(1, uname);
            ps.setString(2, upass);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("username", uname);
                
                // Set session timeout to 24 hours
                session.setMaxInactiveInterval(60 * 60 * 24);
                
                // If "Remember Me" is checked, create a cookie
                if (remember != null && remember.equals("true")) {
                    Cookie userCookie = new Cookie("remembered_user", uname);
                    userCookie.setMaxAge(60 * 60 * 24); // 1 day
                    userCookie.setPath("/");
                    response.addCookie(userCookie);
                    System.out.println("Remember me cookie set for: " + uname);
                }
                
                response.sendRedirect("Dashboard.jsp");
            } else {
                response.sendRedirect("Login.jsp?error=invalid");
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}