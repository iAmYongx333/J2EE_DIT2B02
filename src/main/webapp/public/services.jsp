<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.util.*,Assignment1.Service.Service, Assignment1.Category"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Services | SilverCare</title>

    <%
        ArrayList<Service> serviceList = (ArrayList<Service>) session.getAttribute("serviceList");
        ArrayList<Category> categoryList = (ArrayList<Category>) session.getAttribute("categoryList");
        if (serviceList == null || categoryList == null) {
            response.sendRedirect(request.getContextPath() + "/serviceServlet");
            return;
        }

        String errText = "";
        String errCode = request.getParameter("errCode");
        if (errCode != null) {
            errText = errCode;
        }
    %>

    <!-- Tailwind CDN -->
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text",
                         "Segoe UI", sans-serif;
        }

        .service-card {
            transition:
                transform 0.22s ease,
                box-shadow 0.22s ease,
                border-color 0.22s ease,
                background-color 0.22s ease;
        }
        .service-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.14);
            border-color: rgba(148, 163, 184, 0.7);
            background-color: rgba(255, 255, 255, 0.96);
        }

        .pill-filter {
            transition:
                background-color 0.18s ease,
                color 0.18s ease,
                box-shadow 0.18s ease,
                transform 0.18s ease;
        }
        .pill-filter:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.12);
        }
        .pill-filter-active {
            background: #111827;
            color: #f9fafb;
            box-shadow: 0 14px 30px rgba(15, 23, 42, 0.35);
        }
    </style>
</head>

<body class="bg-[#f7f4ef] text-slate-900">
    <%@ include file="../includes/header.jsp" %>

    <main class="mt-12 min-h-screen pt-24 pb-16 px-6 sm:px-10 lg:px-16">
        <div class="max-w-6xl xl:max-w-7xl mx-auto space-y-10">

            <!-- PAGE HEADER -->
            <section class="space-y-4">
                <div class="inline-flex items-center gap-2 rounded-full bg-white/70 border border-[#e4ddd4] px-3 py-1 text-[11px] tracking-[0.16em] uppercase text-slate-500">
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                    SilverCare Services
                </div>

                <div class="space-y-3">
                    <h1 class="text-3xl sm:text-4xl font-semibold tracking-tight">
                        Calm, organised care services.
                    </h1>
                    <p class="max-w-2xl text-sm sm:text-[15px] text-slate-700 leading-relaxed">
                        Browse our available services, from home visits to overnight care.
                        Filter by category or search by name, then add services to your cart
                        to book them in a single, organised checkout.
                    </p>
                </div>

                <% if (!errText.isEmpty()) { %>
                    <div class="mt-3 rounded-xl border border-amber-200 bg-amber-50/80 px-4 py-3 text-xs sm:text-sm text-amber-800">
                        <strong class="font-medium">Note:</strong>
                        <span class="ml-1"><%= errText %></span>
                    </div>
                <% } %>
            </section>

            <!-- FILTER BAR -->
            <section class="space-y-4">
                <!-- Top row: search + summary -->
                <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                    <div class="space-y-1">
                        <p class="text-xs uppercase tracking-[0.16em] text-slate-500 font-medium">
                            Services
                        </p>
                        <p class="text-xs text-slate-500">
                            <%= serviceList.size() %> services available.
                        </p>
                    </div>

                    <div class="flex items-center gap-3 w-full sm:w-auto">
                        <!-- Mobile category dropdown (fallback) -->
                        <select id="categorySelect"
                                class="sm:hidden flex-1 px-3 py-2 rounded-lg border border-slate-200 bg-white/80 text-xs focus:outline-none focus:ring-2 focus:ring-slate-400/50">
                            <option value="all">All categories</option>
                            <%
                                for (Category c : categoryList) {
                            %>
                                <option value="<%= c.getCategoryId() %>"><%= c.getCategoryName() %></option>
                            <%
                                }
                            %>
                        </select>

                        <!-- Search -->
                        <div class="relative w-full sm:w-64">
                            <input id="serviceSearch"
                                   type="text"
                                   placeholder="Search by name..."
                                   class="w-full pl-9 pr-3 py-2 rounded-lg border border-slate-200 bg-white/80 text-xs sm:text-sm placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-slate-400/50 focus:border-slate-400" />
                            <span class="absolute inset-y-0 left-2.5 flex items-center text-slate-400 text-xs">
                                🔍
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Desktop category pills -->
                <div class="hidden sm:flex flex-wrap gap-2">
                    <button type="button"
                            class="pill-filter pill-filter-active text-xs px-3.5 py-1.5 rounded-full border border-slate-300 bg-white/90"
                            data-category="all">
                        All
                    </button>
                    <%
                        for (Category c : categoryList) {
                    %>
                        <button type="button"
                                class="pill-filter text-xs px-3.5 py-1.5 rounded-full border border-slate-200 bg-white/70 text-slate-700"
                                data-category="<%= c.getCategoryId() %>">
                            <%= c.getCategoryName() %>
                        </button>
                    <%
                        }
                    %>
                </div>
            </section>

            <!-- SERVICES GRID -->
            <section id="servicesGrid"
                     class="grid gap-6 md:grid-cols-2 xl:grid-cols-3">
                <%
                    for (Service s : serviceList) {
                %>
                    <article class="service-card bg-white/90 border border-slate-200 rounded-2xl overflow-hidden flex flex-col"
                             data-category="<%= s.getCategoryId() %>"
                             data-name="<%= s.getServiceName().toLowerCase() %>">

                        <!-- Image -->
                        <div class="relative h-40 overflow-hidden bg-slate-100">
                            <img src="<%= request.getContextPath() %>/<%= s.getImagePath() %>"
                                 alt="<%= s.getServiceName() %>"
                                 class="w-full h-full object-cover" />
                            <div class="absolute inset-0 bg-gradient-to-t from-black/35 via-black/10 to-transparent pointer-events-none"></div>

                            <div class="absolute bottom-3 left-3 right-3 flex items-center justify-between text-[11px] text-slate-100">
                                <span class="inline-flex items-center gap-1.5 px-2 py-1 rounded-full bg-black/40 backdrop-blur">
                                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                                    <span>Available</span>
                                </span>
                                <span class="px-2 py-1 rounded-full bg-black/35 backdrop-blur text-[11px]">
                                    <%= s.getDurationMin() %> min session
                                </span>
                            </div>
                        </div>

                        <!-- Content -->
                        <div class="flex-1 flex flex-col px-4 py-4 sm:px-5 sm:py-5 space-y-3">
                            <div class="space-y-1">
                                <h2 class="text-base sm:text-[17px] font-semibold text-[#111827]">
                                    <%= s.getServiceName() %>
                                </h2>
                                <p class="text-xs text-slate-600 leading-relaxed line-clamp-3">
                                    <%= s.getDescription() %>
                                </p>
                            </div>

                            <div class="flex items-center justify-between text-xs sm:text-sm">
                                <div class="space-y-0.5">
                                    <p class="text-[11px] uppercase tracking-[0.16em] text-slate-500">
                                        From
                                    </p>
                                    <p class="text-[15px] font-semibold text-slate-900">
                                        $<%= s.getPrice() %>
                                        <span class="text-[11px] font-normal text-slate-500">/ session</span>
                                    </p>
                                </div>

                                <div class="text-right text-[11px] text-slate-500">
                                    <p>Duration</p>
                                    <p class="font-medium text-slate-800"><%= s.getDurationMin() %> min</p>
                                </div>
                            </div>

                            <!-- Actions -->
                            <div class="pt-2 flex flex-col sm:flex-row gap-2">
                                <!-- View details -->
                                <form method="get"
                                      action="<%= request.getContextPath() %>/serviceDetailServlet"
                                      class="flex-1">
                                    <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                                    <button type="submit"
                                            class="w-full inline-flex items-center justify-center px-3 py-2 rounded-xl border border-slate-200 bg-white text-xs sm:text-sm text-slate-800 hover:bg-slate-50 transition-colors">
                                        View details
                                    </button>
                                </form>

                                <!-- Add to cart -->
                                <form method="post"
                                      action="<%= request.getContextPath() %>/cart/add"
                                      class="flex-1">
                                    <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                                    <input type="hidden" name="serviceName" value="<%= s.getServiceName() %>">
                                    <input type="hidden" name="price" value="<%= s.getPrice() %>">
                                    <button type="submit"
                                            class="w-full inline-flex items-center justify-center px-3 py-2 rounded-xl bg-slate-900 text-xs sm:text-sm text-white shadow-sm hover:bg-slate-950 hover:shadow-lg transition-all">
                                        Add to cart
                                    </button>
                                </form>
                            </div>
                        </div>
                    </article>
                <%
                    }
                %>
            </section>

            <% if (serviceList.isEmpty()) { %>
                <div class="mt-10 rounded-2xl border border-dashed border-slate-300 bg-white/80 px-6 py-10 text-center text-sm text-slate-500">
                    No services are available at the moment. Please check back later.
                </div>
            <% } %>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>

    <script>
        document.addEventListener("DOMContentLoaded", () => {
            const pills = document.querySelectorAll(".pill-filter");
            const select = document.getElementById("categorySelect");
            const cards = document.querySelectorAll(".service-card");
            const searchInput = document.getElementById("serviceSearch");

            let activeCategory = "all";

            function applyFilters() {
                const query = (searchInput.value || "").toLowerCase();

                cards.forEach(card => {
                    const cardCat = card.getAttribute("data-category");
                    const cardName = card.getAttribute("data-name") || "";

                    const matchesCategory =
                        activeCategory === "all" || activeCategory === cardCat;
                    const matchesSearch =
                        query === "" || cardName.includes(query);

                    card.style.display = (matchesCategory && matchesSearch) ? "" : "none";
                });
            }

            pills.forEach(pill => {
                pill.addEventListener("click", () => {
                    pills.forEach(p => p.classList.remove("pill-filter-active"));
                    pill.classList.add("pill-filter-active");
                    activeCategory = pill.getAttribute("data-category") || "all";

                    // sync dropdown on mobile
                    if (select) {
                        select.value = activeCategory;
                    }

                    applyFilters();
                });
            });

            if (select) {
                select.addEventListener("change", () => {
                    activeCategory = select.value || "all";

                    // sync pills on desktop
                    pills.forEach(p => {
                        const cat = p.getAttribute("data-category") || "all";
                        p.classList.toggle("pill-filter-active", cat === activeCategory);
                    });

                    applyFilters();
                });
            }

            if (searchInput) {
                searchInput.addEventListener("input", applyFilters);
            }
        });
    </script>
</body>
</html>