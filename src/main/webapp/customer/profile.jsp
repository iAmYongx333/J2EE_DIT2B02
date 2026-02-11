<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*,Assignment1.Customer.Customer, Assignment1.Country" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Profile | SilverCare</title>

    <%
        String errText = "";
        String errCode = request.getParameter("errCode");
        if (errCode != null) {
            errText = errCode;
        }
        Customer u = (Customer) session.getAttribute("user");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=SessionExpired");
            return;
        }
        System.out.println("User country ID: " + u.getCountryId());

        ArrayList<Country> countryList = (ArrayList<Country>) session.getAttribute("countryList");
        if (countryList == null) {
            response.sendRedirect(request.getContextPath() + "/countryCodeServlet?origin=profile");
            return;
        }
        String userFlagImage = null;
        for (Country c : countryList) {
            if (c.getId() == u.getCountryId()) {
                userFlagImage = c.getFlagImage();
                break;
            }
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
    </style>
</head>

<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
    <%@ include file="../includes/header.jsp" %>

    <main class="pt-24 max-w-5xl mx-auto px-5 md:px-12 py-12 md:py-16">
        <!-- Page heading -->
        <div class="mb-10">
            <span class="text-copper text-xs uppercase tracking-[0.2em]">SilverCare Account</span>
            <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink mt-2">My Profile</h1>
            <p class="mt-3 text-ink-light text-base max-w-xl">
                Account details and contact information for your SilverCare bookings.
            </p>
        </div>

        <!-- Error banner (if any) -->
        <% if (errText != null && !errText.trim().isEmpty()) { %>
            <div class="mb-6 border border-copper bg-copper/5 px-4 py-3 text-sm text-copper">
                <%= errText %>
            </div>
        <% } %>

        <!-- Profile card -->
        <div class="bg-white border border-stone-mid p-6 md:p-8">

            <!-- Top: name + edit button -->
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
                <div>
                    <h2 class="font-serif text-xl md:text-2xl font-medium text-ink"><%= u.getName() %></h2>
                </div>

                <a href="<%=request.getContextPath()%>/profile/edit"
                   class="inline-flex items-center justify-center border border-stone-mid px-5 py-2.5 text-sm text-ink-light hover:border-ink hover:text-ink transition-colors">
                    Edit profile
                </a>
            </div>

            <div class="border-t border-stone-mid pt-6 grid md:grid-cols-2 gap-8">

                <!-- Column 1: contact -->
                <div class="space-y-5">
                    <div class="space-y-1">
                        <div class="text-xs uppercase tracking-[0.15em] text-ink-muted">Email</div>
                        <p class="text-sm text-ink break-all"><%= u.getEmail() %></p>
                    </div>

                    <div class="space-y-1">
                        <div class="text-xs uppercase tracking-[0.15em] text-ink-muted">Phone</div>
                        <p class="text-sm text-ink"><%= u.getPhone() %></p>
                    </div>

                    <div class="space-y-1">
                        <div class="text-xs uppercase tracking-[0.15em] text-ink-muted">Country</div>
                        <p class="text-sm text-ink flex items-center gap-2">
                            <% if (userFlagImage != null) { %>
                                <img src="<%=request.getContextPath()%>/images/flags/<%= userFlagImage %>"
                                     alt="<%= u.getCountryId() %>" class="w-5 h-auto">
                            <% } %>
                            <span><%= u.getCountryName() %></span>
                        </p>
                    </div>
                </div>

                <!-- Column 2: address -->
                <div class="space-y-5">
                    <div class="space-y-1">
                        <div class="text-xs uppercase tracking-[0.15em] text-ink-muted">Street address</div>
                        <p class="text-sm text-ink"><%= u.getStreet() %></p>
                    </div>

                    <div class="grid grid-cols-2 gap-5">
                        <div class="space-y-1">
                            <div class="text-xs uppercase tracking-[0.15em] text-ink-muted">Postal code</div>
                            <p class="text-sm text-ink"><%= u.getPostalCode() %></p>
                        </div>
                        <div class="space-y-1">
                            <div class="text-xs uppercase tracking-[0.15em] text-ink-muted">Block / unit</div>
                            <p class="text-sm text-ink">
                                <%
                                    String block = u.getBlock() != null ? u.getBlock() : "";
                                    String unit = u.getUnitNumber() != null ? u.getUnitNumber() : "";
                                %>
                                <%= block %><%= (!block.isEmpty() && !unit.isEmpty()) ? ", " : "" %><%= unit %>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
</body>
</html>
