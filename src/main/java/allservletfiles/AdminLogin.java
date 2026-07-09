package allservletfiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/AdminLogin")
public class AdminLogin extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // Admin credentials
        if ("Admin123".equals(username) && "Admin@123".equals(password)) {
            HttpSession session = request.getSession();
            session.setAttribute("admin", username);
            session.setAttribute("isAdmin", true);
            session.setMaxInactiveInterval(60 * 60 * 8); // 8 hours session
            response.sendRedirect("Admin.jsp");
        } else {
            response.sendRedirect("AdminLogin.jsp?error=invalid");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("AdminLogin.jsp");
    }
}