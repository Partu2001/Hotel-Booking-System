<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add Room - Professional</title>
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
    padding: 40px 20px;
}

.container {
    max-width: 600px;
    margin: 0 auto;
    background: white;
    border-radius: 20px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    overflow: hidden;
}

.header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 30px;
    text-align: center;
}

.header h2 {
    font-size: 28px;
    margin-bottom: 10px;
}

.header p {
    opacity: 0.9;
}

.form-body {
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
    border-radius: 8px;
    font-size: 14px;
    transition: all 0.3s;
}

input:focus, select:focus, textarea:focus {
    outline: none;
    border-color: #667eea;
}

.amenity-group {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 15px;
    max-height: 300px;
    overflow-y: auto;
}

.amenity-item {
    display: flex;
    gap: 15px;
    margin-bottom: 10px;
    align-items: center;
}

.amenity-item input[type="checkbox"] {
    width: auto;
    margin-right: 10px;
}

.amenity-item input[type="number"] {
    width: 120px;
}

.image-preview {
    margin-top: 10px;
    text-align: center;
}

.image-preview img {
    max-width: 200px;
    border-radius: 8px;
    display: none;
}

.btn-submit {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: transform 0.2s;
}

.btn-submit:hover {
    transform: translateY(-2px);
}

.btn-back {
    display: inline-block;
    margin-top: 15px;
    text-align: center;
    width: 100%;
    padding: 12px;
    background: #6c757d;
    color: white;
    text-decoration: none;
    border-radius: 8px;
}

.row {
    display: flex;
    gap: 15px;
}

.row .form-group {
    flex: 1;
}

.info-text {
    font-size: 12px;
    color: #666;
    margin-top: 5px;
}

@media (max-width: 768px) {
    .row {
        flex-direction: column;
        gap: 0;
    }
}
</style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2>🏨 Add New Room</h2>
        <p>Fill in the details to add a new room to the hotel</p>
    </div>
    
    <div class="form-body">
        <form action="AddRoomServlet" method="post" enctype="multipart/form-data">
            <div class="row">
                <div class="form-group">
                    <label>Room Number *</label>
                    <input type="text" name="roomNumber" id="roomNumber" 
                           placeholder="Enter room number (e.g., 101, 2001, 3005)" 
                           pattern="[0-9]+" 
                           title="Please enter only numbers"
                           required>
                    <div class="info-text">💡 Tip: You can use any room number (1, 101, 2001, 5000, etc.)</div>
                </div>
                
                <div class="form-group">
                    <label>Room Type *</label>
                    <select name="roomType" required>
                        <option value="Single">Single</option>
                        <option value="Double">Double</option>
                        <option value="Deluxe">Deluxe</option>
                        <option value="Suite">Suite</option>
                        <option value="Presidential">Presidential</option>
                        <option value="Executive">Executive</option>
                    </select>
                </div>
            </div>
            
            <div class="row">
                <div class="form-group">
                    <label>Bed Type *</label>
                    <select name="bedType" required>
                        <option value="Single Bed">Single Bed</option>
                        <option value="Double Bed">Double Bed</option>
                        <option value="Queen Size">Queen Size</option>
                        <option value="King Size">King Size</option>
                        <option value="Super King">Super King</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Price per Night (₹) *</label>
                    <input type="number" name="price" step="0.01" required placeholder="e.g., 3500">
                </div>
            </div>
            
            <div class="row">
                <div class="form-group">
                    <label>Capacity (Persons) *</label>
                    <input type="number" name="capacity" required placeholder="e.g., 2">
                </div>
                
                <div class="form-group">
                    <label>Status *</label>
                    <select name="status" required>
                        <option value="Available">Available</option>
                        <option value="Booked">Booked</option>
                    </select>
                </div>
            </div>
            
            <div class="form-group">
                <label>Amenities with Extra Charges</label>
                <div class="amenity-group">
                    <div class="amenity-item">
                        <input type="checkbox" name="amenities" value="AC">
                        <label style="margin:0; flex:1;">AC</label>
                        <input type="number" name="extra_charge" placeholder="Extra charge (₹)" step="0.01" style="width:120px;" value="0">
                    </div>
                    <div class="amenity-item">
                        <input type="checkbox" name="amenities" value="WiFi">
                        <label style="margin:0; flex:1;">WiFi</label>
                        <input type="number" name="extra_charge" placeholder="Extra charge (₹)" step="0.01" style="width:120px;" value="0">
                    </div>
                    <div class="amenity-item">
                        <input type="checkbox" name="amenities" value="TV">
                        <label style="margin:0; flex:1;">TV</label>
                        <input type="number" name="extra_charge" placeholder="Extra charge (₹)" step="0.01" style="width:120px;" value="0">
                    </div>
                    <div class="amenity-item">
                        <input type="checkbox" name="amenities" value="Mini Bar">
                        <label style="margin:0; flex:1;">Mini Bar</label>
                        <input type="number" name="extra_charge" placeholder="Extra charge (₹)" step="0.01" style="width:120px;" value="0">
                    </div>
                    <div class="amenity-item">
                        <input type="checkbox" name="amenities" value="Breakfast">
                        <label style="margin:0; flex:1;">Breakfast</label>
                        <input type="number" name="extra_charge" placeholder="Extra charge (₹)" step="0.01" style="width:120px;" value="0">
                    </div>
                    <div class="amenity-item">
                        <input type="checkbox" name="amenities" value="Jacuzzi">
                        <label style="margin:0; flex:1;">Jacuzzi</label>
                        <input type="number" name="extra_charge" placeholder="Extra charge (₹)" step="0.01" style="width:120px;" value="0">
                    </div>
                    <div class="amenity-item">
                        <input type="checkbox" name="amenities" value="Parking">
                        <label style="margin:0; flex:1;">Parking</label>
                        <input type="number" name="extra_charge" placeholder="Extra charge (₹)" step="0.01" style="width:120px;" value="0">
                    </div>
                    <div class="amenity-item">
                        <input type="checkbox" name="amenities" value="Room Service">
                        <label style="margin:0; flex:1;">Room Service</label>
                        <input type="number" name="extra_charge" placeholder="Extra charge (₹)" step="0.01" style="width:120px;" value="0">
                    </div>
                    <div class="amenity-item">
                        <input type="checkbox" name="amenities" value="Sea View">
                        <label style="margin:0; flex:1;">Sea View</label>
                        <input type="number" name="extra_charge" placeholder="Extra charge (₹)" step="0.01" style="width:120px;" value="0">
                    </div>
                </div>
                <div class="info-text">💡 Check amenities and enter extra charges if applicable</div>
            </div>
            
            <div class="form-group">
                <label>Room Image *</label>
                <input type="file" name="roomImage" accept="image/*" onchange="previewImage(this)" required>
                <div class="image-preview">
                    <img id="preview" alt="Room preview">
                </div>
            </div>
            
            <button type="submit" class="btn-submit">➕ Add Room</button>
            <a href="Admin.jsp" class="btn-back">← Back to Dashboard</a>
        </form>
    </div>
</div>

<script>
function previewImage(input) {
    const preview = document.getElementById('preview');
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.style.display = 'block';
            preview.src = e.target.result;
        }
        reader.readAsDataURL(input.files[0]);
    }
}
</script>

</body>
</html>