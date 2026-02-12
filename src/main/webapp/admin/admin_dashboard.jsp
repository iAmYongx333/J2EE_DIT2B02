<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="Assignment1.Customer.Customer" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard – SilverCare</title>

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
        Customer u = (Customer) session.getAttribute("user");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/customersServlet?action=retrieveUser");
            return;
        }
    %>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@0,400;0,500;0,600;1,400&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
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
        position: fixed;
        inset: 0;
        background: #f5f3ef;
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        transition: opacity 0.5s ease, visibility 0.5s ease;
    }
    .loader.hidden { opacity: 0; visibility: hidden; }
    .loader-bar {
        width: 120px;
        height: 2px;
        background: #e8e4dc;
        overflow: hidden;
    }
    .loader-bar::after {
        content: '';
        display: block;
        width: 40%;
        height: 100%;
        background: #2c2c2c;
        animation: loadingBar 1s ease-in-out infinite;
    }
    @keyframes loadingBar {
        0% { transform: translateX(-100%); }
        100% { transform: translateX(350%); }
    }

    .page-content { opacity: 0; transition: opacity 0.6s ease; }
    .page-content.visible { opacity: 1; }

    .stagger-1 { animation: fadeSlideIn 0.6s ease 0.1s both; }
    .stagger-2 { animation: fadeSlideIn 0.6s ease 0.2s both; }
    .stagger-3 { animation: fadeSlideIn 0.6s ease 0.3s both; }
    .stagger-4 { animation: fadeSlideIn 0.6s ease 0.4s both; }
    .stagger-5 { animation: fadeSlideIn 0.6s ease 0.5s both; }

    @keyframes fadeSlideIn {
        from { opacity: 0; transform: translateY(16px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .metric-card {
        transition: transform 0.2s ease, border-color 0.2s ease;
    }
    .metric-card:hover {
        transform: translateY(-2px);
        border-color: #2c2c2c;
    }

    .action-card {
        transition: transform 0.2s ease, border-color 0.2s ease;
    }
    .action-card:hover {
        transform: translateY(-2px);
        border-color: #2c2c2c;
    }

    .shortcut-item {
        transition: background-color 0.15s ease, border-color 0.15s ease;
    }
    .shortcut-item:hover {
        background-color: #f5f3ef;
        border-color: #2c2c2c;
    }

    .text-mono {
        font-variant-numeric: tabular-nums;
    }
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
                <div class="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6">
                    <div>
                        <span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Administration</span>
                        <h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-3 mb-4 stagger-2">
                            Dashboard
                        </h1>
                        <p class="text-ink-light text-base max-w-xl leading-relaxed stagger-3">
                            Manage customers, services, and feedback. Monitor platform activity from this central hub.
                        </p>
                    </div>

                    <div class="stagger-3">
                        <div class="bg-white border border-stone-mid px-5 py-4 inline-flex items-center gap-4">
                            <div class="w-10 h-10 bg-stone-mid flex items-center justify-center">
                                <span class="font-serif text-lg text-ink"><%= u.getName().substring(0, 1).toUpperCase() %></span>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-ink"><%= u.getName() %></p>
                                <p class="text-xs text-ink-muted">Administrator</p>
                            </div>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Metric Cards -->
            <section class="mb-12 stagger-3">
                <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">

                    <!-- Total Customers -->
                    <article class="metric-card bg-white border border-stone-mid p-6">
                        <div class="flex items-center justify-between mb-4">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Customers</span>
                            <svg class="w-5 h-5 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
                            </svg>
                        </div>
                        <p class="font-serif text-4xl font-medium text-ink text-mono">
                            <c:choose>
                                <c:when test="${not empty totalCustomers}">${totalCustomers}</c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </p>
                        <p class="text-xs text-ink-muted mt-2">Total registered users</p>
                    </article>

                    <!-- Active Services -->
                    <article class="metric-card bg-white border border-stone-mid p-6">
                        <div class="flex items-center justify-between mb-4">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Services</span>
                            <svg class="w-5 h-5 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                            </svg>
                        </div>
                        <p class="font-serif text-4xl font-medium text-ink text-mono">
                            <c:choose>
                                <c:when test="${not empty totalServices}">${totalServices}</c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </p>
                        <p class="text-xs text-ink-muted mt-2">Active care services</p>
                    </article>

                    <!-- Feedback -->
                    <article class="metric-card bg-white border border-stone-mid p-6">
                        <div class="flex items-center justify-between mb-4">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Feedback</span>
                            <svg class="w-5 h-5 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                            </svg>
                        </div>
                        <p class="font-serif text-4xl font-medium text-ink text-mono">
                            <c:choose>
                                <c:when test="${not empty totalFeedback}">${totalFeedback}</c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </p>
                        <p class="text-xs text-ink-muted mt-2">Customer reviews</p>
                    </article>

                    <!-- New Users -->
                    <article class="metric-card bg-white border border-stone-mid p-6">
                        <div class="flex items-center justify-between mb-4">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">New (30 days)</span>
                            <svg class="w-5 h-5 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"/>
                            </svg>
                        </div>
                        <p class="font-serif text-4xl font-medium text-ink text-mono">
                            <c:choose>
                                <c:when test="${not empty recentUsers}">${recentUsers}</c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </p>
                        <p class="text-xs text-ink-muted mt-2">Recent registrations</p>
                    </article>

                </div>
            </section>

            <!-- Quick Actions + Recent Feedback -->
            <section class="mb-12 grid grid-cols-1 lg:grid-cols-3 gap-8">

                <!-- Quick Actions -->
                <div class="lg:col-span-2 stagger-4">
                    <div class="flex items-center justify-between mb-6">
                        <h2 class="font-serif text-2xl font-medium text-ink">Quick Actions</h2>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">

                        <!-- Manage Services -->
                        <a href="${pageContext.request.contextPath}/admin/services/list" class="action-card bg-white border border-stone-mid p-6 flex flex-col">
                            <div class="w-10 h-10 bg-stone-mid flex items-center justify-center mb-4">
                                <svg class="w-5 h-5 text-ink" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                                </svg>
                            </div>
                            <span class="text-xs uppercase tracking-wide text-copper mb-2">Services</span>
                            <h3 class="font-serif text-lg font-medium text-ink mb-2">Manage Services</h3>
                            <p class="text-sm text-ink-muted flex-1">Create, edit, or remove care service offerings.</p>
                            <span class="text-xs text-ink mt-4 inline-flex items-center gap-1">
                                Go to services
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                                </svg>
                            </span>
                        </a>

                        <!-- Manage Customers -->
                        <a href="${pageContext.request.contextPath}/admin/customers/list" class="action-card bg-white border border-stone-mid p-6 flex flex-col">
                            <div class="w-10 h-10 bg-stone-mid flex items-center justify-center mb-4">
                                <svg class="w-5 h-5 text-ink" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                                </svg>
                            </div>
                            <span class="text-xs uppercase tracking-wide text-copper mb-2">Customers</span>
                            <h3 class="font-serif text-lg font-medium text-ink mb-2">Manage Customers</h3>
                            <p class="text-sm text-ink-muted flex-1">View and update customer profiles and accounts.</p>
                            <span class="text-xs text-ink mt-4 inline-flex items-center gap-1">
                                Go to customers
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                                </svg>
                            </span>
                        </a>

                        <!-- Review Feedback -->
                        <a href="${pageContext.request.contextPath}/admin/feedback" class="action-card bg-white border border-stone-mid p-6 flex flex-col">
                            <div class="w-10 h-10 bg-stone-mid flex items-center justify-center mb-4">
                                <svg class="w-5 h-5 text-ink" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                                </svg>
                            </div>
                            <span class="text-xs uppercase tracking-wide text-copper mb-2">Feedback</span>
                            <h3 class="font-serif text-lg font-medium text-ink mb-2">Review Feedback</h3>
                            <p class="text-sm text-ink-muted flex-1">Read customer reviews and identify improvements.</p>
                            <span class="text-xs text-ink mt-4 inline-flex items-center gap-1">
                                Go to feedback
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                                </svg>
                            </span>
                        </a>

                        <!-- Reports & Analytics -->
                        <a href="${pageContext.request.contextPath}/admin/reports" class="action-card bg-white border border-stone-mid p-6 flex flex-col">
                            <div class="w-10 h-10 bg-stone-mid flex items-center justify-center mb-4">
                                <svg class="w-5 h-5 text-ink" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                                </svg>
                            </div>
                            <span class="text-xs uppercase tracking-wide text-copper mb-2">Analytics</span>
                            <h3 class="font-serif text-lg font-medium text-ink mb-2">Reports & Analytics</h3>
                            <p class="text-sm text-ink-muted flex-1">View service performance, customer insights, and sales data.</p>
                            <span class="text-xs text-ink mt-4 inline-flex items-center gap-1">
                                Go to reports
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                                </svg>
                            </span>
                        </a>

                        <!-- View Bookings -->
                        <a href="${pageContext.request.contextPath}/admin/bookings" class="action-card bg-white border border-stone-mid p-6 flex flex-col">
                            <div class="w-10 h-10 bg-stone-mid flex items-center justify-center mb-4">
                                <svg class="w-5 h-5 text-ink" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                                </svg>
                            </div>
                            <span class="text-xs uppercase tracking-wide text-copper mb-2">Bookings</span>
                            <h3 class="font-serif text-lg font-medium text-ink mb-2">View Bookings</h3>
                            <p class="text-sm text-ink-muted flex-1">Monitor and manage customer appointments and reservations.</p>
                            <span class="text-xs text-ink mt-4 inline-flex items-center gap-1">
                                Go to bookings
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                                </svg>
                            </span>
                        </a>

                        <!-- Manage Payments -->
                        <a href="${pageContext.request.contextPath}/admin/payments/list" class="action-card bg-white border border-stone-mid p-6 flex flex-col">
                            <div class="w-10 h-10 bg-stone-mid flex items-center justify-center mb-4">
                                <svg class="w-5 h-5 text-ink" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
                                </svg>
                            </div>
                            <span class="text-xs uppercase tracking-wide text-copper mb-2">Payments</span>
                            <h3 class="font-serif text-lg font-medium text-ink mb-2">Manage Payments</h3>
                            <p class="text-sm text-ink-muted flex-1">View transactions, revenue, and process refunds.</p>
                            <span class="text-xs text-ink mt-4 inline-flex items-center gap-1">
                                Go to payments
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                                </svg>
                            </span>
                        </a>

                    </div>
                </div>

                <!-- Recent Feedback -->
                <aside class="stagger-4">
                    <div class="bg-white border border-stone-mid h-full">
                        <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                            <h2 class="font-serif text-lg font-medium text-ink">Recent Feedback</h2>
                            <a href="${pageContext.request.contextPath}/admin/feedback" class="text-xs text-ink-muted hover:text-ink transition-colors">
                                View all
                            </a>
                        </div>

                        <div class="p-6 space-y-4 max-h-80 overflow-y-auto">
                            <c:choose>
                                <c:when test="${not empty recentFeedback}">
                                    <c:forEach items="${recentFeedback}" var="fb">
                                        <div class="border border-stone-mid p-4 bg-stone-warm/50">
                                            <p class="text-xs text-ink-muted mb-2">
                                                ${fb.userName} · ${fb.serviceName}
                                            </p>
                                            <p class="text-sm text-ink leading-relaxed">
                                                ${fb.comments}
                                            </p>
                                            <p class="text-xs text-ink-muted mt-2">
                                                <time data-iso="${fb.createdAt}">${fb.createdAt}</time>
                                            </p>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-8">
                                        <svg class="w-10 h-10 text-stone-deep mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                                        </svg>
                                        <p class="text-sm text-ink-muted">No feedback yet</p>
                                        <p class="text-xs text-ink-muted mt-1">Reviews will appear here</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </aside>

            </section>

            <!-- System Overview + Shortcuts -->
            <section class="grid grid-cols-1 lg:grid-cols-2 gap-8 stagger-5">

                <!-- System Overview -->
                <div class="bg-white border border-stone-mid">
                    <div class="px-6 py-5 border-b border-stone-mid">
                        <h2 class="font-serif text-lg font-medium text-ink">System Overview</h2>
                        <p class="text-sm text-ink-muted mt-1">Platform usage at a glance</p>
                    </div>

                    <div class="p-6">
                        <dl class="grid grid-cols-2 gap-x-8 gap-y-6">
                            <div>
                                <dt class="text-xs uppercase tracking-wide text-ink-muted">Total Customers</dt>
                                <dd class="font-serif text-2xl font-medium text-ink mt-1 text-mono">
                                    <c:choose>
                                        <c:when test="${not empty totalCustomers}">${totalCustomers}</c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                </dd>
                            </div>
                            <div>
                                <dt class="text-xs uppercase tracking-wide text-ink-muted">Active Services</dt>
                                <dd class="font-serif text-2xl font-medium text-ink mt-1 text-mono">
                                    <c:choose>
                                        <c:when test="${not empty totalServices}">${totalServices}</c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                </dd>
                            </div>
                            <div>
                                <dt class="text-xs uppercase tracking-wide text-ink-muted">Feedback Entries</dt>
                                <dd class="font-serif text-2xl font-medium text-ink mt-1 text-mono">
                                    <c:choose>
                                        <c:when test="${not empty totalFeedback}">${totalFeedback}</c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                </dd>
                            </div>
                            <div>
                                <dt class="text-xs uppercase tracking-wide text-ink-muted">New Users (30d)</dt>
                                <dd class="font-serif text-2xl font-medium text-ink mt-1 text-mono">
                                    <c:choose>
                                        <c:when test="${not empty recentUsers}">${recentUsers}</c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                </dd>
                            </div>
                        </dl>

                        <p class="text-xs text-ink-muted mt-6 pt-6 border-t border-stone-mid">
                            For detailed analytics, visit the individual management pages.
                        </p>
                    </div>
                </div>

                <!-- Shortcuts -->
                <div class="bg-white border border-stone-mid">
                    <div class="px-6 py-5 border-b border-stone-mid">
                        <h2 class="font-serif text-lg font-medium text-ink">Shortcuts</h2>
                        <p class="text-sm text-ink-muted mt-1">Quick access to common tasks</p>
                    </div>

                    <div class="p-6 space-y-3">
                        <a href="${pageContext.request.contextPath}/admin/services/create" class="shortcut-item flex items-center justify-between border border-stone-mid px-4 py-3 bg-white">
                            <div class="flex items-center gap-3">
                                <svg class="w-4 h-4 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4v16m8-8H4"/>
                                </svg>
                                <span class="text-sm text-ink">Add a new service</span>
                            </div>
                            <span class="text-xs text-ink-muted">Services</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/services" class="shortcut-item flex items-center justify-between border border-stone-mid px-4 py-3 bg-white">
                            <div class="flex items-center gap-3">
                                <svg class="w-4 h-4 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 6h16M4 10h16M4 14h16M4 18h16"/>
                                </svg>
                                <span class="text-sm text-ink">Review all services</span>
                            </div>
                            <span class="text-xs text-ink-muted">Services</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/customers" class="shortcut-item flex items-center justify-between border border-stone-mid px-4 py-3 bg-white">
                            <div class="flex items-center gap-3">
                                <svg class="w-4 h-4 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                                </svg>
                                <span class="text-sm text-ink">View customer directory</span>
                            </div>
                            <span class="text-xs text-ink-muted">Customers</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/feedback" class="shortcut-item flex items-center justify-between border border-stone-mid px-4 py-3 bg-white">
                            <div class="flex items-center gap-3">
                                <svg class="w-4 h-4 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                                </svg>
                                <span class="text-sm text-ink">Check latest feedback</span>
                            </div>
                            <span class="text-xs text-ink-muted">Feedback</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/payments/list" class="shortcut-item flex items-center justify-between border border-stone-mid px-4 py-3 bg-white">
                            <div class="flex items-center gap-3">
                                <svg class="w-4 h-4 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
                                </svg>
                                <span class="text-sm text-ink">View payment transactions</span>
                            </div>
                            <span class="text-xs text-ink-muted">Payments</span>
                        </a>
                    </div>
                </div>

            </section>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <script>
    window.addEventListener('load', function() {
        setTimeout(function() {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 400);
    });

    // Format ISO date strings into readable dates
    document.querySelectorAll('time[data-iso]').forEach(function(el) {
        var iso = el.getAttribute('data-iso');
        if (!iso) return;
        try {
            var d = new Date(iso);
            if (isNaN(d.getTime())) return;
            var now = new Date();
            var diff = now - d;
            var mins = Math.floor(diff / 60000);
            var hrs = Math.floor(diff / 3600000);
            var days = Math.floor(diff / 86400000);
            if (mins < 1) { el.textContent = 'Just now'; }
            else if (mins < 60) { el.textContent = mins + ' min' + (mins !== 1 ? 's' : '') + ' ago'; }
            else if (hrs < 24) { el.textContent = hrs + ' hr' + (hrs !== 1 ? 's' : '') + ' ago'; }
            else if (days < 7) { el.textContent = days + ' day' + (days !== 1 ? 's' : '') + ' ago'; }
            else {
                el.textContent = d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
                    + ', ' + d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
            }
            el.title = d.toLocaleString();
        } catch(e) {}
    });
    </script>
</body>
</html>
