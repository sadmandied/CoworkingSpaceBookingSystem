<%@page import="java.sql.*" %>
<%
    response.setCharacterEncoding("UTF-8");

    Connection conn = (Connection) session.getAttribute("db_conn");
    try {
        if (conn == null || conn.isClosed()) {
            String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
            String dbUser = "SYSTEM";
            String dbPassword = "298056";

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                for (int attempt = 0; attempt < 3; attempt++) {
                    try {
                        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
                        if (conn != null && !conn.isClosed()) {
                            session.setAttribute("db_conn", conn);
                            break;
                        }
                    } catch (SQLException sqle) {
                        if (attempt < 2) {
                            try { Thread.sleep(300 * (attempt + 1)); } catch (Exception ignore) {}
                        } else {
                            conn = null;
                        }
                    } catch (Exception anyEx) {
                        conn = null;
                    }
                }
            } catch (Exception e) {
                conn = null;
            }

            if (conn != null) {
                Statement checkStmt = null;
                try {
                    checkStmt = conn.createStatement();
                    ResultSet rsCheck = checkStmt.executeQuery("SELECT 1 FROM users WHERE ROWNUM = 1");
                    rsCheck.close();
                    checkStmt.close();
                } catch (SQLException ex) {
                    if (checkStmt != null) try { checkStmt.close(); } catch (Exception ignore) {}
                    Statement setupStmt = null;
                    try {
                        setupStmt = conn.createStatement();
                        try { setupStmt.execute("CREATE SEQUENCE user_seq START WITH 1 INCREMENT BY 1"); } catch (Exception e) {}
                        try { setupStmt.execute("CREATE SEQUENCE space_seq START WITH 1 INCREMENT BY 1"); } catch (Exception e) {}
                        try { setupStmt.execute("CREATE SEQUENCE booking_seq START WITH 1 INCREMENT BY 1"); } catch (Exception e) {}
                        try { setupStmt.execute("CREATE SEQUENCE payment_seq START WITH 1 INCREMENT BY 1"); } catch (Exception e) {}

                        setupStmt.execute("CREATE TABLE users (user_id NUMBER PRIMARY KEY, name VARCHAR2(100), email VARCHAR2(100), password VARCHAR2(100), phone VARCHAR2(20), role VARCHAR2(20))");
                        setupStmt.execute("CREATE TABLE spaces (space_id NUMBER PRIMARY KEY, title VARCHAR2(100), space_type VARCHAR2(50), capacity NUMBER, hourly_rate NUMBER, location_floor VARCHAR2(50), description VARCHAR2(200))");
                        setupStmt.execute("CREATE TABLE bookings (booking_id NUMBER PRIMARY KEY, user_id NUMBER, space_id NUMBER, booking_date VARCHAR2(20), start_time VARCHAR2(10), end_time VARCHAR2(10), hours NUMBER, total_amount NUMBER, status VARCHAR2(20))");
                        setupStmt.execute("CREATE TABLE payments (payment_id NUMBER PRIMARY KEY, booking_id NUMBER, payment_method VARCHAR2(50), amount NUMBER, status VARCHAR2(20))");

                        setupStmt.execute("INSERT INTO users VALUES (user_seq.NEXTVAL, 'Admin User', 'admin@cowork.com', 'admin123', '01700000000', 'Admin')");
                        setupStmt.execute("INSERT INTO users VALUES (user_seq.NEXTVAL, 'John Member', 'john@gmail.com', '1234', '01811111111', 'Member')");

                        setupStmt.execute("INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Dedicated Desk A1', 'Desk', 1, 10, 'Floor 2', 'Single desk with Wi-Fi and power outlet')");
                        setupStmt.execute("INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Flexi Hot Desk B04', 'Desk', 1, 8, 'Floor 2', 'Hot desk in open coworking space')");
                        setupStmt.execute("INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Private Cabin C101', 'Cabin', 4, 35, 'Floor 3', 'Soundproof private glass office cabin')");
                        setupStmt.execute("INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Team Suite C105', 'Cabin', 8, 55, 'Floor 3', 'Spacious private cabin for small teams')");
                        setupStmt.execute("INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Conference Room M01', 'Meeting Room', 12, 75, 'Floor 4', 'Conference room with 4K screen & whiteboard')");
                        setupStmt.close();
                    } catch (Exception setupEx) {
                        if (setupStmt != null) try { setupStmt.close(); } catch (Exception ignore) {}
                    }
                }
            } else {
                out.println("<div style='background:rgba(244,63,94,0.15); color:#fb7185; padding:15px; font-family:sans-serif; margin:15px; border-radius:8px; border:1px solid rgba(251,113,133,0.3); text-align:center;'>");
                out.println("<strong style='font-size:16px;'>[!] Oracle Database Busy (ORA-12519)</strong><br>");
                out.println("<span style='font-size:13px;'>Oracle connection process limit reached. Please refresh the page in a moment.</span>");
                out.println("</div>");
            }
        }
    } catch (Exception chkErr) {
    }
%>
