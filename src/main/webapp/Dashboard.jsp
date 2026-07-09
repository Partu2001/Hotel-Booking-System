<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String username = (String) session.getAttribute("username");
    
    if (username == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    // Get user details from database
    String userFullName = "";
    String userEmail = "";
    String userMobile = "";
    String isHotelPartner = "NO";
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    // Booking statistics
    int totalBookings = 0;
    int activeBookings = 0;
    int completedBookings = 0;
    double totalSpent = 0;
    
    // Upcoming booking
    String upcomingRoomNo = "";
    String upcomingRoomType = "";
    String upcomingBedType = "";
    String upcomingCheckIn = "";
    String upcomingCheckOut = "";
    double upcomingAmount = 0;
    int upcomingNights = 0;
    double upcomingPricePerNight = 0;
    
    // Last booking
    String lastRoomNo = "";
    String lastRoomType = "";
    String lastBedType = "";
    String lastCheckIn = "";
    String lastCheckOut = "";
    double lastAmount = 0;
    String lastBookingDate = "";
    int lastNights = 0;
    double lastPricePerNight = 0;
    
    // Partner hotels and rooms
    List<Map<String, Object>> partnerHotels = new ArrayList<Map<String, Object>>();
    Map<Integer, List<Map<String, Object>>> hotelRoomsMap = new HashMap<Integer, List<Map<String, Object>>>();
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        
        // Get user details
        ps = con.prepareStatement("SELECT name, email, mobile, is_hotel_partner FROM userdata WHERE username = ?");
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            userFullName = rs.getString("name");
            userEmail = rs.getString("email");
            userMobile = rs.getString("mobile");
            isHotelPartner = rs.getString("is_hotel_partner");
        }
        rs.close();
        ps.close();
        
        // If user is a hotel partner, get all their hotels
        if (!"NO".equals(isHotelPartner)) {
            ps = con.prepareStatement("SELECT * FROM partner_hotels WHERE partner_username = ? ORDER BY hotel_id DESC");
            ps.setString(1, username);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> hotel = new HashMap<String, Object>();
                hotel.put("hotel_id", rs.getInt("hotel_id"));
                hotel.put("hotel_name", rs.getString("hotel_name"));
                hotel.put("hotel_location", rs.getString("hotel_location"));
                hotel.put("hotel_phone", rs.getString("hotel_phone"));
                hotel.put("hotel_email", rs.getString("hotel_email"));
                hotel.put("hotel_description", rs.getString("hotel_description"));
                hotel.put("hotel_image", rs.getString("hotel_image"));
                hotel.put("status", rs.getString("status"));
                hotel.put("created_date", rs.getDate("created_date"));
                partnerHotels.add(hotel);
            }
            rs.close();
            ps.close();
            
            // Get rooms for each hotel
            for (Map<String, Object> hotel : partnerHotels) {
                int hotelId = (Integer) hotel.get("hotel_id");
                List<Map<String, Object>> rooms = new ArrayList<Map<String, Object>>();
                
                ps = con.prepareStatement("SELECT * FROM partner_rooms WHERE hotel_id = ? ORDER BY room_number");
                ps.setInt(1, hotelId);
                rs = ps.executeQuery();
                
                while (rs.next()) {
                    Map<String, Object> room = new HashMap<String, Object>();
                    room.put("room_id", rs.getInt("room_id"));
                    room.put("room_number", rs.getString("room_number"));
                    room.put("room_type", rs.getString("room_type"));
                    room.put("bed_type", rs.getString("bed_type"));
                    room.put("price", rs.getDouble("price"));
                    room.put("capacity", rs.getInt("capacity"));
                    room.put("amenities", rs.getString("amenities"));
                    room.put("status", rs.getString("status"));
                    room.put("image_url", rs.getString("image_url"));
                    rooms.add(room);
                }
                rs.close();
                ps.close();
                
                hotelRoomsMap.put(hotelId, rooms);
            }
        }
        
        // Get total bookings count
        ps = con.prepareStatement("SELECT COUNT(*) as total FROM bookings WHERE username = ? AND status = 'Confirmed'");
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            totalBookings = rs.getInt("total");
        }
        rs.close();
        ps.close();
        
        // Get active bookings
        ps = con.prepareStatement(
            "SELECT COUNT(*) as active FROM bookings WHERE username = ? AND status = 'Confirmed' AND check_out >= TRUNC(SYSDATE)"
        );
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            activeBookings = rs.getInt("active");
        }
        rs.close();
        ps.close();
        
        // Get total spent
        ps = con.prepareStatement(
            "SELECT SUM(total_amount) as total FROM bookings WHERE username = ? AND status = 'Confirmed'"
        );
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            totalSpent = rs.getDouble("total");
        }
        rs.close();
        ps.close();
        
        // Get upcoming booking
        ps = con.prepareStatement(
            "SELECT b.*, r.roomtype, r.bedtype, r.price FROM bookings b " +
            "JOIN room r ON b.roomno = r.roomno " +
            "WHERE b.username = ? AND b.status = 'Confirmed' AND b.check_in >= TRUNC(SYSDATE) " +
            "ORDER BY b.check_in ASC FETCH FIRST 1 ROW ONLY"
        );
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            upcomingRoomNo = rs.getString("roomno");
            upcomingRoomType = rs.getString("roomtype");
            upcomingBedType = rs.getString("bedtype");
            upcomingCheckIn = rs.getString("check_in");
            upcomingCheckOut = rs.getString("check_out");
            upcomingAmount = rs.getDouble("total_amount");
            upcomingPricePerNight = rs.getDouble("price");
            
            java.sql.Date checkInDate = rs.getDate("check_in");
            java.sql.Date checkOutDate = rs.getDate("check_out");
            if (checkInDate != null && checkOutDate != null) {
                upcomingNights = (int)((checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24));
                if (upcomingNights == 0) upcomingNights = 1;
            }
        }
        rs.close();
        ps.close();
        
        // Get last booking
        ps = con.prepareStatement(
            "SELECT b.*, r.roomtype, r.bedtype, r.price FROM bookings b " +
            "JOIN room r ON b.roomno = r.roomno " +
            "WHERE b.username = ? AND b.status = 'Confirmed' " +
            "ORDER BY b.booking_date DESC FETCH FIRST 1 ROW ONLY"
        );
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            lastRoomNo = rs.getString("roomno");
            lastRoomType = rs.getString("roomtype");
            lastBedType = rs.getString("bedtype");
            lastCheckIn = rs.getString("check_in");
            lastCheckOut = rs.getString("check_out");
            lastAmount = rs.getDouble("total_amount");
            lastBookingDate = rs.getString("booking_date");
            lastPricePerNight = rs.getDouble("price");
            
            java.sql.Date checkInDate = rs.getDate("check_in");
            java.sql.Date checkOutDate = rs.getDate("check_out");
            if (checkInDate != null && checkOutDate != null) {
                lastNights = (int)((checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24));
                if (lastNights == 0) lastNights = 1;
            }
        }
        rs.close();
        ps.close();
        
        completedBookings = totalBookings - activeBookings;
        
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
    
    String activeTab = request.getParameter("tab");
    if (activeTab == null) activeTab = "bookings";
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Dashboard - Hotel Management</title>
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

/* Navbar Styles */
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
    max-width: 1400px;
    margin: 30px auto;
    padding: 0 20px;
}

.welcome-section {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 20px;
    padding: 35px;
    margin-bottom: 30px;
    color: white;
    box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.welcome-section h1 {
    font-size: 32px;
    margin-bottom: 10px;
}

.welcome-section p {
    font-size: 16px;
    opacity: 0.9;
}

.welcome-stats {
    display: flex;
    gap: 30px;
    margin-top: 25px;
    flex-wrap: wrap;
}

.stat-card {
    background: rgba(255,255,255,0.15);
    padding: 15px 25px;
    border-radius: 15px;
    backdrop-filter: blur(10px);
    transition: transform 0.3s;
}

.stat-card:hover {
    transform: translateY(-3px);
    background: rgba(255,255,255,0.25);
}

.stat-number {
    font-size: 28px;
    font-weight: bold;
}

.stat-label {
    font-size: 13px;
    opacity: 0.9;
    margin-top: 5px;
}

.tab-navigation {
    background: white;
    border-radius: 15px;
    margin-bottom: 25px;
    display: flex;
    overflow: hidden;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.tab-btn {
    flex: 1;
    padding: 16px 20px;
    background: white;
    border: none;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    color: #666;
    border-bottom: 3px solid transparent;
    font-family: 'Poppins', sans-serif;
}

.tab-btn.active {
    color: #667eea;
    border-bottom-color: #667eea;
    background: #f8f9ff;
}

.tab-btn:hover:not(.active) {
    background: #f8f9fa;
    color: #333;
}

.tab-content {
    display: none;
    animation: fadeIn 0.3s ease-out;
}

.tab-content.active {
    display: block;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat-box {
    background: white;
    padding: 25px;
    border-radius: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    transition: transform 0.3s;
    text-align: center;
}

.stat-box:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.stat-icon {
    font-size: 40px;
    margin-bottom: 15px;
}

.stat-value {
    font-size: 32px;
    font-weight: bold;
    color: #333;
    margin-bottom: 5px;
}

.stat-title {
    color: #666;
    font-size: 14px;
}

.booking-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 25px;
    margin-bottom: 40px;
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
    padding: 15px 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.booking-header h3 {
    font-size: 18px;
}

.booking-body {
    padding: 20px;
}

.booking-detail {
    display: flex;
    justify-content: space-between;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid #f0f0f0;
}

.detail-label {
    color: #666;
    font-size: 14px;
    font-weight: 500;
}

.detail-value {
    font-weight: 600;
    color: #333;
}

.booking-amount {
    background: #e8f5e9;
    border-radius: 10px;
    padding: 12px;
    margin-top: 15px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.amount-value {
    font-size: 20px;
    font-weight: bold;
    color: #28a745;
}

/* Hotel Partner Section */
.hotel-info-card {
    background: white;
    border-radius: 15px;
    padding: 25px;
    margin-bottom: 25px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.status-badge {
    display: inline-block;
    padding: 5px 15px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.status-pending {
    background: #fff3cd;
    color: #856404;
}

.status-approved {
    background: #d4edda;
    color: #155724;
}

.status-rejected {
    background: #f8d7da;
    color: #721c24;
}

.rooms-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 20px;
    margin-top: 20px;
}

.room-card {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    transition: transform 0.3s;
}

.room-card:hover {
    transform: translateY(-3px);
}

.room-image {
    width: 100%;
    height: 180px;
    object-fit: cover;
    background: #e0e0e0;
}

.room-info {
    padding: 15px;
}

.room-number {
    font-size: 18px;
    font-weight: bold;
    color: #333;
}

.room-price {
    color: #28a745;
    font-weight: bold;
    font-size: 16px;
    margin: 8px 0;
}

.add-room-btn {
    background: #28a745;
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    width: 100%;
    margin-top: 15px;
}

.add-room-form {
    background: #f8f9fa;
    padding: 20px;
    border-radius: 12px;
    margin-top: 20px;
    display: none;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
}

.form-grid input, .form-grid select {
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 8px;
}

.extra-amenity-row {
    display: flex;
    gap: 10px;
    margin-bottom: 10px;
}

.extra-amenity-row input {
    flex: 2;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 5px;
}

.extra-amenity-row input[name="extraPrice"] {
    flex: 1;
}

.remove-amenity-btn {
    background: #dc3545;
    color: white;
    border: none;
    padding: 0 15px;
    border-radius: 5px;
    cursor: pointer;
}

.add-amenity-btn {
    background: #17a2b8;
    color: white;
    border: none;
    padding: 8px 15px;
    border-radius: 5px;
    cursor: pointer;
    margin-bottom: 15px;
}

.no-data {
    text-align: center;
    padding: 40px;
    color: #666;
}

.quick-actions {
    display: flex;
    gap: 15px;
    margin-top: 20px;
    justify-content: center;
    flex-wrap: wrap;
}

.action-btn {
    padding: 12px 25px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    text-decoration: none;
    border-radius: 10px;
    transition: transform 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-weight: 500;
}

.action-btn:hover {
    transform: translateY(-2px);
}

.add-hotel-btn {
    background: #28a745;
    margin-bottom: 20px;
    display: inline-block;
    width: auto;
}

/* Edit/Delete Buttons */
.edit-hotel-btn, .delete-hotel-btn, .edit-room-btn, .delete-room-btn {
    padding: 6px 12px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 12px;
    font-weight: 500;
    transition: all 0.3s;
    margin-left: 5px;
}

.edit-hotel-btn {
    background: #ffc107;
    color: #333;
}

.edit-hotel-btn:hover {
    background: #e0a800;
}

.delete-hotel-btn {
    background: #dc3545;
    color: white;
}

.delete-hotel-btn:hover {
    background: #c82333;
}

.room-actions {
    display: flex;
    gap: 8px;
    margin-top: 10px;
    padding-top: 10px;
    border-top: 1px solid #eee;
}

.edit-room-btn, .delete-room-btn {
    flex: 1;
    padding: 8px;
    font-size: 12px;
}

.edit-room-btn {
    background: #17a2b8;
    color: white;
}

.delete-room-btn {
    background: #dc3545;
    color: white;
}

/* Bookings Table Styles */
.bookings-table-wrapper {
    overflow-x: auto;
    margin-top: 15px;
}

.bookings-table-wrapper table {
    width: 100%;
    border-collapse: collapse;
    background: white;
    border-radius: 12px;
    overflow: hidden;
}

.bookings-table-wrapper th {
    padding: 12px;
    text-align: left;
    font-weight: 600;
    font-size: 13px;
}

.bookings-table-wrapper td {
    padding: 12px;
    border-bottom: 1px solid #f0f0f0;
}

.bookings-table-wrapper tr:hover {
    background: #f8f9fa;
}

.no-bookings-message {
    text-align: center;
    padding: 30px;
    background: #f8f9fa;
    border-radius: 10px;
    margin-top: 15px;
    color: #666;
}

/* Modal Styles */
.edit-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 1000;
    justify-content: center;
    align-items: center;
}

.edit-modal-content {
    background: white;
    border-radius: 20px;
    max-width: 500px;
    width: 90%;
    padding: 25px;
}

.edit-modal-header {
    font-size: 20px;
    font-weight: bold;
    margin-bottom: 15px;
    color: #333;
}

.edit-form-group {
    margin-bottom: 15px;
}

.edit-form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: 600;
    color: #333;
}

.edit-form-group input, 
.edit-form-group textarea,
.edit-form-group select {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 8px;
}

.edit-modal-footer {
    margin-top: 20px;
    display: flex;
    gap: 10px;
    justify-content: flex-end;
}

.save-btn {
    background: #28a745;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    cursor: pointer;
}

.cancel-btn {
    background: #6c757d;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    cursor: pointer;
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
    
    .booking-grid, .rooms-grid {
        grid-template-columns: 1fr;
    }
    
    .tab-btn {
        font-size: 14px;
        padding: 12px;
    }
    
    .extra-amenity-row {
        flex-wrap: wrap;
    }
    
    .welcome-section h1 {
        font-size: 24px;
    }
    
    .welcome-stats {
        gap: 15px;
    }
    
    .stat-card {
        padding: 10px 15px;
    }
    
    .stat-number {
        font-size: 20px;
    }
}
</style>
</head>
<body>

<!-- Navigation Bar -->
<div class="navbar">
    <div class="logo">
        <div class="logo-icon">🏨</div>
        <div>
            <h2>Hotel Management</h2>
            <p>LUXURY REDEFINED</p>
        </div>
    </div>
    <div class="nav-links">
        <a href="Dashboard.jsp" class="active">🏠 Dashboard</a>
        <a href="ViewRoom.jsp">🛏️ View Rooms</a>
        <a href="MyBookings.jsp">📋 My Bookings</a>
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
    <!-- Welcome Section -->
    <div class="welcome-section">
        <h1>Welcome back, <%= firstName %>! 👋</h1>
        <p>We're delighted to have you at Hotel Management System</p>
        <div class="welcome-stats">
            <div class="stat-card">
                <div class="stat-number"><%= totalBookings %></div>
                <div class="stat-label">Total Bookings</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= activeBookings %></div>
                <div class="stat-label">Active Stays</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">₹<%= String.format("%,.0f", totalSpent) %></div>
                <div class="stat-label">Total Spent</div>
            </div>
        </div>
    </div>
    
    <!-- Tab Navigation -->
    <div class="tab-navigation">
        <button class="tab-btn <%= activeTab.equals("bookings") ? "active" : "" %>" onclick="switchTab('bookings')">📅 My Bookings</button>
        <% if (!"NO".equals(isHotelPartner)) { %>
            <button class="tab-btn <%= activeTab.equals("myhotel") ? "active" : "" %>" onclick="switchTab('myhotel')">🏨 My Hotels</button>
        <% } %>
    </div>
    
    <!-- Bookings Tab -->
    <div id="bookingsTab" class="tab-content <%= activeTab.equals("bookings") ? "active" : "" %>">
        <div class="stats-grid">
            <div class="stat-box">
                <div class="stat-icon">👤</div>
                <div class="stat-value"><%= userFullName %></div>
                <div class="stat-title">Full Name</div>
            </div>
            <div class="stat-box">
                <div class="stat-icon">📧</div>
                <div class="stat-value" style="font-size: 16px;"><%= userEmail %></div>
                <div class="stat-title">Email Address</div>
            </div>
            <div class="stat-box">
                <div class="stat-icon">📱</div>
                <div class="stat-value" style="font-size: 16px;"><%= userMobile %></div>
                <div class="stat-title">Mobile Number</div>
            </div>
            <div class="stat-box">
                <div class="stat-icon">✅</div>
                <div class="stat-value"><%= completedBookings %></div>
                <div class="stat-title">Completed Stays</div>
            </div>
        </div>
        
        <div class="booking-grid">
            <div class="booking-card">
                <div class="booking-header">
                    <h3>🔜 Upcoming Booking</h3>
                    <span>📅</span>
                </div>
                <div class="booking-body">
                    <% if (upcomingRoomNo != null && !upcomingRoomNo.isEmpty()) { %>
                        <div class="booking-detail">
                            <span class="detail-label">Room Number</span>
                            <span class="detail-value"><%= upcomingRoomNo %></span>
                        </div>
                        <div class="booking-detail">
                            <span class="detail-label">Check-in Date</span>
                            <span class="detail-value"><%= upcomingCheckIn %></span>
                        </div>
                        <div class="booking-detail">
                            <span class="detail-label">Check-out Date</span>
                            <span class="detail-value"><%= upcomingCheckOut %></span>
                        </div>
                        <div class="booking-detail">
                            <span class="detail-label">Duration</span>
                            <span class="detail-value"><%= upcomingNights %> night(s)</span>
                        </div>
                        <div class="booking-amount">
                            <span>Total Amount</span>
                            <span class="amount-value">₹<%= String.format("%,.2f", upcomingAmount) %></span>
                        </div>
                    <% } else { %>
                        <div class="no-data">
                            <p>🎉 No upcoming bookings</p>
                            <a href="ViewRoom.jsp" class="action-btn" style="margin-top: 15px; display: inline-block;">Book a Room →</a>
                        </div>
                    <% } %>
                </div>
            </div>
            
            <div class="booking-card">
                <div class="booking-header">
                    <h3>📜 Last Booking</h3>
                    <span>🕒</span>
                </div>
                <div class="booking-body">
                    <% if (lastRoomNo != null && !lastRoomNo.isEmpty()) { %>
                        <div class="booking-detail">
                            <span class="detail-label">Room Number</span>
                            <span class="detail-value"><%= lastRoomNo %></span>
                        </div>
                        <div class="booking-detail">
                            <span class="detail-label">Check-in Date</span>
                            <span class="detail-value"><%= lastCheckIn %></span>
                        </div>
                        <div class="booking-detail">
                            <span class="detail-label">Check-out Date</span>
                            <span class="detail-value"><%= lastCheckOut %></span>
                        </div>
                        <div class="booking-detail">
                            <span class="detail-label">Booking Date</span>
                            <span class="detail-value"><%= lastBookingDate %></span>
                        </div>
                        <div class="booking-amount">
                            <span>Total Amount</span>
                            <span class="amount-value">₹<%= String.format("%,.2f", lastAmount) %></span>
                        </div>
                    <% } else { %>
                        <div class="no-data">
                            <p>📭 No previous bookings</p>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <div class="quick-actions">
            <a href="ViewRoom.jsp" class="action-btn">🛏️ Book New Room</a>
            <a href="MyBookings.jsp" class="action-btn">📋 View All Bookings</a>
        </div>
    </div>
    
    <!-- My Hotels Tab -->
    <% if (!"NO".equals(isHotelPartner)) { %>
    <div id="myHotelTab" class="tab-content <%= activeTab.equals("myhotel") ? "active" : "" %>">
        <div style="margin-bottom: 20px; text-align: right;">
            <a href="AddHotel.jsp" class="action-btn add-hotel-btn">➕ Add New Hotel</a>
        </div>
        
        <% if (partnerHotels.isEmpty()) { %>
            <div class="hotel-info-card" style="text-align: center;">
                <h3>🏨 No Hotels Added Yet</h3>
                <p>Click "Add New Hotel" to start listing your hotels.</p>
                <a href="AddHotel.jsp" class="action-btn" style="margin-top: 15px; display: inline-block; width: auto;">➕ Add Your First Hotel</a>
            </div>
        <% } else {
            for (Map<String, Object> hotel : partnerHotels) {
                int hotelId = (Integer) hotel.get("hotel_id");
                String hotelName = (String) hotel.get("hotel_name");
                String hotelLocation = (String) hotel.get("hotel_location");
                String hotelPhone = (String) hotel.get("hotel_phone");
                String hotelEmail = (String) hotel.get("hotel_email");
                String hotelDescription = (String) hotel.get("hotel_description");
                String hotelStatus = (String) hotel.get("status");
                List<Map<String, Object>> hotelRooms = hotelRoomsMap.get(hotelId);
                int roomCount = hotelRooms != null ? hotelRooms.size() : 0;
        %>
        
        <div class="hotel-info-card">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap;">
                <div style="flex: 1;">
                    <h2 style="color: #333;">🏨 <%= hotelName %></h2>
                    <p style="color: #666;">📍 <%= hotelLocation %></p>
                    <p style="color: #666;">📞 <%= hotelPhone %></p>
                    <% if (hotelEmail != null && !hotelEmail.isEmpty()) { %>
                        <p style="color: #666;">📧 <%= hotelEmail %></p>
                    <% } %>
                    <% if (hotelDescription != null && !hotelDescription.isEmpty()) { %>
                        <p style="color: #555; margin-top: 10px;"><%= hotelDescription %></p>
                    <% } %>
                    <div style="margin-top: 15px;"><strong>Total Rooms:</strong> <%= roomCount %></div>
                </div>
                <div style="text-align: right;">
                    <% if ("Approved".equals(hotelStatus)) { %>
                        <span class="status-badge status-approved">✅ Approved</span>
                    <% } else if ("Pending".equals(hotelStatus)) { %>
                        <span class="status-badge status-pending">⏳ Pending Approval</span>
                    <% } else if ("Rejected".equals(hotelStatus)) { %>
                        <span class="status-badge status-rejected">❌ Rejected</span>
                    <% } %>
                    <div style="margin-top: 10px;">
                        <button class="edit-hotel-btn" onclick='editHotel(<%= hotelId %>, "<%= hotelName.replace("'", "\\'") %>", "<%= hotelLocation.replace("'", "\\'") %>", "<%= hotelPhone %>", "<%= hotelEmail != null ? hotelEmail.replace("'", "\\'") : "" %>", "<%= hotelDescription != null ? hotelDescription.replace("'", "\\'").replace("\n", " ") : "" %>")'>✏️ Edit Hotel</button>
                        <button class="delete-hotel-btn" onclick="deleteHotel(<%= hotelId %>, '<%= hotelName.replace("'", "\\'") %>')">🗑️ Delete Hotel</button>
                    </div>
                </div>
            </div>
            
            <% if ("Approved".equals(hotelStatus)) { %>
                <div style="margin-top: 20px; padding-top: 15px; border-top: 1px solid #eee;">
                    <button class="add-room-btn" onclick="toggleAddRoomFormForHotel(<%= hotelId %>, '<%= hotelName.replace("'", "\\'") %>')">➕ Add Room to <%= hotelName %></button>
                    
                    <div id="addRoomForm_<%= hotelId %>" class="add-room-form" style="display: none; margin-top: 15px;">
                        <form action="AddPartnerRoom" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="hotelId" value="<%= hotelId %>">
                            <input type="hidden" name="hotelName" value="<%= hotelName %>">
                            <h4>Add Room to <%= hotelName %></h4>
                            <div class="form-grid">
                                <input type="text" name="roomNumber" placeholder="Room Number" required>
                                <select name="roomType" required>
                                    <option value="">Select Room Type</option>
                                    <option value="Single">Single</option>
                                    <option value="Double">Double</option>
                                    <option value="Deluxe">Deluxe</option>
                                    <option value="Suite">Suite</option>
                                </select>
                                <select name="bedType" required>
                                    <option value="">Select Bed Type</option>
                                    <option value="Single Bed">Single Bed</option>
                                    <option value="Double Bed">Double Bed</option>
                                    <option value="Queen Size">Queen Size</option>
                                    <option value="King Size">King Size</option>
                                </select>
                                <input type="number" name="price" step="0.01" placeholder="Price per Night" required>
                                <input type="number" name="capacity" placeholder="Capacity" required>
                                <input type="text" name="amenities" placeholder="Amenities (comma separated)">
                            </div>
                            <h4>✨ Extra Amenities</h4>
                            <div id="extraAmenitiesContainer_<%= hotelId %>">
                                <div class="extra-amenity-row">
                                    <input type="text" name="extraAmenities" placeholder="Extra Amenity Name">
                                    <input type="number" name="extraPrice" step="0.01" placeholder="Extra Charge">
                                    <button type="button" class="remove-amenity-btn" onclick="this.parentElement.remove()">✖</button>
                                </div>
                            </div>
                            <button type="button" class="add-amenity-btn" onclick="addExtraAmenityRowForHotel(<%= hotelId %>)">+ Add Another Amenity</button>
                            <h4>🖼️ Room Image</h4>
                            <input type="file" name="roomImage" accept="image/*">
                            <button type="submit" style="margin-top: 20px; background: #28a745; color: white; border: none; padding: 12px 20px; border-radius: 8px; cursor: pointer; width: 100%; font-weight: 600;">🏨 Add Room</button>
                        </form>
                    </div>
                </div>
            <% } else if ("Pending".equals(hotelStatus)) { %>
                <div style="margin-top: 15px; padding: 10px; background: #fff3cd; border-radius: 8px; text-align: center;">
                    <span style="color: #856404;">⏳ This hotel is pending admin approval.</span>
                </div>
            <% } %>
            
            <!-- Rooms List -->
            <% if (hotelRooms != null && !hotelRooms.isEmpty()) { %>
                <h4 style="margin: 20px 0 15px;">📋 Rooms in <%= hotelName %></h4>
                <div class="rooms-grid">
                    <% for (Map<String, Object> room : hotelRooms) { 
                        int roomId = (Integer) room.get("room_id");
                        String roomNo = (String) room.get("room_number");
                        String roomTypeName = (String) room.get("room_type");
                        String bedType = (String) room.get("bed_type");
                        double price = (Double) room.get("price");
                        int capacity = (Integer) room.get("capacity");
                        String amenities = (String) room.get("amenities");
                        String imageUrl = (String) room.get("image_url");
                        if (imageUrl == null || imageUrl.isEmpty()) { imageUrl = "https://via.placeholder.com/300x160?text=Room+Image"; } 
                        else { imageUrl = request.getContextPath() + "/" + imageUrl; }
                    %>
                        <div class="room-card">
                            <img src="<%= imageUrl %>" class="room-image" onerror="this.src='https://via.placeholder.com/300x160?text=No+Image'">
                            <div class="room-info">
                                <div class="room-number">Room <%= roomNo %></div>
                                <div class="room-price">₹<%= String.format("%.2f", price) %> / night</div>
                                <div class="booking-detail"><span class="detail-label">Type:</span><span class="detail-value"><%= roomTypeName %> | <%= bedType %></span></div>
                                <div class="booking-detail"><span class="detail-label">Capacity:</span><span class="detail-value"><%= capacity %> persons</span></div>
                                <% if (amenities != null && !amenities.isEmpty()) { %>
                                    <div class="booking-detail"><span class="detail-label">Amenities:</span><span class="detail-value"><%= amenities %></span></div>
                                <% } %>
                                <div class="room-actions">
                                    <button class="edit-room-btn" onclick='editPartnerRoom(<%= roomId %>, "<%= roomNo %>", "<%= roomTypeName %>", "<%= bedType %>", <%= price %>, <%= capacity %>, "<%= amenities != null ? amenities.replace("\"", "&quot;") : "" %>")'>✏️ Edit</button>
                                    <button class="delete-room-btn" onclick='deletePartnerRoom(<%= roomId %>, "<%= roomNo %>", "<%= hotelName.replace("'", "\\'") %>")'>🗑️ Delete</button>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } else if ("Approved".equals(hotelStatus)) { %>
                <div style="text-align: center; padding: 20px; background: #f8f9fa; border-radius: 10px; margin-top: 15px;">
                    <p>No rooms added yet for <%= hotelName %>.</p>
                </div>
            <% } %>
            
            <!-- Bookings Section for Partner Hotel -->
            <% if ("Approved".equals(hotelStatus)) { 
                List<Map<String, Object>> hotelBookings = new ArrayList<Map<String, Object>>();
                Connection con2 = null;
                PreparedStatement ps2 = null;
                ResultSet rs2 = null;
                
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    con2 = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
                    
                    String bookingSql = 
                        "SELECT pb.*, u.name as customer_name, u.email as customer_email, u.mobile as customer_mobile " +
                        "FROM partner_bookings pb " +
                        "JOIN userdata u ON pb.username = u.username " +
                        "WHERE pb.room_id IN (SELECT room_id FROM partner_rooms WHERE hotel_id = ?) " +
                        "ORDER BY pb.booking_date DESC";
                    
                    ps2 = con2.prepareStatement(bookingSql);
                    ps2.setInt(1, hotelId);
                    rs2 = ps2.executeQuery();
                    
                    while (rs2.next()) {
                        Map<String, Object> booking = new HashMap<String, Object>();
                        booking.put("booking_id", rs2.getInt("booking_id"));
                        booking.put("room_number", rs2.getString("room_number"));
                        booking.put("customer_name", rs2.getString("customer_name"));
                        booking.put("customer_email", rs2.getString("customer_email"));
                        booking.put("customer_mobile", rs2.getString("customer_mobile"));
                        booking.put("check_in", rs2.getDate("check_in"));
                        booking.put("check_out", rs2.getDate("check_out"));
                        booking.put("total_amount", rs2.getDouble("total_amount"));
                        booking.put("status", rs2.getString("status"));
                        booking.put("booking_date", rs2.getDate("booking_date"));
                        hotelBookings.add(booking);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try { if (rs2 != null) rs2.close(); } catch(Exception e) {}
                    try { if (ps2 != null) ps2.close(); } catch(Exception e) {}
                    try { if (con2 != null) con2.close(); } catch(Exception e) {}
                }
                
                if (!hotelBookings.isEmpty()) {
            %>
                    <div style="margin-top: 25px;">
                        <h4 style="margin-bottom: 15px; color: #333; border-left: 4px solid #ff9800; padding-left: 10px;">
                            📋 Booking Requests for <%= hotelName %>
                        </h4>
                        <div class="bookings-table-wrapper">
                            <table>
                                <thead>
                                    <tr style="background: linear-gradient(135deg, #ff9800 0%, #ff5722 100%); color: white;">
                                        <th style="padding: 12px;">Booking ID</th>
                                        <th style="padding: 12px;">Customer Details</th>
                                        <th style="padding: 12px;">Room No</th>
                                        <th style="padding: 12px;">Check In</th>
                                        <th style="padding: 12px;">Check Out</th>
                                        <th style="padding: 12px;">Amount</th>
                                        <th style="padding: 12px;">Status</th>
                                        <th style="padding: 12px;">Booked On</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, Object> booking : hotelBookings) { 
                                        String bookingStatus = (String) booking.get("status");
                                        String statusColor = "Confirmed".equals(bookingStatus) ? "#28a745" : "#dc3545";
                                        String statusBg = "Confirmed".equals(bookingStatus) ? "#d4edda" : "#f8d7da";
                                    %>
                                        <tr style="border-bottom: 1px solid #e0e0e0;">
                                            <td style="padding: 12px;">#<%= booking.get("booking_id") %></td>
                                            <td style="padding: 12px;">
                                                <strong><%= booking.get("customer_name") %></strong><br>
                                                <small style="color: #666;">📧 <%= booking.get("customer_email") %></small><br>
                                                <small style="color: #666;">📱 <%= booking.get("customer_mobile") %></small>
                                            </td>
                                            <td style="padding: 12px;"><%= booking.get("room_number") %></td>
                                            <td style="padding: 12px;"><%= booking.get("check_in") %></td>
                                            <td style="padding: 12px;"><%= booking.get("check_out") %></td>
                                            <td style="padding: 12px; color: #28a745; font-weight: bold;">₹<%= String.format("%,.2f", (Double)booking.get("total_amount")) %></td>
                                            <td style="padding: 12px;">
                                                <span style="background: <%= statusBg %>; color: <%= statusColor %>; padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600;">
                                                    <%= bookingStatus %>
                                                </span>
                                            </td>
                                            <td style="padding: 12px; font-size: 12px; color: #666;"><%= booking.get("booking_date") %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
            <%
                } else {
            %>
                    <div style="margin-top: 25px;">
                        <h4 style="margin-bottom: 15px; color: #333; border-left: 4px solid #ff9800; padding-left: 10px;">
                            📋 Booking Requests for <%= hotelName %>
                        </h4>
                        <div class="no-bookings-message">
                            <p>📭 No bookings received yet for this hotel.</p>
                            <p style="font-size: 13px; margin-top: 5px;">When customers book your rooms, they will appear here.</p>
                        </div>
                    </div>
            <%
                }
            } %>
        </div>
        <% } } %>
    </div>
    <% } %>
</div>

<script>
function switchTab(tabName) {
    const url = new URL(window.location.href);
    url.searchParams.set('tab', tabName);
    window.history.pushState({}, '', url);
    
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    document.getElementById('bookingsTab').classList.remove('active');
    if (tabName === 'bookings') {
        document.getElementById('bookingsTab').classList.add('active');
    } else if (tabName === 'myhotel') {
        document.getElementById('myHotelTab').classList.add('active');
    }
}

function toggleAddRoomFormForHotel(hotelId, hotelName) {
    var form = document.getElementById('addRoomForm_' + hotelId);
    if (form.style.display === 'none' || form.style.display === '') {
        form.style.display = 'block';
        var container = document.getElementById('extraAmenitiesContainer_' + hotelId);
        if (container) container.innerHTML = '<div class="extra-amenity-row"><input type="text" name="extraAmenities" placeholder="Extra Amenity Name"><input type="number" name="extraPrice" step="0.01" placeholder="Extra Charge"><button type="button" class="remove-amenity-btn" onclick="this.parentElement.remove()">✖</button></div>';
    } else form.style.display = 'none';
}

function addExtraAmenityRowForHotel(hotelId) {
    var container = document.getElementById('extraAmenitiesContainer_' + hotelId);
    if (container) {
        var newRow = document.createElement('div');
        newRow.className = 'extra-amenity-row';
        newRow.innerHTML = '<input type="text" name="extraAmenities" placeholder="Extra Amenity Name"><input type="number" name="extraPrice" step="0.01" placeholder="Extra Charge"><button type="button" class="remove-amenity-btn" onclick="this.parentElement.remove()">✖</button>';
        container.appendChild(newRow);
    }
}

function editHotel(hotelId, hotelName, hotelLocation, hotelPhone, hotelEmail, hotelDescription) {
    var modalHtml = '<div id="editHotelModal" class="edit-modal" style="display: flex;"><div class="edit-modal-content"><div class="edit-modal-header">✏️ Edit Hotel: ' + hotelName + '</div><form id="editHotelForm"><input type="hidden" name="hotelId" value="' + hotelId + '"><div class="edit-form-group"><label>Hotel Name</label><input type="text" name="hotelName" value="' + hotelName + '" required></div><div class="edit-form-group"><label>Location</label><input type="text" name="hotelLocation" value="' + hotelLocation + '" required></div><div class="edit-form-group"><label>Phone</label><input type="tel" name="hotelPhone" value="' + hotelPhone + '" required></div><div class="edit-form-group"><label>Email</label><input type="email" name="hotelEmail" value="' + (hotelEmail || '') + '"></div><div class="edit-form-group"><label>Description</label><textarea name="hotelDescription" rows="3">' + (hotelDescription || '') + '</textarea></div><div class="edit-modal-footer"><button type="button" class="cancel-btn" onclick="closeEditModal()">Cancel</button><button type="submit" class="save-btn">Save Changes</button></div></form></div></div>';
    var existing = document.getElementById('editHotelModal');
    if (existing) existing.remove();
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    document.getElementById('editHotelForm').addEventListener('submit', function(e) {
        e.preventDefault();
        var formData = new FormData(this);
        fetch('UpdateHotel', { method: 'POST', body: formData }).then(r => r.text()).then(d => { if (d.startsWith('SUCCESS')) { alert('✅ Hotel updated!'); location.reload(); } else { alert('❌ Error: ' + d); } });
    });
}

function deleteHotel(hotelId, hotelName) {
    if (confirm('⚠️ Delete "' + hotelName + '"? This will delete ALL rooms!')) {
        fetch('DeleteHotel', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: 'hotelId=' + hotelId })
            .then(r => r.text()).then(d => { if (d.startsWith('SUCCESS')) { alert('✅ Hotel deleted!'); location.reload(); } else { alert('❌ Error: ' + d); } });
    }
}

function editPartnerRoom(roomId, roomNo, roomType, bedType, price, capacity, amenities) {
    var modalHtml = '<div id="editPartnerRoomModal" class="edit-modal" style="display: flex;"><div class="edit-modal-content"><div class="edit-modal-header">✏️ Edit Room ' + roomNo + '</div><form id="editPartnerRoomForm" action="UpdatePartnerRoom" method="post" enctype="multipart/form-data"><input type="hidden" name="roomId" value="' + roomId + '"><div class="edit-form-group"><label>Room Number</label><input type="text" name="roomNumber" value="' + roomNo + '" required></div><div class="edit-form-group"><label>Room Type</label><select name="roomType"><option value="Single"' + (roomType === 'Single' ? ' selected' : '') + '>Single</option><option value="Double"' + (roomType === 'Double' ? ' selected' : '') + '>Double</option><option value="Deluxe"' + (roomType === 'Deluxe' ? ' selected' : '') + '>Deluxe</option><option value="Suite"' + (roomType === 'Suite' ? ' selected' : '') + '>Suite</option></select></div><div class="edit-form-group"><label>Bed Type</label><select name="bedType"><option value="Single Bed"' + (bedType === 'Single Bed' ? ' selected' : '') + '>Single Bed</option><option value="Double Bed"' + (bedType === 'Double Bed' ? ' selected' : '') + '>Double Bed</option><option value="Queen Size"' + (bedType === 'Queen Size' ? ' selected' : '') + '>Queen Size</option><option value="King Size"' + (bedType === 'King Size' ? ' selected' : '') + '>King Size</option></select></div><div class="edit-form-group"><label>Price</label><input type="number" name="price" step="0.01" value="' + price + '" required></div><div class="edit-form-group"><label>Capacity</label><input type="number" name="capacity" value="' + capacity + '" required></div><div class="edit-form-group"><label>Amenities</label><input type="text" name="amenities" value="' + (amenities || '') + '"></div><div class="edit-form-group"><label>Room Image</label><input type="file" name="roomImage" accept="image/*"></div><div class="edit-modal-footer"><button type="button" class="cancel-btn" onclick="closeEditModal()">Cancel</button><button type="submit" class="save-btn">Save Changes</button></div></form></div></div>';
    var existing = document.getElementById('editPartnerRoomModal');
    if (existing) existing.remove();
    document.body.insertAdjacentHTML('beforeend', modalHtml);
}

function deletePartnerRoom(roomId, roomNo, hotelName) {
    if (confirm('⚠️ Delete Room ' + roomNo + ' from ' + hotelName + '?')) {
        fetch('DeletePartnerRoom', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: 'roomId=' + roomId })
            .then(r => r.text()).then(d => { if (d.startsWith('SUCCESS')) { alert('✅ Room deleted!'); location.reload(); } else { alert('❌ Error: ' + d); } });
    }
}

function closeEditModal() {
    document.querySelectorAll('.edit-modal').forEach(modal => modal.remove());
}
</script>

</body>
</html>