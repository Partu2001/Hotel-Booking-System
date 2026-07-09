<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    String username = (String) session.getAttribute("username");
    boolean isLoggedIn = (username != null);
    
    String roomNo = request.getParameter("roomno");
    String roomType = request.getParameter("type");
    String hotelIdParam = request.getParameter("hotelId");
    String hotelName = request.getParameter("hotelName");
    
    if (roomNo == null || roomNo.isEmpty()) {
        response.sendRedirect("ViewRoom.jsp");
        return;
    }
    
    boolean isPartnerRoom = "partner".equals(roomType);
    
    // Fetch room details
    String roomTypeName = "";
    String bedType = "";
    double price = 0;
    int capacity = 0;
    String amenities = "";
    String status = "";
    String imageUrl = "";
    String description = "";
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    // List of images for the room
    List<String> roomImages = new ArrayList<>();
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        
        if (isPartnerRoom && hotelIdParam != null) {
            // Get partner room details
            ps = con.prepareStatement("SELECT * FROM partner_rooms WHERE room_number = ? AND room_id = ?");
            ps.setString(1, roomNo);
            ps.setInt(2, Integer.parseInt(hotelIdParam));
            rs = ps.executeQuery();
            
            if (rs.next()) {
                roomTypeName = rs.getString("room_type");
                bedType = rs.getString("bed_type");
                price = rs.getDouble("price");
                capacity = rs.getInt("capacity");
                amenities = rs.getString("amenities");
                status = rs.getString("status");
                imageUrl = rs.getString("image_url");
                
                description = "Experience comfort and luxury at " + hotelName + ". " +
                              "This " + roomTypeName + " room features a " + bedType + " with " + capacity + " person capacity. " +
                              "Enjoy modern amenities and excellent service during your stay.";
            }
        } else {
            // Get main hotel room details
            ps = con.prepareStatement("SELECT * FROM room WHERE roomno = ?");
            ps.setString(1, roomNo);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                roomTypeName = rs.getString("roomtype");
                bedType = rs.getString("bedtype");
                price = rs.getDouble("price");
                capacity = rs.getInt("capacity");
                amenities = rs.getString("amenities");
                status = rs.getString("status");
                imageUrl = rs.getString("image_url");
                
                if (roomTypeName.equalsIgnoreCase("Single")) {
                    description = "Perfect for solo travelers, our Single rooms offer comfort and convenience with modern amenities. " +
                                  "Enjoy a peaceful stay with all essential facilities including air conditioning, high-speed WiFi, " +
                                  "and a comfortable work desk.";
                } else if (roomTypeName.equalsIgnoreCase("Double")) {
                    description = "Ideal for couples or business partners, our Double rooms provide spacious comfort with a comfortable double bed. " +
                                  "The room includes air conditioning, flat-screen TV, minibar, and an en-suite bathroom.";
                } else if (roomTypeName.equalsIgnoreCase("Deluxe")) {
                    description = "Experience luxury in our Deluxe rooms, featuring premium furnishings and enhanced amenities. " +
                                  "Enjoy a king-size bed, separate sitting area, and luxury bathroom with rain shower.";
                } else if (roomTypeName.equalsIgnoreCase("Suite")) {
                    description = "Our Suites offer the ultimate in luxury accommodation with separate living and bedroom areas. " +
                                  "Features include a king-size bed, Jacuzzi, private balcony, and dining area.";
                } else {
                    description = "Experience comfort and luxury in our well-appointed room. Enjoy modern amenities, " +
                                  "spacious interiors, and attentive service.";
                }
            }
        }
        
        if (imageUrl != null && !imageUrl.isEmpty()) {
            roomImages.add(imageUrl);
        } else {
            roomImages.add("https://via.placeholder.com/800x500?text=Room+Image");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (ps != null) ps.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
    
    String[] amenitiesList = (amenities != null && !amenities.isEmpty()) ? amenities.split(",") : new String[0];
    String displayRoomTitle = isPartnerRoom ? (hotelName + " - Room " + roomNo) : ("Room " + roomNo + " - " + roomTypeName);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%= displayRoomTitle %> - Hotel Management</title>
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
}

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
    color: #333;
}

.nav-links a {
    color: #333;
    text-decoration: none;
    margin-left: 20px;
    padding: 8px 16px;
    border-radius: 8px;
    transition: all 0.3s;
}

.nav-links a:hover {
    background: #667eea;
    color: white;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.room-details-card {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 25px;
    overflow: hidden;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
}

.image-slider-container {
    position: relative;
    width: 100%;
    height: 500px;
    overflow: hidden;
    background: #000;
}

.slider-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.room-info-section {
    padding: 30px;
}

.room-title {
    font-size: 32px;
    color: #333;
    margin-bottom: 10px;
}

.hotel-name {
    font-size: 18px;
    color: #ff9800;
    margin-bottom: 10px;
}

.room-subtitle {
    font-size: 18px;
    color: #666;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 2px solid #f0f0f0;
}

.info-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin: 25px 0;
}

.info-card {
    background: #f8f9fa;
    border-radius: 15px;
    padding: 20px;
    text-align: center;
    transition: transform 0.3s;
}

.info-card:hover {
    transform: translateY(-5px);
}

.info-icon {
    font-size: 40px;
    margin-bottom: 10px;
}

.info-label {
    font-size: 14px;
    color: #666;
    margin-bottom: 5px;
}

.info-value {
    font-size: 22px;
    font-weight: bold;
    color: #333;
}

.description-section {
    margin: 30px 0;
}

.description-title {
    font-size: 20px;
    font-weight: 600;
    margin-bottom: 15px;
    color: #333;
}

.description-text {
    line-height: 1.8;
    color: #555;
    text-align: justify;
}

.amenities-section {
    margin: 30px 0;
    padding: 20px;
    background: #f8f9fa;
    border-radius: 15px;
}

.amenities-title {
    font-size: 20px;
    font-weight: 600;
    margin-bottom: 20px;
    color: #333;
}

.amenities-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 15px;
}

.amenity-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px;
    background: white;
    border-radius: 10px;
}

.booking-section {
    margin-top: 30px;
    padding-top: 20px;
    border-top: 2px solid #f0f0f0;
    text-align: center;
}

.book-now-btn {
    display: inline-block;
    padding: 15px 40px;
    background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    color: white;
    text-decoration: none;
    border-radius: 50px;
    font-size: 18px;
    font-weight: 600;
    transition: all 0.3s;
}

.book-now-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.2);
}

.back-btn {
    display: inline-block;
    margin-top: 15px;
    padding: 10px 25px;
    background: #6c757d;
    color: white;
    text-decoration: none;
    border-radius: 25px;
    transition: all 0.3s;
}

.back-btn:hover {
    background: #5a6268;
}

.status-badge {
    display: inline-block;
    padding: 5px 15px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 600;
    margin-left: 15px;
}

.status-available {
    background: #d4edda;
    color: #155724;
}

.status-booked {
    background: #f8d7da;
    color: #721c24;
}

@media (max-width: 768px) {
    .image-slider-container {
        height: 300px;
    }
    
    .room-title {
        font-size: 24px;
    }
    
    .info-grid {
        grid-template-columns: 1fr;
    }
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
        <% if (isLoggedIn) { %>
            <a href="MyBookings.jsp">My Bookings</a>
            <a href="LogoutServlet">Logout</a>
        <% } else { %>
            <a href="Login.jsp">Login</a>
            <a href="Register.jsp">Register</a>
        <% } %>
    </div>
</div>

<div class="container">
    <div class="room-details-card">
        <div class="image-slider-container">
            <img id="sliderImage" class="slider-image" src="" alt="Room Image">
        </div>
        
        <div class="room-info-section">
            <div class="room-title">
                <%= displayRoomTitle %>
                <span class="status-badge <%= status.equalsIgnoreCase("Available") ? "status-available" : "status-booked" %>">
                    <%= status %>
                </span>
            </div>
            <% if (isPartnerRoom && hotelName != null) { %>
                <div class="hotel-name">🏨 <%= hotelName %></div>
            <% } %>
            <div class="room-subtitle">
                <%= bedType %> Bed • <%= capacity %> Person Capacity
            </div>
            
            <div class="info-grid">
                <div class="info-card">
                    <div class="info-icon">🛏️</div>
                    <div class="info-label">Bed Type</div>
                    <div class="info-value"><%= bedType %></div>
                </div>
                <div class="info-card">
                    <div class="info-icon">👥</div>
                    <div class="info-label">Capacity</div>
                    <div class="info-value"><%= capacity %> Persons</div>
                </div>
                <div class="info-card">
                    <div class="info-icon">💰</div>
                    <div class="info-label">Price per Night</div>
                    <div class="info-value">₹<%= String.format("%,.2f", price) %></div>
                </div>
            </div>
            
            <div class="description-section">
                <div class="description-title">📖 Room Description</div>
                <div class="description-text">
                    <%= description %>
                </div>
            </div>
            
            <div class="amenities-section">
                <div class="amenities-title">✨ Room Amenities</div>
                <div class="amenities-grid">
                    <% if (amenitiesList.length > 0) {
                        for (String amenity : amenitiesList) { %>
                            <div class="amenity-item">
                                <span class="amenity-icon">✓</span>
                                <span class="amenity-name"><%= amenity.trim() %></span>
                            </div>
                    <%   }
                    } else { %>
                        <div class="amenity-item">No specific amenities listed</div>
                    <% } %>
                </div>
            </div>
            
            <div class="booking-section">
                <% if (isLoggedIn && status.equalsIgnoreCase("Available")) { 
                    String bookUrl = "BookRoom.jsp?roomno=" + roomNo;
                    if (isPartnerRoom) {
                        bookUrl += "&type=partner&hotelId=" + hotelIdParam + "&hotelName=" + hotelName;
                    }
                %>
                    <a href="<%= bookUrl %>" class="book-now-btn">📖 Book This Room Now</a>
                <% } else if (!isLoggedIn) { %>
                    <a href="Login.jsp" class="book-now-btn">🔐 Login to Book</a>
                <% } else if (status.equalsIgnoreCase("Booked")) { %>
                    <div style="text-align: center;">
                        <p style="color: #dc3545; margin-bottom: 15px;">⚠️ This room is currently booked for some dates.</p>
                        <a href="BookRoom.jsp?roomno=<%= roomNo %>" class="book-now-btn">📅 Check Other Dates</a>
                    </div>
                <% } %>
                <div>
                    <a href="ViewRoom.jsp" class="back-btn">← Back to Rooms</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Simple image slider
let roomImages = [];
<%
    StringBuilder imagesArray = new StringBuilder();
    for (int i = 0; i < roomImages.size(); i++) {
        if (i > 0) imagesArray.append(",");
        String img = roomImages.get(i);
        if (img != null && !img.isEmpty()) {
            if (!img.startsWith("http") && !img.startsWith("/")) {
                img = request.getContextPath() + "/" + img;
            }
        } else {
            img = "https://via.placeholder.com/800x500?text=Room+Image";
        }
        imagesArray.append("'").append(img).append("'");
    }
%>
roomImages = [<%= imagesArray.toString() %>];

if (roomImages.length > 0) {
    document.getElementById('sliderImage').src = roomImages[0];
}
</script>

</body>
</html>