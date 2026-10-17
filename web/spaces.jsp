<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String userName = (String) session.getAttribute("user_name");
    String filterType = request.getParameter("type");
    if (filterType != null && filterType.trim().isEmpty()) {
        filterType = null;
    }
    String searchQuery = request.getParameter("search");
    if (searchQuery != null && searchQuery.trim().isEmpty()) {
        searchQuery = null;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>View Spaces - Coworking System</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Coworking Space Catalog</h1>
        </header>

        <div class="container">
            <% if (userName != null) { %>
                <div class="user-info">
                    <span>Signed in as <strong><%= userName %></strong></span>
                    <div>
                        <a href="home.jsp">Home</a>
                        <a href="history.jsp">My Bookings</a>
                        <a href="profile.jsp">My Profile</a>
                        <a href="logout.jsp" style="color:#e11d48;">Sign Out</a>
                    </div>
                </div>
            <% } %>

            <h2>Explore Available Workspaces</h2>
            <p style="text-align:center; color:#64748b; margin-top:-10px; margin-bottom:20px;">Reserve dedicated desks, private office cabins, or executive meeting rooms</p>

            <form action="spaces.jsp" method="get" class="search-form">
                <% if (filterType != null) { %>
                    <input type="hidden" name="type" value="<%= filterType %>">
                <% } %>
                <input type="text" name="search" value="<%= searchQuery != null ? searchQuery : "" %>" placeholder="Search by workspace title, floor, or amenity...">
                <input type="submit" value="Search" class="btn">
                <% if (searchQuery != null) { %>
                    <a href="spaces.jsp<%= filterType != null ? "?type=" + filterType : "" %>" class="btn btn-secondary">Clear</a>
                <% } %>
            </form>

            <div class="filter-bar">
                <a href="spaces.jsp<%= searchQuery != null ? "?search=" + searchQuery : "" %>" class="filter-pill <%= filterType == null ? "active" : "" %>">All Spaces</a>
                <a href="spaces.jsp?type=Desk<%= searchQuery != null ? "&search=" + searchQuery : "" %>" class="filter-pill <%= "Desk".equalsIgnoreCase(filterType) ? "active" : "" %>">Desks</a>
                <a href="spaces.jsp?type=Cabin<%= searchQuery != null ? "&search=" + searchQuery : "" %>" class="filter-pill <%= "Cabin".equalsIgnoreCase(filterType) ? "active" : "" %>">Private Cabins</a>
                <a href="spaces.jsp?type=Meeting Room<%= searchQuery != null ? "&search=" + searchQuery : "" %>" class="filter-pill <%= "Meeting Room".equalsIgnoreCase(filterType) ? "active" : "" %>">Meeting Rooms</a>
            </div>

            <table>
                <tr>
                    <th>Space Title</th>
                    <th>Category</th>
                    <th>Capacity</th>
                    <th>Hourly Rate</th>
                    <th>Location</th>
                    <th>Description</th>
                    <th style="text-align:right;">Action</th>
                </tr>
                <%
                    int rowCount = 0;
                    if (conn != null) {
                        PreparedStatement ps;
                        if (filterType != null && searchQuery != null) {
                            ps = conn.prepareStatement("SELECT * FROM spaces WHERE LOWER(space_type) = LOWER(?) AND (LOWER(title) LIKE ? OR LOWER(location_floor) LIKE ? OR LOWER(description) LIKE ?) ORDER BY space_id ASC");
                            String q = "%" + searchQuery.toLowerCase() + "%";
                            ps.setString(1, filterType);
                            ps.setString(2, q);
                            ps.setString(3, q);
                            ps.setString(4, q);
                        } else if (filterType != null) {
                            ps = conn.prepareStatement("SELECT * FROM spaces WHERE LOWER(space_type) = LOWER(?) ORDER BY space_id ASC");
                            ps.setString(1, filterType);
                        } else if (searchQuery != null) {
                            ps = conn.prepareStatement("SELECT * FROM spaces WHERE LOWER(title) LIKE ? OR LOWER(location_floor) LIKE ? OR LOWER(description) LIKE ? ORDER BY space_id ASC");
                            String q = "%" + searchQuery.toLowerCase() + "%";
                            ps.setString(1, q);
                            ps.setString(2, q);
                            ps.setString(3, q);
                        } else {
                            ps = conn.prepareStatement("SELECT * FROM spaces ORDER BY space_id ASC");
                        }
                        ResultSet rs = ps.executeQuery();
                        while(rs.next()) {
                            rowCount++;
                            String spaceType = rs.getString("space_type");
                %>
                <tr>
                    <td><strong style="color:#0f172a;"><%= rs.getString("title") %></strong></td>
                    <td><span class="badge badge-info"><%= spaceType %></span></td>
                    <td style="white-space:nowrap;"><%= rs.getInt("capacity") %> Person<%= rs.getInt("capacity") > 1 ? "s" : "" %></td>
                    <td style="white-space:nowrap;"><strong style="color:#059669;">$<%= String.format("%.2f", rs.getDouble("hourly_rate")) %></strong> <span style="color:#64748b; font-size:12px;">/ hr</span></td>
                    <td style="white-space:nowrap;"><%= rs.getString("location_floor") %></td>
                    <td style="color:#475569;"><%= rs.getString("description") %></td>
                    <td style="text-align:right; white-space:nowrap;">
                        <a href="book.jsp?id=<%= rs.getInt("space_id") %>" class="btn btn-success">Book Slot</a>
                    </td>
                </tr>
                <% 
                        }
                        rs.close();
                        ps.close();
                    } 
                    if (rowCount == 0) {
                %>
                <tr>
                    <td colspan="7" style="text-align:center; padding:24px; color:#64748b;">No workspaces matched your search or filter criteria.</td>
                </tr>
                <% } %>
            </table>

            <div class="button-center">
                <a href="home.jsp" class="btn btn-secondary">Back to Dashboard</a>
            </div>
        </div>
    </body>
</html>
