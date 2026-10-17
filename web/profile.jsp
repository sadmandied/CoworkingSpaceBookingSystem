<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String userName = (String) session.getAttribute("user_name");
    String role = (String) session.getAttribute("role");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = null;
    String err = null;

    if ("POST".equalsIgnoreCase(request.getMethod()) && conn != null) {
        String newName = request.getParameter("name");
        String newPhone = request.getParameter("phone");
        String newPassword = request.getParameter("password");

        if (newName != null && !newName.trim().isEmpty() && newPassword != null && !newPassword.trim().isEmpty()) {
            PreparedStatement psUpd = conn.prepareStatement("UPDATE users SET name = ?, phone = ?, password = ? WHERE user_id = ?");
            psUpd.setString(1, newName.trim());
            psUpd.setString(2, newPhone != null ? newPhone.trim() : "");
            psUpd.setString(3, newPassword);
            psUpd.setInt(4, userId);
            psUpd.executeUpdate();
            psUpd.close();

            session.setAttribute("user_name", newName.trim());
            userName = newName.trim();
            msg = "Your account profile and credentials have been updated!";
        } else {
            err = "Name and password cannot be empty.";
        }
    }

    String currentEmail = "";
    String currentPhone = "";
    String currentPassword = "";

    if (conn != null) {
        PreparedStatement psU = conn.prepareStatement("SELECT name, email, phone, password FROM users WHERE user_id = ?");
        psU.setInt(1, userId);
        ResultSet rsU = psU.executeQuery();
        if (rsU.next()) {
            userName = rsU.getString("name");
            currentEmail = rsU.getString("email");
            currentPhone = rsU.getString("phone");
            currentPassword = rsU.getString("password");
        }
        rsU.close();
        psU.close();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>My Profile - Coworking System</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Account Profile &amp; Settings</h1>
        </header>

        <div class="container">
            <div class="user-info">
                <span>Signed in as <strong><%= userName %></strong> <span class="badge badge-info" style="margin-left:6px;"><%= role %></span></span>
                <div>
                    <a href="home.jsp">Home</a>
                    <a href="spaces.jsp">Explore Spaces</a>
                    <a href="history.jsp">My Bookings</a>
                    <a href="logout.jsp" style="color:#e11d48;">Sign Out</a>
                </div>
            </div>

            <% if (msg != null) { %>
                <div class="alert-msg"><%= msg %></div>
            <% } %>
            <% if (err != null) { %>
                <div class="alert-err"><%= err %></div>
            <% } %>

            <h2>Manage Personal Information</h2>

            <form action="profile.jsp" method="post">
                <label>Email Address (Login Account)</label>
                <input type="email" value="<%= currentEmail %>" readonly><br>

                <label>Full Name</label>
                <input type="text" name="name" value="<%= userName %>" required><br>

                <label>Phone Number</label>
                <input type="text" name="phone" value="<%= currentPhone != null ? currentPhone : "" %>" required><br>

                <label>Account Password</label>
                <input type="password" name="password" value="<%= currentPassword %>" required><br>

                <div style="text-align:center; margin-top: 15px;">
                    <input type="submit" value="Save Profile Changes" class="btn-success">
                    <a href="home.jsp" class="btn btn-secondary">Back to Dashboard</a>
                </div>
            </form>
        </div>
    </body>
</html>
