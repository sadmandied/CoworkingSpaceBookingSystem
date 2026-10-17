<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String error = null;
    String success = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (conn == null) {
            error = "Unable to connect to Oracle Database! Please verify your Oracle service.";
        } else {
            String inputEmail = request.getParameter("email");
            String inputPass = request.getParameter("password");

            PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE email = ? AND password = ?");
            ps.setString(1, inputEmail);
            ps.setString(2, inputPass);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                session.setAttribute("user_id", rs.getInt("user_id"));
                session.setAttribute("user_name", rs.getString("name"));
                session.setAttribute("role", rs.getString("role"));

                String userRole = rs.getString("role");
                rs.close();
                ps.close();

                if ("Admin".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("admin_dashboard.jsp");
                } else {
                    response.sendRedirect("home.jsp");
                }
                return;
            } else {
                rs.close();
                ps.close();
                error = "Invalid Email or Password! Please try again.";
            }
        }
    }

    if ("1".equals(request.getParameter("registered"))) {
        success = "Registration successful! Please sign in with your credentials below.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Login - Coworking Space Booking System</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Coworking Space Booking System</h1>
        </header>

        <div class="container">
            <h2>Welcome Back</h2>
            <p style="text-align:center; color:#64748b; margin-top:-10px; margin-bottom:20px;">Sign in to manage your workspace reservations</p>

            <% if (error != null) { %>
                <div class="alert-err"><%= error %></div>
            <% } %>

            <% if (success != null) { %>
                <div class="alert-msg"><%= success %></div>
            <% } %>

            <form action="login.jsp" method="post">
                <label>Email Address</label>
                <input type="email" name="email" required placeholder="name@example.com"><br>

                <label>Password</label>
                <input type="password" name="password" required placeholder="Enter your password"><br>

                <div style="text-align:center; margin-top: 20px;">
                    <input type="submit" value="Sign In" class="btn-success">
                    <a href="register.jsp" class="btn">Create Account</a>
                </div>
            </form>
        </div>
    </body>
</html>
