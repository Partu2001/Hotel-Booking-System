<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    // Admin session check
    HttpSession adminSession = request.getSession(false);
    if (adminSession == null || adminSession.getAttribute("admin") == null) {
        response.sendRedirect("AdminLogin.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>View Bookings - Admin Panel</title>
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
    position: relative;
    overflow-x: hidden;
}

/* Animated background */
body::before {
    content: '';
    position: absolute;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255,255,255,0.08) 1px, transparent 1px);
    background-size: 40px 40px;
    animation: moveBackground 20s linear infinite;
    opacity: 0.3;
    pointer-events: none;
}

@keyframes moveBackground {
    0% { transform: translate(0, 0); }
    100% { transform: translate(40px, 40px); }
}

/* Floating shapes */
.floating-shapes {
    position: fixed;
    width: 100%;
    height: 100%;
    overflow: hidden;
    z-index: 0;
    pointer-events: none;
}

.shape {
    position: absolute;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 50%;
    animation: float 8s ease-in-out infinite;
}

.shape1 { width: 300px; height: 300px; top: -100px; right: -100px; animation-delay: 0s; }
.shape2 { width: 200px; height: 200px; bottom: -50px; left: -50px; animation-delay: 2s; }
.shape3 { width: 150px; height: 150px; top: 50%; left: 20%; animation-delay: 4s; }
.shape4 { width: 100px; height: 100px; bottom: 30%; right: 15%; animation-delay: 1s; }

@keyframes float {
    0%, 100% { transform: translateY(0) rotate(0deg); }
    50% { transform: translateY(-20px) rotate(5deg); }
}

.container {
    position: relative;
    z-index: 1;
    max-width: 1400px;
    margin: 0 auto;
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

.logo h2 { font-size: 24px; color: #1e3c72; }
.logo p { font-size: 12px; color: #666; }

.admin-info { display: flex; align-items: center; gap: 20px; }
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

.page-title {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 20px;
    padding: 25px 30px;
    margin-bottom: 30px;
}

.page-title h1 { font-size: 28px; color: #1e3c72; margin-bottom: 10px; }
.page-title p { color: #666; font-size: 14px; }

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
.stat-card .number { font-size: 32px; font-weight: bold; color: #1e3c72; }
.stat-card .label { color: #666; font-size: 14px; margin-top: 5px; }

.filter-bar {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 15px;
    padding: 15px 20px;
    margin-bottom: 25px;
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
    align-items: center;
}

.filter-bar input, .filter-bar select {
    padding: 10px 15px;
    border: 1px solid #ddd;
    border-radius: 10px;
    font-size: 14px;
}
.filter-bar button {
    padding: 10px 20px;
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
}
.reset-btn { background: #6c757d !important; }

.bookings-table-wrapper {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 20px;
    padding: 20px;
    overflow-x: auto;
}

.bookings-table {
    width: 100%;
    border-collapse: collapse;
}
.bookings-table th, .bookings-table td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #e0e0e0;
}
.bookings-table th {
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: white;
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
.cancel-btn {
    background: #dc3545;
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: 5px;
    cursor: pointer;
    font-size: 12px;
}
.cancel-btn:hover { background: #c82333; }
.cancel-btn.disabled {
    background: #6c757d;
    cursor: not-allowed;
}

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
    max-width: 400px;
    width: 90%;
    padding: 25px;
}
.modal-header {
    font-size: 20px;
    font-weight: bold;
    margin-bottom: 15px;
    color: #dc3545;
}
.modal-footer {
    margin-top: 20px;
    display: flex;
    gap: 10px;
    justify-content: flex-end;
}
.confirm-cancel { background: #dc3545; color: white; border: none; padding: 8px 20px; border-radius: 5px; cursor: pointer; }
.close-modal { background: #6c757d; color: white; border: none; padding: 8px 20px; border-radius: 5px; cursor: pointer; }
</style>
</head>
<body>

<div class="floating-shapes">
    <div class="shape shape1"></div>
    <div class="shape shape2"></div>
    <div class="shape shape3"></div>
    <div class="shape shape4"></div>
</div>

<div class="container">
    <div class="navbar">
        <div class="logo">
            <h2>🏨 Hotel Management System</h2>
            <p>Administrator Control Panel</p>
        </div>
        <div class="admin-info">
            <div class="admin-badge">👑 Admin</div>
            <a href="AdminLogout" class="logout-btn">🚪 Logout</a>
        </div>
    </div>

    <div class="page-title">
        <h1>📋 Booking Management</h1>
        <p>View, manage and cancel customer bookings</p>
    </div>

    <%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    int totalBookings = 0;
    int activeBookings = 0;
    int cancelledBookings = 0;
    double totalRevenue = 0;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        
        Statement stmt = con.createStatement();
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM bookings");
        if (rs.next()) totalBookings = rs.getInt("total");
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM bookings WHERE status = 'Confirmed'");
        if (rs.next()) activeBookings = rs.getInt("total");
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM bookings WHERE status = 'Cancelled'");
        if (rs.next()) cancelledBookings = rs.getInt("total");
        rs.close();
        
        rs = stmt.executeQuery("SELECT SUM(total_amount) as revenue FROM bookings WHERE status = 'Confirmed'");
        if (rs.next()) totalRevenue = rs.getDouble("revenue");
        rs.close();
        stmt.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
    %>

    <div class="stats-cards">
        <div class="stat-card"><div class="number"><%= totalBookings %></div><div class="label">Total Bookings</div></div>
        <div class="stat-card"><div class="number"><%= activeBookings %></div><div class="label">Active Bookings</div></div>
        <div class="stat-card"><div class="number"><%= cancelledBookings %></div><div class="label">Cancelled Bookings</div></div>
        <div class="stat-card"><div class="number">₹<%= String.format("%,.0f", totalRevenue) %></div><div class="label">Total Revenue</div></div>
    </div>

    <div class="filter-bar">
        <input type="text" id="searchInput" placeholder="🔍 Search by name, email, or room..." onkeyup="filterTable()">
        <select id="statusFilter" onchange="filterTable()">
            <option value="all">All Status</option>
            <option value="Confirmed">Confirmed</option>
            <option value="Cancelled">Cancelled</option>
        </select>
        <button onclick="filterTable()">Apply Filter</button>
        <button class="reset-btn" onclick="resetFilters()">Reset</button>
    </div>

    <div class="bookings-table-wrapper">
        <table class="bookings-table" id="bookingsTable">
            <thead>
                <tr><th>ID</th><th>Customer Details</th><th>Room Details</th><th>Check In</th><th>Check Out</th><th>Amount</th><th>Status</th><th>Action</th></tr>
            </thead>
            <tbody id="tableBody">
                <%
                try {
                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
                    String sql = "SELECT b.*, u.name as user_name, u.email as user_email, r.roomtype, r.bedtype FROM bookings b " +
                                 "JOIN userdata u ON b.username = u.username " +
                                 "JOIN room r ON b.roomno = r.roomno ORDER BY b.booking_id DESC";
                    ps = con.prepareStatement(sql);
                    rs = ps.executeQuery();
                    
                    boolean hasData = false;
                    while (rs.next()) {
                        hasData = true;
                        int bookingId = rs.getInt("booking_id");
                        String userName = rs.getString("user_name");
                        String userEmail = rs.getString("user_email");
                        String username = rs.getString("username");
                        String roomNo = rs.getString("roomno");
                        String roomType = rs.getString("roomtype");
                        String checkIn = rs.getString("check_in");
                        String checkOut = rs.getString("check_out");
                        double totalAmount = rs.getDouble("total_amount");
                        String status = rs.getString("status");
                %>
                <tr data-status="<%= status %>" data-name="<%= userName.toLowerCase() %>" data-email="<%= userEmail.toLowerCase() %>" data-room="<%= roomNo %>">
                    <td>#<%= bookingId %></td>
                    <td><strong><%= userName %></strong><br><small>📧 <%= userEmail %></small><br><small>👤 @<%= username %></small></td>
                    <td><strong>Room <%= roomNo %></strong><br><small><%= roomType %></small></td>
                    <td><%= checkIn %></td>
                    <td><%= checkOut %></td>
                    <td>₹<%= String.format("%,.2f", totalAmount) %></td>
                    <td><span class="<%= status.equals("Confirmed") ? "status-confirmed" : "status-cancelled" %>"><%= status %></span></td>
                    <td>
                        <% if (status.equals("Confirmed")) { %>
                            <button class="cancel-btn" onclick="showCancelModal(<%= bookingId %>, '<%= roomNo %>')">Cancel Booking</button>
                        <% } else { %>
                            <button class="cancel-btn disabled" disabled>Cancelled</button>
                        <% } %>
                    </td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr><td colspan="8" style="text-align:center; padding:50px;">No bookings found</td></tr>
                <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                %>
                <tr><td colspan="8" style="text-align:center; padding:50px; color:red;">Error: <%= e.getMessage() %></td></tr>
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

<!-- Cancel Confirmation Modal -->
<div id="cancelModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">⚠️ Confirm Cancellation</div>
        <div class="modal-body" id="modalBody"></div>
        <div class="modal-footer">
            <button class="close-modal" onclick="closeModal()">Close</button>
            <button class="confirm-cancel" onclick="confirmCancel()">Yes, Cancel Booking</button>
        </div>
    </div>
</div>

<script>
let cancelBookingId = null;
let cancelRoomNo = null;

function showCancelModal(bookingId, roomNo) {
    cancelBookingId = bookingId;
    cancelRoomNo = roomNo;
    document.getElementById('modalBody').innerHTML = `
        <p>Are you sure you want to cancel this booking?</p>
        <p><strong>Booking ID:</strong> #${bookingId}</p>
        <p><strong>Room Number:</strong> ${roomNo}</p>
        <p style="color: #dc3545; margin-top: 10px;">This action cannot be undone. The room will become available for booking again.</p>
    `;
    document.getElementById('cancelModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('cancelModal').style.display = 'none';
    cancelBookingId = null;
    cancelRoomNo = null;
}

function confirmCancel() {
    if (cancelBookingId) {
        fetch('CancelBooking', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'bookingId=' + cancelBookingId + '&roomNo=' + cancelRoomNo
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('✅ Booking cancelled successfully!');
                location.reload();
            } else {
                alert('❌ Error: ' + data.message);
            }
        })
        .catch(error => {
            alert('❌ Error cancelling booking: ' + error);
        });
    }
}

function filterTable() {
    const searchValue = document.getElementById('searchInput').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;
    const rows = document.querySelectorAll('#tableBody tr');
    
    rows.forEach(row => {
        if (row.querySelector('td[colspan]')) return;
        
        const status = row.getAttribute('data-status');
        const name = row.getAttribute('data-name');
        const email = row.getAttribute('data-email');
        const room = row.getAttribute('data-room');
        
        let statusMatch = statusFilter === 'all' || status === statusFilter;
        let searchMatch = searchValue === '' || name.includes(searchValue) || email.includes(searchValue) || room.includes(searchValue);
        
        row.style.display = (statusMatch && searchMatch) ? '' : 'none';
    });
}

function resetFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('statusFilter').value = 'all';
    filterTable();
}
</script>

</body>
</html>