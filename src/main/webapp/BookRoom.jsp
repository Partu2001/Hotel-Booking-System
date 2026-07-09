<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    // Get room number from URL parameter
    String selectedRoomNo = request.getParameter("roomno");
    String roomType = request.getParameter("type");
    String partnerHotelId = request.getParameter("hotelId");
    String partnerHotelName = request.getParameter("hotelName");
    boolean isPartnerRoom = "partner".equals(roomType);
    
    // Fetch room details
    String roomTypeName = "";
    String bedType = "";
    double roomPrice = 0;
    int capacity = 0;
    String existingBookings = "";
    String displayRoomTitle = "";
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    if (selectedRoomNo != null && !selectedRoomNo.isEmpty()) {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
            
            if (isPartnerRoom && partnerHotelId != null) {
                // Get partner room details
                ps = con.prepareStatement("SELECT room_type, bed_type, price, capacity FROM partner_rooms WHERE room_number = ? AND room_id = ?");
                ps.setString(1, selectedRoomNo);
                ps.setInt(2, Integer.parseInt(partnerHotelId));
                rs = ps.executeQuery();
                if (rs.next()) {
                    roomTypeName = rs.getString("room_type");
                    bedType = rs.getString("bed_type");
                    roomPrice = rs.getDouble("price");
                    capacity = rs.getInt("capacity");
                }
                rs.close();
                ps.close();
                
                displayRoomTitle = partnerHotelName + " - Room " + selectedRoomNo;
                
            } else {
                // Get main hotel room details
                ps = con.prepareStatement("SELECT roomno, roomtype, bedtype, price, capacity FROM room WHERE roomno = ?");
                ps.setString(1, selectedRoomNo);
                rs = ps.executeQuery();
                if (rs.next()) {
                    roomTypeName = rs.getString("roomtype");
                    bedType = rs.getString("bedtype");
                    roomPrice = rs.getDouble("price");
                    capacity = rs.getInt("capacity");
                }
                rs.close();
                ps.close();
                
                // Get existing bookings for display
                ps = con.prepareStatement(
                    "SELECT check_in, check_out FROM bookings WHERE roomno = ? AND status = 'Confirmed' ORDER BY check_in"
                );
                ps.setString(1, selectedRoomNo);
                rs = ps.executeQuery();
                StringBuilder bookings = new StringBuilder();
                while (rs.next()) {
                    if (bookings.length() > 0) bookings.append(", ");
                    bookings.append(rs.getString("check_in")).append(" to ").append(rs.getString("check_out"));
                }
                existingBookings = bookings.toString();
                rs.close();
                ps.close();
                
                displayRoomTitle = "Room " + selectedRoomNo;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Book Room - Hotel Management</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Poppins', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
    max-width: 1000px;
    margin: 0 auto;
}

.booking-card {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 30px;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

h2 {
    color: #333;
    margin-bottom: 20px;
}

.room-info-card {
    background: #e8f0fe;
    border-radius: 15px;
    padding: 20px;
    margin-bottom: 25px;
}

.room-info-title {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 15px;
    color: #1e3c72;
}

.room-info-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
}

.room-info-item {
    display: flex;
    align-items: center;
    gap: 10px;
}

.room-info-label {
    font-weight: 600;
    color: #666;
}

.room-info-value {
    color: #333;
    font-weight: 500;
}

.hotel-name-badge {
    background: #ff9800;
    color: white;
    padding: 5px 12px;
    border-radius: 20px;
    font-size: 12px;
    display: inline-block;
    margin-left: 10px;
}

.existing-bookings {
    background: #fff3cd;
    border: 1px solid #ffecb5;
    border-radius: 10px;
    padding: 15px;
    margin-bottom: 20px;
}

.existing-bookings-title {
    font-weight: 600;
    color: #856404;
    margin-bottom: 8px;
}

.existing-bookings-dates {
    color: #856404;
    font-size: 14px;
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

select, input {
    width: 100%;
    padding: 12px;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    font-size: 16px;
    outline: none;
    background: #f8f9fa;
}

.amenities-section {
    background: #f8f9fa;
    border-radius: 15px;
    padding: 20px;
    margin: 20px 0;
}

.amenities-title {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 15px;
}

.amenities-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 15px;
}

.amenity-item {
    background: white;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    padding: 12px;
    display: flex;
    justify-content: space-between;
    cursor: pointer;
    transition: all 0.3s;
}

.amenity-item.selected {
    border-color: #28a745;
    background: #e8f5e9;
}

.amenity-check {
    width: 24px;
    height: 24px;
    border: 2px solid #ddd;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.amenity-item.selected .amenity-check {
    background: #28a745;
    border-color: #28a745;
    color: white;
}

.price-summary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 15px;
    padding: 20px;
    color: white;
}

.price-row {
    display: flex;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px solid rgba(255,255,255,0.2);
}

.price-row.total {
    font-size: 20px;
    font-weight: bold;
    border-bottom: none;
    margin-top: 10px;
    padding-top: 15px;
    border-top: 2px solid rgba(255,255,255,0.3);
}

.book-btn {
    width: 100%;
    padding: 15px;
    background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 18px;
    font-weight: 600;
    cursor: pointer;
    margin-top: 20px;
}

.book-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.2);
}

.date-warning {
    background: #fff3cd;
    border: 1px solid #ffecb5;
    color: #856404;
    padding: 10px;
    border-radius: 8px;
    margin-top: 10px;
    font-size: 13px;
    display: none;
}

.loading-indicator {
    text-align: center;
    padding: 10px;
    color: #666;
    font-size: 13px;
    display: none;
}

.back-link {
    display: inline-block;
    margin-top: 20px;
    color: #667eea;
    text-decoration: none;
}

.back-link:hover {
    text-decoration: underline;
}

.note {
    background: #e8f0fe;
    padding: 10px;
    border-radius: 8px;
    font-size: 12px;
    color: #666;
    margin-top: 15px;
    text-align: center;
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
    <div class="booking-card">
        <h2>📅 Book Your Room</h2>
        
        <% if (selectedRoomNo == null) { %>
            <div style="text-align: center; padding: 40px;">
                <h3>❌ Room not selected</h3>
                <p>Please select a room to book.</p>
                <a href="ViewRoom.jsp" class="back-link">← Back to Rooms</a>
            </div>
        <% } else { %>
        
        <form id="bookingForm" action="BookRoom" method="post" onsubmit="return validateAndSubmit()">
            <input type="hidden" name="roomno" id="roomNo" value="<%= selectedRoomNo %>">
            <input type="hidden" name="type" value="<%= roomType %>">
            <input type="hidden" name="hotelId" value="<%= partnerHotelId %>">
            <input type="hidden" name="hotelName" value="<%= partnerHotelName %>">
            
            <!-- Room Information Display -->
            <div class="room-info-card">
                <div class="room-info-title">
                    🏨 Selected Room Details
                    <% if (isPartnerRoom && partnerHotelName != null) { %>
                        <span class="hotel-name-badge"><%= partnerHotelName %></span>
                    <% } %>
                </div>
                <div class="room-info-grid">
                    <div class="room-info-item">
                        <span class="room-info-label">Room:</span>
                        <span class="room-info-value"><%= displayRoomTitle %></span>
                    </div>
                    <div class="room-info-item">
                        <span class="room-info-label">Room Type:</span>
                        <span class="room-info-value"><%= roomTypeName %></span>
                    </div>
                    <div class="room-info-item">
                        <span class="room-info-label">Bed Type:</span>
                        <span class="room-info-value"><%= bedType %></span>
                    </div>
                    <div class="room-info-item">
                        <span class="room-info-label">Capacity:</span>
                        <span class="room-info-value"><%= capacity %> persons</span>
                    </div>
                    <div class="room-info-item">
                        <span class="room-info-label">Price per Night:</span>
                        <span class="room-info-value">₹<%= String.format("%.2f", roomPrice) %></span>
                    </div>
                </div>
            </div>
            
            <% if (existingBookings != null && !existingBookings.isEmpty()) { %>
                <div class="existing-bookings">
                    <div class="existing-bookings-title">📅 Already Booked Dates:</div>
                    <div class="existing-bookings-dates"><%= existingBookings %></div>
                    <div style="font-size: 12px; margin-top: 8px;">💡 You can book this room for other available dates.</div>
                </div>
            <% } %>
            
            <div class="form-group">
                <label>Check-in Date</label>
                <input type="date" name="checkin" id="checkin" required onchange="validateDates()">
                <div id="checkinWarning" class="date-warning"></div>
            </div>
            
            <div class="form-group">
                <label>Check-out Date</label>
                <input type="date" name="checkout" id="checkout" required onchange="validateDates()">
                <div id="checkoutWarning" class="date-warning"></div>
            </div>
            
            <div id="loadingIndicator" class="loading-indicator">⏳ Loading blocked dates...</div>
            
            <!-- Extra Amenities Section -->
            <div class="amenities-section">
                <div class="amenities-title">✨ Select Extra Amenities (Optional)</div>
                <div class="amenities-grid" id="amenitiesGrid">
                    <%
                        if (isPartnerRoom && partnerHotelId != null) {
                            // Get partner room extra amenities
                            try {
                                con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
                                ps = con.prepareStatement("SELECT amenity_name, extra_charge FROM partner_room_amenities WHERE room_id = ?");
                                ps.setInt(1, Integer.parseInt(partnerHotelId));
                                rs = ps.executeQuery();
                                boolean hasAmenities = false;
                                while (rs.next()) {
                                    hasAmenities = true;
                                    String amenityName = rs.getString("amenity_name");
                                    double extraCharge = rs.getDouble("extra_charge");
                    %>
                    <div class="amenity-item" data-name="<%= amenityName %>" data-price="<%= extraCharge %>" onclick="toggleAmenity(this)">
                        <div>
                            <div><%= amenityName %></div>
                            <small>+₹<%= String.format("%.0f", extraCharge) %>/night</small>
                        </div>
                        <div class="amenity-check">✓</div>
                    </div>
                    <%
                                }
                                if (!hasAmenities) {
                    %>
                    <div style="grid-column: 1/-1; text-align: center; color: #666; padding: 20px;">
                        ✨ No extra amenities available for this room
                    </div>
                    <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        } else {
                            // Get main hotel room amenities
                            try {
                                con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
                                ps = con.prepareStatement("SELECT amenity_name, extra_charge FROM room_amenities WHERE roomno = ?");
                                ps.setString(1, selectedRoomNo);
                                rs = ps.executeQuery();
                                boolean hasAmenities = false;
                                while (rs.next()) {
                                    hasAmenities = true;
                                    String amenityName = rs.getString("amenity_name");
                                    double extraCharge = rs.getDouble("extra_charge");
                    %>
                    <div class="amenity-item" data-name="<%= amenityName %>" data-price="<%= extraCharge %>" onclick="toggleAmenity(this)">
                        <div>
                            <div><%= amenityName %></div>
                            <small>+₹<%= String.format("%.0f", extraCharge) %>/night</small>
                        </div>
                        <div class="amenity-check">✓</div>
                    </div>
                    <%
                                }
                                if (!hasAmenities) {
                    %>
                    <div style="grid-column: 1/-1; text-align: center; color: #666; padding: 20px;">
                        ✨ No extra amenities available for this room
                    </div>
                    <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    %>
                </div>
            </div>
            
            <div class="price-summary" id="priceSummary">
                <div class="price-row">
                    <span>Room Price per Night:</span>
                    <span id="roomPrice">₹0</span>
                </div>
                <div class="price-row">
                    <span>Number of Nights:</span>
                    <span id="nights">0</span>
                </div>
                <div class="price-row">
                    <span>Room Total:</span>
                    <span id="roomTotal">₹0</span>
                </div>
                <div class="price-row" id="extraRow" style="display:none;">
                    <span>Extra Amenities Total:</span>
                    <span id="extraTotal">₹0</span>
                </div>
                <div class="price-row total">
                    <span>Total Amount:</span>
                    <span id="grandTotal">₹0</span>
                </div>
            </div>
            
            <input type="hidden" name="totalAmount" id="hiddenTotalAmount" value="0">
            <input type="hidden" name="roomTotal" id="hiddenRoomTotal" value="0">
            <input type="hidden" name="extraTotal" id="hiddenExtraTotal" value="0">
            <input type="hidden" name="amenities" id="hiddenAmenities" value="">
            
            <button type="submit" class="book-btn">📖 Confirm Booking</button>
            <a href="ViewRoom.jsp" class="back-link">← Back to Rooms</a>
            <div class="note">
                💡 Note: This room may be booked for other dates. Please select dates that don't conflict with existing bookings.
            </div>
        </form>
        
        <% } %>
    </div>
</div>

<script>
let selectedAmenities = [];
let currentRoomPrice = <%= roomPrice %>;
let currentNights = 0;
let currentRoomTotal = 0;
let currentExtraTotal = 0;
let currentGrandTotal = 0;
let blockedDates = {};

// Initialize room price display
document.getElementById('roomPrice').innerHTML = '₹' + currentRoomPrice.toFixed(2);

function toggleAmenity(element) {
    element.classList.toggle('selected');
    updateAmenitiesList();
    calculateTotal();
}

function updateAmenitiesList() {
    selectedAmenities = [];
    document.querySelectorAll('.amenity-item.selected').forEach(item => {
        selectedAmenities.push({
            name: item.getAttribute('data-name'),
            price: parseFloat(item.getAttribute('data-price'))
        });
    });
}

function loadBlockedDates() {
    const roomNo = document.getElementById('roomNo').value;
    const roomType = '<%= roomType %>';
    const hotelId = '<%= partnerHotelId %>';
    
    if (!roomNo) return;
    
    document.getElementById('loadingIndicator').style.display = 'block';
    document.getElementById('checkin').disabled = true;
    document.getElementById('checkout').disabled = true;
    
    let url = 'GetBlockedDates?roomno=' + encodeURIComponent(roomNo);
    if (roomType === 'partner' && hotelId) {
        url += '&type=partner&hotelId=' + encodeURIComponent(hotelId);
    }
    
    fetch(url)
        .then(response => response.text())
        .then(text => {
            blockedDates = {};
            if (text.trim().length > 0) {
                const dates = text.split(',');
                for (let i = 0; i < dates.length; i++) {
                    if (dates[i].trim().length > 0) {
                        blockedDates[dates[i].trim()] = true;
                    }
                }
            }
            console.log('Blocked dates:', Object.keys(blockedDates));
            enableDatepickers();
        })
        .catch(error => {
            console.error('Error loading blocked dates:', error);
            blockedDates = {};
            enableDatepickers();
        })
        .finally(() => {
            document.getElementById('loadingIndicator').style.display = 'none';
        });
}

function enableDatepickers() {
    document.getElementById('checkin').disabled = false;
    document.getElementById('checkout').disabled = false;
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('checkin').min = today;
}

function validateDates() {
    const checkin = document.getElementById('checkin');
    const checkout = document.getElementById('checkout');
    const checkinDate = new Date(checkin.value);
    const checkoutDate = new Date(checkout.value);
    const today = new Date();
    today.setHours(0,0,0,0);
    
    let isValid = true;
    
    document.getElementById('checkinWarning').style.display = 'none';
    document.getElementById('checkoutWarning').style.display = 'none';
    
    if (checkin.value && blockedDates[checkin.value]) {
        document.getElementById('checkinWarning').innerHTML = '⚠️ This date is already booked! Please select another date.';
        document.getElementById('checkinWarning').style.display = 'block';
        isValid = false;
    }
    
    if (checkout.value && blockedDates[checkout.value]) {
        document.getElementById('checkoutWarning').innerHTML = '⚠️ This date is already booked! Please select another date.';
        document.getElementById('checkoutWarning').style.display = 'block';
        isValid = false;
    }
    
    if (checkin.value && checkout.value && !blockedDates[checkin.value] && !blockedDates[checkout.value]) {
        let currentDate = new Date(checkin.value);
        let endDate = new Date(checkout.value);
        let blockedDateFound = null;
        
        while (currentDate < endDate) {
            const dateStr = currentDate.toISOString().split('T')[0];
            if (blockedDates[dateStr]) {
                blockedDateFound = dateStr;
                break;
            }
            currentDate.setDate(currentDate.getDate() + 1);
        }
        
        if (blockedDateFound) {
            document.getElementById('checkinWarning').innerHTML = `⚠️ The date range includes a booked date (${blockedDateFound}). Please select different dates.`;
            document.getElementById('checkinWarning').style.display = 'block';
            isValid = false;
        }
    }
    
    if (checkin.value && checkinDate < today) {
        alert('❌ Check-in date cannot be in the past');
        isValid = false;
    }
    
    if (checkin.value && checkout.value && checkoutDate <= checkinDate) {
        alert('❌ Check-out date must be after check-in date');
        isValid = false;
    }
    
    if (isValid) {
        calculateTotal();
    } else {
        document.getElementById('nights').innerHTML = '0';
        document.getElementById('roomTotal').innerHTML = '₹0';
        document.getElementById('grandTotal').innerHTML = '₹0';
        document.getElementById('extraRow').style.display = 'none';
    }
    
    return isValid;
}

function calculateTotal() {
    const checkin = document.getElementById('checkin').value;
    const checkout = document.getElementById('checkout').value;
    
    if (checkin && checkout) {
        const checkinDate = new Date(checkin);
        const checkoutDate = new Date(checkout);
        const diffTime = Math.abs(checkoutDate - checkinDate);
        currentNights = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        if (currentNights === 0) currentNights = 1;
        
        currentRoomTotal = currentRoomPrice * currentNights;
        
        currentExtraTotal = 0;
        selectedAmenities.forEach(amenity => {
            currentExtraTotal += amenity.price * currentNights;
        });
        
        currentGrandTotal = currentRoomTotal + currentExtraTotal;
        
        document.getElementById('nights').innerHTML = currentNights;
        document.getElementById('roomTotal').innerHTML = '₹' + currentRoomTotal.toFixed(2);
        
        if (currentExtraTotal > 0) {
            document.getElementById('extraRow').style.display = 'flex';
            document.getElementById('extraTotal').innerHTML = '₹' + currentExtraTotal.toFixed(2);
        } else {
            document.getElementById('extraRow').style.display = 'none';
        }
        document.getElementById('grandTotal').innerHTML = '₹' + currentGrandTotal.toFixed(2);
        
        document.getElementById('hiddenTotalAmount').value = currentGrandTotal;
        document.getElementById('hiddenRoomTotal').value = currentRoomTotal;
        document.getElementById('hiddenExtraTotal').value = currentExtraTotal;
    }
}

function validateAndSubmit() {
    if (!validateDates()) {
        return false;
    }
    
    const checkin = document.getElementById('checkin');
    const checkout = document.getElementById('checkout');
    
    if (!checkin.value) {
        alert('❌ Please select check-in date');
        return false;
    }
    if (!checkout.value) {
        alert('❌ Please select check-out date');
        return false;
    }
    
    calculateTotal();
    
    let amenitiesText = '';
    if (selectedAmenities.length > 0) {
        amenitiesText = '\n✨ Extra Amenities:\n';
        selectedAmenities.forEach(a => {
            amenitiesText += `   - ${a.name} (+₹${a.price}/night)\n`;
        });
        amenitiesText += `\n💰 Extra Amenities Total: ₹${currentExtraTotal.toFixed(2)}`;
    } else {
        amenitiesText = '\n✨ Extra Amenities: None\n';
    }
    
    const roomDisplay = '<%= isPartnerRoom && partnerHotelName != null ? partnerHotelName + " - Room " + selectedRoomNo : "Room " + selectedRoomNo %>';
    
    const confirmMessage = 
        '📋 CONFIRM YOUR BOOKING\n\n' +
        '🏨 ' + roomDisplay + '\n' +
        '📅 Check-in: ' + checkin.value + '\n' +
        '📅 Check-out: ' + checkout.value + '\n' +
        '🌙 Nights: ' + currentNights + '\n' +
        '💰 Room Price per Night: ₹' + currentRoomPrice.toFixed(2) + '\n' +
        '💰 Room Total: ₹' + currentRoomTotal.toFixed(2) + '\n' +
        amenitiesText + '\n' +
        '💵 GRAND TOTAL: ₹' + currentGrandTotal.toFixed(2) + '\n\n' +
        'Click OK to confirm your booking.';
    
    if (confirm(confirmMessage)) {
        document.getElementById('hiddenTotalAmount').value = currentGrandTotal;
        document.getElementById('hiddenRoomTotal').value = currentRoomTotal;
        document.getElementById('hiddenExtraTotal').value = currentExtraTotal;
        document.getElementById('hiddenAmenities').value = JSON.stringify(selectedAmenities);
        return true;
    }
    
    return false;
}

// Load blocked dates on page load
loadBlockedDates();

// Event listeners
document.getElementById('checkin').addEventListener('change', validateDates);
document.getElementById('checkout').addEventListener('change', validateDates);
</script>

</body>
</html>