<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String role = (String) session.getAttribute("role");
    if (!"Admin".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod()) && conn != null) {
        String title = request.getParameter("title");
        String spaceType = request.getParameter("space_type");
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        double hourlyRate = Double.parseDouble(request.getParameter("hourly_rate"));
        String locationFloor = request.getParameter("location_floor");
        String description = request.getParameter("description");

        PreparedStatement ps = conn.prepareStatement("INSERT INTO spaces (SPACE_ID, TITLE, SPACE_TYPE, CAPACITY, HOURLY_RATE, LOCATION_FLOOR, DESCRIPTION) VALUES (space_seq.NEXTVAL, ?, ?, ?, ?, ?, ?)");
        ps.setString(1, title);
        ps.setString(2, spaceType);
        ps.setInt(3, capacity);
        ps.setDouble(4, hourlyRate);
        ps.setString(5, locationFloor);
        ps.setString(6, description);
        ps.executeUpdate();
        ps.close();

        response.sendRedirect("admin_dashboard.jsp?added=1");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Add Space - Admin</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Add New Coworking Space</h1>
        </header>

        <div class="container">
            <div class="user-info">
                <span>Signed in as <strong>Administrator</strong></span>
                <div>
                    <a href="admin_dashboard.jsp">Admin Panel</a>
                    <a href="home.jsp">Member View</a>
                    <a href="logout.jsp" style="color:#e11d48;">Sign Out</a>
                </div>
            </div>

            <h2>New Workspace Details</h2>

            <form action="addspace.jsp" method="post">
                <label>Workspace Title</label>
                <input type="text" name="title" required placeholder="e.g. Executive Cabin C02"><br>

                <label>Category</label>
                <select name="space_type">
                    <option value="Desk">Desk</option>
                    <option value="Cabin">Cabin</option>
                    <option value="Meeting Room">Meeting Room</option>
                </select><br>

                <label>Seating Capacity (Persons)</label>
                <input type="number" name="capacity" min="1" required value="1"><br>

                <label>Hourly Rate ($)</label>
                <input type="number" step="0.01" min="1" name="hourly_rate" required placeholder="15.00"><br>

                <label>Floor Location</label>
                <input type="text" name="location_floor" required placeholder="e.g. Floor 2"><br>

                <label>Amenities &amp; Description</label>
                <input type="text" name="description" required placeholder="Ergonomic seating, high-speed Wi-Fi, power outlets"><br>

                <div style="text-align:center; margin-top: 15px;">
                    <input type="submit" value="Save Workspace" class="btn-success">
                    <a href="admin_dashboard.jsp" class="btn">Cancel</a>
                </div>
            </form>
        </div>
    </body>
</html>
