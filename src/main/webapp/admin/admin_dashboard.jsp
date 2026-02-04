<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="Assignment1.Customer.Customer"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>SilverCare Admin Dashboard</title>
    <%
    Object userRole = session.getAttribute("sessRole");
    if(userRole == null){
    	response.sendRedirect(request.getContextPath()+"/public/login.jsp?errCode=NoSession");
    	return;
    }
    String userRoleString = userRole.toString();
    if (!"admin".equals(userRoleString)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    Customer u = (Customer) session.getAttribute("user");
    if(u == null){
    	response.sendRedirect(request.getContextPath()+"/customersServlet?action=retrieveUser");
    	return;
    }
   
    %>

    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- GSAP (entrance animation only) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>

    <style>
        html, body {
            height: 100%;
        }

        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        .metric-card,
        .panel-card {
            transition:
                transform 0.25s cubic-bezier(0.16, 1, 0.3, 1),
                box-shadow 0.25s ease,
                border-color 0.22s ease,
                background-color 0.22s ease;
        }

        .metric-card:hover,
        .panel-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 16px 32px rgba(15, 23, 42, 0.16);
            border-color: rgba(148, 163, 184, 0.7);
            background-color: rgba(255, 255, 255, 0.98);
        }

        .text-mono {
            font-variant-numeric: tabular-nums;
        }
    </style>
</head>

<body class="bg-[#f7f4ef] text-slate-900">

<%@ include file="../includes/header.jsp" %>

<main id="adminRoot" class="mt-12 min-h-screen pt-24 pb-16 px-6 sm:px-10 lg:px-16">
    <div class="max-w-6xl xl:max-w-7xl mx-auto space-y-12">

        <!-- HEADER -->
        <section id="dashHeader">
            <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-6">
                <div class="space-y-3">
                    <h1 class="text-3xl sm:text-4xl lg:text-5xl font-semibold tracking-tight">
                        Admin Dashboard
                    </h1>
                    <p class="max-w-xl text-sm sm:text-base text-slate-700">
                        Review customers, services and feedback, and keep SilverCare running smoothly from one place.
                    </p>
                </div>

                <div class="flex items-center gap-4">
                    <div class="hidden sm:flex flex-col text-right text-[11px] text-slate-600">
                        <span>Today</span>
                        <span class="font-medium">System Overview</span>
                    </div>
                    <div class="flex items-center gap-3 rounded-2xl border border-slate-300/70 bg-white/90 px-4 py-3 shadow-sm">
                        <div class="text-xs sm:text-sm">
                            <p class="font-medium"><%= u.getFullName() %></p>
                            <p class="text-slate-500">Administration</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- METRIC CARDS -->
        <section id="metricSection">
            <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5 lg:gap-6">

                <!-- Total Customers -->
                <article class="metric-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6">
                    <p class="text-[11px] font-medium text-slate-500 uppercase tracking-wide">Total Customers</p>
                    <p class="text-3xl sm:text-4xl font-semibold mt-3 text-mono">
                        <c:choose>
                            <c:when test="${not empty totalCustomers}">${totalCustomers}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </p>
                    <p class="text-xs text-slate-500 mt-3">
                        Number of registered customers in the system.
                    </p>
                </article>

                <!-- Active Services -->
                <article class="metric-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6">
                    <p class="text-[11px] font-medium text-slate-500 uppercase tracking-wide">Active Services</p>
                    <p class="text-3xl sm:text-4xl font-semibold mt-3 text-mono">
                        <c:choose>
                            <c:when test="${not empty totalServices}">${totalServices}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </p>
                    <p class="text-xs text-slate-500 mt-3">
                        Services currently published and visible to customers.
                    </p>
                </article>

                <!-- Feedback Entries -->
                <article class="metric-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6">
                    <p class="text-[11px] font-medium text-slate-500 uppercase tracking-wide">Feedback Entries</p>
                    <p class="text-3xl sm:text-4xl font-semibold mt-3 text-mono">
                        <c:choose>
                            <c:when test="${not empty totalFeedback}">${totalFeedback}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </p>
                    <p class="text-xs text-slate-500 mt-3">
                        Feedback records collected from customers.
                    </p>
                </article>

                <!-- New Users (30 days) -->
                <article class="metric-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6">
                    <p class="text-[11px] font-medium text-slate-500 uppercase tracking-wide">New Users (30 Days)</p>
                    <p class="text-3xl sm:text-4xl font-semibold mt-3 text-mono">
                        <c:choose>
                            <c:when test="${not empty recentUsers}">${recentUsers}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </p>
                    <p class="text-xs text-slate-500 mt-3">
                        New registrations in the last thirty days.
                    </p>
                </article>

            </div>
        </section>

        <!-- QUICK ACTIONS + RECENT FEEDBACK -->
        <section id="middleSection">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

                <!-- QUICK ACTIONS -->
                <div class="lg:col-span-2 space-y-5">
                    <div class="flex items-center justify-between">
                        <h2 class="text-xl sm:text-2xl font-semibold tracking-tight">Quick Actions</h2>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-5 lg:gap-6">

                        <!-- Manage Services -->
                        <a href="${pageContext.request.contextPath}/admin/services/list"
                           class="panel-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6 flex flex-col">
                            <p class="text-[11px] text-slate-500 font-medium uppercase tracking-wide">Services</p>
                            <p class="text-base sm:text-lg font-semibold mt-3">Manage Services</p>
                            <p class="text-xs text-slate-600 mt-2">
                                Create new services or update existing details and pricing.
                            </p>
                            <span class="text-[11px] font-medium mt-4 pt-1 underline text-slate-800">
                                Go to services
                            </span>
                        </a>

                        <!-- Manage Customers -->
                        <a href="${pageContext.request.contextPath}/admin/customers/list"
                           class="panel-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6 flex flex-col">
                            <p class="text-[11px] text-slate-500 font-medium uppercase tracking-wide">Customers</p>
                            <p class="text-base sm:text-lg font-semibold mt-3">Manage Customers</p>
                            <p class="text-xs text-slate-600 mt-2">
                                View customer profiles and keep their contact information accurate.
                            </p>
                            <span class="text-[11px] font-medium mt-4 pt-1 underline text-slate-800">
                                Go to customers
                            </span>
                        </a>

                        <!-- Feedback -->
                        <a href="${pageContext.request.contextPath}/admin/feedback"
                           class="panel-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6 flex flex-col">
                            <p class="text-[11px] text-slate-500 font-medium uppercase tracking-wide">Feedback</p>
                            <p class="text-base sm:text-lg font-semibold mt-3">Review Feedback</p>
                            <p class="text-xs text-slate-600 mt-2">
                                Read comments from families and identify areas to improve.
                            </p>
                            <span class="text-[11px] font-medium mt-4 pt-1 underline text-slate-800">
                                Go to feedback
                            </span>
                        </a>

                    </div>
                </div>

                <!-- RECENT FEEDBACK -->
                <aside class="panel-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6">
                    <div class="flex items-center justify-between mb-3">
                        <h2 class="text-lg font-semibold tracking-tight">Recent Feedback</h2>
                        <a href="${pageContext.request.contextPath}/admin/adminFeedback.jsp"
                           class="text-[11px] text-slate-600 hover:underline">
                            View all
                        </a>
                    </div>

                    <div class="space-y-3 max-h-72 overflow-y-auto pr-1 text-xs">
                        <c:choose>
                            <c:when test="${not empty recentFeedback}">
                                <c:forEach items="${recentFeedback}" var="fb">
                                    <div class="rounded-xl border border-slate-200 px-4 py-3 bg-white">
                                        <p class="text-slate-500 mb-1">
                                            ${fb.user_name} · ${fb.service_name}
                                        </p>
                                        <p class="text-slate-800">
                                            ${fb.comments}
                                        </p>
                                        <p class="text-[11px] text-slate-400 mt-1">
                                            ${fb.created_at}
                                        </p>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <p class="text-slate-600">
                                    No recent feedback yet. New feedback will appear here once customers start submitting reviews.
                                </p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </aside>

            </div>
        </section>

        <!-- SYSTEM OVERVIEW + SHORTCUTS -->
        <section id="lowerSection" class="grid grid-cols-1 lg:grid-cols-2 gap-8">

            <!-- SYSTEM OVERVIEW -->
            <section class="panel-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6">
                <h2 class="text-lg font-semibold tracking-tight mb-3">System Overview</h2>
                <p class="text-xs text-slate-600 mb-4">
                    High-level indicators to understand how the platform is being used before diving into detailed pages.
                </p>

                <dl class="grid grid-cols-2 gap-x-6 gap-y-4 text-xs">
                    <div>
                        <dt class="text-slate-500">Total customers</dt>
                        <dd class="font-medium text-mono mt-1">
                            <c:choose>
                                <c:when test="${not empty totalCustomers}">${totalCustomers}</c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </dd>
                    </div>

                    <div>
                        <dt class="text-slate-500">Active services</dt>
                        <dd class="font-medium text-mono mt-1">
                            <c:choose>
                                <c:when test="${not empty totalServices}">${totalServices}</c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </dd>
                    </div>

                    <div>
                        <dt class="text-slate-500">Feedback entries</dt>
                        <dd class="font-medium text-mono mt-1">
                            <c:choose>
                                <c:when test="${not empty totalFeedback}">${totalFeedback}</c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </dd>
                    </div>

                    <div>
                        <dt class="text-slate-500">New users (30 days)</dt>
                        <dd class="font-medium text-mono mt-1">
                            <c:choose>
                                <c:when test="${not empty recentUsers}">${recentUsers}</c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </dd>
                    </div>
                </dl>

                <p class="text-[11px] text-slate-400 mt-4">
                    For deeper analysis, use the dedicated Services, Customers and Feedback pages. This section can later be extended with bookings or revenue if needed.
                </p>
            </section>

            <!-- SHORTCUTS -->
            <section class="panel-card bg-white/90 border border-slate-200 rounded-2xl px-5 py-5 sm:px-6 sm:py-6">
                <h2 class="text-lg font-semibold tracking-tight mb-3">Shortcuts</h2>
                <p class="text-xs text-slate-600 mb-4">
                    Jump directly to frequent actions without navigating through multiple screens.
                </p>

                <div class="space-y-3 text-xs">
                    <a href="${pageContext.request.contextPath}/admin/adminAddService.jsp"
                       class="flex items-center justify-between rounded-xl border border-slate-200 px-4 py-2.5 bg-white hover:bg-slate-50">
                        <span>Add a new service</span>
                        <span class="text-[11px] text-slate-500">Services · Add</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/adminServices.jsp"
                       class="flex items-center justify-between rounded-xl border border-slate-200 px-4 py-2.5 bg-white hover:bg-slate-50">
                        <span>Review all services</span>
                        <span class="text-[11px] text-slate-500">Services · List</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/manage_customers.jsp"
                       class="flex items-center justify-between rounded-xl border border-slate-200 px-4 py-2.5 bg-white hover:bg-slate-50">
                        <span>View customer directory</span>
                        <span class="text-[11px] text-slate-500">Customers</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/adminFeedback.jsp"
                       class="flex items-center justify-between rounded-xl border border-slate-200 px-4 py-2.5 bg-white hover:bg-slate-50">
                        <span>Check latest feedback</span>
                        <span class="text-[11px] text-slate-500">Feedback</span>
                    </a>
                </div>
            </section>

        </section>

    </div>
</main>

<script>
document.addEventListener("DOMContentLoaded", () => {
    const tl = gsap.timeline({ defaults: { duration: 0.6, ease: "power2.out" } });

    tl.from("#dashHeader", { y: 22, opacity: 0 })
      .from("#metricSection .metric-card", {
          y: 22,
          opacity: 0,
          stagger: 0.07
      }, "-=0.25")
      .from("#middleSection", {
          y: 24,
          opacity: 0
      }, "-=0.2")
      .from("#lowerSection", {
          y: 24,
          opacity: 0
      }, "-=0.25");
});
</script>

</body>
</html>