<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    HttpSession adminSession = request.getSession(false);
    if (adminSession == null || adminSession.getAttribute("admin") == null) {
        response.sendRedirect("AdminLogin.jsp");
        return;
    }
    
    String roomNo = request.getParameter("roomno");
    if (roomNo == null || roomNo.isEmpty()) {
        response.sendRedirect("ViewRoom.jsp");
        return;
    }
    
    // Fetch room details
    String roomType = "";
    String bedType = "";
    double price = 0;
    int capacity = 0;
    String amenities = "";
    String status = "";
    String imageUrl = "";
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        ps = con.prepareStatement("SELECT * FROM room WHERE roomno = ?");
        ps.setString(1, roomNo);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            roomType = rs.getString("roomtype");
            bedType = rs.getString("bedtype");
            price = rs.getDouble("price");
            capacity = rs.getInt("capacity");
            amenities = rs.getString("amenities");
            status = rs.getString("status");
            imageUrl = rs.getString("image_url");
        } else {
            response.sendRedirect("ViewRoom.jsp");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (ps != null) ps.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Room - Admin Panel</title>
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    min-height: 100vh;
    padding: 20px;
}

.navbar {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 15px 30px;
    margin-bottom: 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo h2 { color: #1e3c72; }
.nav-links a {
    color: #333;
    text-decoration: none;
    margin-left: 20px;
    padding: 8px 16px;
    border-radius: 8px;
}
.nav-links a:hover { background: #1e3c72; color: white; }

.container {
    max-width: 800px;
    margin: 0 auto;
}

.edit-card {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 30px;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

h2 {
    color: #1e3c72;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
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

input, select {
    width: 100%;
    padding: 12px;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    font-size: 16px;
    outline: none;
}

input:focus, select:focus {
    border-color: #1e3c72;
}

.btn-group {
    display: flex;
    gap: 15px;
    margin-top: 20px;
}

.update-btn {
    flex: 1;
    padding: 12px;
    background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
}

.cancel-btn {
    flex: 1;
    padding: 12px;
    background: #6c757d;
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    display: inline-block;
}

.update-btn:hover, .cancel-btn:hover {
    transform: translateY(-2px);
}

.success-message {
    position: fixed;
    top: 20px;
    right: 20px;
    background: #28a745;
    color: white;
    padding: 15px 25px;
    border-radius: 10px;
    animation: slideIn 0.3s ease-out, fadeOut 3s forwards;
    z-index: 1000;
}

@keyframes slideIn {
    from { transform: translateX(100px); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}

@keyframes fadeOut {
    0% { opacity: 1; }
    70% { opacity: 1; }
    100% { opacity: 0; visibility: hidden; }
}
</style>
</head>
<body>

<div class="navbar">
    <div class="logo"><h2>🏨 Hotel Management System</h2></div>
    <div class="nav-links">
        <a href="Admin.jsp">Dashboard</a>
        <a href="ViewRoom.jsp">View Rooms</a>
        <a href="ViewBookings.jsp">View Bookings</a>
        <a href="AdminLogout">Logout</a>
    </div>
</div>

<div class="container">
    <div class="edit-card">
        <h2>✏️ Edit Room <%= roomNo %></h2>
        
        <form action="UpdateRoom" method="post" enctype="multipart/form-data">
            <input type="hidden" name="roomno" value="<%= roomNo %>">
            
            <div class="form-group">
                <label>Room Type</label>
                <select name="roomType" required>
                    <option value="Single" <%= roomType.equals("Single") ? "selected" : "" %>>Single</option>
                    <option value="Double" <%= roomType.equals("Double") ? "selected" : "" %>>Double</option>
                    <option value="Deluxe" <%= roomType.equals("Deluxe") ? "selected" : "" %>>Deluxe</option>
                    <option value="Suite" <%= roomType.equals("Suite") ? "selected" : "" %>>Suite</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Bed Type</label>
                <select name="bedType" required>
                    <option value="Single Bed" <%= bedType.equals("Single Bed") ? "selected" : "" %>>Single Bed</option>
                    <option value="Double Bed" <%= bedType.equals("Double Bed") ? "selected" : "" %>>Double Bed</option>
                    <option value="Queen Size" <%= bedType.equals("Queen Size") ? "selected" : "" %>>Queen Size</option>
                    <option value="King Size" <%= bedType.equals("King Size") ? "selected" : "" %>>King Size</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Price per Night (₹)</label>
                <input type="number" name="price" step="0.01" value="<%= price %>" required>
            </div>
            
            <div class="form-group">
                <label>Capacity (Persons)</label>
                <input type="number" name="capacity" value="<%= capacity %>" required>
            </div>
            
            <div class="form-group">
                <label>Amenities (comma separated)</label>
                <input type="text" name="amenities" value="<%= amenities %>" placeholder="AC, WiFi, TV, Breakfast">
            </div>
            
            <div class="form-group">
                <label>Status</label>
                <select name="status" required>
                    <option value="Available" <%= status.equals("Available") ? "selected" : "" %>>Available</option>
                    <option value="Booked" <%= status.equals("Booked") ? "selected" : "" %>>Booked</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Change Image (optional)</label>
                <input type="file" name="roomImage" accept="image/*">
                <small style="color:#666;">Leave empty to keep current image</small>
            </div>
            
            <div class="btn-group">
                <button type="submit" class="update-btn">💾 Update Room</button>
                <a href="ViewRoom.jsp" class="cancel-btn">↩️ Cancel</a>
            </div>
        </form>
    </div>
</div>

<%
    String success = request.getParameter("success");
    if (success != null && success.equals("true")) {
%>
<div class="success-message">✅ Room updated successfully!</div>
<%
    }
%>

</body>
</html>