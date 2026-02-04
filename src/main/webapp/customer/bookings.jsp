<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="Assignment1.Booking" %>
<%@ page import="Assignment1.BookingDetail" %>

<%
Object userRole = session.getAttribute("sessRole");
if (userRole == null) {
    response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
    return;
}

// bookings are now passed on the *request* by BookingServlet
@SuppressWarnings("unchecked")
ArrayList<Booking> bookings = (ArrayList<Booking>) request.getAttribute("bookings");
if (bookings == null) {
    bookings = new ArrayList<Booking>(); // treat as empty, DO NOT redirect
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>My Bookings – SilverCare</title>

  <!-- Tailwind CDN (remove if already included globally) -->
  <script src="https://cdn.tailwindcss.com"></script>

  <style>
    body {
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text",
                   "Helvetica Neue", Arial, sans-serif;
    }

    .page-shell {
      background: linear-gradient(
        to bottom,
        #f6f1e9 0%,
        #f9f4ec 45%,
        #faf7f1 100%
      );
    }

    @keyframes softFadeUp {
      0% { opacity: 0; transform: translateY(14px); }
      100% { opacity: 1; transform: translateY(0); }
    }

    .card-appear {
      opacity: 0;
      animation: softFadeUp 0.45s ease-out 0.12s forwards;
    }

    .accent-line {
      width: 44px;
      height: 2px;
      border-radius: 999px;
      background: #1e2a38;
    }
  </style>
</head>

<body class="page-shell min-h-screen text-[#1e2a38]">
  <%@ include file = "../includes/header.jsp"%>

  <main class="pt-28 pb-20">
    <div class="max-w-6xl mx-auto px-6 md:px-8">

      <!-- Page heading -->
      <section class="mb-6 md:mb-8">
        <p class="text-[11px] tracking-[0.18em] uppercase text-slate-500">
          SilverCare bookings
        </p>
        <h1 class="mt-1 text-[26px] md:text-[30px] font-serif font-semibold tracking-tight text-[#1e2a38]">
          My bookings
        </h1>
        <div class="mt-3 accent-line"></div>
      </section>

      <%
        if (bookings.isEmpty()) {
      %>
        <!-- Empty state -->
        <section class="card-appear rounded-[24px] bg-[#fdfaf5]
                        border border-[#e0dcd4]
                        shadow-[0_14px_40px_rgba(15,23,42,0.10)]
                        px-6 py-8 md:px-8 md:py-10 text-center">
          <h2 class="text-[18px] md:text-[20px] font-semibold text-[#1e2a38] mb-2">
            You don’t have any bookings yet.
          </h2>
          <p class="text-[13.5px] text-slate-600 max-w-md mx-auto mb-5">
            Once you book a SilverCare service, it will appear here with full details,
            including date, status and services booked.
          </p>
          <a href="<%= request.getContextPath() %>/public/services.jsp"
             class="inline-flex items-center justify-center
                    rounded-full bg-[#1e2a38] text-[#fdfaf5]
                    text-[14px] font-medium
                    px-5 py-3
                    shadow-[0_14px_30px_rgba(15,23,42,0.30)]
                    hover:bg-[#253447]
                    active:scale-[0.99]
                    transition-all duration-200">
            Browse services
          </a>
        </section>
      <%
        } else {
          int index = 0;
          for (Booking b : bookings) {
              index++;

              String status = b.getStatus() != null ? b.getStatus() : "";
              String statusClass = "bg-slate-100 text-slate-700 border border-slate-200";

              if ("confirmed".equalsIgnoreCase(status) ||
                  "completed".equalsIgnoreCase(status)) {
                  statusClass = "bg-emerald-50 text-emerald-800 border border-emerald-200";
              } else if ("pending".equalsIgnoreCase(status)) {
                  statusClass = "bg-amber-50 text-amber-800 border border-amber-200";
              } else if ("cancelled".equalsIgnoreCase(status) ||
                         "canceled".equalsIgnoreCase(status)) {
                  statusClass = "bg-rose-50 text-rose-800 border border-rose-200";
              }
      %>

        <!-- Booking card -->
        <section class="card-appear rounded-[22px] bg-[#fdfaf5]
                        border border-[#e0dcd4]
                        shadow-[0_10px_32px_rgba(15,23,42,0.08)]
                        px-5 py-5 md:px-7 md:py-6 mb-5">

          <!-- Top row: id, date, status -->
          <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-4">
            <div>
              <p class="text-[11px] tracking-[0.18em] uppercase text-slate-500">
                Booking <span class="text-slate-700">#<%= b.getBookingId() %></span>
              </p>
              <p class="mt-1 text-[14px] text-slate-700">
                Scheduled date:
                <span class="font-medium text-[#111827]">
                  <%= b.getScheduledAt() %>
                </span>
              </p>
              <%
                String notes = b.getNotes();
                if (notes != null && !notes.trim().isEmpty()) {
              %>
              <p class="mt-1 text-[12.5px] text-slate-600">
                Notes:
                <span class="text-slate-700"><%= notes %></span>
              </p>
              <%
                }
              %>
            </div>

            <div class="flex md:flex-col items-start md:items-end gap-2">
              <span class="inline-flex items-center rounded-full px-3 py-1
                           text-[11.5px] font-medium capitalize <%= statusClass %>">
                <%= status.isEmpty() ? "Unknown" : status %>
              </span>
            </div>
          </div>

          <!-- Details table -->
          <div class="mt-3 border-t border-[#e4dfd6] pt-4">
            <h3 class="text-[13px] font-semibold text-[#1e2a38] mb-2">
              Services in this booking
            </h3>

            <%
              ArrayList<BookingDetail> details = b.getBookingDetails();
              if (details != null && !details.isEmpty()) {
            %>
              <div class="overflow-x-auto">
                <table class="min-w-full text-left text-[13px]">
                  <thead>
                    <tr class="border-b border-[#e4dfd6] text-slate-500">
                      <th class="py-2 pr-4 font-medium">Service</th>
                      <th class="py-2 pr-4 font-medium">Quantity</th>
                      <th class="py-2 pr-4 font-medium">Unit price</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%
                      for (BookingDetail d : details) {
                    %>
                      <tr class="border-b border-[#f0ebe2] last:border-b-0">
                        <td class="py-2.5 pr-4 text-[#111827]">
                          <%= d.getServiceName() %>
                        </td>
                        <td class="py-2.5 pr-4 text-slate-800">
                          <%= d.getQuantity() %>
                        </td>
                        <td class="py-2.5 pr-4 text-slate-800">
                          <%= d.getUnitPrice() %>
                        </td>
                      </tr>
                    <%
                      }
                    %>
                  </tbody>
                </table>
              </div>
            <%
              } else {
            %>
              <p class="text-[13px] text-slate-600">
                No booking line items are available for this booking.
              </p>
            <%
              }
            %>
          </div>
        </section>

      <%
          } // end for
        } // end else (has bookings)
      %>

    </div>
  </main>

  <%@ include file = "../includes/footer.jsp"%>
</body>
</html>