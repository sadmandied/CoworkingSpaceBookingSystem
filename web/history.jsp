<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String userName = (String) session.getAttribute("user_name");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String statusFilter = request.getParameter("status");
    if (statusFilter != null && statusFilter.trim().isEmpty()) {
        statusFilter = null;
    }

    String cancelIdStr = request.getParameter("cancel_id");
    if (cancelIdStr != null && conn != null) {
        int cancelId = Integer.parseInt(cancelIdStr);
        PreparedStatement psC = conn.prepareStatement("UPDATE bookings SET status = 'CANCELLED' WHERE booking_id = ? AND user_id = ?");
        psC.setInt(1, cancelId);
        psC.setInt(2, userId);
        int updated = psC.executeUpdate();
        psC.close();

        if (updated > 0) {
            PreparedStatement psRef = conn.prepareStatement("UPDATE payments SET status = 'Refunded' WHERE booking_id = ?");
            psRef.setInt(1, cancelId);
            psRef.executeUpdate();
            psRef.close();
        }
        response.sendRedirect("history.jsp?cancelled=1");
        return;
    }

    String msg = null;
    if ("1".equals(request.getParameter("booked"))) {
        msg = "Reservation slot booked and payment recorded successfully!";
    } else if ("1".equals(request.getParameter("cancelled"))) {
        msg = "Booking cancelled and payment marked as Refunded.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>My Bookings - Coworking System</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>My Booking History</h1>
        </header>

        <div class="container">
            <div class="user-info">
                <span>Signed in as <strong><%= userName %></strong></span>
                <div>
                    <a href="home.jsp">Home</a>
                    <a href="spaces.jsp">Explore Spaces</a>
                    <a href="profile.jsp">My Profile</a>
                    <a href="logout.jsp" style="color:#e11d48;">Sign Out</a>
                </div>
            </div>

            <% if (msg != null) { %>
                <div class="alert-msg"><%= msg %></div>
            <% } %>

            <h2>Your Space Reservations</h2>

            <div class="filter-bar">
                <a href="history.jsp" class="filter-pill <%= statusFilter == null ? "active" : "" %>">All Reservations</a>
                <a href="history.jsp?status=CONFIRMED" class="filter-pill <%= "CONFIRMED".equalsIgnoreCase(statusFilter) ? "active" : "" %>">Confirmed</a>
                <a href="history.jsp?status=CANCELLED" class="filter-pill <%= "CANCELLED".equalsIgnoreCase(statusFilter) ? "active" : "" %>">Cancelled</a>
            </div>

            <table>
                <tr>
                    <th>Space Title</th>
                    <th>Date</th>
                    <th>Time Slot</th>
                    <th>Payment</th>
                    <th>Total Amount</th>
                    <th>Status</th>
                    <th style="text-align:right;">Actions</th>
                </tr>
                <%
                    int count = 0;
                    if (conn != null) {
                        PreparedStatement ps;
                        if (statusFilter != null) {
                            ps = conn.prepareStatement("SELECT b.*, s.title, p.payment_method, p.status AS pay_status FROM bookings b JOIN spaces s ON b.space_id = s.space_id LEFT JOIN payments p ON b.booking_id = p.booking_id WHERE b.user_id = ? AND UPPER(b.status) = UPPER(?) ORDER BY b.booking_id DESC");
                            ps.setInt(1, userId);
                            ps.setString(2, statusFilter);
                        } else {
                            ps = conn.prepareStatement("SELECT b.*, s.title, p.payment_method, p.status AS pay_status FROM bookings b JOIN spaces s ON b.space_id = s.space_id LEFT JOIN payments p ON b.booking_id = p.booking_id WHERE b.user_id = ? ORDER BY b.booking_id DESC");
                            ps.setInt(1, userId);
                        }
                        ResultSet rs = ps.executeQuery();
                        while(rs.next()) {
                            count++;
                            String status = rs.getString("status");
                            String payMethod = rs.getString("payment_method");
                            int hrs = rs.getInt("hours");
                %>
                <tr>
                    <td style="white-space:nowrap;"><strong style="color:#0f172a;"><%= rs.getString("title") %></strong></td>
                    <td style="white-space:nowrap;"><%= rs.getString("booking_date") %></td>
                    <td style="white-space:nowrap;"><%= rs.getString("start_time") %> &ndash; <%= rs.getString("end_time") %> <span style="color:#64748b; font-size:12px;">(<%= hrs %>h)</span></td>
                    <td style="white-space:nowrap;"><span class="badge badge-info"><%= payMethod != null ? payMethod : "Standard" %></span></td>
                    <td style="white-space:nowrap;"><strong style="color:#059669;">$<%= String.format("%.2f", rs.getDouble("total_amount")) %></strong></td>
                    <td style="white-space:nowrap;">
                        <% if ("CONFIRMED".equalsIgnoreCase(status)) { %>
                            <span class="badge badge-success">Confirmed</span>
                        <% } else if ("CANCELLED".equalsIgnoreCase(status)) { %>
                            <span class="badge badge-danger">Cancelled &bull; Refunded</span>
                        <% } else { %>
                            <span class="badge badge-info"><%= status %></span>
                        <% } %>
                    </td>
                    <td style="text-align:right; white-space:nowrap;">
                        <a href="receipt.jsp?id=<%= rs.getInt("booking_id") %>" class="btn">Receipt</a>
                        <% if ("CONFIRMED".equalsIgnoreCase(status)) { %>
                            <a href="history.jsp?cancel_id=<%= rs.getInt("booking_id") %>" class="btn btn-danger" onclick="return confirm('Cancel this booking reservation?');">Cancel</a>
                        <% } %>
                    </td>
                </tr>
                <% 
                        }
                        rs.close();
                        ps.close();
                    } 
                    if (count == 0) {
                %>
                <tr>
                    <td colspan="7" style="text-align:center; color:#64748b; padding:24px;">No reservations found for this filter.</td>
                </tr>
                <% } %>
            </table>

            <div class="button-center">
                <a href="spaces.jsp" class="btn btn-success">+ Book New Space</a>
                <a href="home.jsp" class="btn btn-secondary">Back to Dashboard</a>
            </div>
        </div>
    </body>
</html>
