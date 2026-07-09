<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    // Check if admin is logged in
    HttpSession adminSession = request.getSession(false);
    boolean isAdmin = (adminSession != null && adminSession.getAttribute("admin") != null);
    
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    boolean isLoggedIn = (username != null);
    
    // Get user name for navbar
    String userFullName = "";
    if (isLoggedIn) {
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
    }
    
    String firstName = userFullName;
    if (firstName != null && firstName.contains(" ")) {
        firstName = firstName.substring(0, firstName.indexOf(" "));
    }
    if (firstName == null || firstName.isEmpty()) {
        firstName = username != null ? username : "Guest";
    }
    
    // Get search and filter parameters
    String searchQuery = request.getParameter("search");
    String priceFilter = request.getParameter("price");
    String typeFilter = request.getParameter("type");
    String sortBy = request.getParameter("sort");
    
    if (searchQuery == null) searchQuery = "";
    if (priceFilter == null) priceFilter = "";
    if (typeFilter == null) typeFilter = "";
    if (sortBy == null) sortBy = "";
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>View Rooms - Hotel Management</title>
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

/* Search and Filter Section */
.search-filter-section {
    background: white;
    border-radius: 20px;
    padding: 25px;
    margin-bottom: 30px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.search-bar {
    display: flex;
    gap: 15px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}

.search-input {
    flex: 2;
    padding: 15px;
    border: 2px solid #e0e0e0;
    border-radius: 12px;
    font-size: 16px;
    outline: none;
    transition: all 0.3s;
    font-family: 'Poppins', sans-serif;
}

.search-input:focus {
    border-color: #667eea;
}

.search-btn {
    padding: 15px 30px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
}

.search-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(0,0,0,0.2);
}

.reset-btn {
    background: #6c757d;
}

.reset-btn:hover {
    background: #5a6268;
}

.filter-toggle {
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
    color: #667eea;
    font-weight: 600;
    margin-top: 10px;
}

.filter-toggle:hover {
    color: #764ba2;
}

.filter-panel {
    display: none;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #e0e0e0;
    animation: fadeIn 0.3s ease-out;
}

.filter-panel.show {
    display: block;
}

.filter-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
}

.filter-group {
    display: flex;
    flex-direction: column;
}

.filter-group label {
    font-weight: 600;
    color: #333;
    margin-bottom: 8px;
}

.filter-group select {
    padding: 10px;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    font-size: 14px;
    outline: none;
    font-family: 'Poppins', sans-serif;
}

.filter-group select:focus {
    border-color: #667eea;
}

.apply-filter-btn {
    margin-top: 20px;
    padding: 12px 25px;
    background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    color: white;
    border: none;
    border-radius: 10px;
    font-weight: 600;
    cursor: pointer;
    width: 100%;
}

.results-summary {
    background: white;
    border-radius: 15px;
    padding: 15px 20px;
    margin-bottom: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
}

.results-count {
    color: #666;
    font-size: 14px;
}

.results-highlight {
    color: #667eea;
    font-weight: bold;
}

.sort-dropdown {
    padding: 8px 15px;
    border: 1px solid #ddd;
    border-radius: 8px;
    outline: none;
    font-family: 'Poppins', sans-serif;
}

.room-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
    gap: 25px;
}

.room-card-link {
    text-decoration: none;
    display: block;
    transition: transform 0.3s;
}

.room-card-link:hover {
    transform: translateY(-5px);
}

.room-card {
    background: white;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
    cursor: pointer;
    transition: all 0.3s;
    height: 100%;
    display: flex;
    flex-direction: column;
}

.room-card:hover {
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
}

.room-image {
    width: 100%;
    height: 220px;
    object-fit: cover;
    background: #e0e0e0;
    transition: transform 0.5s ease;
}

.room-card:hover .room-image {
    transform: scale(1.05);
}

.image-container {
    overflow: hidden;
    position: relative;
}

.hotel-badge {
    position: absolute;
    top: 10px;
    left: 10px;
    background: rgba(0,0,0,0.7);
    color: white;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 600;
    z-index: 1;
}

.room-info {
    padding: 20px;
    flex: 1;
}

.room-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    flex-wrap: wrap;
    gap: 8px;
}

.room-number {
    font-size: 18px;
    font-weight: bold;
    color: #333;
}

.room-type {
    background: #667eea;
    color: white;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 11px;
}

.price {
    font-size: 24px;
    font-weight: bold;
    color: #28a745;
    margin: 10px 0;
}

.details {
    margin: 15px 0;
    padding: 10px 0;
    border-top: 1px solid #e0e0e0;
    border-bottom: 1px solid #e0e0e0;
}

.detail-item {
    display: flex;
    justify-content: space-between;
    margin: 8px 0;
}

.location {
    color: #666;
    font-size: 13px;
    margin-top: 8px;
    display: flex;
    align-items: center;
    gap: 5px;
}

.amenities {
    margin: 15px 0;
    flex: 1;
}

.amenity-tag {
    display: inline-block;
    background: #f0f0f0;
    padding: 4px 10px;
    border-radius: 15px;
    font-size: 11px;
    margin: 3px;
}

.status {
    display: inline-block;
    padding: 5px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.status-available {
    background: #d4edda;
    color: #155724;
}

.availability-note {
    font-size: 11px;
    color: #666;
    margin-top: 5px;
}

.card-actions {
    display: flex;
    gap: 10px;
    margin-top: 15px;
    padding-top: 15px;
    border-top: 1px solid #e0e0e0;
}

.book-btn {
    flex: 1;
    padding: 10px;
    background: #28a745;
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s;
    text-align: center;
    text-decoration: none;
    display: inline-block;
}

.book-btn:hover {
    background: #218838;
    transform: translateY(-2px);
}

.no-data {
    text-align: center;
    padding: 50px;
    background: white;
    border-radius: 15px;
    grid-column: 1 / -1;
}

.partner-badge {
    background: #ff9800;
    color: white;
    font-size: 10px;
    padding: 2px 6px;
    border-radius: 10px;
    margin-left: 8px;
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
    
    .room-grid {
        grid-template-columns: 1fr;
    }
    
    .search-bar {
        flex-direction: column;
    }
    
    .filter-grid {
        grid-template-columns: 1fr;
    }
    
    .results-summary {
        flex-direction: column;
        text-align: center;
    }
    
    .page-title h1 {
        font-size: 24px;
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
        <a href="ViewRoom.jsp" class="active">🛏️ View Rooms</a>
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
    <div class="page-title">
        <h1>🏨 Find Your Perfect Stay</h1>
        <p>Search and filter rooms by name, location, price, and more</p>
    </div>

    <!-- Search and Filter Section -->
    <div class="search-filter-section">
        <form method="get" action="ViewRoom.jsp" id="searchForm">
            <div class="search-bar">
                <input type="text" name="search" class="search-input" 
                       placeholder="🔍 Search by hotel name, room number, or location..." 
                       value="<%= searchQuery %>">
                <button type="submit" class="search-btn">Search</button>
                <button type="button" class="search-btn reset-btn" onclick="resetFilters()">Reset</button>
            </div>
            
            <div class="filter-toggle" onclick="toggleFilters()">
                <span>🔧</span> Advanced Filters
                <span id="filterArrow">▼</span>
            </div>
            
            <div id="filterPanel" class="filter-panel">
                <div class="filter-grid">
                    <div class="filter-group">
                        <label>💰 Price Range</label>
                        <select name="price" id="priceFilter">
                            <option value="">All Prices</option>
                            <option value="0-2000">Under ₹2000</option>
                            <option value="2000-5000">₹2000 - ₹5000</option>
                            <option value="5000-10000">₹5000 - ₹10000</option>
                            <option value="10000-999999">₹10000+</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label>🏨 Room Type</label>
                        <select name="type" id="typeFilter">
                            <option value="">All Types</option>
                            <option value="Single">Single</option>
                            <option value="Double">Double</option>
                            <option value="Deluxe">Deluxe</option>
                            <option value="Suite">Suite</option>
                            <option value="Presidential">Presidential</option>
                            <option value="Villa">Villa</option>
                            <option value="Duplex">Duplex</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label>📊 Sort By</label>
                        <select name="sort" id="sortFilter" onchange="this.form.submit()">
                            <option value="">Default</option>
                            <option value="price_asc">Price: Low to High</option>
                            <option value="price_desc">Price: High to Low</option>
                            <option value="name_asc">Name: A to Z</option>
                            <option value="name_desc">Name: Z to A</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="apply-filter-btn">Apply Filters</button>
            </div>
        </form>
    </div>

    <%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    List<Map<String, Object>> allRooms = new ArrayList<Map<String, Object>>();
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        
        // Main hotel rooms
        String mainSql = "SELECT roomno, roomtype, bedtype, price, capacity, amenities, image_url FROM room";
        ps = con.prepareStatement(mainSql);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> room = new HashMap<String, Object>();
            room.put("roomno", rs.getString("roomno"));
            room.put("roomtype", rs.getString("roomtype"));
            room.put("bedtype", rs.getString("bedtype"));
            room.put("price", rs.getDouble("price"));
            room.put("capacity", rs.getInt("capacity"));
            room.put("amenities", rs.getString("amenities"));
            room.put("image_url", rs.getString("image_url"));
            room.put("source", "main");
            room.put("hotel_name", "Main Hotel");
            room.put("display_name", "Room " + rs.getString("roomno"));
            allRooms.add(room);
        }
        rs.close();
        ps.close();
        
        // Partner hotel rooms
        String partnerSql = 
            "SELECT ph.hotel_id, ph.hotel_name, ph.hotel_location, " +
            "pr.room_id, pr.room_number, pr.room_type, pr.bed_type, pr.price, pr.capacity, pr.amenities, pr.image_url " +
            "FROM partner_hotels ph " +
            "JOIN partner_rooms pr ON ph.hotel_id = pr.hotel_id " +
            "WHERE ph.status = 'Approved'";
        
        ps = con.prepareStatement(partnerSql);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> room = new HashMap<String, Object>();
            room.put("room_id", rs.getInt("room_id"));
            room.put("roomno", rs.getString("room_number"));
            room.put("roomtype", rs.getString("room_type"));
            room.put("bedtype", rs.getString("bed_type"));
            room.put("price", rs.getDouble("price"));
            room.put("capacity", rs.getInt("capacity"));
            room.put("amenities", rs.getString("amenities"));
            room.put("image_url", rs.getString("image_url"));
            room.put("source", "partner");
            room.put("hotel_name", rs.getString("hotel_name"));
            room.put("hotel_location", rs.getString("hotel_location"));
            room.put("display_name", rs.getString("hotel_name") + " - " + rs.getString("room_number"));
            allRooms.add(room);
        }
        rs.close();
        ps.close();
        
        int totalResults = allRooms.size();
    %>
    
    <!-- Results Summary -->
    <div class="results-summary">
        <div class="results-count">
            Found <span class="results-highlight"><%= totalResults %></span> rooms
        </div>
        <div class="sort-options">
            <label>Sort by: </label>
            <select class="sort-dropdown" onchange="window.location.href=this.value">
                <option value="ViewRoom.jsp?sort=">Default</option>
                <option value="ViewRoom.jsp?sort=price_asc">Price: Low to High</option>
                <option value="ViewRoom.jsp?sort=price_desc">Price: High to Low</option>
                <option value="ViewRoom.jsp?sort=name_asc">Name: A to Z</option>
                <option value="ViewRoom.jsp?sort=name_desc">Name: Z to A</option>
            </select>
        </div>
    </div>
    
    <div class="room-grid">
    <%
        if (allRooms.isEmpty()) {
    %>
        <div class="no-data">
            <h3>🔍 No rooms found</h3>
            <p>Try adjusting your search or filter criteria</p>
            <button onclick="resetFilters()" class="book-btn" style="margin-top: 15px; display: inline-block; width: auto; padding: 10px 25px;">Clear Filters</button>
        </div>
    <%
        } else {
            for (Map<String, Object> room : allRooms) {
                String roomNo = (String) room.get("roomno");
                String roomTypeName = (String) room.get("roomtype");
                String bedType = (String) room.get("bedtype");
                double price = (Double) room.get("price");
                int capacity = (Integer) room.get("capacity");
                String amenities = (String) room.get("amenities");
                String imageUrl = (String) room.get("image_url");
                String source = (String) room.get("source");
                String hotelName = (String) room.get("hotel_name");
                String hotelLocation = (String) room.get("hotel_location");
                String displayName = (String) room.get("display_name");
                
                if (imageUrl == null || imageUrl.isEmpty()) {
                    imageUrl = "https://via.placeholder.com/350x220?text=No+Image";
                } else {
                    imageUrl = request.getContextPath() + "/" + imageUrl;
                }
                
                String bookUrl = "BookRoom.jsp?roomno=" + roomNo + "&type=" + source;
                String detailUrl = "RoomDetails.jsp?roomno=" + roomNo + "&type=" + source;
                
                if ("partner".equals(source)) {
                    bookUrl += "&hotelId=" + room.get("room_id") + "&hotelName=" + hotelName;
                    detailUrl += "&hotelId=" + room.get("room_id") + "&hotelName=" + hotelName;
                }
    %>
        <div class="room-card-link" onclick="window.location.href='<%= detailUrl %>'">
            <div class="room-card">
                <div class="image-container">
                    <% if ("partner".equals(source)) { %>
                        <span class="hotel-badge">🏨 <%= hotelName %></span>
                    <% } %>
                    <img src="<%= imageUrl %>" alt="<%= displayName %>" class="room-image" onerror="this.src='https://via.placeholder.com/350x220?text=Image+Not+Found'">
                </div>
                <div class="room-info">
                    <div class="room-header">
                        <span class="room-number">
                            <%= displayName %>
                            <% if ("partner".equals(source)) { %>
                                <span class="partner-badge">Partner</span>
                            <% } %>
                        </span>
                        <span class="room-type"><%= roomTypeName %></span>
                    </div>
                    <% if ("partner".equals(source) && hotelLocation != null) { %>
                        <div class="location">📍 <%= hotelLocation %></div>
                    <% } %>
                    <div class="price">₹<%= String.format("%.2f", price) %> <small>/ night</small></div>
                    <div class="details">
                        <div class="detail-item">
                            <span>🛏️ Bed Type:</span>
                            <span><strong><%= bedType %></strong></span>
                        </div>
                        <div class="detail-item">
                            <span>👥 Capacity:</span>
                            <span><strong><%= capacity %> persons</strong></span>
                        </div>
                    </div>
                    <div class="amenities">
                        <strong>Amenities:</strong><br>
                        <% 
                        if (amenities != null && !amenities.isEmpty()) {
                            String[] amenityList = amenities.split(",");
                            int count = 0;
                            for (String amenity : amenityList) {
                                if (count < 3) {
                        %>
                            <span class="amenity-tag">✓ <%= amenity.trim() %></span>
                        <%
                                    count++;
                                }
                            }
                            if (amenityList.length > 3) { %>
                                <span class="amenity-tag">+<%= (amenityList.length - 3) %> more</span>
                        <%   }
                        } else { %>
                            <span style="color:#999;">No amenities listed</span>
                        <% } %>
                    </div>
                    
                    <!-- Status - Always shows available -->
                    <div style="margin: 15px 0;">
                        <span class="status status-available">
                            ✅ Available for Booking
                        </span>
                        <div class="availability-note">
                            💡 Select dates to check availability
                        </div>
                    </div>
                    
                    <div class="card-actions" onclick="event.stopPropagation()">
                        <a href="<%= bookUrl %>" class="book-btn">📖 Book Now</a>
                    </div>
                </div>
            </div>
        </div>
    <%
            }
        }
    %>
    </div>
    
    <%
    } catch (Exception e) {
        e.printStackTrace();
    %>
        <div class="room-grid">
            <div class="no-data">
                <h3>⚠️ Error Loading Rooms</h3>
                <p><%= e.getMessage() %></p>
            </div>
        </div>
    <%
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e){}
        try { if (ps != null) ps.close(); } catch(Exception e){}
        try { if (con != null) con.close(); } catch(Exception e){}
    }
    %>
</div>

<script>
function toggleFilters() {
    var panel = document.getElementById('filterPanel');
    var arrow = document.getElementById('filterArrow');
    panel.classList.toggle('show');
    if (panel.classList.contains('show')) {
        arrow.innerHTML = '▲';
    } else {
        arrow.innerHTML = '▼';
    }
}

function resetFilters() {
    window.location.href = 'ViewRoom.jsp';
}
</script>

</body>
</html>