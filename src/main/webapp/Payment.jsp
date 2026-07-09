<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    // Get booking details from session
    Double totalAmount = (Double) session.getAttribute("totalAmount");
    Double roomTotal = (Double) session.getAttribute("roomTotal");
    Double extraTotal = (Double) session.getAttribute("extraTotal");
    String roomNo = (String) session.getAttribute("roomNo");
    String hotelName = (String) session.getAttribute("hotelName");
    String checkIn = (String) session.getAttribute("checkIn");
    String checkOut = (String) session.getAttribute("checkOut");
    Boolean isPartnerBooking = (Boolean) session.getAttribute("isPartnerBooking");
    
    // Display room with hotel name for partner bookings
    String displayRoom = roomNo;
    if (isPartnerBooking != null && isPartnerBooking && hotelName != null && !hotelName.isEmpty()) {
        displayRoom = hotelName + " - " + roomNo;
    }
    
    // If no booking details, redirect to dashboard
    if (totalAmount == null || totalAmount == 0) {
        response.sendRedirect("Dashboard.jsp");
        return;
    }
    
    // Set default values if null
    if (roomTotal == null) roomTotal = 0.0;
    if (extraTotal == null) extraTotal = 0.0;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Payment - Hotel Management</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
    font-family: 'Poppins', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
}
.payment-container {
    max-width: 550px;
    width: 100%;
    background: white;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 20px 40px rgba(0,0,0,0.2);
    animation: slideUp 0.5s ease-out;
}
@keyframes slideUp {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
}
.payment-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 30px;
    text-align: center;
}
.payment-header h2 { font-size: 28px; margin-bottom: 10px; }
.payment-header p { font-size: 14px; opacity: 0.9; }
.payment-body { padding: 30px; }
.booking-summary {
    background: #f8f9fa;
    border-radius: 15px;
    padding: 20px;
    margin-bottom: 25px;
}
.summary-title {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 15px;
    color: #333;
}
.summary-row {
    display: flex;
    justify-content: space-between;
    padding: 12px 0;
    border-bottom: 1px solid #e0e0e0;
}
.summary-label { color: #666; font-weight: 500; }
.summary-value { color: #333; font-weight: 600; }
.total-row {
    background: #e8f5e9;
    margin-top: 15px;
    padding: 15px;
    border-radius: 10px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.total-label { font-size: 18px; font-weight: bold; color: #333; }
.total-amount { font-size: 24px; font-weight: bold; color: #28a745; }
.form-group { margin-bottom: 20px; }
label { display: block; margin-bottom: 8px; font-weight: 600; color: #333; }
select, input {
    width: 100%;
    padding: 12px;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    font-size: 16px;
    outline: none;
    font-family: 'Poppins', sans-serif;
}
select:focus, input:focus { border-color: #667eea; }
.pay-btn {
    width: 100%;
    padding: 15px;
    background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 18px;
    font-weight: 600;
    cursor: pointer;
    margin-top: 10px;
    transition: all 0.3s;
}
.pay-btn:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(0,0,0,0.2); }
.password-hint {
    background: #fff3cd;
    border: 1px solid #ffecb5;
    color: #856404;
    padding: 10px;
    border-radius: 8px;
    font-size: 12px;
    margin-top: 10px;
    text-align: center;
}
</style>
</head>
<body>

<div class="payment-container">
    <div class="payment-header">
        <h2>💳 Payment Details</h2>
        <p>Complete your booking payment securely</p>
    </div>
    
    <div class="payment-body">
        <div class="booking-summary">
            <div class="summary-title">📋 Booking Summary</div>
            <div class="summary-row">
                <span class="summary-label">Room:</span>
                <span class="summary-value"><strong><%= displayRoom %></strong></span>
            </div>
            <% if (checkIn != null && checkOut != null) { %>
            <div class="summary-row">
                <span class="summary-label">Check-in Date:</span>
                <span class="summary-value"><%= checkIn %></span>
            </div>
            <div class="summary-row">
                <span class="summary-label">Check-out Date:</span>
                <span class="summary-value"><%= checkOut %></span>
            </div>
            <% } %>
            <div class="summary-row">
                <span class="summary-label">Room Charges:</span>
                <span class="summary-value">₹<%= String.format("%,.2f", roomTotal) %></span>
            </div>
            <% if (extraTotal > 0) { %>
            <div class="summary-row">
                <span class="summary-label">Extra Amenities:</span>
                <span class="summary-value">₹<%= String.format("%,.2f", extraTotal) %></span>
            </div>
            <% } %>
            <div class="total-row">
                <span class="total-label">Total Amount:</span>
                <span class="total-amount">₹<%= String.format("%,.2f", totalAmount) %></span>
            </div>
        </div>
        
        <form action="PaymentServlet" method="post" onsubmit="return validateForm()">
            <div class="form-group">
                <label>💳 Payment Method</label>
                <select name="method" id="method" required>
                    <option value="">-- Select Payment Method --</option>
                    <option value="Credit Card">💳 Credit Card</option>
                    <option value="Debit Card">💳 Debit Card</option>
                    <option value="UPI">📱 UPI</option>
                    <option value="Net Banking">🏦 Net Banking</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>🔐 Payment Password</label>
                <input type="password" name="pass" id="pass" placeholder="Enter your payment password" required>
                <div class="password-hint">
                    💡 Enter the payment password you created during registration
                </div>
            </div>
            
            <button type="submit" class="pay-btn">✅ Pay ₹<%= String.format("%,.2f", totalAmount) %></button>
        </form>
    </div>
</div>

<script>
function validateForm() {
    const method = document.getElementById('method').value;
    const pass = document.getElementById('pass').value;
    
    if (!method) {
        alert('❌ Please select a payment method');
        return false;
    }
    
    if (!pass) {
        alert('❌ Please enter your payment password');
        return false;
    }
    
    return true;
}
</script>

</body>
</html>