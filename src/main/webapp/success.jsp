<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful – SilverCare</title>

    <%
        Object userRole = session.getAttribute("sessRole");
        if (userRole == null) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            return;
        }
        String paymentId = request.getParameter("paymentId");
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

    @keyframes checkDraw { 0% { stroke-dashoffset: 48; } 100% { stroke-dashoffset: 0; } }
    .check-icon { stroke-dasharray: 48; stroke-dashoffset: 48; animation: checkDraw 0.5s ease 0.8s forwards; }
    @keyframes circleDraw { 0% { stroke-dashoffset: 160; } 100% { stroke-dashoffset: 0; } }
    .circle-icon { stroke-dasharray: 160; stroke-dashoffset: 160; animation: circleDraw 0.7s ease 0.3s forwards; }
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
    <%@ include file="includes/header.jsp" %>

    <main class="pt-24 pb-20 px-5 md:px-12">
        <div class="max-w-lg mx-auto text-center">

            <!-- Success Icon -->
            <div class="stagger-1 mb-8">
                <div class="w-20 h-20 mx-auto">
                    <svg viewBox="0 0 52 52" xmlns="http://www.w3.org/2000/svg">
                        <circle class="circle-icon" cx="26" cy="26" r="25" fill="none" stroke="#b87a4b" stroke-width="1.5"/>
                        <path class="check-icon" fill="none" stroke="#2c2c2c" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
                    </svg>
                </div>
            </div>

            <span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Payment Confirmed</span>
            <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink mt-3 mb-4 stagger-2">
                Thank You
            </h1>
            <p class="text-ink-light text-base max-w-md mx-auto leading-relaxed stagger-2">
                Your payment has been processed successfully. Your care service booking is now confirmed.
            </p>

            <!-- Payment Details -->
            <div class="mt-10 stagger-3">
                <div class="bg-white border border-stone-mid p-6 text-left">
                    <h2 class="font-serif text-lg font-medium text-ink mb-4">Booking Details</h2>
                    <dl class="space-y-3 text-sm">
                        <% if (paymentId != null && !paymentId.isBlank()) { %>
                        <div class="flex justify-between py-2 border-b border-stone-mid">
                            <dt class="text-ink-muted">Payment Reference</dt>
                            <dd class="text-ink font-medium font-mono text-xs">
                                <%= paymentId.length() > 24 ? paymentId.substring(0, 24) + "..." : paymentId %>
                            </dd>
                        </div>
                        <% } %>
                        <div class="flex justify-between py-2 border-b border-stone-mid">
                            <dt class="text-ink-muted">Status</dt>
                            <dd class="inline-flex items-center gap-1.5">
                                <span class="w-1.5 h-1.5 bg-green-500 inline-block"></span>
                                <span class="text-ink font-medium">Confirmed</span>
                            </dd>
                        </div>
                        <div class="flex justify-between py-2 border-b border-stone-mid">
                            <dt class="text-ink-muted">Date</dt>
                            <dd class="text-ink"><%= new java.text.SimpleDateFormat("d MMM yyyy, HH:mm").format(new java.util.Date()) %></dd>
                        </div>
                    </dl>
                </div>
            </div>

            <!-- Actions -->
            <div class="mt-8 stagger-4 space-y-3">
                <a href="<%=request.getContextPath()%>/bookings"
                   class="block w-full bg-ink text-stone-warm px-6 py-3.5 text-sm font-normal hover:bg-ink-light transition-colors text-center">
                    View My Bookings
                </a>
                <a href="<%=request.getContextPath()%>/customer/payments"
                   class="block w-full border border-stone-mid bg-white text-ink px-6 py-3.5 text-sm hover:bg-stone-warm transition-colors text-center">
                    Payment History
                </a>
                <a href="<%=request.getContextPath()%>/"
                   class="block text-ink-muted text-sm hover:text-ink transition-colors mt-4">
                    Back to Home
                </a>
            </div>

            <!-- Info -->
            <div class="mt-10 stagger-4">
                <div class="bg-stone-mid/30 border border-stone-mid p-4">
                    <p class="text-xs text-ink-muted leading-relaxed">
                        A confirmation email has been sent to your registered email address. 
                        If you have any questions about your booking, please contact our support team.
                    </p>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="includes/footer.jsp" %>
    </div>

    <script>
    window.addEventListener('load', function() {
        setTimeout(function() {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 400);
    });
    </script>
</body>
</html>
