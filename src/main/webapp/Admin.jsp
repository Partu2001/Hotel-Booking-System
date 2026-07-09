<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
    
<%
    HttpSession adminSession = request.getSession(false);
    if (adminSession == null || adminSession.getAttribute("admin") == null) {
        response.sendRedirect("AdminLogin.jsp");
        return;
    }
    String adminName = (String) adminSession.getAttribute("admin");
    
    // Fetch statistics from database
    int totalRooms = 0;
    int availableRooms = 0;
    int bookedRooms = 0;
    int totalBookings = 0;
    int totalUsers = 0;
    int pendingPartners = 0;
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        
        ps = con.prepareStatement("SELECT COUNT(*) FROM room");
        rs = ps.executeQuery();
        if (rs.next()) totalRooms = rs.getInt(1);
        rs.close();
        ps.close();
        
        ps = con.prepareStatement("SELECT COUNT(*) FROM room WHERE status = 'Available'");
        rs = ps.executeQuery();
        if (rs.next()) availableRooms = rs.getInt(1);
        rs.close();
        ps.close();
        
        ps = con.prepareStatement("SELECT COUNT(*) FROM room WHERE status = 'Booked'");
        rs = ps.executeQuery();
        if (rs.next()) bookedRooms = rs.getInt(1);
        rs.close();
        ps.close();
        
        ps = con.prepareStatement("SELECT COUNT(*) FROM bookings");
        rs = ps.executeQuery();
        if (rs.next()) totalBookings = rs.getInt(1);
        rs.close();
        ps.close();
        
        ps = con.prepareStatement("SELECT COUNT(*) FROM userdata");
        rs = ps.executeQuery();
        if (rs.next()) totalUsers = rs.getInt(1);
        rs.close();
        ps.close();
        
        ps = con.prepareStatement("SELECT COUNT(*) FROM partner_hotels WHERE status = 'Pending'");
        rs = ps.executeQuery();
        if (rs.next()) pendingPartners = rs.getInt(1);
        
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
<title>Admin Dashboard - Hotel Management System</title>
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
}

/* Navbar */
.navbar {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 15px 30px;
    margin: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.logo h2 {
    font-size: 24px;
    color: #1e3c72;
}

.admin-info {
    display: flex;
    align-items: center;
    gap: 20px;
}

.admin-badge {
    display: flex;
    align-items: center;
    gap: 10px;
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    padding: 8px 20px;
    border-radius: 50px;
    color: white;
}

.logout-btn {
    background: #dc3545;
    color: white;
    text-decoration: none;
    padding: 8px 20px;
    border-radius: 10px;
    transition: all 0.3s;
}

.logout-btn:hover {
    background: #c82333;
    transform: translateY(-2px);
}

/* Container */
.container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 20px;
}

/* Welcome Section */
.welcome-section {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 30px;
    margin-bottom: 30px;
    text-align: center;
}

.welcome-section h1 {
    font-size: 32px;
    color: #1e3c72;
    margin-bottom: 10px;
}

.welcome-section p {
    color: #666;
    font-size: 16px;
}

/* Stats Grid */
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat-card {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 15px;
    padding: 20px;
    text-align: center;
    transition: transform 0.3s;
}

.stat-card:hover {
    transform: translateY(-5px);
}

.stat-card .number {
    font-size: 28px;
    font-weight: bold;
    color: #1e3c72;
}

.stat-card .label {
    color: #666;
    font-size: 12px;
    margin-top: 5px;
}

/* Action Cards */
.section-title {
    font-size: 22px;
    color: white;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.action-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.action-card {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 15px;
    padding: 25px;
    text-align: center;
    text-decoration: none;
    transition: all 0.3s;
    display: block;
}

.action-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.2);
}

.action-icon {
    font-size: 45px;
    margin-bottom: 10px;
}

.action-card h3 {
    font-size: 18px;
    color: #1e3c72;
    margin-bottom: 5px;
}

.action-card p {
    color: #666;
    font-size: 12px;
}

.partner-badge {
    position: absolute;
    top: 10px;
    right: 10px;
    background: #ffc107;
    color: #333;
    padding: 3px 8px;
    border-radius: 15px;
    font-size: 10px;
}

@media (max-width: 768px) {
    .navbar {
        flex-direction: column;
        gap: 15px;
        text-align: center;
    }
    
    .stats-grid, .action-grid {
        grid-template-columns: 1fr;
    }
    
    .welcome-section h1 {
        font-size: 24px;
    }
}
</style>
</head>
<body>

<div class="navbar">
    <div class="logo">
        <h2>🏨 Hotel Management System</h2>
        <p>Administrator Control Panel</p>
    </div>
    <div class="admin-info">
        <div class="admin-badge">
            <span>👑</span>
            <span><%= adminName %></span>
        </div>
        <a href="AdminLogout" class="logout-btn">🚪 Logout</a>
    </div>
</div>

<div class="container">
    <div class="welcome-section">
        <h1>Welcome back, <%= adminName %>! 👋</h1>
        <p>You have full control over the hotel management system.</p>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="number"><%= totalRooms %></div>
            <div class="label">Total Rooms</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= availableRooms %></div>
            <div class="label">Available Rooms</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= bookedRooms %></div>
            <div class="label">Booked Rooms</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= totalBookings %></div>
            <div class="label">Total Bookings</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= totalUsers %></div>
            <div class="label">Registered Users</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= pendingPartners %></div>
            <div class="label">Pending Partners</div>
        </div>
    </div>

    <div class="section-title">
        <span>⚡</span> Quick Actions
    </div>
    <div class="action-grid">
        <a href="AddRoom.jsp" class="action-card">
            <div class="action-icon">➕</div>
            <h3>Add New Room</h3>
            <p>Add rooms to the hotel inventory</p>
        </a>
        
        <a href="ViewRoom.jsp" class="action-card">
            <div class="action-icon">👁️</div>
            <h3>View All Rooms</h3>
            <p>View, edit, and manage all hotel rooms</p>
        </a>
        
        <a href="ViewBookings.jsp" class="action-card">
            <div class="action-icon">📋</div>
            <h3>View Bookings</h3>
            <p>Monitor and manage customer bookings</p>
        </a>
        
        <a href="ManageUsers.jsp" class="action-card">
            <div class="action-icon">👥</div>
            <h3>Manage Users</h3>
            <p>View and manage registered customers</p>
        </a>
        
        <a href="AdminManagePartners.jsp" class="action-card" style="position: relative;">
            <div class="action-icon">🏨</div>
            <h3>Hotel Partners</h3>
            <p>Approve or reject hotel partner requests</p>
            <% if (pendingPartners > 0) { %>
                <span class="partner-badge"><%= pendingPartners %> New</span>
            <% } %>
        </a>
    </div>
</div>

</body>
</html>