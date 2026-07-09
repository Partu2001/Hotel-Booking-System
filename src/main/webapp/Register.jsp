<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
if(session.getAttribute("username") != null){
    response.sendRedirect("Dashboard.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register - Hotel Management System</title>
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    min-height: 100vh;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
}

.register-container {
    max-width: 650px;
    width: 100%;
    background: white;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 20px 40px rgba(0,0,0,0.2);
    animation: slideUp 0.5s ease-out;
}

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

.register-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 30px;
    text-align: center;
    color: white;
}

.register-header h2 {
    font-size: 28px;
    margin-bottom: 10px;
}

.register-form {
    padding: 30px;
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

input, select, textarea {
    width: 100%;
    padding: 12px;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    font-size: 14px;
    transition: all 0.3s;
    font-family: inherit;
}

input:focus, select:focus, textarea:focus {
    outline: none;
    border-color: #667eea;
}

.checkbox-group {
    display: flex;
    align-items: center;
    gap: 10px;
    margin: 15px 0;
}

.checkbox-group input {
    width: auto;
}

.checkbox-group label {
    margin: 0;
    font-weight: normal;
}

.hotel-partner-section {
    display: none;
    background: #f8f9fa;
    padding: 20px;
    border-radius: 10px;
    margin-top: 15px;
    animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(-10px); }
    to { opacity: 1; transform: translateY(0); }
}

.register-btn {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    margin-top: 10px;
}

.register-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.2);
}

.login-link {
    text-align: center;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #e0e0e0;
}

.login-link a {
    color: #667eea;
    text-decoration: none;
}

.error-message {
    color: #dc3545;
    font-size: 12px;
    margin-top: 5px;
    display: none;
}

.error-border {
    border-color: #dc3545 !important;
}

.success-border {
    border-color: #28a745 !important;
}

.help-text {
    font-size: 11px;
    color: #999;
    margin-top: 5px;
}
</style>
</head>
<body>

<div class="register-container">
    <div class="register-header">
        <h2>🏨 Create Account</h2>
        <p>Join us for a luxurious hotel experience</p>
    </div>

    <div class="register-form">
        <form action="RegisterServlet" method="post" id="registerForm">
            <!-- Basic Information -->
            <div class="form-group">
                <label>Full Name *</label>
                <input type="text" name="name" id="fullName" required placeholder="Enter your full name">
                <div id="nameError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label>Email Address *</label>
                <input type="email" name="email" id="email" required placeholder="Enter your email">
                <div id="emailError" class="error-message"></div>
                <div class="help-text">Example: name@domain.com</div>
            </div>

            <div class="form-group">
                <label>Mobile Number *</label>
                <input type="tel" name="mobile" id="mobile" required placeholder="Enter 10 digit mobile number">
                <div id="mobileError" class="error-message"></div>
                <div class="help-text">Enter 10 digit mobile number starting with 6-9</div>
            </div>

            <div class="form-group">
                <label>Username *</label>
                <input type="text" name="username" id="username" required placeholder="Choose a username">
                <div id="usernameError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label>Login Password *</label>
                <input type="password" name="password" id="password" required placeholder="Create a password">
                <div id="passwordError" class="error-message"></div>
                <div class="help-text">Password must be at least 6 characters</div>
            </div>

            <div class="form-group">
                <label>Confirm Password *</label>
                <input type="password" name="confirmPassword" id="confirmPassword" required placeholder="Confirm your password">
                <div id="confirmError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label>Payment Password *</label>
                <input type="password" name="paymentPassword" id="paymentPassword" required placeholder="Create payment password">
                <div id="paymentError" class="error-message"></div>
                <div class="help-text">This password will be used for payment confirmation</div>
            </div>

            <!-- Hotel Partner Option -->
            <div class="checkbox-group">
                <input type="checkbox" name="isHotelPartner" id="isHotelPartner" value="true">
                <label for="isHotelPartner">🏨 I want to list my hotel on this platform</label>
            </div>

            <!-- Hotel Partner Details Section (Hidden by default) -->
            <div id="hotelPartnerSection" class="hotel-partner-section">
                <h3 style="margin-bottom: 15px; color: #333;">Hotel Details</h3>
                
                <div class="form-group">
                    <label>Hotel Name *</label>
                    <input type="text" name="hotelName" id="hotelName" placeholder="Enter your hotel name">
                </div>

                <div class="form-group">
                    <label>Hotel Location *</label>
                    <input type="text" name="hotelLocation" id="hotelLocation" placeholder="Enter hotel address/location">
                </div>

                <div class="form-group">
                    <label>Hotel Phone *</label>
                    <input type="tel" name="hotelPhone" id="hotelPhone" placeholder="Hotel contact number">
                </div>

                <div class="form-group">
                    <label>Hotel Description</label>
                    <textarea name="hotelDescription" id="hotelDescription" rows="3" placeholder="Describe your hotel..."></textarea>
                </div>
            </div>

            <button type="submit" class="register-btn">Create Account →</button>

            <div class="login-link">
                Already have an account? <a href="Login.jsp">Sign In</a>
            </div>
        </form>
    </div>
</div>

<script>
// Toggle hotel partner section
document.getElementById('isHotelPartner').addEventListener('change', function() {
    const section = document.getElementById('hotelPartnerSection');
    if (this.checked) {
        section.style.display = 'block';
        document.getElementById('hotelName').required = true;
        document.getElementById('hotelLocation').required = true;
        document.getElementById('hotelPhone').required = true;
    } else {
        section.style.display = 'none';
        document.getElementById('hotelName').required = false;
        document.getElementById('hotelLocation').required = false;
        document.getElementById('hotelPhone').required = false;
    }
});

// Email validation
function validateEmail(email) {
    const re = /^[^\s@]+@([^\s@]+\.)+[^\s@]+$/;
    return re.test(email);
}

// Mobile number validation (10 digits)
function validateMobile(mobile) {
    const re = /^[6-9]\d{9}$/;
    return re.test(mobile);
}

// Real-time validation
document.getElementById('email').addEventListener('input', function() {
    const email = this.value;
    const errorDiv = document.getElementById('emailError');
    if (email && !validateEmail(email)) {
        errorDiv.textContent = 'Please enter a valid email address (e.g., name@domain.com)';
        errorDiv.style.display = 'block';
        this.classList.add('error-border');
    } else {
        errorDiv.style.display = 'none';
        this.classList.remove('error-border');
        if (email) this.classList.add('success-border');
    }
});

document.getElementById('mobile').addEventListener('input', function() {
    const mobile = this.value;
    const errorDiv = document.getElementById('mobileError');
    if (mobile && !validateMobile(mobile)) {
        errorDiv.textContent = 'Please enter a valid 10 digit mobile number starting with 6-9';
        errorDiv.style.display = 'block';
        this.classList.add('error-border');
    } else {
        errorDiv.style.display = 'none';
        this.classList.remove('error-border');
        if (mobile && mobile.length === 10) this.classList.add('success-border');
    }
});

document.getElementById('confirmPassword').addEventListener('input', function() {
    const password = document.getElementById('password').value;
    const confirm = this.value;
    const errorDiv = document.getElementById('confirmError');
    if (confirm && password !== confirm) {
        errorDiv.textContent = 'Passwords do not match';
        errorDiv.style.display = 'block';
        this.classList.add('error-border');
    } else {
        errorDiv.style.display = 'none';
        this.classList.remove('error-border');
        if (confirm) this.classList.add('success-border');
    }
});

document.getElementById('password').addEventListener('input', function() {
    const password = this.value;
    const errorDiv = document.getElementById('passwordError');
    if (password && password.length < 6) {
        errorDiv.textContent = 'Password must be at least 6 characters';
        errorDiv.style.display = 'block';
        this.classList.add('error-border');
    } else {
        errorDiv.style.display = 'none';
        this.classList.remove('error-border');
        if (password) this.classList.add('success-border');
    }
});

// Form validation before submit
document.getElementById('registerForm').addEventListener('submit', function(e) {
    let isValid = true;
    
    const email = document.getElementById('email').value;
    if (!validateEmail(email)) {
        document.getElementById('emailError').textContent = 'Please enter a valid email address';
        document.getElementById('emailError').style.display = 'block';
        isValid = false;
    }
    
    const mobile = document.getElementById('mobile').value;
    if (!validateMobile(mobile)) {
        document.getElementById('mobileError').textContent = 'Please enter a valid 10 digit mobile number';
        document.getElementById('mobileError').style.display = 'block';
        isValid = false;
    }
    
    const password = document.getElementById('password').value;
    const confirm = document.getElementById('confirmPassword').value;
    if (password !== confirm) {
        document.getElementById('confirmError').textContent = 'Passwords do not match';
        document.getElementById('confirmError').style.display = 'block';
        isValid = false;
    }
    
    if (!isValid) {
        e.preventDefault();
    }
});
</script>

</body>
</html>