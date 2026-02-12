<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Bookings – SilverCare</title>
</head>

<body>
<%
        Object userRole = session.getAttribute("sessRole");
        if (userRole == null) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            return;
        }
        String userRoleString = userRole.toString();
        if (!"admin".equals(userRoleString)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
    %>

<%@ include file="../includes/header.jsp" %>

<main style="padding:40px; max-width:1200px; margin:auto;">

    <h2>Booking Management</h2>
    <p>View and manage all care schedules</p>

    <table border="1" cellpadding="10" cellspacing="0" width="100%">
        <thead>
            <tr>
                <th>ID</th>
                <th>Customer</th>
                <th>Service</th>
                <th>Date</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>

        <tbody>
            <c:forEach var="b" items="${bookings}">
                <tr>
                    <td>${b.bookingId}</td>
                    <td>${b.customerName}</td>
                    <td>${b.serviceName}</td>
                    <td>${b.bookingDate}</td>
                    <td>${b.status}</td>
                    <td>
                        <form method="post" action="${pageContext.request.contextPath}/admin/bookings/delete">
                            <input type="hidden" name="bookingId" value="${b.bookingId}">
                            <button type="submit">Delete</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>

            <c:if test="${empty bookings}">
                <tr>
                    <td colspan="6" align="center">No bookings found</td>
                </tr>
            </c:if>
        </tbody>
    </table>

</main>

<%@ include file="../includes/footer.jsp" %>

</body>
</html>
