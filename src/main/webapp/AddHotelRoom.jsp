<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    // Check if user is a hotel partner
    boolean isHotelPartner = false;
    String hotelName = "";
    int hotelId = 0;
    
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
            String status = rs.getString("is_hotel_partner");
            isHotelPartner = "APPROVED".equals(status);
        }
        rs.close();
        ps.close();
        
        if (isHotelPartner) {
            ps = con.prepareStatement("SELECT hotel_id, hotel_name FROM partner_hotels WHERE partner_username = ? AND status = 'Approved'");
            ps.setString(1, username);
            rs = ps.executeQuery();
            if (rs.next()) {
                hotelId = rs.getInt("hotel_id");
                hotelName = rs.getString("hotel_name");
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (ps != null) ps.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
    
    if (!isHotelPartner) {
        response.sendRedirect("Dashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add Hotel Room - <%= hotelName %></title>
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

.hotel-info {
    background: #e8f0fe;
    padding: 15px;
    border-radius: 10px;
    margin-bottom: 20px;
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

input, select, textarea {
    width: 100%;
    padding: 12px;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    font-size: 14px;
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
}

.back-btn {
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
        <a href="Dashboard.jsp" style="color: #333; text-decoration: none; margin-left: 20px;">Dashboard</a>
        <a href="LogoutServlet" style="color: #333; text-decoration: none; margin-left: 20px;">Logout</a>
    </div>
</div>

<div class="container">
    <div class="form-card">
        <h2>🏨 Add Room to <%= hotelName %></h2>
        <div class="hotel-info">
            <strong>Hotel:</strong> <%= hotelName %><br>
            <strong>Partner:</strong> <%= username %>
        </div>
        
        <form action="AddPartnerRoom" method="post" enctype="multipart/form-data">
            <input type="hidden" name="hotelId" value="<%= hotelId %>">
            
            <div class="form-group">
                <label>Room Number</label>
                <input type="text" name="roomNumber" required placeholder="e.g., 101, 201">
            </div>
            
            <div class="form-group">
                <label>Room Type</label>
                <select name="roomType" required>
                    <option value="Single">Single</option>
                    <option value="Double">Double</option>
                    <option value="Deluxe">Deluxe</option>
                    <option value="Suite">Suite</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Bed Type</label>
                <select name="bedType" required>
                    <option value="Single Bed">Single Bed</option>
                    <option value="Double Bed">Double Bed</option>
                    <option value="Queen Size">Queen Size</option>
                    <option value="King Size">King Size</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Price per Night (₹)</label>
                <input type="number" name="price" step="0.01" required>
            </div>
            
            <div class="form-group">
                <label>Capacity (Persons)</label>
                <input type="number" name="capacity" required>
            </div>
            
            <div class="form-group">
                <label>Amenities (comma separated)</label>
                <input type="text" name="amenities" placeholder="AC, WiFi, TV, Breakfast">
            </div>
            
            <div class="form-group">
                <label>Room Image</label>
                <input type="file" name="roomImage" accept="image/*">
            </div>
            
            <button type="submit" class="btn-submit">➕ Add Room</button>
            <a href="Dashboard.jsp" class="back-btn">← Back to Dashboard</a>
        </form>
    </div>
</div>

</body>
</html>