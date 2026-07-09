<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    // Admin session check
    HttpSession adminSession = request.getSession(false);
    if (adminSession == null || adminSession.getAttribute("admin") == null) {
        response.sendRedirect("AdminLogin.jsp");
        return;
    }
    
    String viewUsername = request.getParameter("username");
    if (viewUsername == null || viewUsername.isEmpty()) {
        response.sendRedirect("ManageUsers.jsp");
        return;
    }
    
    String userFullName = "";
    String userEmail = "";
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Bookings - <%= viewUsername %></title>
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

/* Navbar */
.navbar {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 15px 30px;
    margin-bottom: 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.logo h2 {
    font-size: 24px;
    color: #1e3c72;
}

.back-btn {
    background: #6c757d;
    color: white;
    padding: 10px 20px;
    border-radius: 10px;
    text-decoration: none;
    transition: all 0.3s;
}

.back-btn:hover {
    background: #5a6268;
    transform: translateX(-3px);
}

/* Container */
.container {
    max-width: 1200px;
    margin: 0 auto;
}

/* Page Title */
.page-title {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 25px;
    margin-bottom: 30px;
}

.page-title h1 {
    font-size: 28px;
    color: #1e3c72;
    margin-bottom: 10px;
}

.page-title p {
    color: #666;
    font-size: 14px;
}

/* Stats Cards */
.stats-cards {
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
}

.stat-card .number {
    font-size: 32px;
    font-weight: bold;
    color: #1e3c72;
}

.stat-card .label {
    color: #666;
    font-size: 14px;
    margin-top: 5px;
}

/* Bookings Table */
.bookings-table-wrapper {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 20px;
    overflow-x: auto;
}

.bookings-table {
    width: 100%;
    border-collapse: collapse;
}

.bookings-table th,
.bookings-table td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #e0e0e0;
}

.bookings-table th {
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: white;
    font-weight: 600;
}

.bookings-table tr:hover {
    background: #f8f9fa;
}

.status-confirmed {
    display: inline-block;
    padding: 5px 12px;
    background: #d4edda;
    color: #155724;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.status-cancelled {
    display: inline-block;
    padding: 5px 12px;
    background: #f8d7da;
    color: #721c24;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.no-data {
    text-align: center;
    padding: 50px;
    color: #666;
}

.no-data .icon {
    font-size: 60px;
    margin-bottom: 15px;
}

.amount {
    color: #28a745;
    font-weight: bold;
}

@media (max-width: 768px) {
    .navbar {
        flex-direction: column;
        gap: 15px;
        text-align: center;
    }
    
    .bookings-table th,
    .bookings-table td {
        padding: 10px;
        font-size: 12px;
    }
    
    .stats-cards {
        grid-template-columns: 1fr;
    }
}
</style>
</head>
<body>

<div class="container">
    <!-- Navbar -->
    <div class="navbar">
        <div class="logo">
            <h2>🏨 Hotel Management System</h2>
        </div>
        <a href="ManageUsers.jsp" class="back-btn">← Back to Users</a>
    </div>

    <%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    int totalBookings = 0;
    double totalSpent = 0;
    int activeBookings = 0;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        
        // Get user details
        ps = con.prepareStatement("SELECT name, email FROM userdata WHERE username = ?");
        ps.setString(1, viewUsername);
        rs = ps.executeQuery();
        if (rs.next()) {
            userFullName = rs.getString("name");
            userEmail = rs.getString("email");
        }
        rs.close();
        ps.close();
        
        // Get booking statistics
        ps = con.prepareStatement("SELECT COUNT(*) as total, NVL(SUM(total_amount), 0) as total_spent FROM bookings WHERE username = ? AND status = 'Confirmed'");
        ps.setString(1, viewUsername);
        rs = ps.executeQuery();
        if (rs.next()) {
            totalBookings = rs.getInt("total");
            totalSpent = rs.getDouble("total_spent");
        }
        rs.close();
        ps.close();
        
        // Get active bookings count
        ps = con.prepareStatement("SELECT COUNT(*) as active FROM bookings WHERE username = ? AND status = 'Confirmed' AND check_out >= TRUNC(SYSDATE)");
        ps.setString(1, viewUsername);
        rs = ps.executeQuery();
        if (rs.next()) {
            activeBookings = rs.getInt("active");
        }
        rs.close();
        ps.close();
        
    } catch (Exception e) {
        e.printStackTrace();
    }
    %>

    <!-- Page Title -->
    <div class="page-title">
        <h1>📋 Bookings for: <%= viewUsername %></h1>
        <p><strong><%= userFullName %></strong> | 📧 <%= userEmail %></p>
    </div>

    <!-- Stats Cards -->
    <div class="stats-cards">
        <div class="stat-card">
            <div class="number"><%= totalBookings %></div>
            <div class="label">Total Bookings</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= activeBookings %></div>
            <div class="label">Active Bookings</div>
        </div>
        <div class="stat-card">
            <div class="number">₹<%= String.format("%,.2f", totalSpent) %></div>
            <div class="label">Total Spent</div>
        </div>
    </div>

    <!-- Bookings Table -->
    <div class="bookings-table-wrapper">
        <table class="bookings-table">
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Room No</th>
                    <th>Room Type</th>
                    <th>Check In</th>
                    <th>Check Out</th>
                    <th>Nights</th>
                    <th>Amount</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                try {
                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
                    
                    ps = con.prepareStatement(
                        "SELECT b.*, r.roomtype, r.bedtype " +
                        "FROM bookings b " +
                        "JOIN room r ON b.roomno = r.roomno " +
                        "WHERE b.username = ? " +
                        "ORDER BY b.booking_id DESC"
                    );
                    ps.setString(1, viewUsername);
                    rs = ps.executeQuery();
                    
                    boolean hasData = false;
                    while (rs.next()) {
                        hasData = true;
                        int bookingId = rs.getInt("booking_id");
                        String roomNo = rs.getString("roomno");
                        String roomType = rs.getString("roomtype");
                        String checkIn = rs.getString("check_in");
                        String checkOut = rs.getString("check_out");
                        double amount = rs.getDouble("total_amount");
                        String status = rs.getString("status");
                        
                        // Calculate nights
                        int nights = 1;
                        try {
                            java.sql.Date checkInDate = rs.getDate("check_in");
                            java.sql.Date checkOutDate = rs.getDate("check_out");
                            if (checkInDate != null && checkOutDate != null) {
                                nights = (int)((checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24));
                                if (nights == 0) nights = 1;
                            }
                        } catch (Exception e) {
                            nights = 1;
                        }
                %>
                <tr>
                    <td>#<%= bookingId %></td>
                    <td><%= roomNo %></td>
                    <td><%= roomType %></td>
                    <td><%= checkIn %></td>
                    <td><%= checkOut %></td>
                    <td style="text-align: center;"><%= nights %></td>
                    <td class="amount">₹<%= String.format("%,.2f", amount) %></td>
                    <td>
                        <span class="<%= status.equals("Confirmed") ? "status-confirmed" : "status-cancelled" %>">
                            <%= status %>
                        </span>
                    </td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr>
                    <td colspan="8" class="no-data">
                        <div class="icon">📭</div>
                        <h3>No Bookings Found</h3>
                        <p>This user has not made any bookings yet.</p>
                    </td>
                </tr>
                <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                %>
                <tr>
                    <td colspan="8" class="no-data">
                        <div class="icon">⚠️</div>
                        <h3>Error Loading Bookings</h3>
                        <p><%= e.getMessage() %></p>
                    </td>
                </tr>
                <%
                } finally {
                    try { if (rs != null) rs.close(); } catch(Exception e) {}
                    try { if (ps != null) ps.close(); } catch(Exception e) {}
                    try { if (con != null) con.close(); } catch(Exception e) {}
                }
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>