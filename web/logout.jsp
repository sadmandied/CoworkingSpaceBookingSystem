<%@page import="java.sql.Connection" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Connection oldConn = (Connection) session.getAttribute("db_conn");
    if (oldConn != null) {
        try { oldConn.close(); } catch (Exception ignore) {}
    }
    session.invalidate();
    response.sendRedirect("login.jsp");
%>
