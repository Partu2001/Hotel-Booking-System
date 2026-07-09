<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    // Get user name for navbar
    String userFullName = "";
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        ps = con.prepareStatement("SELECT name FROM userdata WHERE username = ?");
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            userFullName = rs.getString("name");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (ps != null) ps.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
    
    String firstName = userFullName;
    if (firstName != null && firstName.contains(" ")) {
        firstName = firstName.substring(0, firstName.indexOf(" "));
    }
    if (firstName == null || firstName.isEmpty()) {
        firstName = username;
    }
    
    // Lists to store bookings
    List<Map<String, Object>> mainBookings = new ArrayList<>();
    List<Map<String, Object>> partnerBookings = new ArrayList<>();
    
    int totalMainBookings = 0;
    int totalPartnerBookings = 0;
    double totalMainSpent = 0;
    double totalPartnerSpent = 0;
    int activeMainBookings = 0;
    int activePartnerBookings = 0;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        
        // ========== MAIN HOTEL BOOKINGS ==========
        ps = con.prepareStatement(
            "SELECT b.*, r.roomtype, r.bedtype, p.payment_method, p.status as payment_status " +
            "FROM bookings b " +
            "JOIN room r ON b.roomno = r.roomno " +
            "LEFT JOIN payments p ON b.booking_id = p.booking_id " +
            "WHERE b.username = ? " +
            "ORDER BY b.booking_id DESC"
        );
        ps.setString(1, username);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> booking = new HashMap<>();
            booking.put("booking_id", rs.getInt("booking_id"));
            booking.put("room_no", rs.getString("roomno"));
            booking.put("room_type", rs.getString("roomtype"));
            booking.put("bed_type", rs.getString("bedtype"));
            booking.put("check_in", rs.getString("check_in"));
            booking.put("check_out", rs.getString("check_out"));
            booking.put("total_amount", rs.getDouble("total_amount"));
            booking.put("status", rs.getString("status"));
            booking.put("payment_method", rs.getString("payment_method"));
            booking.put("booking_type", "main");
            mainBookings.add(booking);
            totalMainBookings++;
            totalMainSpent += rs.getDouble("total_amount");
            if (rs.getString("status").equals("Confirmed")) {
                activeMainBookings++;
            }
        }
        rs.close();
        ps.close();
        
        // ========== PARTNER HOTEL BOOKINGS ==========
        ps = con.prepareStatement(
            "SELECT pb.*, ph.hotel_name, pp.payment_method, pp.status as payment_status " +
            "FROM partner_bookings pb " +
            "LEFT JOIN partner_payments pp ON pb.booking_id = pp.booking_id " +
            "LEFT JOIN partner_rooms pr ON pb.room_id = pr.room_id " +
            "LEFT JOIN partner_hotels ph ON pr.hotel_id = ph.hotel_id " +
            "WHERE pb.username = ? " +
            "ORDER BY pb.booking_id DESC"
        );
        ps.setString(1, username);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> booking = new HashMap<>();
            booking.put("booking_id", rs.getInt("booking_id"));
            booking.put("room_no", rs.getString("room_number"));
            booking.put("hotel_name", rs.getString("hotel_name"));
            booking.put("check_in", rs.getString("check_in"));
            booking.put("check_out", rs.getString("check_out"));
            booking.put("total_amount", rs.getDouble("total_amount"));
            booking.put("status", rs.getString("status"));
            booking.put("payment_method", rs.getString("payment_method"));
            booking.put("booking_type", "partner");
            partnerBookings.add(booking);
            totalPartnerBookings++;
            totalPartnerSpent += rs.getDouble("total_amount");
            if (rs.getString("status").equals("Confirmed")) {
                activePartnerBookings++;
            }
        }
        rs.close();
        ps.close();
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (ps != null) ps.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
    
    int totalBookings = totalMainBookings + totalPartnerBookings;
    int activeBookings = activeMainBookings + activePartnerBookings;
    double totalSpent = totalMainSpent + totalPartnerSpent;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Bookings - Hotel Management</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Poppins', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: #f0f2f5;
}

.navbar {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    color: white;
    padding: 0 40px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    position: sticky;
    top: 0;
    z-index: 1000;
    height: 70px;
}

.logo {
    display: flex;
    align-items: center;
    gap: 12px;
}

.logo-icon {
    font-size: 32px;
}

.logo h2 {
    font-size: 22px;
    font-weight: 600;
    letter-spacing: 0.5px;
}

.logo p {
    font-size: 10px;
    opacity: 0.7;
    letter-spacing: 1px;
}

.nav-links {
    display: flex;
    gap: 8px;
    align-items: center;
}

.nav-links a {
    color: white;
    text-decoration: none;
    padding: 8px 20px;
    border-radius: 10px;
    transition: all 0.3s;
    font-weight: 500;
    font-size: 14px;
}

.nav-links a:hover {
    background: rgba(255,255,255,0.1);
    transform: translateY(-2px);
}

.nav-links a.active {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.user-info {
    display: flex;
    align-items: center;
    gap: 20px;
    padding-left: 20px;
    border-left: 1px solid rgba(255,255,255,0.2);
}

.user-avatar {
    width: 40px;
    height: 40px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    font-size: 18px;
}

.user-name {
    font-weight: 500;
    font-size: 14px;
}

.logout-btn {
    background: rgba(220, 53, 69, 0.9);
    padding: 8px 18px;
    border-radius: 8px;
    transition: all 0.3s;
}

.logout-btn:hover {
    background: #dc3545;
    transform: translateY(-2px);
}

.container {
    max-width: 1200px;
    margin: 30px auto;
    padding: 0 20px;
}

.page-title {
    margin-bottom: 30px;
}

.page-title h1 {
    font-size: 32px;
    color: #333;
    margin-bottom: 10px;
}

.page-title p {
    color: #666;
    font-size: 14px;
}

.stats-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat-card {
    background: white;
    border-radius: 15px;
    padding: 20px;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    transition: transform 0.3s;
}

.stat-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.stat-number {
    font-size: 32px;
    font-weight: bold;
    color: #667eea;
}

.stat-label {
    color: #666;
    font-size: 14px;
    margin-top: 5px;
}

.section-title {
    font-size: 20px;
    font-weight: 600;
    margin: 25px 0 15px;
    padding-bottom: 10px;
    border-bottom: 2px solid #e0e0e0;
    color: #333;
}

.bookings-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.booking-card {
    background: white;
    border-radius: 15px;
    overflow: hidden;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    transition: transform 0.3s;
}

.booking-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.booking-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 15px 25px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.booking-id {
    font-size: 18px;
    font-weight: 600;
}

.status-badge {
    padding: 5px 15px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.status-confirmed {
    background: #d4edda;
    color: #155724;
}

.status-cancelled {
    background: #f8d7da;
    color: #721c24;
}

.partner-badge {
    background: #ff9800;
    color: white;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 600;
    margin-left: 10px;
}

.booking-body {
    padding: 20px 25px;
}

.booking-details {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    margin-bottom: 20px;
}

.detail-item {
    display: flex;
    flex-direction: column;
}

.detail-label {
    font-size: 12px;
    color: #999;
    margin-bottom: 5px;
}

.detail-value {
    font-size: 16px;
    font-weight: 600;
    color: #333;
}

.booking-footer {
    border-top: 1px solid #f0f0f0;
    padding-top: 15px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;
}

.total-amount {
    font-size: 20px;
    font-weight: bold;
    color: #28a745;
}

.cancelled-badge {
    background: #dc3545;
    color: white;
    padding: 5px 12px;
    border-radius: 5px;
    font-size: 12px;
}

.no-bookings {
    text-align: center;
    padding: 60px;
    background: white;
    border-radius: 15px;
}

.no-bookings .icon {
    font-size: 60px;
    margin-bottom: 15px;
}

.no-bookings h3 {
    color: #333;
    margin-bottom: 10px;
}

.no-bookings p {
    color: #666;
    margin-bottom: 20px;
}

.browse-btn {
    display: inline-block;
    padding: 12px 30px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    text-decoration: none;
    border-radius: 10px;
    font-weight: 600;
    transition: all 0.3s;
}

.browse-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(0,0,0,0.2);
}

@media (max-width: 768px) {
    .navbar {
        flex-direction: column;
        height: auto;
        padding: 15px 20px;
        gap: 15px;
    }
    
    .nav-links {
        flex-wrap: wrap;
        justify-content: center;
    }
    
    .user-info {
        border-left: none;
        padding-left: 0;
    }
    
    .booking-header {
        flex-direction: column;
        gap: 10px;
        text-align: center;
    }
    
    .booking-details {
        grid-template-columns: 1fr;
    }
    
    .booking-footer {
        flex-direction: column;
        text-align: center;
    }
    
    .page-title h1 {
        font-size: 24px;
    }
    
    .stats-cards {
        grid-template-columns: 1fr;
    }
}
</style>
</head>
<body>

<!-- Navbar -->
<div class="navbar">
    <div class="logo">
        <div class="logo-icon">🏨</div>
        <div>
            <h2>Hotel Management</h2>
            <p>LUXURY REDEFINED</p>
        </div>
    </div>
    <div class="nav-links">
        <a href="Dashboard.jsp">🏠 Dashboard</a>
        <a href="ViewRoom.jsp">🛏️ View Rooms</a>
        <a href="MyBookings.jsp" class="active">📋 My Bookings</a>
    </div>
    <div class="user-info">
        <div class="user-avatar">
            <%= firstName.substring(0, 1).toUpperCase() %>
        </div>
        <div class="user-name">Hello, <%= firstName %></div>
        <a href="LogoutServlet" class="logout-btn">🚪 Logout</a>
    </div>
</div>

<div class="container">
    <div class="page-title">
        <h1>📋 My Bookings</h1>
        <p>View all your booking history and status</p>
    </div>

    <!-- Stats Cards -->
    <div class="stats-cards">
        <div class="stat-card">
            <div class="stat-number"><%= totalBookings %></div>
            <div class="stat-label">Total Bookings</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= activeBookings %></div>
            <div class="stat-label">Active Bookings</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">₹<%= String.format("%,.0f", totalSpent) %></div>
            <div class="stat-label">Total Spent</div>
        </div>
    </div>

    <!-- Main Hotel Bookings Section -->
    <% if (!mainBookings.isEmpty()) { %>
        <div class="section-title">
            <span>🏨 Main Hotel Bookings</span>
        </div>
        <div class="bookings-list">
            <% for (Map<String, Object> booking : mainBookings) { 
                int bookingId = (Integer) booking.get("booking_id");
                String roomNo = (String) booking.get("room_no");
                String roomType = (String) booking.get("room_type");
                String bedType = (String) booking.get("bed_type");
                String checkIn = (String) booking.get("check_in");
                String checkOut = (String) booking.get("check_out");
                double totalAmount = (Double) booking.get("total_amount");
                String status = (String) booking.get("status");
                String paymentMethod = (String) booking.get("payment_method");
                
                int nights = 1;
                try {
                    java.sql.Date checkInDate = java.sql.Date.valueOf(checkIn);
                    java.sql.Date checkOutDate = java.sql.Date.valueOf(checkOut);
                    nights = (int)((checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24));
                    if (nights == 0) nights = 1;
                } catch (Exception e) {
                    nights = 1;
                }
            %>
            <div class="booking-card">
                <div class="booking-header">
                    <span class="booking-id">Booking #<%= bookingId %></span>
                    <span class="status-badge <%= status.equals("Confirmed") ? "status-confirmed" : "status-cancelled" %>">
                        <%= status.equals("Confirmed") ? "✓ Confirmed" : "✗ Cancelled" %>
                    </span>
                </div>
                <div class="booking-body">
                    <div class="booking-details">
                        <div class="detail-item">
                            <span class="detail-label">Room Number</span>
                            <span class="detail-value"><%= roomNo %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Room Type</span>
                            <span class="detail-value"><%= roomType %> (<%= bedType %>)</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Check-in Date</span>
                            <span class="detail-value"><%= checkIn %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Check-out Date</span>
                            <span class="detail-value"><%= checkOut %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Duration</span>
                            <span class="detail-value"><%= nights %> night(s)</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Payment Method</span>
                            <span class="detail-value"><%= paymentMethod != null ? paymentMethod : "Pending" %></span>
                        </div>
                    </div>
                    <div class="booking-footer">
                        <div>
                            <span class="detail-label">Total Amount</span>
                            <div class="total-amount">₹<%= String.format("%,.2f", totalAmount) %></div>
                        </div>
                        <% if (status.equals("Cancelled")) { %>
                            <div class="cancelled-badge">⚠️ Booking Cancelled</div>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    <% } %>

    <!-- Partner Hotel Bookings Section -->
    <% if (!partnerBookings.isEmpty()) { %>
        <div class="section-title">
            <span>🏨 Partner Hotel Bookings</span>
        </div>
        <div class="bookings-list">
            <% for (Map<String, Object> booking : partnerBookings) { 
                int bookingId = (Integer) booking.get("booking_id");
                String roomNo = (String) booking.get("room_no");
                String hotelName = (String) booking.get("hotel_name");
                String checkIn = (String) booking.get("check_in");
                String checkOut = (String) booking.get("check_out");
                double totalAmount = (Double) booking.get("total_amount");
                String status = (String) booking.get("status");
                String paymentMethod = (String) booking.get("payment_method");
                
                int nights = 1;
                try {
                    java.sql.Date checkInDate = java.sql.Date.valueOf(checkIn);
                    java.sql.Date checkOutDate = java.sql.Date.valueOf(checkOut);
                    nights = (int)((checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24));
                    if (nights == 0) nights = 1;
                } catch (Exception e) {
                    nights = 1;
                }
            %>
            <div class="booking-card">
                <div class="booking-header">
                    <span class="booking-id">
                        Booking #<%= bookingId %>
                        <span class="partner-badge">Partner Hotel</span>
                    </span>
                    <span class="status-badge <%= status.equals("Confirmed") ? "status-confirmed" : "status-cancelled" %>">
                        <%= status.equals("Confirmed") ? "✓ Confirmed" : "✗ Cancelled" %>
                    </span>
                </div>
                <div class="booking-body">
                    <div class="booking-details">
                        <div class="detail-item">
                            <span class="detail-label">Hotel</span>
                            <span class="detail-value"><%= hotelName != null ? hotelName : "Partner Hotel" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Room Number</span>
                            <span class="detail-value"><%= roomNo %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Check-in Date</span>
                            <span class="detail-value"><%= checkIn %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Check-out Date</span>
                            <span class="detail-value"><%= checkOut %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Duration</span>
                            <span class="detail-value"><%= nights %> night(s)</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Payment Method</span>
                            <span class="detail-value"><%= paymentMethod != null ? paymentMethod : "Pending" %></span>
                        </div>
                    </div>
                    <div class="booking-footer">
                        <div>
                            <span class="detail-label">Total Amount</span>
                            <div class="total-amount">₹<%= String.format("%,.2f", totalAmount) %></div>
                        </div>
                        <% if (status.equals("Cancelled")) { %>
                            <div class="cancelled-badge">⚠️ Booking Cancelled</div>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    <% } %>

    <!-- No Bookings Message -->
    <% if (mainBookings.isEmpty() && partnerBookings.isEmpty()) { %>
        <div class="no-bookings">
            <div class="icon">📭</div>
            <h3>No bookings found</h3>
            <p>You haven't made any reservations yet.</p>
            <a href="ViewRoom.jsp" class="browse-btn">Browse Rooms →</a>
        </div>
    <% } %>
</div>

</body>
</html>