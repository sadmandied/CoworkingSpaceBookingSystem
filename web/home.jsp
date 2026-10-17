<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String userName = (String) session.getAttribute("user_name");
    String role = (String) session.getAttribute("role");
    if (userName == null || userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int availableSpaces = 0;
    int myActiveBookings = 0;
    double myTotalSpent = 0.0;
    String todayStr = java.time.LocalDate.now().toString();

    if (conn != null) {
        Statement st = conn.createStatement();
        ResultSet rs1 = st.executeQuery("SELECT COUNT(*) FROM spaces");
        if (rs1.next()) availableSpaces = rs1.getInt(1);
        rs1.close();
        st.close();

        PreparedStatement psM = conn.prepareStatement("SELECT COUNT(*), NVL(SUM(total_amount), 0) FROM bookings WHERE user_id = ? AND status = 'CONFIRMED'");
        psM.setInt(1, userId);
        ResultSet rs2 = psM.executeQuery();
        if (rs2.next()) {
            myActiveBookings = rs2.getInt(1);
            myTotalSpent = rs2.getDouble(2);
        }
        rs2.close();
        psM.close();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Home - Coworking Space Booking System</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Coworking Space Booking System</h1>
        </header>

        <div class="container">
            <div class="user-info">
                <span>Welcome, <strong><%= userName %></strong> <span class="badge badge-info" style="margin-left:6px;"><%= role %></span></span>
                <div>
                    <a href="spaces.jsp">Explore Spaces</a>
                    <a href="history.jsp">My Bookings</a>
                    <a href="profile.jsp">My Profile</a>
                    <a href="logout.jsp" style="color:#e11d48;">Sign Out</a>
                </div>
            </div>

            <h2>Member Dashboard</h2>
            <p style="text-align:center; margin-top:-12px; margin-bottom:24px;">Manage your workspace reservations and explore available rooms</p>

            <div class="stats-grid">
                <div class="stat-card">
                    <span class="stat-label">Available Workspaces</span>
                    <span class="stat-value"><%= availableSpaces %></span>
                </div>
                <div class="stat-card">
                    <span class="stat-label">My Active Bookings</span>
                    <span class="stat-value" style="color:#4f46e5;"><%= myActiveBookings %></span>
                </div>
                <div class="stat-card">
                    <span class="stat-label">My Total Spent</span>
                    <span class="stat-value" style="color:#059669;">$<%= String.format("%.2f", myTotalSpent) %></span>
                </div>
            </div>

            <div class="button-center" style="margin-bottom:32px;">
                <a href="spaces.jsp" class="btn btn-success">View &amp; Book Spaces</a>
                <a href="history.jsp" class="btn">My Booking History</a>
                <a href="profile.jsp" class="btn">Account Settings</a>
                <% if ("Admin".equalsIgnoreCase(role)) { %>
                    <a href="admin_dashboard.jsp" class="btn">Admin Panel</a>
                <% } %>
            </div>

            <h3>Your Upcoming Confirmed Schedule</h3>
            <table>
                <tr>
                    <th>Workspace</th>
                    <th>Category</th>
                    <th>Floor</th>
                    <th>Date</th>
                    <th>Time Window</th>
                    <th>Total</th>
                    <th style="text-align:right;">Receipt</th>
                </tr>
                <%
                    int upCount = 0;
                    if (conn != null) {
                        PreparedStatement psUp = conn.prepareStatement("SELECT b.*, s.title, s.space_type, s.location_floor FROM bookings b JOIN spaces s ON b.space_id = s.space_id WHERE b.user_id = ? AND b.status = 'CONFIRMED' AND b.booking_date >= ? ORDER BY b.booking_date ASC, b.start_time ASC");
                        psUp.setInt(1, userId);
                        psUp.setString(2, todayStr);
                        ResultSet rsUp = psUp.executeQuery();
                        while (rsUp.next()) {
                            upCount++;
                %>
                <tr>
                    <td><strong style="color:#0f172a;"><%= rsUp.getString("title") %></strong></td>
                    <td><span class="badge badge-info"><%= rsUp.getString("space_type") %></span></td>
                    <td style="white-space:nowrap;"><%= rsUp.getString("location_floor") %></td>
                    <td style="white-space:nowrap;"><%= rsUp.getString("booking_date") %></td>
                    <td style="white-space:nowrap;"><%= rsUp.getString("start_time") %> &ndash; <%= rsUp.getString("end_time") %></td>
                    <td style="white-space:nowrap;"><strong style="color:#059669;">$<%= String.format("%.2f", rsUp.getDouble("total_amount")) %></strong></td>
                    <td style="text-align:right; white-space:nowrap;">
                        <a href="receipt.jsp?id=<%= rsUp.getInt("booking_id") %>" class="btn">Receipt</a>
                    </td>
                </tr>
                <%
                        }
                        rsUp.close();
                        psUp.close();
                    }
                    if (upCount == 0) {
                %>
                <tr>
                    <td colspan="7" style="text-align:center; color:#64748b; padding:20px;">You have no upcoming reservations scheduled. Click <strong>View &amp; Book Spaces</strong> above to reserve a workspace!</td>
                </tr>
                <% } %>
            </table>
        </div>
    </body>
</html>
