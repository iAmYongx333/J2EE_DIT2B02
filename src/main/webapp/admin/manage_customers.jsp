<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Customers – SilverCare</title>

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

    .loader {
        position: fixed; inset: 0; background: #f5f3ef;
        display: flex; align-items: center; justify-content: center;
        z-index: 9999; transition: opacity 0.5s ease, visibility 0.5s ease;
    }
    .loader.hidden { opacity: 0; visibility: hidden; }
    .loader-bar {
        width: 120px; height: 2px; background: #e8e4dc; overflow: hidden;
    }
    .loader-bar::after {
        content: ''; display: block; width: 40%; height: 100%;
        background: #2c2c2c; animation: loadingBar 1s ease-in-out infinite;
    }
    @keyframes loadingBar {
        0% { transform: translateX(-100%); }
        100% { transform: translateX(350%); }
    }

    .page-content { opacity: 0; transition: opacity 0.6s ease; }
    .page-content.visible { opacity: 1; }

    .stagger-1 { animation: fadeSlideIn 0.6s ease 0.1s both; }
    .stagger-2 { animation: fadeSlideIn 0.6s ease 0.2s both; }
    .stagger-3 { animation: fadeSlideIn 0.6s ease 0.3s both; }
    .stagger-4 { animation: fadeSlideIn 0.6s ease 0.4s both; }

    @keyframes fadeSlideIn {
        from { opacity: 0; transform: translateY(16px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .table-row-hover { transition: background-color 0.15s ease; }
    .table-row-hover:hover { background-color: #f5f3ef; }
    .text-mono { font-variant-numeric: tabular-nums; }
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
            <header class="mb-10">
                <div class="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6">
                    <div>
                        <span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Administration</span>
                        <h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-3 mb-4 stagger-2">
                            Manage Customers
                        </h1>
                        <p class="text-ink-light text-base max-w-xl leading-relaxed stagger-3">
                            View registered customers, review contact details, and manage accounts.
                        </p>
                    </div>

                    <div class="stagger-3 flex items-center gap-4">
                        <a href="${pageContext.request.contextPath}/admin/dashboard"
                           class="text-xs text-ink-muted hover:text-ink transition-colors inline-flex items-center gap-1">
                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                            </svg>
                            Dashboard
                        </a>
                    </div>
                </div>
            </header>

            <!-- Table Card -->
            <section class="stagger-3">
                <div class="bg-white border border-stone-mid">

                    <!-- Toolbar -->
                    <div class="px-6 py-5 border-b border-stone-mid flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                        <div>
                            <h2 class="font-serif text-lg font-medium text-ink">Customer Directory</h2>
                            <p class="text-xs text-ink-muted mt-1">
                                <c:choose>
                                    <c:when test="${not empty customers}">
                                        ${fn:length(customers)} customer<c:if test="${fn:length(customers) != 1}">s</c:if> registered
                                    </c:when>
                                    <c:otherwise>No customers found</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div>
                            <input type="text" id="customerSearch" placeholder="Search by name or email..."
                                   class="w-full sm:w-64 px-4 py-2.5 border border-stone-mid text-sm bg-stone-warm text-ink placeholder:text-ink-muted focus:outline-none focus:border-ink transition-colors" />
                        </div>
                    </div>

                    <!-- Desktop Table -->
                    <div class="hidden md:block overflow-x-auto">
                        <table class="min-w-full">
                            <thead class="bg-stone-warm border-b border-stone-mid">
                                <tr class="text-xs uppercase tracking-[0.15em] text-ink-muted">
                                    <th class="text-left px-6 py-3 font-medium">Customer</th>
                                    <th class="text-left px-6 py-3 font-medium">Email</th>
                                    <th class="text-left px-4 py-3 font-medium">Phone</th>
                                    <th class="text-left px-4 py-3 font-medium">Country</th>
                                    <th class="text-left px-4 py-3 font-medium">Joined</th>
                                    <th class="text-right px-6 py-3 font-medium">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-stone-mid text-sm">
                                <c:forEach var="cust" items="${customers}">
                                    <tr class="table-row-hover customer-row"
                                        data-name="${fn:toLowerCase(cust.name)}"
                                        data-email="${fn:toLowerCase(cust.email)}">
                                        <td class="px-6 py-4 align-middle">
                                            <div class="flex items-center gap-3">
                                                <div class="w-9 h-9 bg-stone-mid flex items-center justify-center flex-shrink-0">
                                                    <span class="font-serif text-sm text-ink">
                                                        ${fn:substring(cust.name, 0, 1)}
                                                    </span>
                                                </div>
                                                <div>
                                                    <p class="font-medium text-ink text-sm">${cust.name}</p>
                                                    <p class="text-[11px] text-ink-muted">ID: ${cust.userId}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="px-6 py-4 align-middle">
                                            <span class="text-ink-light text-sm">${cust.email}</span>
                                        </td>
                                        <td class="px-4 py-4 align-middle">
                                            <span class="text-ink-light text-sm text-mono">${cust.phone}</span>
                                        </td>
                                        <td class="px-4 py-4 align-middle">
                                            <c:choose>
                                                <c:when test="${not empty cust.countryName}">
                                                    <div class="inline-flex items-center gap-2 px-3 py-1.5 bg-stone-warm border border-stone-mid">
                                                        <c:if test="${not empty cust.flagImage}">
                                                            <img src="${pageContext.request.contextPath}/images/flags/${cust.flagImage}"
                                                                 alt="${cust.countryName}" class="w-4 h-3 object-cover" />
                                                        </c:if>
                                                        <span class="text-xs text-ink">${cust.countryName}</span>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-xs text-ink-muted">Unknown</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="px-4 py-4 align-middle">
                                            <time data-iso="${cust.createdAt}" class="text-xs text-ink-muted text-mono">${cust.createdAt}</time>
                                        </td>
                                        <td class="px-6 py-4 align-middle text-right">
                                            <button type="button"
                                                    class="open-delete-modal text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 hover:bg-red-50 transition-colors"
                                                    data-id="${cust.userId}" data-name="${cust.name}" data-email="${cust.email}">
                                                Delete
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty customers}">
                                    <tr>
                                        <td colspan="6" class="px-6 py-12 text-center">
                                            <svg class="w-10 h-10 text-stone-deep mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                                            </svg>
                                            <p class="text-sm text-ink-muted">No customers yet</p>
                                            <p class="text-xs text-ink-muted mt-1">Accounts will appear here after registration</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- Mobile Cards -->
                    <div class="md:hidden divide-y divide-stone-mid" id="customersCards">
                        <c:forEach items="${customers}" var="cust">
                            <div class="customer-row px-5 py-4 space-y-3"
                                 data-name="${fn:toLowerCase(cust.name)}"
                                 data-email="${fn:toLowerCase(cust.email)}">
                                <div class="flex items-start justify-between gap-3">
                                    <div class="flex items-center gap-3">
                                        <div class="w-9 h-9 bg-stone-mid flex items-center justify-center flex-shrink-0">
                                            <span class="font-serif text-sm text-ink">${fn:substring(cust.name, 0, 1)}</span>
                                        </div>
                                        <div>
                                            <p class="font-medium text-sm text-ink">${cust.name}</p>
                                            <p class="text-[11px] text-ink-muted">${cust.email}</p>
                                        </div>
                                    </div>
                                    <c:if test="${not empty cust.countryName}">
                                        <div class="inline-flex items-center gap-1.5 px-2 py-1 bg-stone-warm border border-stone-mid">
                                            <c:if test="${not empty cust.flagImage}">
                                                <img src="${pageContext.request.contextPath}/images/flags/${cust.flagImage}"
                                                     alt="${cust.countryName}" class="w-4 h-3 object-cover" />
                                            </c:if>
                                            <span class="text-[11px] text-ink">${cust.countryName}</span>
                                        </div>
                                    </c:if>
                                </div>
                                <div class="flex items-center justify-between text-xs text-ink-muted">
                                    <span class="text-mono">${cust.phone}</span>
                                    <time data-iso="${cust.createdAt}" class="text-mono">${cust.createdAt}</time>
                                </div>
                                <div class="flex justify-end">
                                    <button type="button"
                                            class="open-delete-modal text-[11px] px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 transition-colors"
                                            data-id="${cust.userId}" data-name="${cust.name}" data-email="${cust.email}">
                                        Delete
                                    </button>
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty customers}">
                            <div class="px-5 py-12 text-center">
                                <p class="text-sm text-ink-muted">No customers yet</p>
                            </div>
                        </c:if>
                    </div>

                </div>
            </section>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <!-- Delete Modal -->
    <div id="deleteModalBackdrop"
         class="fixed inset-0 z-[220] bg-black/20 backdrop-blur-sm flex items-center justify-center opacity-0 invisible transition-opacity duration-200">
        <div id="deleteModal"
             class="w-full max-w-md mx-4 bg-white border border-stone-mid shadow-lg px-7 py-7 transform translate-y-4 transition-all duration-250 ease-out">

            <h2 class="font-serif text-xl font-medium text-ink">Delete Customer</h2>
            <p class="mt-3 text-sm text-ink-light leading-relaxed">
                This action will permanently remove this customer account from SilverCare.
                Bookings tied to this account may also be affected. This cannot be undone.
            </p>

            <div class="mt-5 border border-stone-mid bg-stone-warm px-5 py-4">
                <p class="text-sm font-medium text-ink" id="deleteCustomerName">Customer name</p>
                <p class="text-xs text-ink-muted mt-1 break-all" id="deleteCustomerEmail">customer@example.com</p>
                <p class="text-[11px] text-ink-muted mt-1" id="deleteCustomerId">ID: —</p>
            </div>

            <form id="deleteCustomerForm" method="post"
                  action="${pageContext.request.contextPath}/admin/customers/delete"
                  class="mt-6 flex items-center justify-end gap-3">
                <input type="hidden" name="user_id" id="deleteUserId" />

                <button type="button" id="cancelDeleteBtn"
                        class="px-4 py-2 border border-stone-mid text-sm text-ink bg-white hover:bg-stone-warm transition-colors">
                    Cancel
                </button>
                <button type="submit"
                        class="px-4 py-2 bg-red-600 text-white text-sm font-medium hover:bg-red-700 transition-colors">
                    Delete customer
                </button>
            </form>
        </div>
    </div>

    <script>
    window.addEventListener('load', function() {
        setTimeout(function() {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 400);
    });

    // Format ISO date strings
    document.querySelectorAll('time[data-iso]').forEach(function(el) {
        var iso = el.getAttribute('data-iso');
        if (!iso) return;
        try {
            var d = new Date(iso);
            if (isNaN(d.getTime())) return;
            var now = new Date();
            var diff = now - d;
            var days = Math.floor(diff / 86400000);
            if (days < 1) { el.textContent = 'Today'; }
            else if (days < 2) { el.textContent = 'Yesterday'; }
            else if (days < 7) { el.textContent = days + ' days ago'; }
            else {
                el.textContent = d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
            }
            el.title = d.toLocaleString();
        } catch(e) {}
    });

    document.addEventListener("DOMContentLoaded", () => {
        // Search
        const input = document.getElementById("customerSearch");
        if (input) {
            const rows = Array.from(document.querySelectorAll(".customer-row"));
            input.addEventListener("input", () => {
                const q = input.value.toLowerCase();
                rows.forEach(row => {
                    const name = row.dataset.name || "";
                    const email = row.dataset.email || "";
                    row.style.display = (name.includes(q) || email.includes(q)) ? "" : "none";
                });
            });
        }

        // Delete Modal
        const backdrop = document.getElementById("deleteModalBackdrop");
        const modal = document.getElementById("deleteModal");
        const nameSpan = document.getElementById("deleteCustomerName");
        const emailSpan = document.getElementById("deleteCustomerEmail");
        const idSpan = document.getElementById("deleteCustomerId");
        const userIdInput = document.getElementById("deleteUserId");
        const cancelBtn = document.getElementById("cancelDeleteBtn");

        function openDeleteModal(userId, name, email) {
            nameSpan.textContent = name || "Unknown customer";
            emailSpan.textContent = email || "No email";
            idSpan.textContent = "ID: " + (userId || "\u2014");
            userIdInput.value = userId || "";

            backdrop.classList.remove("invisible");
            backdrop.style.opacity = "0";
            requestAnimationFrame(() => {
                backdrop.style.opacity = "1";
                modal.style.transform = "translateY(0)";
            });
        }

        function closeDeleteModal() {
            backdrop.style.opacity = "0";
            modal.style.transform = "translateY(16px)";
            setTimeout(() => backdrop.classList.add("invisible"), 180);
        }

        document.querySelectorAll(".open-delete-modal").forEach(btn => {
            btn.addEventListener("click", () => {
                openDeleteModal(btn.dataset.id, btn.dataset.name, btn.dataset.email);
            });
        });

        if (cancelBtn) cancelBtn.addEventListener("click", closeDeleteModal);
        backdrop.addEventListener("click", (e) => { if (e.target === backdrop) closeDeleteModal(); });
        document.addEventListener("keydown", (e) => {
            if (e.key === "Escape" && !backdrop.classList.contains("invisible")) closeDeleteModal();
        });
    });
    </script>
</body>
</html>
