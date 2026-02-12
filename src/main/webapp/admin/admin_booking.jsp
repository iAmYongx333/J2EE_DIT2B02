<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Bookings – SilverCare</title>

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

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@0,400;0,500;0,600;1,400&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script>
    tailwind.config = {
        theme: {
            extend: {
                fontFamily: {
                    serif: ['Cormorant', 'Georgia', 'serif'],
                    sans: ['Outfit', 'system-ui', 'sans-serif'],
                },
                colors: {
                    stone: { warm: '#f5f3ef', mid: '#e8e4dc', deep: '#d4cec3' },
                    ink: { DEFAULT: '#2c2c2c', light: '#5a5a5a', muted: '#8a8a8a' },
                    copper: { DEFAULT: '#b87a4b', light: '#d4a574' },
                }
            }
        }
    }
    </script>
    <style>
    html { scroll-behavior: smooth; }
    body { -webkit-font-smoothing: antialiased; }

    .loader {
        position: fixed; inset: 0; background: #f5f3ef;
        display: flex; align-items: center; justify-content: center;
        z-index: 9999; transition: opacity 0.5s ease, visibility 0.5s ease;
    }
    .loader.hidden { opacity: 0; visibility: hidden; }
    .loader-bar {
        width: 120px; height: 2px; background: #e8e4dc; overflow: hidden;
    }
    .loader-bar::after {
        content: ''; display: block; width: 40%; height: 100%;
        background: #2c2c2c; animation: loadingBar 1s ease-in-out infinite;
    }
    @keyframes loadingBar {
        0% { transform: translateX(-100%); }
        100% { transform: translateX(350%); }
    }

    .page-content { opacity: 0; transition: opacity 0.6s ease; }
    .page-content.visible { opacity: 1; }

    .data-table {
        width: 100%;
        border-collapse: collapse;
    }
    .data-table th {
        background-color: #e8e4dc;
        padding: 12px;
        text-align: left;
        font-weight: 500;
        border-bottom: 2px solid #2c2c2c;
        font-size: 0.875rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .data-table td {
        padding: 16px 12px;
        border-bottom: 1px solid #e8e4dc;
    }
    .data-table tbody tr {
        transition: background-color 0.15s ease;
    }
    .data-table tbody tr:hover {
        background-color: #f5f3ef;
    }

    .status-badge {
        display: inline-block;
        padding: 4px 12px;
        font-size: 0.75rem;
        border-radius: 2px;
        font-weight: 500;
    }
    .status-confirmed { background: #d4f4dd; color: #1e7e34; }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-completed { background: #d1ecf1; color: #0c5460; }
    .status-cancelled { background: #f8d7da; color: #721c24; }
    </style>
</head>

<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
    <!-- Loading Screen -->
    <div class="loader" id="loader">
        <div class="text-center">
            <p class="font-serif text-2xl text-ink mb-6">SilverCare</p>
            <div class="loader-bar"></div>
        </div>
    </div>

    <div class="page-content" id="pageContent">
    <%@ include file="../includes/header.jsp" %>

    <main class="pt-24 pb-20 px-5 md:px-12">
        <div class="max-w-7xl mx-auto">

            <!-- Page Header -->
            <header class="mb-12">
                <span class="text-copper text-xs uppercase tracking-[0.2em]">Administration</span>
                <h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-3 mb-4">
                    Booking Management
                </h1>
                <p class="text-ink-light text-base md:text-lg max-w-2xl">
                    View and manage all customer care service bookings and appointments.
                </p>
            </header>

            <!-- Stats Cards -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Total Bookings</p>
                    <p class="font-serif text-3xl font-medium text-ink">
                        <c:choose>
                            <c:when test="${not empty bookings}">${bookings.size()}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Confirmed</p>
                    <p class="font-serif text-3xl font-medium text-green-700">
                        <c:set var="confirmed" value="0"/>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status == 'confirmed'}">
                                <c:set var="confirmed" value="${confirmed + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${confirmed}
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Pending</p>
                    <p class="font-serif text-3xl font-medium text-yellow-700">
                        <c:set var="pending" value="0"/>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status == 'pending'}">
                                <c:set var="pending" value="${pending + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${pending}
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Completed</p>
                    <p class="font-serif text-3xl font-medium text-blue-700">
                        <c:set var="completed" value="0"/>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status == 'completed'}">
                                <c:set var="completed" value="${completed + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${completed}
                    </p>
                </div>
            </div>

            <!-- Bookings Table -->
            <section class="bg-white border border-stone-mid">
                <div class="px-6 py-5 border-b border-stone-mid">
                    <h2 class="font-serif text-xl font-medium text-ink">All Bookings</h2>
                </div>

                <div class="overflow-x-auto">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Booking ID</th>
                                <th>Customer</th>
                                <th>Email</th>
                                <th>Service</th>
                                <th>Scheduled Date</th>
                                <th>Status</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${bookings}">
                                <tr>
                                    <td>
                                        <span class="font-medium text-sm">${b.bookingId}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink font-medium">${b.customerName}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink-light text-sm">${b.customerEmail}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink">${b.serviceName}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink-light">${b.bookingDate}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${b.status == 'confirmed'}">
                                                <span class="status-badge status-confirmed">Confirmed</span>
                                            </c:when>
                                            <c:when test="${b.status == 'pending'}">
                                                <span class="status-badge status-pending">Pending</span>
                                            </c:when>
                                            <c:when test="${b.status == 'completed'}">
                                                <span class="status-badge status-completed">Completed</span>
                                            </c:when>
                                            <c:when test="${b.status == 'cancelled'}">
                                                <span class="status-badge status-cancelled">Cancelled</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge" style="background: #e8e4dc; color: #2c2c2c;">${b.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-right">
                                        <form method="post" action="${pageContext.request.contextPath}/admin/bookings/delete" class="inline">
                                            <input type="hidden" name="bookingId" value="${b.bookingId}">
                                            <button type="submit" class="text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 hover:bg-red-50 transition-colors">
                                                Delete
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty bookings}">
                                <tr>
                                    <td colspan="7" class="text-center py-12">
                                        <svg class="w-10 h-10 text-stone-deep mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                                        </svg>
                                        <p class="text-sm text-ink-muted">No bookings found</p>
                                        <p class="text-xs text-ink-muted mt-1">Bookings will appear here when customers make appointments</p>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </section>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <script>
    window.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 500);
    });
    </script>
</body>
</html>
