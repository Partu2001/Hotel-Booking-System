<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Main Page</title>
<style type="text/css">

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-image: url("hotel.jpg");
    background-size: cover;       
    background-position: center;  
    background-repeat: no-repeat; 
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}
.container {
    background: rgba(255, 255, 255, 0.1);
    padding: 40px;
    border-radius: 15px;
    text-align: center;
    backdrop-filter: blur(10px);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    width: 400px;
}
.container h1 {
    color: #fff;
    margin-bottom: 20px;
    font-size: 28px;
}
.container img {
    width: 100%;
    border-radius: 10px;
    margin-bottom: 20px;
}
.btn {
    display: inline-block;
    padding: 12px 25px;
    margin: 10px;
    border-radius: 25px;
    background: #ff7e5f;
    background: linear-gradient(to right, #ff7e5f, #feb47b);
    color: white;
    text-decoration: none;
    font-size: 16px;
    transition: 0.3s;
}


.btn:hover {
    transform: scale(1.05);
    box-shadow: 0 5px 15px rgba(0,0,0,0.3);
}


@media (max-width: 500px) {
    .container {
        width: 90%;
        padding: 20px;
    }

    .container h1 {
        font-size: 22px;
    }
}
 
</style>
</head>
<body>
<div class="container">
<h1>WELCOME TO HOTEL MANAGEMENT SYSTEM</h1>

<a href="Register.jsp" class="btn">Register</a>
<a href="Login.jsp" class="btn">Login</a> 
<a href="AdminLogin.jsp" class="btn">Admin Login</a>
</div>
</body>
</html>