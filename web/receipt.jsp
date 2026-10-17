<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    if (idStr == null || conn == null) {
        response.sendRedirect("history.jsp");
        return;
    }

    int bookingId = Integer.parseInt(idStr);
    PreparedStatement ps;
    if ("Admin".equalsIgnoreCase(role)) {
        ps = conn.prepareStatement("SELECT b.*, u.name AS member_name, u.email AS member_email, u.phone AS member_phone, s.title AS space_title, s.space_type, s.location_floor, s.hourly_rate, p.payment_method, p.status AS pay_status FROM bookings b LEFT JOIN users u ON b.user_id = u.user_id LEFT JOIN spaces s ON b.space_id = s.space_id LEFT JOIN payments p ON b.booking_id = p.booking_id WHERE b.booking_id = ?");
        ps.setInt(1, bookingId);
    } else {
        ps = conn.prepareStatement("SELECT b.*, u.name AS member_name, u.email AS member_email, u.phone AS member_phone, s.title AS space_title, s.space_type, s.location_floor, s.hourly_rate, p.payment_method, p.status AS pay_status FROM bookings b LEFT JOIN users u ON b.user_id = u.user_id LEFT JOIN spaces s ON b.space_id = s.space_id LEFT JOIN payments p ON b.booking_id = p.booking_id WHERE b.booking_id = ? AND b.user_id = ?");
        ps.setInt(1, bookingId);
        ps.setInt(2, userId);
    }

    ResultSet rs = ps.executeQuery();
    if (!rs.next()) {
        rs.close();
        ps.close();
        response.sendRedirect("history.jsp");
        return;
    }

    String memberName = rs.getString("member_name");
    String memberEmail = rs.getString("member_email");
    String memberPhone = rs.getString("member_phone");
    String spaceTitle = rs.getString("space_title");
    String spaceType = rs.getString("space_type");
    String locationFloor = rs.getString("location_floor");
    double hourlyRate = rs.getDouble("hourly_rate");
    String bookingDate = rs.getString("booking_date");
    String startTime = rs.getString("start_time");
    String endTime = rs.getString("end_time");
    int hours = rs.getInt("hours");
    double totalAmount = rs.getDouble("total_amount");
    String bStatus = rs.getString("status");
    String payMethod = rs.getString("payment_method");
    String payStatus = rs.getString("pay_status");
    rs.close();
    ps.close();
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Booking Receipt - Coworking System</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Coworking Space Booking System</h1>
        </header>

        <div class="container">
            <h2>Official Reservation Receipt</h2>

            <div class="receipt-box">
                <div style="text-align:center; margin-bottom:20px;">
                    <h3 style="text-align:center; margin:0 0 6px 0; font-size:18px; color:#0f172a;"><%= spaceTitle != null ? spaceTitle : "Workspace Reservation" %></h3>
                    <span class="badge badge-info"><%= spaceType != null ? spaceType : "Coworking" %></span>
                    <% if ("CONFIRMED".equalsIgnoreCase(bStatus)) { %>
                        <span class="badge badge-success" style="margin-left:6px;">Confirmed</span>
                    <% } else { %>
                        <span class="badge badge-danger" style="margin-left:6px;">Cancelled</span>
                    <% } %>
                </div>

                <div class="receipt-row">
                    <span>Member Name</span>
                    <strong style="color:#0f172a;"><%= memberName != null ? memberName : "Member" %></strong>
                </div>
                <div class="receipt-row">
                    <span>Email Address</span>
                    <strong style="color:#0f172a;"><%= memberEmail != null ? memberEmail : "-" %></strong>
                </div>
                <div class="receipt-row">
                    <span>Contact Phone</span>
                    <strong style="color:#0f172a;"><%= memberPhone != null ? memberPhone : "-" %></strong>
                </div>
                <div class="receipt-row">
                    <span>Floor Location</span>
                    <strong style="color:#0f172a;"><%= locationFloor != null ? locationFloor : "-" %></strong>
                </div>
                <div class="receipt-row">
                    <span>Reservation Date</span>
                    <strong style="color:#0f172a;"><%= bookingDate %></strong>
                </div>
                <div class="receipt-row">
                    <span>Time Window</span>
                    <strong style="color:#0f172a;"><%= startTime %> &ndash; <%= endTime %> (<%= hours %> hr<%= hours > 1 ? "s" : "" %>)</strong>
                </div>
                <div class="receipt-row">
                    <span>Hourly Rate</span>
                    <strong style="color:#0f172a;">$<%= String.format("%.2f", hourlyRate) %> / hr</strong>
                </div>
                <div class="receipt-row">
                    <span>Payment Method</span>
                    <strong style="color:#0f172a;"><%= payMethod != null ? payMethod : "Standard" %></strong>
                </div>
                <div class="receipt-row">
                    <span>Payment Status</span>
                    <% if ("Refunded".equalsIgnoreCase(payStatus) || "CANCELLED".equalsIgnoreCase(bStatus)) { %>
                        <span class="badge badge-warning">Refunded</span>
                    <% } else { %>
                        <span class="badge badge-success">Paid in Full</span>
                    <% } %>
                </div>

                <div class="receipt-total">
                    <span>Total Amount</span>
                    <span style="color:#4f46e5; font-size:20px; font-weight:800;">$<%= String.format("%.2f", totalAmount) %></span>
                </div>
            </div>

            <div class="button-center no-print">
                <button type="button" onclick="window.print()" class="btn btn-success">Print Receipt</button>
                <a href="history.jsp" class="btn">My Bookings</a>
                <% if ("Admin".equalsIgnoreCase(role)) { %>
                    <a href="admin_dashboard.jsp" class="btn btn-secondary">Back to Admin Panel</a>
                <% } %>
            </div>
        </div>
    </body>
</html>
