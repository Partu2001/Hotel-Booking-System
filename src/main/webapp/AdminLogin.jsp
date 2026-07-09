<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Login - Hotel Management System</title>
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    min-height: 100vh;
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    overflow-x: hidden;
}

/* Animated background */
body::before {
    content: '';
    position: absolute;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255,255,255,0.1) 1px, transparent 1px);
    background-size: 40px 40px;
    animation: moveBackground 20s linear infinite;
    opacity: 0.3;
}

@keyframes moveBackground {
    0% { transform: translate(0, 0); }
    100% { transform: translate(40px, 40px); }
}

/* Floating shapes */
.floating-shapes {
    position: absolute;
    width: 100%;
    height: 100%;
    overflow: hidden;
    z-index: 0;
}

.shape {
    position: absolute;
    background: rgba(255, 255, 255, 0.08);
    border-radius: 50%;
    animation: float 8s ease-in-out infinite;
}

.shape1 { width: 350px; height: 350px; top: -120px; right: -120px; animation-delay: 0s; }
.shape2 { width: 250px; height: 250px; bottom: -80px; left: -80px; animation-delay: 2s; }
.shape3 { width: 180px; height: 180px; top: 60%; left: 15%; animation-delay: 4s; }
.shape4 { width: 120px; height: 120px; bottom: 20%; right: 15%; animation-delay: 1s; }

@keyframes float {
    0%, 100% { transform: translateY(0) rotate(0deg); }
    50% { transform: translateY(-25px) rotate(5deg); }
}

/* Main container */
.login-container {
    position: relative;
    z-index: 1;
    width: 100%;
    max-width: 1200px;
    margin: 20px;
    display: flex;
    background: rgba(255, 255, 255, 0.98);
    border-radius: 30px;
    overflow: hidden;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
    animation: slideUp 0.5s ease-out;
}

@keyframes slideUp {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
}

/* Left side - Admin Welcome section */
.welcome-section {
    flex: 1;
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    padding: 50px;
    color: white;
    display: flex;
    flex-direction: column;
    justify-content: center;
    position: relative;
    overflow: hidden;
}

.welcome-section::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255,255,255,0.08) 1px, transparent 1px);
    background-size: 30px 30px;
    animation: slowMove 30s linear infinite;
}

@keyframes slowMove {
    0% { transform: translate(0, 0); }
    100% { transform: translate(50px, 50px); }
}

.admin-badge {
    display: inline-block;
    background: rgba(255,255,255,0.2);
    padding: 8px 20px;
    border-radius: 50px;
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 20px;
    width: fit-content;
    position: relative;
    z-index: 1;
}

.welcome-section .icon {
    font-size: 70px;
    margin-bottom: 20px;
    position: relative;
    z-index: 1;
}

.welcome-section h1 {
    font-size: 42px;
    margin-bottom: 20px;
    position: relative;
    z-index: 1;
}

.welcome-section p {
    font-size: 16px;
    line-height: 1.6;
    margin-bottom: 30px;
    position: relative;
    z-index: 1;
    opacity: 0.95;
}

.feature-list {
    list-style: none;
    position: relative;
    z-index: 1;
}

.feature-list li {
    margin-bottom: 15px;
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 15px;
}

.feature-list li::before {
    content: '🔐';
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
}

/* Right side - Admin Login form */
.login-form-section {
    flex: 1;
    padding: 50px;
    background: white;
    display: flex;
    flex-direction: column;
    justify-content: center;
}

.login-header {
    text-align: center;
    margin-bottom: 40px;
}

.login-header h2 {
    font-size: 32px;
    color: #1e3c72;
    margin-bottom: 10px;
}

.login-header p {
    color: #666;
    font-size: 14px;
}

.input-group {
    margin-bottom: 25px;
    position: relative;
}

.input-group label {
    display: block;
    margin-bottom: 8px;
    color: #333;
    font-weight: 500;
    font-size: 14px;
}

.input-group input {
    width: 100%;
    padding: 15px 45px 15px 15px;
    border: 2px solid #e0e0e0;
    border-radius: 12px;
    font-size: 16px;
    transition: all 0.3s;
    outline: none;
    font-family: inherit;
}

.input-group input:focus {
    border-color: #2a5298;
    box-shadow: 0 0 0 3px rgba(42, 82, 152, 0.1);
}

.input-group .input-icon {
    position: absolute;
    right: 15px;
    top: 45px;
    color: #999;
    font-size: 18px;
    cursor: pointer;
}

.login-btn {
    width: 100%;
    padding: 15px;
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
}

.login-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(30, 60, 114, 0.3);
}

.login-btn:active {
    transform: translateY(0);
}

.back-link {
    text-align: center;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #e0e0e0;
}

.back-link a {
    color: #666;
    text-decoration: none;
    font-size: 14px;
    transition: color 0.3s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.back-link a:hover {
    color: #2a5298;
}

/* Alert messages */
.alert {
    padding: 12px;
    border-radius: 10px;
    margin-bottom: 20px;
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 10px;
    animation: shake 0.5s ease-out;
}

@keyframes shake {
    0%, 100% { transform: translateX(0); }
    10%, 30%, 50%, 70%, 90% { transform: translateX(-2px); }
    20%, 40%, 60%, 80% { transform: translateX(2px); }
}

.alert-error {
    background: #fee;
    color: #c33;
    border-left: 4px solid #c33;
}

/* Demo credentials */
.demo-credentials {
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    border-radius: 12px;
    padding: 15px;
    margin-top: 20px;
}

.demo-title {
    font-size: 12px;
    font-weight: 600;
    color: #1e3c72;
    margin-bottom: 10px;
    text-align: center;
}

.credential-box {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    font-size: 12px;
}

.cred-item {
    flex: 1;
    background: white;
    padding: 8px;
    border-radius: 8px;
    text-align: center;
}

.cred-label {
    color: #666;
    font-size: 10px;
    margin-bottom: 4px;
}

.cred-value {
    color: #1e3c72;
    font-weight: 600;
    font-family: monospace;
}

/* Loading animation */
.loading {
    display: inline-block;
    width: 18px;
    height: 18px;
    border: 2px solid rgba(255,255,255,0.3);
    border-radius: 50%;
    border-top-color: white;
    animation: spin 0.6s linear infinite;
}

@keyframes spin {
    to { transform: rotate(360deg); }
}

/* Responsive */
@media (max-width: 768px) {
    .login-container {
        flex-direction: column;
        margin: 20px;
    }
    
    .welcome-section {
        padding: 30px;
        text-align: center;
    }
    
    .welcome-section h1 {
        font-size: 32px;
    }
    
    .admin-badge {
        margin: 0 auto 20px auto;
    }
    
    .feature-list {
        text-align: left;
    }
    
    .login-form-section {
        padding: 30px;
    }
    
    .login-header h2 {
        font-size: 28px;
    }
    
    .credential-box {
        flex-direction: column;
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

<div class="login-container">
    <!-- Left Side - Admin Welcome Section -->
    <div class="welcome-section">
        <div class="admin-badge">⭐ ADMIN PORTAL ⭐</div>
        <div class="icon">👑</div>
        <h1>Admin Access</h1>
        <p>Secure administrator login for hotel management system. Manage rooms, view bookings, and control operations.</p>
        <ul class="feature-list">
            <li>Manage Room Inventory</li>
            <li>View All Bookings</li>
            <li>Add/Remove Rooms</li>
            <li>Generate Reports</li>
            <li>User Management</li>
        </ul>
    </div>

    <!-- Right Side - Admin Login Form -->
    <div class="login-form-section">
        <div class="login-header">
            <h2>Administrator Login</h2>
            <p>Enter your admin credentials to access the dashboard</p>
        </div>

        <%
        String error = request.getParameter("error");
        if (error != null && error.equals("invalid")) {
        %>
        <div class="alert alert-error">
            ⚠️ Invalid admin credentials! Access denied.
        </div>
        <%
        }
        %>

        <form action="AdminLogin" method="post" id="adminLoginForm">
            <div class="input-group">
                <label>👑 Admin Username</label>
                <input type="text" name="username" id="username" placeholder="Enter admin username" required autocomplete="off">
                <span class="input-icon">👤</span>
            </div>

            <div class="input-group">
                <label>🔒 Admin Password</label>
                <input type="password" name="password" id="password" placeholder="Enter admin password" required>
                <span class="input-icon" style="cursor: pointer;" onclick="togglePassword()">👁️</span>
            </div>

            <button type="submit" class="login-btn" id="loginBtn">
                <span>🔐 Access Dashboard</span>
            </button>

            <div class="demo-credentials">
                <div class="demo-title">📋 Demo Admin Credentials</div>
                <div class="credential-box">
                    <div class="cred-item">
                        <div class="cred-label">Username</div>
                        <div class="cred-value">Admin123</div>
                    </div>
                    <div class="cred-item">
                        <div class="cred-label">Password</div>
                        <div class="cred-value">Admin@123</div>
                    </div>
                </div>
            </div>

            <div class="back-link">
                <a href="Login.jsp">← Back to User Login</a>
            </div>
        </form>
    </div>
</div>

<script>
function togglePassword() {
    const passwordInput = document.getElementById('password');
    const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
    passwordInput.setAttribute('type', type);
}

document.getElementById('adminLoginForm').addEventListener('submit', function(e) {
    const btn = document.getElementById('loginBtn');
    btn.innerHTML = '<span class="loading"></span> Verifying credentials...';
    btn.disabled = true;
});

// Add floating animation effect on focus
const inputs = document.querySelectorAll('.input-group input');
inputs.forEach(input => {
    input.addEventListener('focus', function() {
        this.parentElement.style.transform = 'translateX(5px)';
    });
    input.addEventListener('blur', function() {
        this.parentElement.style.transform = 'translateX(0)';
    });
});

window.addEventListener('load', function() {
    const container = document.querySelector('.login-container');
    container.style.animation = 'slideUp 0.5s ease-out';
});

const style = document.createElement('style');
style.textContent = `
    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);
</script>

</body>
</html>