<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList, java.util.HashMap" %>
<%
    Object userRole = session.getAttribute("sessRole");
    if (userRole == null) {
        response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
        return;
    }
    @SuppressWarnings("unchecked")
    ArrayList<HashMap<String, String>> payments = (ArrayList<HashMap<String, String>>) request.getAttribute("payments");
    if (payments == null) payments = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment History – SilverCare</title>
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

    .payment-row { transition: background-color 0.15s ease; }
    .payment-row:hover { background-color: #f5f3ef; }
    .text-mono { font-variant-numeric: tabular-nums; }
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

    <main class="pt-24 pb-20 px-5 md:px-12">
        <div class="max-w-6xl mx-auto">

            <!-- Header -->
            <div class="mb-10">
                <span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Account</span>
                <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink mt-2 stagger-2">Payment History</h1>
                <p class="mt-3 text-ink-light text-base max-w-xl stagger-2">
                    View all your past transactions and payment details.
                </p>
            </div>

            <!-- Search / Filter -->
            <div class="mb-6 stagger-3">
                <div class="flex flex-col sm:flex-row gap-3">
                    <div class="flex-1 relative">
                        <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                        </svg>
                        <input type="text" id="searchPayments" placeholder="Search by reference or status..."
                               class="w-full bg-white border border-stone-mid pl-10 pr-4 py-2.5 text-sm text-ink placeholder:text-ink-muted focus:outline-none focus:border-ink transition-colors">
                    </div>
                    <select id="filterStatus" class="bg-white border border-stone-mid px-4 py-2.5 text-sm text-ink focus:outline-none focus:border-ink transition-colors">
                        <option value="">All statuses</option>
                        <option value="succeeded">Succeeded</option>
                        <option value="pending">Pending</option>
                        <option value="failed">Failed</option>
                        <option value="canceled">Canceled</option>
                    </select>
                </div>
            </div>

            <% if (payments.isEmpty()) { %>
            <!-- Empty State -->
            <div class="bg-white border border-stone-mid p-8 md:p-12 text-center stagger-3">
                <div class="w-12 h-12 bg-stone-mid flex items-center justify-center mx-auto mb-4">
                    <svg class="w-6 h-6 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
                    </svg>
                </div>
                <h2 class="font-serif text-xl md:text-2xl font-medium text-ink mb-3">No payments yet</h2>
                <p class="text-sm text-ink-light max-w-md mx-auto mb-8">
                    Once you book a SilverCare service, your payment history will appear here.
                </p>
                <a href="<%= request.getContextPath() %>/services"
                   class="inline-flex items-center gap-2 bg-ink text-stone-warm px-6 py-3 text-sm font-normal hover:bg-ink-light transition-colors">
                    Browse services
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                    </svg>
                </a>
            </div>
            <% } else { %>

            <!-- Summary Cards -->
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-5 mb-8 stagger-3">
                <div class="bg-white border border-stone-mid p-5">
                    <span class="text-xs uppercase tracking-wide text-ink-muted">Total Payments</span>
                    <p class="font-serif text-2xl font-medium text-ink mt-1 text-mono"><%= payments.size() %></p>
                </div>
                <%
                    long totalCents = 0;
                    long totalRefundCents = 0;
                    for (HashMap<String, String> pm : payments) {
                        try { totalCents += Long.parseLong(pm.get("amount")); } catch (Exception e) {}
                        try { totalRefundCents += Long.parseLong(pm.get("totalRefunded")); } catch (Exception e) {}
                    }
                    String totalDisplay = String.format("%.2f", totalCents / 100.0);
                    String refundDisplay = String.format("%.2f", totalRefundCents / 100.0);
                %>
                <div class="bg-white border border-stone-mid p-5">
                    <span class="text-xs uppercase tracking-wide text-ink-muted">Total Spent</span>
                    <p class="font-serif text-2xl font-medium text-ink mt-1 text-mono">$<%= totalDisplay %></p>
                </div>
                <div class="bg-white border border-stone-mid p-5">
                    <span class="text-xs uppercase tracking-wide text-ink-muted">Total Refunded</span>
                    <p class="font-serif text-2xl font-medium text-ink mt-1 text-mono">$<%= refundDisplay %></p>
                </div>
            </div>

            <!-- Payments Table (desktop) -->
            <div class="stagger-4 hidden md:block">
                <div class="bg-white border border-stone-mid overflow-hidden">
                    <table class="min-w-full" id="paymentsTable">
                        <thead>
                            <tr class="border-b border-stone-mid">
                                <th class="py-3 px-5 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Reference</th>
                                <th class="py-3 px-5 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Date</th>
                                <th class="py-3 px-5 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Amount</th>
                                <th class="py-3 px-5 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Status</th>
                                <th class="py-3 px-5 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Refunded</th>
                                <th class="py-3 px-5 text-right text-xs uppercase tracking-wide text-ink-muted font-normal"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (HashMap<String, String> pm : payments) {
                                String pmId = pm.get("paymentId");
                                String piId = pm.get("paymentIntentId");
                                String amtStr = pm.get("amount");
                                String status = pm.get("status");
                                String createdAt = pm.get("createdAt");
                                String refundedStr = pm.get("totalRefunded");
                                long amtCents = 0;
                                long refCents = 0;
                                try { amtCents = Long.parseLong(amtStr); } catch (Exception e) {}
                                try { refCents = Long.parseLong(refundedStr); } catch (Exception e) {}
                                String amountFmt = String.format("%.2f", amtCents / 100.0);
                                String refFmt = String.format("%.2f", refCents / 100.0);

                                String statusClass = "bg-stone-mid text-ink-light";
                                if ("succeeded".equalsIgnoreCase(status)) {
                                    statusClass = "bg-forest/10 text-forest border border-forest/20";
                                } else if ("pending".equalsIgnoreCase(status) || "processing".equalsIgnoreCase(status)) {
                                    statusClass = "bg-copper/10 text-copper border border-copper/20";
                                } else if ("failed".equalsIgnoreCase(status) || "canceled".equalsIgnoreCase(status)) {
                                    statusClass = "bg-stone-deep text-ink-muted";
                                }

                                String shortRef = piId != null && piId.length() > 16 ? "..." + piId.substring(piId.length() - 12) : (piId != null ? piId : "—");
                            %>
                            <tr class="payment-row border-b border-stone-mid/50 last:border-b-0" data-status="<%= status != null ? status.toLowerCase() : "" %>" data-ref="<%= piId != null ? piId.toLowerCase() : "" %>">
                                <td class="py-4 px-5">
                                    <span class="font-mono text-xs text-ink" title="<%= piId %>"><%= shortRef %></span>
                                </td>
                                <td class="py-4 px-5 text-sm text-ink-light">
                                    <time data-iso="<%= createdAt %>"><%= createdAt %></time>
                                </td>
                                <td class="py-4 px-5 text-sm font-medium text-ink text-mono">$<%= amountFmt %></td>
                                <td class="py-4 px-5">
                                    <span class="inline-flex items-center px-2.5 py-1 text-xs capitalize <%= statusClass %>">
                                        <%= status != null ? status : "—" %>
                                    </span>
                                </td>
                                <td class="py-4 px-5 text-sm text-ink-muted text-mono">
                                    <% if (refCents > 0) { %>$<%= refFmt %><% } else { %>—<% } %>
                                </td>
                                <td class="py-4 px-5 text-right">
                                    <a href="<%= request.getContextPath() %>/customer/payments/receipt?id=<%= pmId %>"
                                       class="text-xs text-ink hover:text-copper transition-colors inline-flex items-center gap-1">
                                        Receipt
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                                        </svg>
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Payments Cards (mobile) -->
            <div class="stagger-4 md:hidden space-y-4" id="paymentCards">
                <% for (HashMap<String, String> pm : payments) {
                    String pmId = pm.get("paymentId");
                    String piId = pm.get("paymentIntentId");
                    String amtStr = pm.get("amount");
                    String status = pm.get("status");
                    String createdAt = pm.get("createdAt");
                    String refundedStr = pm.get("totalRefunded");
                    long amtCents = 0;
                    long refCents = 0;
                    try { amtCents = Long.parseLong(amtStr); } catch (Exception e) {}
                    try { refCents = Long.parseLong(refundedStr); } catch (Exception e) {}
                    String amountFmt = String.format("%.2f", amtCents / 100.0);
                    String refFmt = String.format("%.2f", refCents / 100.0);

                    String statusClass = "bg-stone-mid text-ink-light";
                    if ("succeeded".equalsIgnoreCase(status)) {
                        statusClass = "bg-forest/10 text-forest border border-forest/20";
                    } else if ("pending".equalsIgnoreCase(status) || "processing".equalsIgnoreCase(status)) {
                        statusClass = "bg-copper/10 text-copper border border-copper/20";
                    } else if ("failed".equalsIgnoreCase(status) || "canceled".equalsIgnoreCase(status)) {
                        statusClass = "bg-stone-deep text-ink-muted";
                    }

                    String shortRef = piId != null && piId.length() > 20 ? "..." + piId.substring(piId.length() - 16) : (piId != null ? piId : "—");
                %>
                <div class="bg-white border border-stone-mid p-5 payment-card" data-status="<%= status != null ? status.toLowerCase() : "" %>" data-ref="<%= piId != null ? piId.toLowerCase() : "" %>">
                    <div class="flex items-start justify-between mb-3">
                        <span class="font-mono text-xs text-ink-muted" title="<%= piId %>"><%= shortRef %></span>
                        <span class="inline-flex items-center px-2.5 py-1 text-xs capitalize <%= statusClass %>">
                            <%= status != null ? status : "—" %>
                        </span>
                    </div>
                    <p class="font-serif text-2xl font-medium text-ink text-mono">$<%= amountFmt %></p>
                    <p class="text-xs text-ink-muted mt-1">
                        <time data-iso="<%= createdAt %>"><%= createdAt %></time>
                    </p>
                    <% if (refCents > 0) { %>
                    <p class="text-xs text-copper mt-2">Refunded: $<%= refFmt %></p>
                    <% } %>
                    <div class="mt-4 pt-3 border-t border-stone-mid">
                        <a href="<%= request.getContextPath() %>/customer/payments/receipt?id=<%= pmId %>"
                           class="text-xs text-ink hover:text-copper transition-colors inline-flex items-center gap-1">
                            View receipt
                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                            </svg>
                        </a>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>

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

        // Desktop rows
        document.querySelectorAll('#paymentsTable tbody tr.payment-row').forEach(function(row) {
            var ref = row.getAttribute('data-ref') || '';
            var st = row.getAttribute('data-status') || '';
            var matchSearch = !query || ref.indexOf(query) !== -1 || st.indexOf(query) !== -1;
            var matchStatus = !status || st === status;
            row.style.display = (matchSearch && matchStatus) ? '' : 'none';
        });

        // Mobile cards
        document.querySelectorAll('.payment-card').forEach(function(card) {
            var ref = card.getAttribute('data-ref') || '';
            var st = card.getAttribute('data-status') || '';
            var matchSearch = !query || ref.indexOf(query) !== -1 || st.indexOf(query) !== -1;
            var matchStatus = !status || st === status;
            card.style.display = (matchSearch && matchStatus) ? '' : 'none';
        });
    }

    if (searchInput) searchInput.addEventListener('input', filterPayments);
    if (filterSelect) filterSelect.addEventListener('change', filterPayments);
    </script>
</body>
</html>
