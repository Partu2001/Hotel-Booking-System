<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
    
<%
    // Admin session check
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
<title>Manage Users - Admin Panel</title>
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

.logo p {
    font-size: 12px;
    color: #666;
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

/* Page Title */
.page-title {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 25px 30px;
    margin-bottom: 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.page-title h1 {
    font-size: 28px;
    color: #1e3c72;
}

.page-title p {
    color: #666;
    font-size: 14px;
    margin-top: 5px;
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
    transition: transform 0.3s;
}

.stat-card:hover {
    transform: translateY(-3px);
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

/* Filter Bar */
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

.filter-bar input {
    flex: 1;
    padding: 12px 15px;
    border: 1px solid #ddd;
    border-radius: 10px;
    font-size: 14px;
    outline: none;
    min-width: 250px;
}

.filter-bar input:focus {
    border-color: #2a5298;
}

.filter-bar button {
    padding: 12px 24px;
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.3s;
    font-weight: 600;
}

.filter-bar button:hover {
    transform: translateY(-2px);
}

.reset-btn {
    background: #6c757d !important;
}

/* Users Table */
.users-table-wrapper {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    padding: 20px;
    overflow-x: auto;
}

.users-table {
    width: 100%;
    border-collapse: collapse;
    border-radius: 15px;
    overflow: hidden;
}

.users-table th,
.users-table td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #e0e0e0;
}

.users-table th {
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: white;
    font-weight: 600;
}

.users-table tr:hover {
    background: #f8f9fa;
}

.users-table td {
    vertical-align: middle;
}

.delete-user-btn {
    background: #dc3545;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 12px;
    font-weight: 600;
    transition: all 0.3s;
}

.delete-user-btn:hover {
    background: #c82333;
    transform: scale(1.02);
}

.view-bookings-btn {
    background: #17a2b8;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
    display: inline-block;
    margin-right: 8px;
    transition: all 0.3s;
}

.view-bookings-btn:hover {
    background: #138496;
    transform: scale(1.02);
}

.action-buttons {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
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
    max-width: 450px;
    width: 90%;
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
    color: #dc3545;
    display: flex;
    align-items: center;
    gap: 10px;
}

.modal-body {
    margin-bottom: 20px;
    line-height: 1.6;
    color: #333;
}

.modal-footer {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
}

.confirm-delete {
    background: #dc3545;
    color: white;
    border: none;
    padding: 10px 24px;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s;
}

.confirm-delete:hover {
    background: #c82333;
    transform: translateY(-2px);
}

.close-modal {
    background: #6c757d;
    color: white;
    border: none;
    padding: 10px 24px;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s;
}

.close-modal:hover {
    background: #5a6268;
    transform: translateY(-2px);
}

/* Success Message */
.success-message {
    position: fixed;
    top: 20px;
    right: 20px;
    background: #28a745;
    color: white;
    padding: 15px 25px;
    border-radius: 10px;
    animation: slideInRight 0.3s ease-out, fadeOut 3s forwards 1s;
    z-index: 1001;
    box-shadow: 0 5px 15px rgba(0,0,0,0.2);
}

@keyframes slideInRight {
    from {
        opacity: 0;
        transform: translateX(100px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes fadeOut {
    to {
        opacity: 0;
        visibility: hidden;
    }
}

/* Responsive */
@media (max-width: 768px) {
    .navbar {
        flex-direction: column;
        gap: 15px;
        text-align: center;
    }
    
    .admin-info {
        flex-wrap: wrap;
        justify-content: center;
    }
    
    .page-title {
        flex-direction: column;
        gap: 15px;
        text-align: center;
    }
    
    .stats-cards {
        grid-template-columns: 1fr;
    }
    
    .users-table th,
    .users-table td {
        padding: 10px;
        font-size: 12px;
    }
    
    .filter-bar {
        flex-direction: column;
    }
    
    .filter-bar input,
    .filter-bar button {
        width: 100%;
    }
    
    .action-buttons {
        flex-direction: column;
    }
    
    .view-bookings-btn,
    .delete-user-btn {
        width: 100%;
        text-align: center;
    }
}
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
    <!-- Navbar -->
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

    <!-- Page Title -->
    <div class="page-title">
        <div>
            <h1>👥 Manage Users</h1>
            <p>View, manage and delete registered users</p>
        </div>
        <a href="Admin.jsp" class="back-btn">← Back to Dashboard</a>
    </div>

    <%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    int totalUsers = 0;
    int usersWithBookings = 0;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
        
        Statement stmt = con.createStatement();
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM userdata");
        if (rs.next()) {
            totalUsers = rs.getInt("total");
        }
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(DISTINCT username) as total FROM bookings");
        if (rs.next()) {
            usersWithBookings = rs.getInt("total");
        }
        rs.close();
        stmt.close();
        
    } catch (Exception e) {
        e.printStackTrace();
    }
    %>

    <!-- Stats Cards -->
    <div class="stats-cards">
        <div class="stat-card">
            <div class="number"><%= totalUsers %></div>
            <div class="label">Total Registered Users</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= totalUsers %></div>
            <div class="label">Active Users</div>
        </div>
        <div class="stat-card">
            <div class="number"><%= usersWithBookings %></div>
            <div class="label">Users with Bookings</div>
        </div>
    </div>

    <!-- Filter Bar -->
    <div class="filter-bar">
        <input type="text" id="searchInput" placeholder="🔍 Search by name, username, or email..." onkeyup="filterTable()">
        <button onclick="filterTable()">Apply Filter</button>
        <button class="reset-btn" onclick="resetFilters()">Reset</button>
    </div>

    <!-- Users Table -->
    <div class="users-table-wrapper">
        <table class="users-table" id="usersTable">
            <thead>
                <tr>
                    <th style="width: 5%;">ID</th>
                    <th style="width: 20%;">Full Name</th>
                    <th style="width: 15%;">Username</th>
                    <th style="width: 25%;">Email</th>
                    <th style="width: 10%;">Bookings</th>
                    <th style="width: 10%;">Total Spent</th>
                    <th style="width: 15%;">Actions</th>
                </tr>
            </thead>
            <tbody id="tableBody">
                <%
                try {
                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522:xe", "system", "system");
                    
                    String sql = 
                        "SELECT u.*, " +
                        "   (SELECT COUNT(*) FROM bookings WHERE username = u.username) as booking_count, " +
                        "   (SELECT NVL(SUM(total_amount), 0) FROM bookings WHERE username = u.username AND status = 'Confirmed') as total_spent " +
                        "FROM userdata u " +
                        "ORDER BY u.name";
                    
                    ps = con.prepareStatement(sql);
                    rs = ps.executeQuery();
                    
                    boolean hasData = false;
                    int serialNo = 1;
                    while (rs.next()) {
                        hasData = true;
                        String userName = rs.getString("name");
                        String userUsername = rs.getString("username");
                        String userEmail = rs.getString("email");
                        int bookingCount = rs.getInt("booking_count");
                        double totalSpent = rs.getDouble("total_spent");
                %>
                <tr data-name="<%= userName.toLowerCase() %>" data-username="<%= userUsername.toLowerCase() %>" data-email="<%= userEmail.toLowerCase() %>">
                    <td style="text-align: center;"><%= serialNo++ %></td>
                    <td><strong><%= userName %></strong></td>
                    <td>@<%= userUsername %></td>
                    <td><%= userEmail %></td>
                    <td style="text-align: center;"><%= bookingCount %></td>
                    <td>₹<%= String.format("%,.2f", totalSpent) %></td>
                    <td class="action-buttons">
                        <a href="ViewUserBookings.jsp?username=<%= userUsername %>" class="view-bookings-btn">📋 View Bookings</a>
                        <% if (!userUsername.equals("admin") && !userUsername.equals(adminName)) { %>
                            <button class="delete-user-btn" onclick="confirmDelete('<%= userUsername %>', '<%= userName %>')">🗑️ Delete</button>
                        <% } %>
                    </td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr>
                    <td colspan="7" class="no-data">
                        <div class="icon">📭</div>
                        <h3>No Users Found</h3>
                        <p>There are no registered users in the system.</p>
                    </td>
                </tr>
                <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                %>
                <tr>
                    <td colspan="7" class="no-data">
                        <div class="icon">⚠️</div>
                        <h3>Error Loading Users</h3>
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

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span>⚠️</span> Confirm Delete User
        </div>
        <div class="modal-body" id="deleteModalBody">
            Are you sure you want to delete this user?
        </div>
        <div class="modal-footer">
            <button class="close-modal" onclick="closeDeleteModal()">Cancel</button>
            <button class="confirm-delete" onclick="confirmDeleteUser()">Yes, Delete User</button>
        </div>
    </div>
</div>

<script>
let deleteUsername = null;
let deleteUserFullName = null;

function confirmDelete(username, fullName) {
    deleteUsername = username;
    deleteUserFullName = fullName;
    document.getElementById('deleteModalBody').innerHTML = `
        <p>Are you sure you want to delete user <strong>${fullName}</strong>?</p>
        <p><strong>Username:</strong> ${username}</p>
        <p style="color: #dc3545; margin-top: 10px;">⚠️ Warning: This will also delete all bookings and payments made by this user. This action cannot be undone!</p>
    `;
    document.getElementById('deleteModal').style.display = 'flex';
}

function closeDeleteModal() {
    document.getElementById('deleteModal').style.display = 'none';
    deleteUsername = null;
    deleteUserFullName = null;
}

function confirmDeleteUser() {
    if (deleteUsername) {
        const confirmBtn = document.querySelector('.confirm-delete');
        const originalText = confirmBtn.innerText;
        confirmBtn.innerHTML = 'Deleting...';
        confirmBtn.disabled = true;
        
        fetch('DeleteUser', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'username=' + encodeURIComponent(deleteUsername)
        })
        .then(response => response.text())
        .then(text => {
            console.log('Response:', text);
            if (text.startsWith('SUCCESS')) {
                showMessage('✅ User ' + deleteUserFullName + ' deleted successfully!');
                setTimeout(() => location.reload(), 1500);
            } else if (text.startsWith('ERROR')) {
                alert('❌ ' + text.substring(6));
            } else {
                alert('❌ Error: ' + text);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('❌ Error deleting user: ' + error.message);
        })
        .finally(() => {
            confirmBtn.innerHTML = originalText;
            confirmBtn.disabled = false;
        });
        
        closeDeleteModal();
    }
}

function filterTable() {
    const searchValue = document.getElementById('searchInput').value.toLowerCase();
    const rows = document.querySelectorAll('#tableBody tr');
    
    rows.forEach(row => {
        if (row.querySelector('.no-data')) return;
        
        const name = row.getAttribute('data-name');
        const username = row.getAttribute('data-username');
        const email = row.getAttribute('data-email');
        
        let searchMatch = searchValue === '' || 
                         (name && name.includes(searchValue)) || 
                         (username && username.includes(searchValue)) || 
                         (email && email.includes(searchValue));
        
        row.style.display = searchMatch ? '' : 'none';
    });
}

function resetFilters() {
    document.getElementById('searchInput').value = '';
    filterTable();
}

function showMessage(message) {
    const existingMsg = document.querySelector('.success-message');
    if (existingMsg) existingMsg.remove();
    
    const msgDiv = document.createElement('div');
    msgDiv.className = 'success-message';
    msgDiv.innerHTML = message;
    document.body.appendChild(msgDiv);
    
    setTimeout(() => {
        if (msgDiv) msgDiv.remove();
    }, 4000);
}
</script>

</body>
</html>