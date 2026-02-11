<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.util.*,Assignment1.Service.Service, Assignment1.Category"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Services – SilverCare</title>

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
        stone: {
          warm: '#f5f3ef',
          mid: '#e8e4dc',
          deep: '#d4cec3',
        },
        ink: {
          DEFAULT: '#2c2c2c',
          light: '#5a5a5a',
          muted: '#8a8a8a',
        },
        copper: {
          DEFAULT: '#b87a4b',
          light: '#d4a574',
        },
      }
    }
  }
}
</script>
<style>
html { scroll-behavior: smooth; }
body { -webkit-font-smoothing: antialiased; }

/* Loading screen */
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
.loader.hidden {
  opacity: 0;
  visibility: hidden;
}
.loader-bar {
  width: 120px;
  height: 2px;
  background: #e8e4dc;
  margin: 0 auto;
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

.page-content {
  opacity: 0;
  transition: opacity 0.6s ease;
}
.page-content.visible {
  opacity: 1;
}

.stagger-1 { animation: fadeSlideIn 0.6s ease 0.1s both; }
.stagger-2 { animation: fadeSlideIn 0.6s ease 0.2s both; }
.stagger-3 { animation: fadeSlideIn 0.6s ease 0.3s both; }

@keyframes fadeSlideIn {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}

.service-card {
  transition: transform 0.2s ease, border-color 0.2s ease;
}
.service-card:hover {
  transform: translateY(-2px);
  border-color: #2c2c2c;
}

.filter-btn {
  transition: background-color 0.2s, color 0.2s;
}
.filter-btn.active {
  background: #2c2c2c;
  color: #f5f3ef;
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
                <span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Our Services</span>
                <h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-3 mb-4 stagger-2">
                    Care, thoughtfully delivered
                </h1>
                <p class="text-ink-light text-base max-w-2xl leading-relaxed stagger-3">
                    Browse our available services — from home visits to overnight care. 
                    Filter by category, search by name, then add services to your cart.
                </p>

                <% if (!errText.isEmpty()) { %>
                <div class="mt-6 border border-copper/30 bg-copper/5 px-4 py-3 text-sm text-copper">
                    <%= errText %>
                </div>
                <% } %>
            </header>

            <!-- Filter Bar -->
            <section class="mb-10 pb-8 border-b border-stone-mid">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
                    <!-- Left: Category filters -->
                    <div class="flex flex-wrap gap-2">
                        <button type="button"
                                class="filter-btn active text-xs uppercase tracking-wide px-4 py-2 border border-stone-mid"
                                data-category="all">
                            All
                        </button>
                        <% for (Category c : categoryList) { %>
                        <button type="button"
                                class="filter-btn text-xs uppercase tracking-wide px-4 py-2 border border-stone-mid text-ink-light hover:border-ink"
                                data-category="<%= c.getCategoryId() %>">
                            <%= c.getCategoryName() %>
                        </button>
                        <% } %>
                    </div>

                    <!-- Right: Search + count -->
                    <div class="flex items-center gap-4">
                        <span class="text-xs text-ink-muted">
                            <%= serviceList.size() %> services
                        </span>
                        <div class="relative">
                            <input id="serviceSearch"
                                   type="text"
                                   placeholder="Search services..."
                                   class="w-56 border border-stone-mid bg-stone-warm px-4 py-2 text-sm text-ink placeholder:text-ink-muted focus:outline-none focus:border-ink">
                        </div>
                    </div>
                </div>

                <!-- Mobile category select -->
                <select id="categorySelect"
                        class="lg:hidden mt-4 w-full border border-stone-mid bg-stone-warm px-4 py-2 text-sm text-ink focus:outline-none focus:border-ink">
                    <option value="all">All categories</option>
                    <% for (Category c : categoryList) { %>
                    <option value="<%= c.getCategoryId() %>"><%= c.getCategoryName() %></option>
                    <% } %>
                </select>
            </section>

            <!-- Services Grid -->
            <section id="servicesGrid" class="grid gap-6 md:grid-cols-2 xl:grid-cols-3">
                <% for (Service s : serviceList) { %>
                <article class="service-card bg-white border border-stone-mid flex flex-col"
                         data-category="<%= s.getCategoryId() %>"
                         data-name="<%= s.getServiceName().toLowerCase() %>">

                    <!-- Image -->
                    <div class="relative h-48 overflow-hidden bg-stone-mid">
                        <img src="<%= request.getContextPath() %>/<%= s.getImagePath() %>"
                             alt="<%= s.getServiceName() %>"
                             class="w-full h-full object-cover">
                        <div class="absolute inset-0 bg-gradient-to-t from-ink/40 to-transparent"></div>
                        
                        <div class="absolute bottom-3 left-3 right-3 flex items-center justify-between">
                            <span class="inline-flex items-center gap-1.5 px-2 py-1 bg-ink/60 text-stone-warm text-xs">
                                <span class="w-1.5 h-1.5 bg-green-400"></span>
                                Available
                            </span>
                            <span class="px-2 py-1 bg-ink/60 text-stone-warm text-xs">
                                <%= s.getDurationMin() %> min
                            </span>
                        </div>
                    </div>

                    <!-- Content -->
                    <div class="flex-1 flex flex-col p-5">
                        <div class="flex-1">
                            <h2 class="font-serif text-xl font-medium text-ink mb-2">
                                <%= s.getServiceName() %>
                            </h2>
                            <p class="text-sm text-ink-light leading-relaxed line-clamp-2 mb-4">
                                <%= s.getDescription() %>
                            </p>
                        </div>

                        <div class="flex items-end justify-between mb-4">
                            <div>
                                <p class="text-xs uppercase tracking-wide text-ink-muted mb-1">From</p>
                                <p class="text-lg font-medium text-ink">
                                    $<%= s.getPrice() %>
                                    <span class="text-xs font-normal text-ink-muted">/ session</span>
                                </p>
                            </div>
                            <div class="text-right">
                                <p class="text-xs text-ink-muted">Duration</p>
                                <p class="text-sm text-ink"><%= s.getDurationMin() %> min</p>
                            </div>
                        </div>

                        <!-- Actions -->
                        <div class="flex gap-3 pt-4 border-t border-stone-mid">
                            <form method="get"
                                  action="<%= request.getContextPath() %>/serviceDetailServlet"
                                  class="flex-1">
                                <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                                <button type="submit"
                                        class="w-full px-4 py-2.5 border border-stone-mid text-sm text-ink hover:border-ink transition-colors">
                                    Details
                                </button>
                            </form>

                            <form method="post"
                                  action="<%= request.getContextPath() %>/cart/add"
                                  class="flex-1">
                                <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                                <input type="hidden" name="serviceName" value="<%= s.getServiceName() %>">
                                <input type="hidden" name="price" value="<%= s.getPrice() %>">
                                <button type="submit"
                                        class="w-full px-4 py-2.5 bg-ink text-stone-warm text-sm hover:bg-ink-light transition-colors">
                                    Add to cart
                                </button>
                            </form>
                        </div>
                    </div>
                </article>
                <% } %>
            </section>

            <% if (serviceList.isEmpty()) { %>
            <div class="mt-10 border border-dashed border-stone-deep bg-white px-6 py-12 text-center">
                <p class="text-ink-muted text-sm">No services available at the moment.</p>
                <p class="text-ink-muted text-xs mt-2">Please check back later.</p>
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
        }, 600);
    });

    document.addEventListener("DOMContentLoaded", function() {
        var filterBtns = document.querySelectorAll(".filter-btn");
        var select = document.getElementById("categorySelect");
        var cards = document.querySelectorAll(".service-card");
        var searchInput = document.getElementById("serviceSearch");

        var activeCategory = "all";

        function applyFilters() {
            var query = (searchInput.value || "").toLowerCase();

            cards.forEach(function(card) {
                var cardCat = card.getAttribute("data-category");
                var cardName = card.getAttribute("data-name") || "";

                var matchesCategory = activeCategory === "all" || activeCategory === cardCat;
                var matchesSearch = query === "" || cardName.includes(query);

                card.style.display = (matchesCategory && matchesSearch) ? "" : "none";
            });
        }

        filterBtns.forEach(function(btn) {
            btn.addEventListener("click", function() {
                filterBtns.forEach(function(b) { b.classList.remove("active"); });
                btn.classList.add("active");
                activeCategory = btn.getAttribute("data-category") || "all";

                if (select) {
                    select.value = activeCategory;
                }

                applyFilters();
            });
        });

        if (select) {
            select.addEventListener("change", function() {
                activeCategory = select.value || "all";

                filterBtns.forEach(function(b) {
                    var cat = b.getAttribute("data-category") || "all";
                    b.classList.toggle("active", cat === activeCategory);
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
