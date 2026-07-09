<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    // Check if user is an approved partner
    boolean isApprovedPartner = false;
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        ps = con.prepareStatement("SELECT is_hotel_partner FROM userdata WHERE username = ?");
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            isApprovedPartner = "APPROVED".equals(rs.getString("is_hotel_partner"));
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (ps != null) ps.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
    
    if (!isApprovedPartner) {
        response.sendRedirect("Dashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add New Hotel - Partner Dashboard</title>
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    padding: 20px;
}

.navbar {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 20px;
    padding: 15px 30px;
    margin-bottom: 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo h2 {
    font-size: 24px;
    color: #333;
}

.nav-links a {
    color: #333;
    text-decoration: none;
    margin-left: 20px;
    padding: 8px 16px;
    border-radius: 8px;
}

.nav-links a:hover {
    background: #667eea;
    color: white;
}

.container {
    max-width: 800px;
    margin: 0 auto;
}

.form-card {
    background: white;
    border-radius: 20px;
    padding: 30px;
    box-shadow: 0 20px 40px rgba(0,0,0,0.1);
}

h2 {
    color: #333;
    margin-bottom: 10px;
}

.subtitle {
    color: #666;
    margin-bottom: 25px;
}

.form-group {
    margin-bottom: 20px;
}

label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: #333;
}

input, textarea, select {
    width: 100%;
    padding: 12px;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    font-size: 14px;
    font-family: inherit;
}

input:focus, textarea:focus, select:focus {
    outline: none;
    border-color: #667eea;
}

.btn-submit {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    margin-top: 10px;
}

.btn-submit:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.2);
}

.btn-back {
    display: inline-block;
    margin-top: 15px;
    text-align: center;
    width: 100%;
    padding: 12px;
    background: #6c757d;
    color: white;
    text-decoration: none;
    border-radius: 10px;
}
</style>
</head>
<body>

<div class="navbar">
    <div class="logo">
        <h2>🏨 Hotel Management System</h2>
    </div>
    <div class="nav-links">
        <a href="Dashboard.jsp">Dashboard</a>
        <a href="ViewRoom.jsp">View Rooms</a>
        <a href="MyBookings.jsp">My Bookings</a>
        <a href="LogoutServlet">Logout</a>
    </div>
</div>

<div class="container">
    <div class="form-card">
        <h2>🏨 Add New Hotel</h2>
        <p class="subtitle">Add another hotel to your portfolio</p>
        
        <form action="AddPartnerHotel" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label>Hotel Name *</label>
                <input type="text" name="hotelName" required placeholder="Enter hotel name">
            </div>
            
            <div class="form-group">
                <label>Hotel Location *</label>
                <input type="text" name="hotelLocation" required placeholder="Enter full address">
            </div>
            
            <div class="form-group">
                <label>Hotel Phone *</label>
                <input type="tel" name="hotelPhone" required placeholder="Contact number">
            </div>
            
            <div class="form-group">
                <label>Hotel Email</label>
                <input type="email" name="hotelEmail" placeholder="hotel@example.com">
            </div>
            
            <div class="form-group">
                <label>Hotel Description</label>
                <textarea name="hotelDescription" rows="4" placeholder="Describe your hotel..."></textarea>
            </div>
            
            <div class="form-group">
                <label>Hotel Image</label>
                <input type="file" name="hotelImage" accept="image/*">
            </div>
            
            <button type="submit" class="btn-submit">➕ Add Hotel</button>
            <a href="Dashboard.jsp?tab=myhotel" class="btn-back">← Back to Dashboard</a>
        </form>
    </div>
</div>

</body>
</html>