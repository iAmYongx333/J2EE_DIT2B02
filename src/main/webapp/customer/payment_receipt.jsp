<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.HashMap" %>
<%
    Object userRole = session.getAttribute("sessRole");
    if (userRole == null) {
        response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
        return;
    }
    @SuppressWarnings("unchecked")
    HashMap<String, String> receipt = (HashMap<String, String>) request.getAttribute("receipt");
    if (receipt == null) receipt = new HashMap<>();
    String errorMessage = (String) request.getAttribute("errorMessage");

    String piId = receipt.getOrDefault("paymentIntentId", "");
    String amtStr = receipt.getOrDefault("amount", "0");
    String currency = receipt.getOrDefault("currency", "sgd").toUpperCase();
    String status = receipt.getOrDefault("status", "");
    String createdAt = receipt.getOrDefault("createdAt", "");
    String custName = receipt.getOrDefault("customerName", "");
    String custEmail = receipt.getOrDefault("customerEmail", "");
    String serviceName = receipt.getOrDefault("serviceName", "");
    String quantity = receipt.getOrDefault("quantity", "");
    String unitPrice = receipt.getOrDefault("unitPrice", "");
    String amtRefunded = receipt.getOrDefault("amountRefunded", "0");
    String remaining = receipt.getOrDefault("remainingBalance", "0");

    long amtCents = 0;
    long refCents = 0;
    long remCents = 0;
    long unitCents = 0;
    try { amtCents = Long.parseLong(amtStr); } catch (Exception e) {}
    try { refCents = Long.parseLong(amtRefunded); } catch (Exception e) {}
    try { remCents = Long.parseLong(remaining); } catch (Exception e) {}
    try { unitCents = Long.parseLong(unitPrice); } catch (Exception e) {}

    String amountFmt = String.format("%.2f", amtCents / 100.0);
    String refFmt = String.format("%.2f", refCents / 100.0);
    String remFmt = String.format("%.2f", remCents / 100.0);
    String unitFmt = String.format("%.2f", unitCents / 100.0);

    boolean hasReceipt = !piId.isEmpty();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Receipt – SilverCare</title>
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

    @media print {
        .loader, header, .no-print { display: none !important; }
        .page-content { opacity: 1 !important; }
        body { background: white; }
        main { padding-top: 0 !important; }
    }
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
        <div class="max-w-2xl mx-auto">

            <!-- Back link -->
            <div class="mb-8 no-print stagger-1">
                <a href="<%= request.getContextPath() %>/customer/payments"
                   class="text-sm text-ink-muted hover:text-ink transition-colors inline-flex items-center gap-1.5">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 19l-7-7 7-7"/>
                    </svg>
                    Back to Payment History
                </a>
            </div>

            <% if (errorMessage != null) { %>
            <div class="bg-white border border-stone-mid p-8 md:p-12 text-center stagger-2">
                <div class="w-12 h-12 bg-stone-mid flex items-center justify-center mx-auto mb-4">
                    <svg class="w-6 h-6 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4.5c-.77-.833-2.694-.833-3.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z"/>
                    </svg>
                </div>
                <h2 class="font-serif text-xl font-medium text-ink mb-2"><%= errorMessage %></h2>
                <p class="text-sm text-ink-muted">The receipt you requested could not be loaded.</p>
            </div>
            <% } else if (!hasReceipt) { %>
            <div class="bg-white border border-stone-mid p-8 md:p-12 text-center stagger-2">
                <h2 class="font-serif text-xl font-medium text-ink mb-2">Receipt not available</h2>
                <p class="text-sm text-ink-muted">No receipt data found for this payment.</p>
            </div>
            <% } else { %>

            <!-- Receipt Header -->
            <div class="stagger-1 mb-6 flex items-start justify-between">
                <div>
                    <span class="text-copper text-xs uppercase tracking-[0.2em]">Receipt</span>
                    <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink mt-2">Payment Receipt</h1>
                </div>
                <button onclick="window.print()" class="no-print bg-white border border-stone-mid px-4 py-2 text-xs text-ink hover:border-ink transition-colors inline-flex items-center gap-1.5">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                    </svg>
                    Print
                </button>
            </div>

            <!-- Receipt Body -->
            <div class="bg-white border border-stone-mid stagger-2">

                <!-- Brand -->
                <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                    <span class="font-serif text-xl font-medium text-ink">SilverCare</span>
                    <%
                        String statusClass = "bg-stone-mid text-ink-light";
                        if ("succeeded".equalsIgnoreCase(status)) {
                            statusClass = "bg-forest/10 text-forest border border-forest/20";
                        } else if ("pending".equalsIgnoreCase(status) || "processing".equalsIgnoreCase(status)) {
                            statusClass = "bg-copper/10 text-copper border border-copper/20";
                        } else if ("failed".equalsIgnoreCase(status) || "canceled".equalsIgnoreCase(status)) {
                            statusClass = "bg-stone-deep text-ink-muted";
                        }
                    %>
                    <span class="inline-flex items-center px-2.5 py-1 text-xs capitalize <%= statusClass %>"><%= status %></span>
                </div>

                <!-- Amount -->
                <div class="px-6 py-8 border-b border-stone-mid text-center stagger-3">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Amount Paid</p>
                    <p class="font-serif text-4xl md:text-5xl font-medium text-ink" style="font-variant-numeric: tabular-nums;">$<%= amountFmt %></p>
                    <p class="text-xs text-ink-muted mt-2"><%= currency %></p>
                </div>

                <!-- Details -->
                <div class="p-6 space-y-6">

                    <!-- Payment Details -->
                    <div class="stagger-3">
                        <h3 class="text-xs uppercase tracking-wide text-ink-muted mb-3">Payment Details</h3>
                        <dl class="space-y-2 text-sm">
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Reference</dt>
                                <dd class="text-ink font-mono text-xs max-w-[50%] truncate" title="<%= piId %>"><%= piId %></dd>
                            </div>
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Date</dt>
                                <dd class="text-ink"><time data-iso="<%= createdAt %>" data-format="absolute"><%= createdAt %></time></dd>
                            </div>
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Status</dt>
                                <dd class="text-ink capitalize"><%= status %></dd>
                            </div>
                        </dl>
                    </div>

                    <!-- Customer -->
                    <% if (!custName.isEmpty() || !custEmail.isEmpty()) { %>
                    <div class="stagger-4">
                        <h3 class="text-xs uppercase tracking-wide text-ink-muted mb-3">Customer</h3>
                        <dl class="space-y-2 text-sm">
                            <% if (!custName.isEmpty()) { %>
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Name</dt>
                                <dd class="text-ink"><%= custName %></dd>
                            </div>
                            <% } %>
                            <% if (!custEmail.isEmpty()) { %>
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Email</dt>
                                <dd class="text-ink"><%= custEmail %></dd>
                            </div>
                            <% } %>
                        </dl>
                    </div>
                    <% } %>

                    <!-- Service -->
                    <% if (!serviceName.isEmpty()) { %>
                    <div class="stagger-4">
                        <h3 class="text-xs uppercase tracking-wide text-ink-muted mb-3">Service</h3>
                        <dl class="space-y-2 text-sm">
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Service</dt>
                                <dd class="text-ink"><%= serviceName %></dd>
                            </div>
                            <% if (!quantity.isEmpty()) { %>
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Quantity</dt>
                                <dd class="text-ink"><%= quantity %></dd>
                            </div>
                            <% } %>
                            <% if (unitCents > 0) { %>
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Unit Price</dt>
                                <dd class="text-ink" style="font-variant-numeric: tabular-nums;">$<%= unitFmt %></dd>
                            </div>
                            <% } %>
                        </dl>
                    </div>
                    <% } %>

                    <!-- Refund Info -->
                    <% if (refCents > 0) { %>
                    <div class="stagger-5">
                        <h3 class="text-xs uppercase tracking-wide text-copper mb-3">Refund Information</h3>
                        <dl class="space-y-2 text-sm">
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Amount Refunded</dt>
                                <dd class="text-copper font-medium" style="font-variant-numeric: tabular-nums;">$<%= refFmt %></dd>
                            </div>
                            <% if (remCents > 0) { %>
                            <div class="flex justify-between py-2 border-b border-stone-mid/50">
                                <dt class="text-ink-muted">Remaining Balance</dt>
                                <dd class="text-ink" style="font-variant-numeric: tabular-nums;">$<%= remFmt %></dd>
                            </div>
                            <% } %>
                        </dl>
                    </div>
                    <% } %>

                </div>

                <!-- Footer -->
                <div class="px-6 py-4 border-t border-stone-mid bg-stone-warm/30">
                    <p class="text-xs text-ink-muted text-center">
                        Thank you for choosing SilverCare. If you have any questions, please contact our support team.
                    </p>
                </div>
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
            var fmt = el.getAttribute('data-format');
            if (fmt === 'absolute') {
                el.textContent = d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
                    + ', ' + d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
            } else {
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
            }
            el.title = d.toLocaleString();
        } catch(e) {}
    });
    </script>
</body>
</html>
