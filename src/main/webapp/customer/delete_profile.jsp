<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Assignment1.Customer.Customer" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Delete Account</title>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<%
    Customer u = (Customer) session.getAttribute("user");

    if (u == null) {
        response.sendRedirect(request.getContextPath() + "/customersServlet?action=retrieveUser");
        return;
    }
%>

<h2>Delete Account</h2>

<p>This action is <b>permanent</b>. Please enter your password to continue.</p>

<form method="post" action="<%= request.getContextPath() %>/customersServlet">
    <input type="hidden" name="action" value="delete">

    <label for="password">Password:</label>
    <input type="password" name="password" required>

    <br/><br/>

    <button type="submit">Confirm Delete</button>
    <a href="<%= request.getContextPath() %>/customer/edit_profile.jsp">Cancel</a>
</form>

<%@ include file="../includes/footer.jsp" %>
</body>
</html>
