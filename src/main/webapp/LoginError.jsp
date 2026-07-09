<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>Login Error</title>
<style>
body {
    font-family: Arial;
    background: linear-gradient(to right, #ff4b2b, #ff416c);
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}
.container {
    background: white;
    padding: 30px;
    border-radius: 10px;
    text-align: center;
}
h2 { color: red; }
a {
    padding: 10px 20px;
    background: blue;
    color: white;
    text-decoration: none;
    border-radius: 5px;
}
</style>
</head>
<body>

<div class="container">
    <h2 style="color:red;">Invalid Username or Password</h2>
<a href="Login.jsp">Try Again</a>
</div>

</body>
</html>