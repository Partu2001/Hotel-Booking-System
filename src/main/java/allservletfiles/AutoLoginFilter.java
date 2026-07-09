package allservletfiles;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebFilter(urlPatterns = {"/*"})
public class AutoLoginFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AutoLoginFilter Initialized");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        
        String path = req.getRequestURI();
        
        // Skip login, register, and static resources - ALLOW these pages to load normally
        if (path.contains("Login.jsp") || path.contains("Register.jsp") || 
            path.contains("LoginServlet") || path.contains("RegisterServlet") ||
            path.contains(".css") || path.contains(".js") || path.contains(".jpg") ||
            path.contains(".png") || path.contains(".jpeg") || path.contains(".ico") ||
            path.contains("AdminLogin") || path.contains("Admin.jsp") ||
            path.contains("index.jsp") || path.contains("LoginError.jsp") ||
            path.contains("AdminLogout") || path.contains("LogoutServlet")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Check if user is already logged in
        if (session != null && session.getAttribute("username") != null) {
            chain.doFilter(request, response);
            return;
        }
        
        // Try to auto-login using cookies
        Cookie[] cookies = req.getCookies();
        String rememberedUser = null;
        
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("remembered_user")) {
                    rememberedUser = cookie.getValue();
                    break;
                }
            }
        }
        
        // If remember me cookie exists, try to auto-login
        if (rememberedUser != null && !rememberedUser.isEmpty()) {
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            
            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
                
                ps = con.prepareStatement("SELECT username FROM userdata WHERE username = ?");
                ps.setString(1, rememberedUser);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    // Auto-login successful - create new session
                    session = req.getSession();
                    session.setAttribute("username", rememberedUser);
                    session.setMaxInactiveInterval(60 * 60 * 24); // 24 hours
                    System.out.println("Auto-login successful for: " + rememberedUser);
                    
                    // Continue to requested page
                    chain.doFilter(request, response);
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try { if (rs != null) rs.close(); } catch(Exception e) {}
                try { if (ps != null) ps.close(); } catch(Exception e) {}
                try { if (con != null) con.close(); } catch(Exception e) {}
            }
        }
        
        // If no valid session or cookie, redirect to login page
        // But don't redirect for AJAX requests or static resources
        String requestURI = req.getRequestURI();
        if (!requestURI.endsWith(".css") && !requestURI.endsWith(".js") && 
            !requestURI.endsWith(".jpg") && !requestURI.endsWith(".png") &&
            !requestURI.endsWith(".jpeg") && !requestURI.endsWith(".ico")) {
            
            // Check if it's a page that requires login (not login page itself)
            if (!requestURI.contains("Login.jsp") && !requestURI.contains("Register.jsp") &&
                !requestURI.contains("AdminLogin.jsp") && !requestURI.contains("index.jsp")) {
                res.sendRedirect(req.getContextPath() + "/Login.jsp");
                return;
            }
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        System.out.println("AutoLoginFilter Destroyed");
    }
}