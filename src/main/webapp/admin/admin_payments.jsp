<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, java.util.HashMap" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Payments – SilverCare</title>

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

        @SuppressWarnings("unchecked")
        ArrayList<HashMap<String, String>> payments = (ArrayList<HashMap<String, String>>) request.getAttribute("payments");
        if (payments == null) payments = new ArrayList<>();

        @SuppressWarnings("unchecked")
        HashMap<String, String> stats = (HashMap<String, String>) request.getAttribute("paymentStats");
        if (stats == null) stats = new HashMap<>();

        // Flash messages
        String flashSuccess = (String) session.getAttribute("flashSuccess");
        String flashError = (String) session.getAttribute("flashError");
        if (flashSuccess != null) session.removeAttribute("flashSuccess");
        if (flashError != null) session.removeAttribute("flashError");
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
                    forest: '#3d4f3d',
                }
            }
        }
    }
    </script>
    <style>
    html { scroll-behavior: smooth; }
    body { -webkit-font-smoothing: antialiased; }

    .loader { position: fixed; inset: 0; background: #f5f3ef; display: flex; align-items: center; justify-content: center; z-index: 9999; transition: opacity 0.5s ease, visibility 0.5s ease; }
    .loader.hidden { opacity: 0; visibility: hidden; }
    .loader-bar { width: 120px; height: 2px; background: #e8e4dc; overflow: hidden; }
    .loader-bar::after { content: ''; display: block; width: 40%; height: 100%; background: #2c2c2c; animation: loadingBar 1s ease-in-out infinite; }
    @keyframes loadingBar { 0% { transform: translateX(-100%); } 100% { transform: translateX(350%); } }
    .page-content { opacity: 0; transition: opacity 0.6s ease; }
    .page-content.visible { opacity: 1; }

    @keyframes fadeSlideIn { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }
    .stagger-1 { animation: fadeSlideIn 0.6s ease 0.1s both; }
    .stagger-2 { animation: fadeSlideIn 0.6s ease 0.2s both; }
    .stagger-3 { animation: fadeSlideIn 0.6s ease 0.3s both; }
    .stagger-4 { animation: fadeSlideIn 0.6s ease 0.4s both; }
    .stagger-5 { animation: fadeSlideIn 0.6s ease 0.5s both; }

    .metric-card { transition: transform 0.2s ease, border-color 0.2s ease; }
    .metric-card:hover { transform: translateY(-2px); border-color: #2c2c2c; }
    .payment-row { transition: background-color 0.15s ease; }
    .payment-row:hover { background-color: #f5f3ef; }
    .text-mono { font-variant-numeric: tabular-nums; }

    /* Refund Modal */
    .modal-overlay {
        position: fixed; inset: 0; z-index: 200;
        background: rgba(44,44,44,0.4);
        backdrop-filter: blur(4px);
        opacity: 0; pointer-events: none;
        transition: opacity 0.2s ease;
    }
    .modal-overlay.active { opacity: 1; pointer-events: auto; }
    .modal-panel {
        position: fixed; top: 50%; left: 50%; z-index: 201;
        transform: translate(-50%, -50%) scale(0.97);
        opacity: 0; pointer-events: none;
        transition: transform 0.25s ease, opacity 0.25s ease;
        width: 90vw; max-width: 480px;
    }
    .modal-panel.active { opacity: 1; pointer-events: auto; transform: translate(-50%, -50%) scale(1); }

    /* Flash messages */
    .flash-msg { animation: flashIn 0.3s ease both, flashOut 0.3s ease 4s both; }
    @keyframes flashIn { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes flashOut { from { opacity: 1; } to { opacity: 0; } }
    </style>
</head>
<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
    <div class="loader" id="loader">
        <div class="text-center">
            <p class="font-serif text-2xl text-ink mb-6">SilverCare</p>
            <div class="loader-bar"></div>
        </div>
    </div>

    <div class="page-content" id="pageContent">
    <%@ include file="../includes/header.jsp" %>

    <!-- Flash Messages -->
    <% if (flashSuccess != null) { %>
    <div class="flash-msg fixed top-20 left-1/2 -translate-x-1/2 z-[150] bg-forest/10 border border-forest/20 text-forest px-6 py-3 text-sm max-w-md">
        <%= flashSuccess %>
    </div>
    <% } %>
    <% if (flashError != null) { %>
    <div class="flash-msg fixed top-20 left-1/2 -translate-x-1/2 z-[150] bg-red-50 border border-red-200 text-red-700 px-6 py-3 text-sm max-w-md">
        <%= flashError %>
    </div>
    <% } %>

    <main class="pt-24 pb-20 px-5 md:px-12">
        <div class="max-w-7xl mx-auto">

            <!-- Page Header -->
            <header class="mb-10">
                <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                    <div>
                        <a href="<%= request.getContextPath() %>/admin" class="text-sm text-ink-muted hover:text-ink transition-colors inline-flex items-center gap-1 mb-3 stagger-1">
                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 19l-7-7 7-7"/>
                            </svg>
                            Dashboard
                        </a>
                        <span class="block text-copper text-xs uppercase tracking-[0.2em] stagger-1">Administration</span>
                        <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink mt-2 stagger-2">Payments</h1>
                        <p class="mt-2 text-ink-light text-base max-w-xl stagger-2">
                            View all transactions, monitor revenue, and process refunds.
                        </p>
                    </div>
                    <div class="stagger-3">
                        <span class="text-xs text-ink-muted"><%= payments.size() %> transaction<%= payments.size() != 1 ? "s" : "" %> total</span>
                    </div>
                </div>
            </header>

            <!-- Statistics Cards -->
            <section class="mb-10 stagger-3">
                <div class="grid grid-cols-2 lg:grid-cols-4 gap-5">
                    <%
                        String totalPayments = stats.getOrDefault("totalPayments", "0");
                        String totalAmount = stats.getOrDefault("totalAmount", "0");
                        String totalRefunded = stats.getOrDefault("totalRefunded", "0");
                        String avgAmount = stats.getOrDefault("averagePaymentAmount", "0");
                        String refundRate = stats.getOrDefault("refundRate", "0");

                        long totalAmtCents = 0;
                        long totalRefCents = 0;
                        long avgCents = 0;
                        try { totalAmtCents = Long.parseLong(totalAmount); } catch (Exception e) {}
                        try { totalRefCents = Long.parseLong(totalRefunded); } catch (Exception e) {}
                        try { avgCents = Long.parseLong(avgAmount); } catch (Exception e) {}
                    %>
                    <article class="metric-card bg-white border border-stone-mid p-5">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Payments</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
                            </svg>
                        </div>
                        <p class="font-serif text-3xl font-medium text-ink text-mono"><%= totalPayments %></p>
                        <p class="text-xs text-ink-muted mt-1">Total transactions</p>
                    </article>

                    <article class="metric-card bg-white border border-stone-mid p-5">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Revenue</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                        <p class="font-serif text-3xl font-medium text-ink text-mono">$<%= String.format("%.2f", totalAmtCents / 100.0) %></p>
                        <p class="text-xs text-ink-muted mt-1">Total revenue</p>
                    </article>

                    <article class="metric-card bg-white border border-stone-mid p-5">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Refunded</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"/>
                            </svg>
                        </div>
                        <p class="font-serif text-3xl font-medium text-ink text-mono">$<%= String.format("%.2f", totalRefCents / 100.0) %></p>
                        <p class="text-xs text-ink-muted mt-1">Total refunds</p>
                    </article>

                    <article class="metric-card bg-white border border-stone-mid p-5">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Average</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                            </svg>
                        </div>
                        <p class="font-serif text-3xl font-medium text-ink text-mono">$<%= String.format("%.2f", avgCents / 100.0) %></p>
                        <p class="text-xs text-ink-muted mt-1">Per transaction</p>
                    </article>
                </div>
            </section>

            <!-- Search & Filter -->
            <div class="mb-6 stagger-4">
                <div class="flex flex-col sm:flex-row gap-3">
                    <div class="flex-1 relative">
                        <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                        </svg>
                        <input type="text" id="searchPayments" placeholder="Search by name, email, or reference..."
                               class="w-full bg-white border border-stone-mid pl-10 pr-4 py-2.5 text-sm text-ink placeholder:text-ink-muted focus:outline-none focus:border-ink transition-colors">
                    </div>
                    <select id="filterStatus" class="bg-white border border-stone-mid px-4 py-2.5 text-sm text-ink focus:outline-none focus:border-ink transition-colors">
                        <option value="">All statuses</option>
                        <option value="succeeded">Succeeded</option>
                        <option value="pending">Pending</option>
                        <option value="processing">Processing</option>
                        <option value="failed">Failed</option>
                        <option value="canceled">Canceled</option>
                    </select>
                </div>
            </div>

            <% if (payments.isEmpty()) { %>
            <!-- Empty State -->
            <div class="bg-white border border-stone-mid p-8 md:p-12 text-center stagger-4">
                <div class="w-12 h-12 bg-stone-mid flex items-center justify-center mx-auto mb-4">
                    <svg class="w-6 h-6 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
                    </svg>
                </div>
                <h2 class="font-serif text-xl md:text-2xl font-medium text-ink mb-3">No payments recorded</h2>
                <p class="text-sm text-ink-light max-w-md mx-auto">
                    Payment transactions will appear here once customers start making bookings through the platform.
                </p>
            </div>
            <% } else { %>

            <!-- Payments Table (desktop) -->
            <div class="stagger-4 hidden lg:block">
                <div class="bg-white border border-stone-mid overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="min-w-full" id="paymentsTable">
                            <thead>
                                <tr class="border-b border-stone-mid">
                                    <th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Customer</th>
                                    <th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Reference</th>
                                    <th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Date</th>
                                    <th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Amount</th>
                                    <th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Status</th>
                                    <th class="py-3 px-4 text-right text-xs uppercase tracking-wide text-ink-muted font-normal">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (HashMap<String, String> pm : payments) {
                                    String pmId = pm.get("paymentId");
                                    String piId = pm.get("paymentIntentId");
                                    String amtStr = pm.get("amount");
                                    String pmStatus = pm.get("status");
                                    String pmCreatedAt = pm.get("createdAt");
                                    String pmName = pm.get("customerName");
                                    String pmEmail = pm.get("customerEmail");

                                    long amtCents = 0;
                                    try { amtCents = Long.parseLong(amtStr); } catch (Exception e) {}
                                    String amountFmt = String.format("%.2f", amtCents / 100.0);

                                    String statusClass = "bg-stone-mid text-ink-light";
                                    if ("succeeded".equalsIgnoreCase(pmStatus)) {
                                        statusClass = "bg-forest/10 text-forest border border-forest/20";
                                    } else if ("pending".equalsIgnoreCase(pmStatus) || "processing".equalsIgnoreCase(pmStatus)) {
                                        statusClass = "bg-copper/10 text-copper border border-copper/20";
                                    } else if ("failed".equalsIgnoreCase(pmStatus) || "canceled".equalsIgnoreCase(pmStatus)) {
                                        statusClass = "bg-stone-deep text-ink-muted";
                                    }

                                    String shortRef = piId != null && piId.length() > 16 ? "..." + piId.substring(piId.length() - 12) : (piId != null ? piId : "—");
                                    String searchStr = ((pmName != null ? pmName : "") + " " + (pmEmail != null ? pmEmail : "") + " " + (piId != null ? piId : "")).toLowerCase();
                                %>
                                <tr class="payment-row border-b border-stone-mid/50 last:border-b-0"
                                    data-status="<%= pmStatus != null ? pmStatus.toLowerCase() : "" %>"
                                    data-search="<%= searchStr %>">
                                    <td class="py-4 px-4">
                                        <div>
                                            <p class="text-sm text-ink"><%= pmName != null && !pmName.isEmpty() ? pmName : "—" %></p>
                                            <p class="text-xs text-ink-muted"><%= pmEmail != null && !pmEmail.isEmpty() ? pmEmail : "" %></p>
                                        </div>
                                    </td>
                                    <td class="py-4 px-4">
                                        <span class="font-mono text-xs text-ink-muted" title="<%= piId %>"><%= shortRef %></span>
                                    </td>
                                    <td class="py-4 px-4 text-sm text-ink-light">
                                        <time data-iso="<%= pmCreatedAt %>"><%= pmCreatedAt %></time>
                                    </td>
                                    <td class="py-4 px-4 text-sm font-medium text-ink text-mono">$<%= amountFmt %></td>
                                    <td class="py-4 px-4">
                                        <span class="inline-flex items-center px-2.5 py-1 text-xs capitalize <%= statusClass %>">
                                            <%= pmStatus != null ? pmStatus : "—" %>
                                        </span>
                                    </td>
                                    <td class="py-4 px-4 text-right">
                                        <div class="flex items-center justify-end gap-3">
                                            <% if ("succeeded".equalsIgnoreCase(pmStatus)) { %>
                                            <button onclick="openRefundModal('<%= piId %>', <%= amtCents %>)"
                                                    class="text-xs text-copper hover:text-ink transition-colors inline-flex items-center gap-1">
                                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"/>
                                                </svg>
                                                Refund
                                            </button>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Payments Cards (mobile / tablet) -->
            <div class="stagger-4 lg:hidden space-y-4" id="paymentCards">
                <% for (HashMap<String, String> pm : payments) {
                    String pmId = pm.get("paymentId");
                    String piId = pm.get("paymentIntentId");
                    String amtStr = pm.get("amount");
                    String pmStatus = pm.get("status");
                    String pmCreatedAt = pm.get("createdAt");
                    String pmName = pm.get("customerName");
                    String pmEmail = pm.get("customerEmail");

                    long amtCents = 0;
                    try { amtCents = Long.parseLong(amtStr); } catch (Exception e) {}
                    String amountFmt = String.format("%.2f", amtCents / 100.0);

                    String statusClass = "bg-stone-mid text-ink-light";
                    if ("succeeded".equalsIgnoreCase(pmStatus)) {
                        statusClass = "bg-forest/10 text-forest border border-forest/20";
                    } else if ("pending".equalsIgnoreCase(pmStatus) || "processing".equalsIgnoreCase(pmStatus)) {
                        statusClass = "bg-copper/10 text-copper border border-copper/20";
                    } else if ("failed".equalsIgnoreCase(pmStatus) || "canceled".equalsIgnoreCase(pmStatus)) {
                        statusClass = "bg-stone-deep text-ink-muted";
                    }

                    String shortRef = piId != null && piId.length() > 20 ? "..." + piId.substring(piId.length() - 16) : (piId != null ? piId : "—");
                    String searchStr = ((pmName != null ? pmName : "") + " " + (pmEmail != null ? pmEmail : "") + " " + (piId != null ? piId : "")).toLowerCase();
                %>
                <div class="bg-white border border-stone-mid p-5 payment-card"
                     data-status="<%= pmStatus != null ? pmStatus.toLowerCase() : "" %>"
                     data-search="<%= searchStr %>">
                    <div class="flex items-start justify-between mb-3">
                        <div>
                            <p class="text-sm font-medium text-ink"><%= pmName != null && !pmName.isEmpty() ? pmName : "—" %></p>
                            <p class="text-xs text-ink-muted"><%= pmEmail != null && !pmEmail.isEmpty() ? pmEmail : "" %></p>
                        </div>
                        <span class="inline-flex items-center px-2.5 py-1 text-xs capitalize <%= statusClass %>">
                            <%= pmStatus != null ? pmStatus : "—" %>
                        </span>
                    </div>
                    <p class="font-serif text-2xl font-medium text-ink text-mono mb-1">$<%= amountFmt %></p>
                    <p class="text-xs text-ink-muted mb-1">
                        <time data-iso="<%= pmCreatedAt %>"><%= pmCreatedAt %></time>
                    </p>
                    <p class="font-mono text-xs text-ink-muted" title="<%= piId %>"><%= shortRef %></p>
                    <% if ("succeeded".equalsIgnoreCase(pmStatus)) { %>
                    <div class="mt-4 pt-3 border-t border-stone-mid">
                        <button onclick="openRefundModal('<%= piId %>', <%= amtCents %>)"
                                class="text-xs text-copper hover:text-ink transition-colors inline-flex items-center gap-1">
                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"/>
                            </svg>
                            Process Refund
                        </button>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
            <% } %>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <!-- Refund Modal Overlay -->
    <div class="modal-overlay" id="refundOverlay" onclick="closeRefundModal()"></div>

    <!-- Refund Modal Panel -->
    <div class="modal-panel" id="refundPanel">
        <div class="bg-white border border-stone-mid">
            <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                <h2 class="font-serif text-lg font-medium text-ink">Process Refund</h2>
                <button onclick="closeRefundModal()" class="text-ink-muted hover:text-ink transition-colors p-1">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>

            <form action="<%= request.getContextPath() %>/admin/payments/refund" method="POST" id="refundForm">
                <div class="p-6 space-y-5">
                    <input type="hidden" name="paymentIntentId" id="refundPiId">

                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Payment Reference</label>
                        <p class="font-mono text-xs text-ink bg-stone-warm border border-stone-mid px-3 py-2 truncate" id="refundRefDisplay"></p>
                    </div>

                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2" for="refundAmount">Refund Amount (cents)</label>
                        <div class="relative">
                            <input type="number" name="amount" id="refundAmount" min="1" required
                                   class="w-full bg-white border border-stone-mid px-4 py-2.5 text-sm text-ink focus:outline-none focus:border-ink transition-colors">
                            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-ink-muted" id="refundAmountHint"></span>
                        </div>
                        <p class="text-xs text-ink-muted mt-1">Max: <span id="refundMaxDisplay">—</span></p>
                    </div>

                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2" for="refundReason">Reason (optional)</label>
                        <select name="reason" id="refundReason"
                                class="w-full bg-white border border-stone-mid px-4 py-2.5 text-sm text-ink focus:outline-none focus:border-ink transition-colors">
                            <option value="">Select a reason</option>
                            <option value="requested_by_customer">Requested by customer</option>
                            <option value="duplicate">Duplicate charge</option>
                            <option value="fraudulent">Fraudulent</option>
                        </select>
                    </div>
                </div>

                <div class="px-6 py-4 border-t border-stone-mid bg-stone-warm/30 flex items-center justify-end gap-3">
                    <button type="button" onclick="closeRefundModal()" class="px-4 py-2 text-sm text-ink-muted hover:text-ink transition-colors">
                        Cancel
                    </button>
                    <button type="submit" class="bg-ink text-stone-warm px-5 py-2 text-sm font-normal hover:bg-ink-light transition-colors">
                        Process Refund
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
    // Loader
    window.addEventListener('load', function() {
        setTimeout(function() {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 400);
    });

    // Format ISO dates
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

    // Search & filter
    var searchInput = document.getElementById('searchPayments');
    var filterSelect = document.getElementById('filterStatus');

    function filterPayments() {
        var query = (searchInput.value || '').toLowerCase();
        var status = (filterSelect.value || '').toLowerCase();

        document.querySelectorAll('#paymentsTable tbody tr.payment-row').forEach(function(row) {
            var search = row.getAttribute('data-search') || '';
            var st = row.getAttribute('data-status') || '';
            var matchSearch = !query || search.indexOf(query) !== -1;
            var matchStatus = !status || st === status;
            row.style.display = (matchSearch && matchStatus) ? '' : 'none';
        });

        document.querySelectorAll('.payment-card').forEach(function(card) {
            var search = card.getAttribute('data-search') || '';
            var st = card.getAttribute('data-status') || '';
            var matchSearch = !query || search.indexOf(query) !== -1;
            var matchStatus = !status || st === status;
            card.style.display = (matchSearch && matchStatus) ? '' : 'none';
        });
    }

    if (searchInput) searchInput.addEventListener('input', filterPayments);
    if (filterSelect) filterSelect.addEventListener('change', filterPayments);

    // Refund Modal
    function openRefundModal(piId, maxCents) {
        document.getElementById('refundPiId').value = piId;
        document.getElementById('refundRefDisplay').textContent = piId;
        document.getElementById('refundAmount').value = maxCents;
        document.getElementById('refundAmount').max = maxCents;
        document.getElementById('refundMaxDisplay').textContent = '$' + (maxCents / 100).toFixed(2) + ' (' + maxCents + ' cents)';
        document.getElementById('refundAmountHint').textContent = '= $' + (maxCents / 100).toFixed(2);
        document.getElementById('refundOverlay').classList.add('active');
        document.getElementById('refundPanel').classList.add('active');
    }

    function closeRefundModal() {
        document.getElementById('refundOverlay').classList.remove('active');
        document.getElementById('refundPanel').classList.remove('active');
    }

    // Update dollar display as user types
    var refundAmountInput = document.getElementById('refundAmount');
    if (refundAmountInput) {
        refundAmountInput.addEventListener('input', function() {
            var cents = parseInt(this.value) || 0;
            document.getElementById('refundAmountHint').textContent = '= $' + (cents / 100).toFixed(2);
        });
    }

    // Close modal on Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeRefundModal();
    });
    </script>
</body>
</html>
