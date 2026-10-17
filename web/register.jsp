<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String error = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");

        try {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO users (USER_ID, NAME, EMAIL, PASSWORD, PHONE, ROLE) VALUES (user_seq.NEXTVAL, ?, ?, ?, ?, ?)");
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, phone);
            ps.setString(5, role);
            ps.executeUpdate();
            ps.close();

            response.sendRedirect("login.jsp?registered=1");
            return;
        } catch (Exception e) {
            error = "Registration failed! Email address may already be registered.";
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Register - Coworking Space Booking System</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Coworking Space Booking System</h1>
        </header>

        <div class="container">
            <h2>Create Member Account</h2>
            <p style="text-align:center; color:#64748b; margin-top:-10px; margin-bottom:20px;">Register to browse and book coworking workspaces</p>

            <% if (error != null) { %>
                <div class="alert-err"><%= error %></div>
            <% } %>

            <form action="register.jsp" method="post">
                <label>Full Name</label>
                <input type="text" name="name" required placeholder="Enter your full name"><br>

                <label>Email Address</label>
                <input type="email" name="email" required placeholder="name@example.com"><br>

                <label>Password</label>
                <input type="password" name="password" required placeholder="Create a password"><br>

                <label>Phone Number</label>
                <input type="text" name="phone" required placeholder="017XXXXXXXX"><br>

                <label>Account Role</label>
                <select name="role">
                    <option value="Member">Member</option>
                    <option value="Admin">Admin</option>
                </select><br>

                <div style="text-align:center; margin-top: 15px;">
                    <input type="submit" value="Register Account" class="btn-success">
                    <a href="login.jsp" class="btn">Back to Sign In</a>
                </div>
            </form>
        </div>
    </body>
</html>
