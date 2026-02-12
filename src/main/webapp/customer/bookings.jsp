<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="Assignment1.Booking" %>
<%@ page import="Assignment1.BookingDetail" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    Object userRole = session.getAttribute("sessRole");
    if (userRole == null) {
        response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
        return;
    }
    @SuppressWarnings("unchecked")
    ArrayList<Booking> bookings = (ArrayList<Booking>) request.getAttribute("bookings");
    if (bookings == null) {
        bookings = new ArrayList<Booking>();
    }
    SimpleDateFormat displayDate = new SimpleDateFormat("d MMM yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Bookings | SilverCare</title>
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
    </style>
</head>

<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
    <%@ include file="../includes/header.jsp" %>

    <main class="pt-24 max-w-6xl mx-auto px-5 md:px-12 py-12 md:py-16">
        <div class="mb-10">
            <span class="text-copper text-xs uppercase tracking-[0.2em]">Your History</span>
            <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink mt-2">My Bookings</h1>
            <p class="mt-3 text-ink-light text-base max-w-xl">
                View all your past and upcoming care bookings.
            </p>
        </div>

        <% if (bookings.isEmpty()) { %>
            <!-- Empty state -->
            <div class="bg-white border border-stone-mid p-8 md:p-12 text-center">
                <h2 class="font-serif text-xl md:text-2xl font-medium text-ink mb-3">
                    You don't have any bookings yet.
                </h2>
                <p class="text-sm text-ink-light max-w-md mx-auto mb-8">
                    Once you book a SilverCare service, it will appear here with full details, including date, status and services booked.
                </p>
                <a href="<%= request.getContextPath() %>/services" 
                   class="inline-flex items-center gap-2 bg-ink text-stone-warm px-6 py-3 text-sm font-normal hover:bg-ink-light transition-colors">
                    Browse services
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                    </svg>
                </a>
            </div>
        <% } else { 
            for (Booking b : bookings) {
                String status = b.getStatus() != null ? b.getStatus() : "";
                String statusClass = "bg-stone-mid text-ink-light";
                if ("confirmed".equalsIgnoreCase(status) || "completed".equalsIgnoreCase(status)) {
                    statusClass = "bg-forest/10 text-forest border border-forest/20";
                } else if ("pending".equalsIgnoreCase(status)) {
                    statusClass = "bg-copper/10 text-copper border border-copper/20";
                } else if ("cancelled".equalsIgnoreCase(status) || "canceled".equalsIgnoreCase(status)) {
                    statusClass = "bg-stone-deep text-ink-muted";
                }
        %>
            <!-- Booking card -->
            <div class="bg-white border border-stone-mid p-5 md:p-7 mb-5">
                <!-- Top row: id, date, status -->
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-5">
                    <div>
                        <span class="text-xs uppercase tracking-[0.15em] text-ink-muted">
                            Booking <span class="text-ink">#<%= b.getBookingId() %></span>
                        </span>
                        <p class="mt-1 text-sm text-ink-light">
                            Scheduled date: <span class="font-medium text-ink"><%= b.getScheduledAt() != null ? displayDate.format(b.getScheduledAt()) : "Not set" %></span>
                        </p>
                        <% String notes = b.getNotes(); if (notes != null && !notes.trim().isEmpty()) { %>
                            <p class="mt-1 text-xs text-ink-muted">
                                Notes: <span class="text-ink-light"><%= notes %></span>
                            </p>
                        <% } %>
                    </div>

                    <div class="flex md:flex-col items-start md:items-end gap-2">
                        <span class="inline-flex items-center px-3 py-1 text-xs font-normal capitalize <%= statusClass %>">
                            <%= status.isEmpty() ? "Unknown" : status %>
                        </span>
                    </div>
                </div>

                <!-- Details table -->
                <div class="border-t border-stone-mid pt-5">
                    <h3 class="text-sm font-medium text-ink mb-3">Services in this booking</h3>

                    <% ArrayList<BookingDetail> details = b.getBookingDetails();
                       if (details != null && !details.isEmpty()) { %>
                        <div class="overflow-x-auto">
                            <table class="min-w-full text-sm">
                                <thead>
                                    <tr class="border-b border-stone-mid text-xs uppercase tracking-[0.15em] text-ink-muted">
                                        <th class="py-2 pr-4 text-left font-normal">Service</th>
                                        <th class="py-2 pr-4 text-left font-normal">Quantity</th>
                                        <th class="py-2 pr-4 text-left font-normal">Unit price</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (BookingDetail d : details) { %>
                                        <tr class="border-b border-stone-mid/50 last:border-b-0">
                                            <td class="py-3 pr-4 text-ink"><%= d.getServiceName() %></td>
                                            <td class="py-3 pr-4 text-ink-light"><%= d.getQuantity() %></td>
                                            <td class="py-3 pr-4 text-ink-light">$<%= d.getUnitPrice() %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } else { %>
                        <p class="text-sm text-ink-muted">No booking line items are available for this booking.</p>
                    <% } %>
                </div>
            </div>
        <% } } %>
    </main>

    <%@ include file="../includes/footer.jsp" %>
</body>
</html>
