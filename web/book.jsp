<%@include file="connection.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String error = null;
    String idStr = request.getParameter("id");
    if (idStr == null) {
        response.sendRedirect("spaces.jsp");
        return;
    }

    if (conn == null) {
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Database Busy - Coworking System</title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Coworking Space Booking System</h1>
        </header>
        <div class="container">
            <div class="alert-err" style="text-align:center; padding:25px; margin:30px 0;">
                <h3 style="margin-top:0;">⚠️ Database Connection Temporarily Unavailable</h3>
                <p>The database is currently busy or reconnecting. Please refresh this page in a moment.</p>
                <div style="margin-top:20px;">
                    <a href="javascript:location.reload()" class="btn btn-success">↻ Refresh Page</a>
                    <a href="spaces.jsp" class="btn">Back to Spaces</a>
                </div>
            </div>
        </div>
    </body>
</html>
<%
        return;
    }

    int spaceId = Integer.parseInt(idStr);
    PreparedStatement psS = conn.prepareStatement("SELECT * FROM spaces WHERE space_id = ?");
    psS.setInt(1, spaceId);
    ResultSet rsS = psS.executeQuery();
    if (!rsS.next()) {
        response.sendRedirect("spaces.jsp");
        return;
    }

    String title = rsS.getString("title");
    String spaceType = rsS.getString("space_type");
    double hourlyRate = rsS.getDouble("hourly_rate");
    String todayStr = java.time.LocalDate.now().toString();

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String bookingDate = request.getParameter("booking_date");
        String startTime = request.getParameter("start_time");
        String endTime = request.getParameter("end_time");
        String paymentMethod = request.getParameter("payment_method");

        int startHour = Integer.parseInt(startTime.split(":")[0]);
        int endHour = Integer.parseInt(endTime.split(":")[0]);
        int hours = endHour - startHour;

        if (bookingDate == null || bookingDate.compareTo(todayStr) < 0) {
            error = "Booking date cannot be in the past! Please select today or a future date.";
        } else if (hours <= 0) {
            error = "End time must be after start time!";
        } else {
            PreparedStatement chk = conn.prepareStatement("SELECT COUNT(*) FROM bookings WHERE space_id = ? AND booking_date = ? AND status = 'CONFIRMED' AND ((start_time < ? AND end_time > ?) OR (start_time >= ? AND start_time < ?))");
            chk.setInt(1, spaceId);
            chk.setString(2, bookingDate);
            chk.setString(3, endTime);
            chk.setString(4, startTime);
            chk.setString(5, startTime);
            chk.setString(6, endTime);
            ResultSet rsChk = chk.executeQuery();
            rsChk.next();

            if (rsChk.getInt(1) > 0) {
                error = "Slot already booked! Please select another date or time.";
            } else {
                double totalAmount = hours * hourlyRate;

                PreparedStatement psB = conn.prepareStatement("INSERT INTO bookings (BOOKING_ID, USER_ID, SPACE_ID, BOOKING_DATE, START_TIME, END_TIME, HOURS, TOTAL_AMOUNT, STATUS) VALUES (booking_seq.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, 'CONFIRMED')");
                psB.setInt(1, userId);
                psB.setInt(2, spaceId);
                psB.setString(3, bookingDate);
                psB.setString(4, startTime);
                psB.setString(5, endTime);
                psB.setInt(6, hours);
                psB.setDouble(7, totalAmount);
                psB.executeUpdate();

                Statement stmtSeq = conn.createStatement();
                ResultSet rsSeq = stmtSeq.executeQuery("SELECT booking_seq.CURRVAL FROM DUAL");
                rsSeq.next();
                int bookingId = rsSeq.getInt(1);

                PreparedStatement psP = conn.prepareStatement("INSERT INTO payments (PAYMENT_ID, BOOKING_ID, PAYMENT_METHOD, AMOUNT, STATUS) VALUES (payment_seq.NEXTVAL, ?, ?, ?, 'Paid')");
                psP.setInt(1, bookingId);
                psP.setString(2, paymentMethod);
                psP.setDouble(3, totalAmount);
                psP.executeUpdate();

                response.sendRedirect("history.jsp?booked=1");
                return;
            }
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Book Space - <%= title %></title>
        <link rel="stylesheet" href="newcss.css">
    </head>
    <body>
        <header>
            <h1>Book Space: <%= title %></h1>
        </header>

        <div class="container">
            <h2>Reserve Workspace</h2>
            <p style="text-align:center; margin-top:-12px; margin-bottom:20px;">
                <span class="badge badge-info"><%= spaceType %></span> &nbsp; Rate: <strong style="color:#059669;">$<%= String.format("%.2f", hourlyRate) %> / hr</strong>
            </p>

            <% if (error != null) { %>
                <div class="alert-err"><%= error %></div>
            <% } %>

            <form action="book.jsp?id=<%= spaceId %>" method="post">
                <label>Booking Date</label>
                <input type="date" name="booking_date" min="<%= todayStr %>" value="<%= todayStr %>" required><br>

                <label>Start Time</label>
                <select name="start_time" id="start_time" onchange="updateBill()" required>
                    <option value="08:00">08:00 AM</option>
                    <option value="09:00">09:00 AM</option>
                    <option value="10:00">10:00 AM</option>
                    <option value="11:00">11:00 AM</option>
                    <option value="12:00">12:00 PM</option>
                    <option value="13:00">01:00 PM</option>
                    <option value="14:00">02:00 PM</option>
                    <option value="15:00">03:00 PM</option>
                    <option value="16:00">04:00 PM</option>
                    <option value="17:00">05:00 PM</option>
                </select><br>

                <label>End Time</label>
                <select name="end_time" id="end_time" onchange="updateBill()" required>
                    <option value="09:00">09:00 AM</option>
                    <option value="10:00">10:00 AM</option>
                    <option value="11:00">11:00 AM</option>
                    <option value="12:00">12:00 PM</option>
                    <option value="13:00">01:00 PM</option>
                    <option value="14:00">02:00 PM</option>
                    <option value="15:00">03:00 PM</option>
                    <option value="16:00">04:00 PM</option>
                    <option value="17:00">05:00 PM</option>
                    <option value="18:00">06:00 PM</option>
                </select><br>

                <label>Payment Method</label>
                <select name="payment_method" required>
                    <option value="Credit Card">Credit Card</option>
                    <option value="bKash">bKash</option>
                    <option value="Nagad">Nagad</option>
                    <option value="Cash at Desk">Cash at Desk</option>
                </select><br>

                <div class="bill-preview">
                    <span id="bill_duration">Duration: 1 hr</span>
                    <strong id="bill_total">Total: $<%= String.format("%.2f", hourlyRate) %></strong>
                </div>

                <div style="text-align:center; margin-top: 15px;">
                    <input type="submit" value="Confirm &amp; Pay Now" class="btn-success">
                    <a href="spaces.jsp" class="btn">Cancel</a>
                </div>
            </form>

            <h3 style="margin-top:34px; text-align:center;">Upcoming Reserved Slots for <%= title %></h3>
            <table style="max-width:650px; margin:12px auto 0 auto;">
                <tr>
                    <th>Date</th>
                    <th>Reserved Time Window</th>
                    <th>Duration</th>
                    <th>Availability</th>
                </tr>
                <%
                    int slotCount = 0;
                    PreparedStatement psTaken = conn.prepareStatement("SELECT booking_date, start_time, end_time, hours FROM bookings WHERE space_id = ? AND status = 'CONFIRMED' AND booking_date >= ? ORDER BY booking_date ASC, start_time ASC");
                    psTaken.setInt(1, spaceId);
                    psTaken.setString(2, todayStr);
                    ResultSet rsTaken = psTaken.executeQuery();
                    while (rsTaken.next()) {
                        slotCount++;
                %>
                <tr>
                    <td style="white-space:nowrap;"><strong style="color:#0f172a;"><%= rsTaken.getString("booking_date") %></strong></td>
                    <td style="white-space:nowrap;"><%= rsTaken.getString("start_time") %> &ndash; <%= rsTaken.getString("end_time") %></td>
                    <td style="white-space:nowrap;"><%= rsTaken.getInt("hours") %> hr<%= rsTaken.getInt("hours") > 1 ? "s" : "" %></td>
                    <td><span class="badge badge-danger">Booked</span></td>
                </tr>
                <%
                    }
                    rsTaken.close();
                    psTaken.close();
                    if (slotCount == 0) {
                %>
                <tr>
                    <td colspan="4" style="text-align:center; color:#059669; font-weight:500; padding:18px;">All upcoming time slots are currently open for this workspace!</td>
                </tr>
                <% } %>
            </table>
        </div>
        <script>
            function updateBill() {
                var rate = <%= hourlyRate %>;
                var s = parseInt(document.getElementById('start_time').value.split(':')[0], 10);
                var e = parseInt(document.getElementById('end_time').value.split(':')[0], 10);
                var hrs = e - s;
                if (hrs > 0) {
                    document.getElementById('bill_duration').textContent = 'Duration: ' + hrs + (hrs > 1 ? ' hrs' : ' hr');
                    document.getElementById('bill_total').textContent = 'Total: $' + (hrs * rate).toFixed(2);
                } else {
                    document.getElementById('bill_duration').textContent = 'Invalid time range';
                    document.getElementById('bill_total').textContent = 'End time must be after start';
                }
            }
        </script>
    </body>
</html>
