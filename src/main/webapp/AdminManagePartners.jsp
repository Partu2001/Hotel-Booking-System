<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    HttpSession adminSession = request.getSession(false);
    if (adminSession == null || adminSession.getAttribute("admin") == null) {
        response.sendRedirect("AdminLogin.jsp");
        return;
    }
    
    String adminName = (String) adminSession.getAttribute("admin");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Hotel Partners - Admin</title>
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

.container {
    max-width: 1400px;
    margin: 0 auto;
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

.filter-bar {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 15px;
    padding: 15px 20px;
    margin-bottom: 25px;
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
    align-items: center;
}

.filter-bar select {
    padding: 10px 15px;
    border: 1px solid #ddd;
    border-radius: 10px;
    font-size: 14px;
    outline: none;
    background: white;
}

.filter-bar button {
    padding: 10px 20px;
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.3s;
}

.filter-bar button:hover {
    transform: translateY(-2px);
}

.partners-table-wrapper {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 20px;
    overflow-x: auto;
}

.partners-table {
    width: 100%;
    border-collapse: collapse;
}

.partners-table th,
.partners-table td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #e0e0e0;
}

.partners-table th {
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: white;
    font-weight: 600;
}

.partners-table tr:hover {
    background: #f8f9fa;
}

.status-pending {
    display: inline-block;
    padding: 5px 12px;
    background: #fff3cd;
    color: #856404;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.status-approved {
    display: inline-block;
    padding: 5px 12px;
    background: #d4edda;
    color: #155724;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.status-rejected {
    display: inline-block;
    padding: 5px 12px;
    background: #f8d7da;
    color: #721c24;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.approve-btn {
    background: #28a745;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 6px;
    cursor: pointer;
    margin-right: 8px;
    transition: all 0.3s;
    font-weight: 600;
}

.approve-btn:hover {
    background: #218838;
    transform: scale(1.02);
}

.reject-btn {
    background: #dc3545;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.3s;
    font-weight: 600;
}

.reject-btn:hover {
    background: #c82333;
    transform: scale(1.02);
}

.view-rooms-btn {
    background: #17a2b8;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 6px;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
    margin-right: 8px;
    transition: all 0.3s;
    font-weight: 600;
}

.view-rooms-btn:hover {
    background: #138496;
    transform: scale(1.02);
}

.no-data {
    text-align: center;
    padding: 50px;
    color: #666;
}

/* Modal Styles */
.modal {
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

.modal-content {
    background: white;
    border-radius: 20px;
    max-width: 600px;
    width: 90%;
    max-height: 80vh;
    overflow-y: auto;
    padding: 25px;
    animation: modalSlideIn 0.3s ease-out;
}

@keyframes modalSlideIn {
    from {
        opacity: 0;
        transform: translateY(-50px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.modal-header {
    font-size: 22px;
    font-weight: bold;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 2px solid #e0e0e0;
    color: #1e3c72;
}

.rooms-list {
    margin-top: 15px;
}

.room-item {
    padding: 12px;
    border-bottom: 1px solid #eee;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.room-item:hover {
    background: #f8f9fa;
}

.room-item strong {
    color: #1e3c72;
}

.close-modal {
    margin-top: 20px;
    padding: 10px 25px;
    background: #6c757d;
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s;
    width: 100%;
}

.close-modal:hover {
    background: #5a6268;
    transform: translateY(-2px);
}

@media (max-width: 768px) {
    .navbar {
        flex-direction: column;
        gap: 15px;
        text-align: center;
    }
    
    .partners-table th,
    .partners-table td {
        padding: 10px;
        font-size: 12px;
    }
    
    .filter-bar {
        flex-direction: column;
    }
    
    .filter-bar select,
    .filter-bar button {
        width: 100%;
    }
    
    .room-item {
        flex-direction: column;
        text-align: center;
        gap: 8px;
    }
}
</style>
</head>
<body>

<div class="container">
    <div class="navbar">
        <div class="logo">
            <h2>🏨 Hotel Management System</h2>
        </div>
        <a href="Admin.jsp" class="back-btn">← Back to Dashboard</a>
    </div>

    <div class="page-title">
        <h1>🏨 Hotel Partner Management</h1>
        <p>Approve or reject hotel partner requests and manage their hotels</p>
    </div>

    <%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    String statusFilter = request.getParameter("status");
    if (statusFilter == null || statusFilter.isEmpty()) statusFilter = "Pending";
    
    int pendingCount = 0;
    int approvedCount = 0;
    int rejectedCount = 0;
    int totalHotels = 0;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        
        Statement stmt = con.createStatement();
        rs = stmt.executeQuery("SELECT COUNT(*) FROM partner_hotels WHERE status = 'Pending'");
        if (rs.next()) pendingCount = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM partner_hotels WHERE status = 'Approved'");
        if (rs.next()) approvedCount = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM partner_hotels WHERE status = 'Rejected'");
        if (rs.next()) rejectedCount = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM partner_hotels");
        if (rs.next()) totalHotels = rs.getInt(1);
        rs.close();
        stmt.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
    %>

    <div class="stats-cards">
        <div class="stat-card">
            <div class="number"><%= totalHotels %></div>
            <div class="label">Total Hotels</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= pendingCount %></div>
            <div class="label">Pending Approval</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= approvedCount %></div>
            <div class="label">Approved Hotels</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= rejectedCount %></div>
            <div class="label">Rejected Hotels</div>
        </div>
    </div>

    <div class="filter-bar">
        <select id="statusFilter">
            <option value="Pending" <%= statusFilter.equals("Pending") ? "selected" : "" %>>Pending</option>
            <option value="Approved" <%= statusFilter.equals("Approved") ? "selected" : "" %>>Approved</option>
            <option value="Rejected" <%= statusFilter.equals("Rejected") ? "selected" : "" %>>Rejected</option>
            <option value="All" <%= statusFilter.equals("All") ? "selected" : "" %>>All Hotels</option>
        </select>
        <button onclick="filterByStatus()">Apply Filter</button>
    </div>

    <div class="partners-table-wrapper">
        <table class="partners-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Partner Username</th>
                    <th>Hotel Name</th>
                    <th>Location</th>
                    <th>Phone</th>
                    <th>Email</th>
                    <th>Request Date</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                try {
                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
                    
                    String sql = "SELECT * FROM partner_hotels";
                    if (!"All".equals(statusFilter)) {
                        sql += " WHERE status = ?";
                    }
                    sql += " ORDER BY created_date DESC";
                    
                    ps = con.prepareStatement(sql);
                    if (!"All".equals(statusFilter)) {
                        ps.setString(1, statusFilter);
                    }
                    rs = ps.executeQuery();
                    
                    boolean hasData = false;
                    while (rs.next()) {
                        hasData = true;
                        int hotelId = rs.getInt("hotel_id");
                        String partnerUsername = rs.getString("partner_username");
                        String hotelName = rs.getString("hotel_name");
                        String hotelLocation = rs.getString("hotel_location");
                        String hotelPhone = rs.getString("hotel_phone");
                        String hotelEmail = rs.getString("hotel_email");
                        
                        java.sql.Date createdDateSql = rs.getDate("created_date");
                        String createdDateStr = (createdDateSql != null) ? createdDateSql.toString() : "N/A";
                        
                        String status = rs.getString("status");
                        
                        String statusClass = "";
                        if ("Pending".equals(status)) statusClass = "status-pending";
                        else if ("Approved".equals(status)) statusClass = "status-approved";
                        else if ("Rejected".equals(status)) statusClass = "status-rejected";
                %>
                <tr>
                    <td><%= hotelId %></td>
                    <td><strong><%= partnerUsername %></strong></td>
                    <td><%= hotelName %></td>
                    <td><%= hotelLocation %></td>
                    <td><%= hotelPhone %></td>
                    <td><%= hotelEmail != null ? hotelEmail : "-" %></td>
                    <td><%= createdDateStr %></td>
                    <td><span class="<%= statusClass %>"><%= status %></span></td>
                    <td>
                        <button class="view-rooms-btn" onclick="viewHotelRooms(<%= hotelId %>, '<%= hotelName.replace("'", "\\'") %>')">📋 View Rooms</button>
                        <% if ("Pending".equals(status)) { %>
                            <button class="approve-btn" onclick="approveHotel(<%= hotelId %>, '<%= partnerUsername %>', '<%= hotelName.replace("'", "\\'") %>')">✅ Approve</button>
                            <button class="reject-btn" onclick="rejectHotel(<%= hotelId %>, '<%= partnerUsername %>', '<%= hotelName.replace("'", "\\'") %>')">❌ Reject</button>
                        <% } %>
                    </td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr>
                    <td colspan="9" class="no-data">No hotels found</td>
                </tr>
                <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                %>
                <tr>
                    <td colspan="9" class="no-data">Error: <%= e.getMessage() %></td>
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

<!-- View Rooms Modal -->
<div id="roomsModal" class="modal">
    <div class="modal-content">
        <div class="modal-header" id="modalTitle">🏨 Rooms</div>
        <div id="modalRoomsList" class="rooms-list">Loading...</div>
        <button class="close-modal" onclick="closeModal()">Close</button>
    </div>
</div>

<script>
function filterByStatus() {
    var status = document.getElementById('statusFilter').value;
    window.location.href = 'AdminManagePartners.jsp?status=' + status;
}

function approveHotel(hotelId, username, hotelName) {
    if (confirm('✅ Approve hotel "' + hotelName + '" for ' + username + '?')) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'ApprovePartner', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (xhr.status === 200) {
                var response = xhr.responseText;
                if (response.indexOf('SUCCESS') !== -1) {
                    alert('✅ Hotel approved successfully!');
                    location.reload();
                } else {
                    alert('❌ Error: ' + response);
                }
            } else {
                alert('❌ Server error: ' + xhr.status);
            }
        };
        xhr.onerror = function() {
            alert('❌ Network error occurred');
        };
        xhr.send('hotelId=' + hotelId + '&username=' + username + '&action=approve');
    }
}

function rejectHotel(hotelId, username, hotelName) {
    if (confirm('❌ Reject hotel "' + hotelName + '" for ' + username + '?')) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'ApprovePartner', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (xhr.status === 200) {
                var response = xhr.responseText;
                if (response.indexOf('SUCCESS') !== -1) {
                    alert('✅ Hotel request rejected successfully!');
                    location.reload();
                } else {
                    alert('❌ Error: ' + response);
                }
            } else {
                alert('❌ Server error: ' + xhr.status);
            }
        };
        xhr.onerror = function() {
            alert('❌ Network error occurred');
        };
        xhr.send('hotelId=' + hotelId + '&username=' + username + '&action=reject');
    }
}

function viewHotelRooms(hotelId, hotelName) {
    document.getElementById('modalTitle').innerHTML = '🏨 Rooms in ' + hotelName;
    document.getElementById('modalRoomsList').innerHTML = '<div style="text-align:center; padding:20px;">⏳ Loading rooms...</div>';
    document.getElementById('roomsModal').style.display = 'flex';
    
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'GetHotelRooms?hotelId=' + hotelId, true);
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                if (data.length > 0) {
                    var html = '';
                    for (var i = 0; i < data.length; i++) {
                        var room = data[i];
                        html += '<div class="room-item">' +
                                    '<span><strong>Room ' + room.room_number + '</strong> - ' + room.room_type + ' (' + room.bed_type + ')</span>' +
                                    '<span>₹' + parseFloat(room.price).toFixed(2) + '/night</span>' +
                                '</div>';
                    }
                    document.getElementById('modalRoomsList').innerHTML = html;
                } else {
                    document.getElementById('modalRoomsList').innerHTML = '<div style="text-align:center; padding:20px;">📭 No rooms added yet for this hotel.</div>';
                }
            } catch(e) {
                console.error('Parse error:', e);
                document.getElementById('modalRoomsList').innerHTML = '<div style="text-align:center; padding:20px; color:red;">❌ Error parsing room data</div>';
            }
        } else {
            document.getElementById('modalRoomsList').innerHTML = '<div style="text-align:center; padding:20px; color:red;">❌ Error loading rooms (Status: ' + xhr.status + ')</div>';
        }
    };
    xhr.onerror = function() {
        document.getElementById('modalRoomsList').innerHTML = '<div style="text-align:center; padding:20px; color:red;">❌ Network error</div>';
    };
    xhr.send();
}

function closeModal() {
    document.getElementById('roomsModal').style.display = 'none';
}

window.onclick = function(event) {
    var modal = document.getElementById('roomsModal');
    if (event.target == modal) {
        modal.style.display = 'none';
    }
}
</script>

</body>
</html>