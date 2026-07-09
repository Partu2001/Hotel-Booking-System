package allservletfiles;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/AdminLogout")
public class AdminLogout extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            session.removeAttribute("admin");
            session.removeAttribute("isAdmin");
            session.invalidate();
        }
        
        response.sendRedirect("AdminLogin.jsp");
    }
}