<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String role = (String) session.getAttribute("role");
    if (!"Admin".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String statusFilter = request.getParameter("status");
    if (statusFilter != null && statusFilter.trim().isEmpty()) {
        statusFilter = null;
    }

    String cancelBookingStr = request.getParameter("cancel_booking_id");
    if (cancelBookingStr != null && conn != null) {
        int cancelBId = Integer.parseInt(cancelBookingStr);
        PreparedStatement psCanB = conn.prepareStatement("UPDATE bookings SET status = 'CANCELLED' WHERE booking_id = ?");
        psCanB.setInt(1, cancelBId);
        psCanB.executeUpdate();
        psCanB.close();

        PreparedStatement psCanP = conn.prepareStatement("UPDATE payments SET status = 'Refunded' WHERE booking_id = ?");
        psCanP.setInt(1, cancelBId);
        psCanP.executeUpdate();
        psCanP.close();

        response.sendRedirect("admin_dashboard.jsp?cancelled=1");
        return;
    }

    String deleteIdStr = request.getParameter("delete_id");
    if (deleteIdStr != null && conn != null) {
        int delId = Integer.parseInt(deleteIdStr);
        PreparedStatement psDelPay = conn.prepareStatement("DELETE FROM payments WHERE booking_id IN (SELECT booking_id FROM bookings WHERE space_id = ?)");
        psDelPay.setInt(1, delId);
        psDelPay.executeUpdate();
        psDelPay.close();

        PreparedStatement psDelBook = conn.prepareStatement("DELETE FROM bookings WHERE space_id = ?");
        psDelBook.setInt(1, delId);
        psDelBook.executeUpdate();
        psDelBook.close();

        PreparedStatement psD = conn.prepareStatement("DELETE FROM spaces WHERE space_id = ?");
        psD.setInt(1, delId);
        psD.executeUpdate();
        psD.close();

        response.sendRedirect("admin_dashboard.jsp?deleted=1");
        return;
    }

    String adminMsg = null;
    if ("1".equals(request.getParameter("added"))) {
        adminMsg = "New coworking workspace added to catalog!";
    } else if ("1".equals(request.getParameter("updated"))) {
        adminMsg = "Workspace details updated successfully!";
    } else if ("1".equals(request.getParameter("deleted"))) {
        adminMsg = "Workspace listing and associated records removed.";
    } else if ("1".equals(request.getParameter("cancelled"))) {
        adminMsg = "Reservation cancelled and payment marked as Refunded.";
    }

    int totalSpaces = 0;
    int totalMembers = 0;
    int activeBookings = 0;
    double totalRevenue = 0.0;

    if (conn != null) {
        Statement stStats = conn.createStatement();
        ResultSet rsSt1 = stStats.executeQuery("SELECT COUNT(*) FROM spaces");
        if (rsSt1.next()) totalSpaces = rsSt1.getInt(1);
        rsSt1.close();

        ResultSet rsStUsers = stStats.executeQuery("SELECT COUNT(*) FROM users");
        if (rsStUsers.next()) totalMembers = rsStUsers.getInt(1);
        rsStUsers.close();

        ResultSet rsSt2 = stStats.executeQuery("SELECT COUNT(*), NVL(SUM(total_amount), 0) FROM bookings WHERE status = 'CONFIRMED'");
        if (rsSt2.next()) {
            activeBookings = rsSt2.getInt(1);
            totalRevenue = rsSt2.getDouble(2);
        }
        rsSt2.close();
        stStats.close();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Admin Dashboard - Coworking System</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Admin Control Panel</h1>
        </header>

        <div class="container">
            <div class="user-info">
                <span>Signed in as <strong>Administrator</strong></span>
                <div>
                    <a href="home.jsp">Member View</a>
                    <a href="profile.jsp">My Profile</a>
                    <a href="logout.jsp" style="color:#e11d48;">Sign Out</a>
                </div>
            </div>

            <% if (adminMsg != null) { %>
                <div class="alert-msg"><%= adminMsg %></div>
            <% } %>

            <h2>System Overview &amp; Space Management</h2>

            <div class="stats-grid">
                <div class="stat-card">
                    <span class="stat-label">Total Workspaces</span>
                    <span class="stat-value"><%= totalSpaces %></span>
                </div>
                <div class="stat-card">
                    <span class="stat-label">Registered Accounts</span>
                    <span class="stat-value"><%= totalMembers %></span>
                </div>
                <div class="stat-card">
                    <span class="stat-label">Confirmed Bookings</span>
                    <span class="stat-value" style="color:#4f46e5;"><%= activeBookings %></span>
                </div>
                <div class="stat-card">
                    <span class="stat-label">Confirmed Revenue</span>
                    <span class="stat-value" style="color:#059669;">$<%= String.format("%.2f", totalRevenue) %></span>
                </div>
            </div>

            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px; margin-bottom:8px;">
                <h3 style="margin:0;">Coworking Spaces Catalog</h3>
                <a href="addspace.jsp" class="btn btn-success">+ Add New Coworking Space</a>
            </div>
            <table>
                <tr>
                    <th>Title</th>
                    <th>Type</th>
                    <th>Capacity</th>
                    <th>Hourly Rate</th>
                    <th>Floor</th>
                    <th style="text-align:right;">Actions</th>
                </tr>
                <%
                    if (conn != null) {
                        Statement stmt1 = conn.createStatement();
                        ResultSet rs1 = stmt1.executeQuery("SELECT * FROM spaces ORDER BY space_id ASC");
                        while(rs1.next()) {
                %>
                <tr>
                    <td style="white-space:nowrap;"><strong style="color:#0f172a;"><%= rs1.getString("title") %></strong></td>
                    <td><span class="badge badge-info"><%= rs1.getString("space_type") %></span></td>
                    <td style="white-space:nowrap;"><%= rs1.getInt("capacity") %> Person<%= rs1.getInt("capacity") > 1 ? "s" : "" %></td>
                    <td style="white-space:nowrap;"><strong style="color:#059669;">$<%= String.format("%.2f", rs1.getDouble("hourly_rate")) %></strong> <span style="color:#64748b; font-size:12px;">/ hr</span></td>
                    <td style="white-space:nowrap;"><%= rs1.getString("location_floor") %></td>
                    <td style="text-align:right; white-space:nowrap;">
                        <a href="editspace.jsp?id=<%= rs1.getInt("space_id") %>" class="btn">Edit</a>
                        <a href="admin_dashboard.jsp?delete_id=<%= rs1.getInt("space_id") %>" class="btn btn-danger" onclick="return confirm('Delete this space listing?');">Delete</a>
                    </td>
                </tr>
                <% 
                        }
                        rs1.close();
                        stmt1.close();
                    } 
                %>
            </table>

            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:36px; margin-bottom:8px; flex-wrap:wrap; gap:10px;">
                <h3 style="margin:0;">All User Booking Reservations</h3>
                <div class="filter-bar" style="margin:0;">
                    <a href="admin_dashboard.jsp" class="filter-pill <%= statusFilter == null ? "active" : "" %>">All Bookings</a>
                    <a href="admin_dashboard.jsp?status=CONFIRMED" class="filter-pill <%= "CONFIRMED".equalsIgnoreCase(statusFilter) ? "active" : "" %>">Confirmed</a>
                    <a href="admin_dashboard.jsp?status=CANCELLED" class="filter-pill <%= "CANCELLED".equalsIgnoreCase(statusFilter) ? "active" : "" %>">Cancelled</a>
                </div>
            </div>
            <table>
                <tr>
                    <th>Member</th>
                    <th>Workspace</th>
                    <th>Date</th>
                    <th>Time Slot</th>
                    <th>Payment</th>
                    <th>Total ($)</th>
                    <th>Status</th>
                    <th style="text-align:right;">Action</th>
                </tr>
                <%
                    int bRowCount = 0;
                    if (conn != null) {
                        PreparedStatement ps2;
                        if (statusFilter != null) {
                            ps2 = conn.prepareStatement("SELECT b.*, u.name AS user_name, s.title AS space_title, p.payment_method, p.status AS pay_status FROM bookings b LEFT JOIN users u ON b.user_id = u.user_id LEFT JOIN spaces s ON b.space_id = s.space_id LEFT JOIN payments p ON b.booking_id = p.booking_id WHERE UPPER(b.status) = UPPER(?) ORDER BY b.booking_id DESC");
                            ps2.setString(1, statusFilter);
                        } else {
                            ps2 = conn.prepareStatement("SELECT b.*, u.name AS user_name, s.title AS space_title, p.payment_method, p.status AS pay_status FROM bookings b LEFT JOIN users u ON b.user_id = u.user_id LEFT JOIN spaces s ON b.space_id = s.space_id LEFT JOIN payments p ON b.booking_id = p.booking_id ORDER BY b.booking_id DESC");
                        }
                        ResultSet rs2 = ps2.executeQuery();
                        while(rs2.next()) {
                            bRowCount++;
                            String bStatus = rs2.getString("status");
                            String memberName = rs2.getString("user_name");
                            String spaceTitle = rs2.getString("space_title");
                            String payMethod = rs2.getString("payment_method");
                            int hrs = rs2.getInt("hours");
                %>
                <tr>
                    <td style="white-space:nowrap;"><strong style="color:#0f172a;"><%= memberName != null ? memberName : "Member" %></strong></td>
                    <td style="white-space:nowrap;"><%= spaceTitle != null ? spaceTitle : "Workspace" %></td>
                    <td style="white-space:nowrap;"><%= rs2.getString("booking_date") %></td>
                    <td style="white-space:nowrap;"><%= rs2.getString("start_time") %> &ndash; <%= rs2.getString("end_time") %> <span style="color:#64748b; font-size:12px;">(<%= hrs %>h)</span></td>
                    <td style="white-space:nowrap;"><span class="badge badge-info"><%= payMethod != null ? payMethod : "Standard" %></span></td>
                    <td style="white-space:nowrap;"><strong style="color:#059669;">$<%= String.format("%.2f", rs2.getDouble("total_amount")) %></strong></td>
                    <td style="white-space:nowrap;">
                        <% if ("CONFIRMED".equalsIgnoreCase(bStatus)) { %>
                            <span class="badge badge-success">Confirmed</span>
                        <% } else { %>
                            <span class="badge badge-danger">Cancelled &bull; Refunded</span>
                        <% } %>
                    </td>
                    <td style="text-align:right; white-space:nowrap;">
                        <% if ("CONFIRMED".equalsIgnoreCase(bStatus)) { %>
                            <a href="admin_dashboard.jsp?cancel_booking_id=<%= rs2.getInt("booking_id") %>" class="btn btn-danger" onclick="return confirm('Cancel this user reservation and issue a refund?');">Cancel</a>
                        <% } else { %>
                            <span style="color:#94a3b8; font-size:12px;">&mdash;</span>
                        <% } %>
                    </td>
                </tr>
                <% 
                        }
                        rs2.close();
                        ps2.close();
                    }
                    if (bRowCount == 0) {
                %>
                <tr>
                    <td colspan="8" style="text-align:center; color:#64748b; padding:24px;">No reservations match the selected status filter.</td>
                </tr>
                <% } %>
            </table>

            <h3 style="margin-top:36px;">Registered Members Directory</h3>
            <table>
                <tr>
                    <th>Full Name</th>
                    <th>Email Address</th>
                    <th>Phone Number</th>
                    <th>Account Role</th>
                    <th>Total Bookings</th>
                    <th>Confirmed Spend ($)</th>
                </tr>
                <%
                    if (conn != null) {
                        Statement stmt3 = conn.createStatement();
                        ResultSet rs3 = stmt3.executeQuery("SELECT u.name, u.email, u.phone, u.role, COUNT(b.booking_id) AS total_bookings, NVL(SUM(CASE WHEN b.status = 'CONFIRMED' THEN b.total_amount ELSE 0 END), 0) AS total_spent FROM users u LEFT JOIN bookings b ON u.user_id = b.user_id GROUP BY u.user_id, u.name, u.email, u.phone, u.role ORDER BY u.name ASC");
                        while (rs3.next()) {
                            String uRole = rs3.getString("role");
                %>
                <tr>
                    <td style="white-space:nowrap;"><strong style="color:#0f172a;"><%= rs3.getString("name") %></strong></td>
                    <td><%= rs3.getString("email") %></td>
                    <td style="white-space:nowrap;"><%= rs3.getString("phone") != null ? rs3.getString("phone") : "-" %></td>
                    <td>
                        <% if ("Admin".equalsIgnoreCase(uRole)) { %>
                            <span class="badge badge-info">Admin</span>
                        <% } else { %>
                            <span class="badge badge-success">Member</span>
                        <% } %>
                    </td>
                    <td style="white-space:nowrap;"><%= rs3.getInt("total_bookings") %> Reservation<%= rs3.getInt("total_bookings") == 1 ? "" : "s" %></td>
                    <td style="white-space:nowrap;"><strong style="color:#059669;">$<%= String.format("%.2f", rs3.getDouble("total_spent")) %></strong></td>
                </tr>
                <%
                        }
                        rs3.close();
                        stmt3.close();
                    }
                %>
            </table>
        </div>
    </body>
</html>
