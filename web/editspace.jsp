<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String role = (String) session.getAttribute("role");
    if (!"Admin".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    if (idStr == null || conn == null) {
        response.sendRedirect("admin_dashboard.jsp");
        return;
    }

    int spaceId = Integer.parseInt(idStr);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String title = request.getParameter("title");
        String spaceType = request.getParameter("space_type");
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        double hourlyRate = Double.parseDouble(request.getParameter("hourly_rate"));
        String locationFloor = request.getParameter("location_floor");
        String description = request.getParameter("description");

        PreparedStatement ps = conn.prepareStatement("UPDATE spaces SET title=?, space_type=?, capacity=?, hourly_rate=?, location_floor=?, description=? WHERE space_id=?");
        ps.setString(1, title);
        ps.setString(2, spaceType);
        ps.setInt(3, capacity);
        ps.setDouble(4, hourlyRate);
        ps.setString(5, locationFloor);
        ps.setString(6, description);
        ps.setInt(7, spaceId);
        ps.executeUpdate();
        ps.close();

        response.sendRedirect("admin_dashboard.jsp?updated=1");
        return;
    }

    PreparedStatement psS = conn.prepareStatement("SELECT * FROM spaces WHERE space_id = ?");
    psS.setInt(1, spaceId);
    ResultSet rsS = psS.executeQuery();
    if (!rsS.next()) {
        rsS.close();
        psS.close();
        response.sendRedirect("admin_dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Edit Space - Admin</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Edit Coworking Space</h1>
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

            <h2>Update Workspace Details</h2>

            <form action="editspace.jsp?id=<%= spaceId %>" method="post">
                <label>Workspace Title</label>
                <input type="text" name="title" value="<%= rsS.getString("title") %>" required><br>

                <label>Category</label>
                <select name="space_type">
                    <option value="Desk" <%= "Desk".equalsIgnoreCase(rsS.getString("space_type")) ? "selected" : "" %>>Desk</option>
                    <option value="Cabin" <%= "Cabin".equalsIgnoreCase(rsS.getString("space_type")) ? "selected" : "" %>>Cabin</option>
                    <option value="Meeting Room" <%= "Meeting Room".equalsIgnoreCase(rsS.getString("space_type")) ? "selected" : "" %>>Meeting Room</option>
                </select><br>

                <label>Seating Capacity (Persons)</label>
                <input type="number" name="capacity" min="1" value="<%= rsS.getInt("capacity") %>" required><br>

                <label>Hourly Rate ($)</label>
                <input type="number" step="0.01" min="1" name="hourly_rate" value="<%= rsS.getDouble("hourly_rate") %>" required><br>

                <label>Floor Location</label>
                <input type="text" name="location_floor" value="<%= rsS.getString("location_floor") %>" required><br>

                <label>Amenities &amp; Description</label>
                <input type="text" name="description" value="<%= rsS.getString("description") %>" required><br>

                <div style="text-align:center; margin-top: 15px;">
                    <input type="submit" value="Update Workspace" class="btn-success">
                    <a href="admin_dashboard.jsp" class="btn">Cancel</a>
                </div>
            </form>
        </div>
    </body>
</html>
<%
    rsS.close();
    psS.close();
%>
