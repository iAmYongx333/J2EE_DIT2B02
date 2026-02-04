<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*,Assignment1.CartItem" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SilverCare | Cart</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        html { scroll-behavior: smooth; }
        body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Inter", sans-serif; }
    </style>
    <%
    Object userRole = session.getAttribute("sessRole");
    if(userRole == null){
    	response.sendRedirect(request.getContextPath()+"/public/login.jsp?errCode=NoSession");
    }
    %>
</head>
<body class="bg-[#f7f4ef] text-slate-900 min-h-screen">
  <%@ include file="../includes/header.jsp" %>

<%
    // Get cart from session
    HttpSession sessionObj = request.getSession(false);
    List<CartItem> cart = null;
    if (sessionObj != null) {
        cart = (List<CartItem>) sessionObj.getAttribute("cart");
    }
    boolean isEmpty = (cart == null || cart.isEmpty());
    double totalAmount = 0.0;
    if (!isEmpty) {
        for (CartItem item : cart) {
            totalAmount += item.getLineTotal();
        }
    }
%>

<main class="mt-12 max-w-6xl mx-auto px-4 md:px-6 lg:px-8 py-10 md:py-14">
    <div class="mb-8">
        <h1 class="text-2xl md:text-3xl font-semibold tracking-tight text-slate-900">
            Your Care Cart
        </h1>
        <p class="mt-2 text-sm md:text-base text-slate-600 max-w-xl">
            Review the services you’ve selected for your loved one. You can adjust quantities, remove items,
            or proceed to confirm your booking.
        </p>
    </div>

    <div class="bg-white/90 rounded-3xl shadow-sm border border-slate-100 p-4 md:p-6 lg:p-8">
        <%
            if (isEmpty) {
        %>
            <div class="flex flex-col items-center justify-center py-12">
                <div class="w-16 h-16 rounded-full bg-slate-100 flex items-center justify-center mb-4">
                    <span class="text-2xl">🧺</span>
                </div>
                <h2 class="text-lg md:text-xl font-semibold text-slate-900 mb-2">
                    Your cart is empty
                </h2>
                <p class="text-slate-600 text-sm md:text-base mb-6 text-center max-w-sm">
                    You haven’t added any services yet. Browse our care services and add them to your cart
                    to start a booking.
                </p>
                <a href="<%=request.getContextPath()%>/services.jsp"
                   class="inline-flex items-center justify-center px-5 py-2.5 rounded-full text-sm font-medium
                          bg-emerald-500 text-white hover:bg-emerald-600 transition">
                    Browse Services
                </a>
            </div>
        <%
            } else {
        %>

        <!-- Cart table -->
        <div class="overflow-x-auto">
            <table class="min-w-full text-sm md:text-base">
                <thead>
                <tr class="border-b border-slate-200 text-left text-xs md:text-sm uppercase tracking-wide text-slate-500">
                    <th class="py-3 pr-3">Service</th>
                    <th class="py-3 px-3">Category</th>
                    <th class="py-3 px-3 text-right">Unit Price</th>
                    <th class="py-3 px-3 text-center">Quantity</th>
                    <th class="py-3 px-3 text-right">Line Total</th>
                    <th class="py-3 pl-3 text-center">Actions</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                <%
                    for (CartItem item : cart) {
                %>
                <tr class="hover:bg-slate-50/70">
                    <td class="py-3 pr-3 align-middle">
                        <div class="font-medium text-slate-900"><%= item.getServiceName() %></div>
                        <div class="text-xs text-slate-500 mt-0.5">ID: <%= item.getServiceId() %></div>
                    </td>
                    <td class="py-3 px-3 align-middle text-slate-700">
                        <%= item.getCategoryName() %>
                    </td>
                    <td class="py-3 px-3 align-middle text-right text-slate-700">
                        $<%= String.format("%.2f", item.getUnitPrice()) %>
                    </td>
                    <td class="py-3 px-3 align-middle text-center">
                        <form action="<%=request.getContextPath()%>/cart/update" method="post"
                              class="inline-flex items-center gap-2 justify-center">
                            <input type="hidden" name="service_id" value="<%= item.getServiceId() %>">
                            <input type="number"
                                   name="quantity"
                                   min="0"
                                   value="<%= item.getQuantity() %>"
                                   class="w-16 rounded-full border border-slate-200 px-3 py-1 text-sm text-center focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500">
                            <button type="submit" name="action" value="update"
                                    class="text-xs md:text-sm px-3 py-1 rounded-full border border-emerald-500 text-emerald-600 font-medium hover:bg-emerald-50 transition">
                                Update
                            </button>
                        </form>
                    </td>
                    <td class="py-3 px-3 align-middle text-right font-medium text-slate-900">
                        $<%= String.format("%.2f", item.getLineTotal()) %>
                    </td>
                    <td class="py-3 pl-3 align-middle text-center">
                        <form action="<%=request.getContextPath()%>/cart/update" method="post">
                            <input type="hidden" name="service_id" value="<%= item.getServiceId() %>">
                            <input type="hidden" name="quantity" value="0">
                            <button type="submit" name="action" value="remove"
                                    class="text-xs md:text-sm px-3 py-1 rounded-full text-slate-500 hover:text-red-600 hover:bg-red-50 border border-slate-200 transition">
                                Remove
                            </button>
                        </form>
                    </td>
                </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>

        <!-- Summary + clear/browse buttons -->
        <div class="mt-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div class="flex items-center gap-3 text-sm text-slate-600">
                <form action="<%=request.getContextPath()%>/cart/clear" method="post">
                    <button type="submit"
                            class="inline-flex items-center px-4 py-2 rounded-full border border-slate-200 text-slate-600 text-xs md:text-sm font-medium hover:bg-slate-50 transition">
                        Clear Cart
                    </button>
                </form>
                <a href="<%=request.getContextPath()%>/services.jsp"
                   class="inline-flex items-center px-4 py-2 rounded-full border border-slate-200 text-slate-600 text-xs md:text-sm font-medium hover:bg-slate-50 transition">
                    Continue Browsing
                </a>
            </div>
            <div class="text-right">
                <div class="text-xs md:text-sm text-slate-500 uppercase tracking-wide">Total</div>
                <div class="text-xl md:text-2xl font-semibold text-slate-900">
                    $<%= String.format("%.2f", totalAmount) %>
                </div>
            </div>
        </div>

        <!-- Checkout form -->
        <div class="mt-8 pt-6 border-t border-slate-100">
            <h2 class="text-lg md:text-xl font-semibold text-slate-900 mb-2">
                Confirm Booking Details
            </h2>
            <p class="text-sm md:text-base text-slate-600 mb-4 max-w-xl">
                Choose when the services should start and leave any additional notes for our care team.
                After you confirm, your booking will be submitted for processing.
            </p>

            <form action="<%=request.getContextPath()%>/cart/checkout" method="post" class="space-y-4 md:space-y-5">
                <div class="grid md:grid-cols-2 gap-4 md:gap-6">
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">
                            Service Date <span class="text-red-500">*</span>
                        </label>
                        <input type="date"
                               name="service_date"
                               required
                               class="w-full rounded-2xl border border-slate-200 px-3 py-2 text-sm md:text-base focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 bg-white">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">
                            Preferred Time
                        </label>
                        <input type="text"
                               name="preferred_time"
                               placeholder="e.g. Morning, 2–4 pm"
                               class="w-full rounded-2xl border border-slate-200 px-3 py-2 text-sm md:text-base focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 bg-white">
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">
                        Notes for our team
                    </label>
                    <textarea name="notes"
                              rows="3"
                              placeholder="Share any medical conditions, mobility concerns, or special preferences."
                              class="w-full rounded-2xl border border-slate-200 px-3 py-2 text-sm md:text-base focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 bg-white resize-y"></textarea>
                </div>

                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mt-2">
                    <p class="text-xs md:text-sm text-slate-500 max-w-md">
                        By confirming, you agree that SilverCare will review your booking and contact you
                        if any clarification is needed. Payment can be handled according to the method shown
                        on the confirmation page.
                    </p>
                    <button type="submit"
                            class="inline-flex items-center justify-center px-6 py-2.5 md:py-3 rounded-full text-sm md:text-base font-semibold bg-emerald-500 text-white hover:bg-emerald-600 shadow-sm hover:shadow transition">
                        Confirm Booking
                    </button>
                </div>
            </form>
        </div>

        <%
            } // end else (cart not empty)
        %>
    </div>
</main>

</body>
</html>