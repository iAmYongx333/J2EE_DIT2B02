<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Services – SilverCare</title>

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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
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

    .primary-btn {
        transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.2s ease, background-color 0.2s ease;
    }
    .primary-btn:hover { transform: translateY(-1px); }
    .primary-btn:active { transform: translateY(0); }

    .panel {
        transition: transform 0.35s cubic-bezier(0.22, 1, 0.26, 1), opacity 0.25s ease;
    }
    .backdrop-overlay {
        background: rgba(0, 0, 0, 0.15);
        backdrop-filter: blur(4px);
        transition: opacity 0.25s ease, visibility 0.25s ease;
    }

    #addServicePanel { margin-top: 96px; height: calc(100vh - 96px); }
    textarea { resize: none; }

    .form-input {
        width: 100%; padding: 0.625rem 1rem;
        border: 1px solid #e8e4dc; background: #f5f3ef;
        font-size: 0.875rem; color: #2c2c2c;
        transition: border-color 0.15s ease;
    }
    .form-input:focus { outline: none; border-color: #2c2c2c; }
    .form-input::placeholder { color: #8a8a8a; }
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
                            Manage Services
                        </h1>
                        <p class="text-ink-light text-base max-w-xl leading-relaxed stagger-3">
                            Add, edit and remove SilverCare services. Each update is reflected on the public services page.
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
                        <button id="openAddPanelBtn"
                                class="primary-btn bg-ink text-white px-5 py-2.5 text-sm font-medium inline-flex items-center gap-2 hover:bg-ink-light">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                            </svg>
                            Add service
                        </button>
                    </div>
                </div>
            </header>

            <!-- Table Card -->
            <section class="stagger-4">
                <div class="bg-white border border-stone-mid">

                    <!-- Toolbar -->
                    <div class="px-6 py-5 border-b border-stone-mid flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                        <div>
                            <h2 class="font-serif text-lg font-medium text-ink">Service Catalogue</h2>
                            <p class="text-xs text-ink-muted mt-1">
                                <c:choose>
                                    <c:when test="${not empty serviceList}">
                                        ${fn:length(serviceList)} service<c:if test="${fn:length(serviceList) != 1}">s</c:if> available
                                    </c:when>
                                    <c:otherwise>No services found</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div>
                            <input type="text" id="serviceSearch" placeholder="Search by name..."
                                   class="w-full sm:w-56 px-4 py-2.5 border border-stone-mid text-sm bg-stone-warm text-ink placeholder:text-ink-muted focus:outline-none focus:border-ink transition-colors" />
                        </div>
                    </div>

                    <!-- Desktop Table -->
                    <div class="hidden md:block overflow-x-auto">
                        <table class="min-w-full">
                            <thead class="bg-stone-warm border-b border-stone-mid">
                                <tr class="text-xs uppercase tracking-[0.15em] text-ink-muted">
                                    <th class="text-left px-6 py-3 font-medium">Service</th>
                                    <th class="text-left px-4 py-3 font-medium">Category</th>
                                    <th class="text-right px-4 py-3 font-medium">Price</th>
                                    <th class="text-right px-4 py-3 font-medium">Duration</th>
                                    <th class="text-right px-6 py-3 font-medium">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-stone-mid text-sm">
                                <c:forEach items="${serviceList}" var="svc">
                                    <tr class="table-row-hover service-row"
                                        data-id="${svc.serviceId}"
                                        data-name="${svc.serviceName}"
                                        data-category-id="${svc.categoryId}"
                                        data-description="${fn:escapeXml(svc.description)}"
                                        data-price="${svc.price}"
                                        data-duration="${svc.durationMin}"
                                        data-image="${svc.imagePath}">
                                        <td class="px-6 py-4 align-middle">
                                            <div>
                                                <p class="font-medium text-ink text-sm">${svc.serviceName}</p>
                                                <p class="text-[11px] text-ink-muted">ID: ${svc.serviceId}</p>
                                            </div>
                                        </td>
                                        <td class="px-4 py-4 align-middle">
                                            <span class="inline-block px-3 py-1 bg-stone-warm border border-stone-mid text-xs text-ink">
                                                <c:set var="catName" value="Unknown" />
                                                <c:forEach items="${categoryList}" var="cat">
                                                    <c:if test="${cat.categoryId == svc.categoryId}">
                                                        <c:set var="catName" value="${cat.categoryName}" />
                                                    </c:if>
                                                </c:forEach>
                                                ${catName}
                                            </span>
                                        </td>
                                        <td class="px-4 py-4 text-right align-middle">
                                            <span class="text-ink text-mono">$${svc.price}</span>
                                        </td>
                                        <td class="px-4 py-4 text-right align-middle">
                                            <span class="text-ink-light text-mono">${svc.durationMin} min</span>
                                        </td>
                                        <td class="px-6 py-4 text-right align-middle">
                                            <div class="inline-flex items-center gap-2">
                                                <button type="button"
                                                        class="edit-btn text-xs px-3 py-1.5 border border-stone-mid text-ink hover:bg-stone-warm transition-colors"
                                                        data-id="${svc.serviceId}">
                                                    Edit
                                                </button>
                                                <button type="button"
                                                        class="delete-btn text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 hover:bg-red-50 transition-colors"
                                                        data-id="${svc.serviceId}">
                                                    Delete
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty serviceList}">
                                    <tr>
                                        <td colspan="5" class="px-6 py-12 text-center">
                                            <svg class="w-10 h-10 text-stone-deep mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                                            </svg>
                                            <p class="text-sm text-ink-muted">No services yet</p>
                                            <p class="text-xs text-ink-muted mt-1">Use "Add service" to create the first one</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- Mobile Cards -->
                    <div class="md:hidden divide-y divide-stone-mid" id="servicesCards">
                        <c:forEach items="${serviceList}" var="svc">
                            <div class="service-row px-5 py-4 space-y-2"
                                 data-id="${svc.serviceId}"
                                 data-name="${svc.serviceName}"
                                 data-category-id="${svc.categoryId}"
                                 data-description="${fn:escapeXml(svc.description)}"
                                 data-price="${svc.price}"
                                 data-duration="${svc.durationMin}"
                                 data-image="${svc.imagePath}">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <p class="font-medium text-sm text-ink">${svc.serviceName}</p>
                                        <p class="text-[11px] text-ink-muted">ID: ${svc.serviceId}</p>
                                    </div>
                                    <span class="inline-block px-2 py-1 bg-stone-warm border border-stone-mid text-[11px] text-ink">
                                        <c:set var="catName" value="Unknown" />
                                        <c:forEach items="${categoryList}" var="cat">
                                            <c:if test="${cat.categoryId == svc.categoryId}">
                                                <c:set var="catName" value="${cat.categoryName}" />
                                            </c:if>
                                        </c:forEach>
                                        ${catName}
                                    </span>
                                </div>
                                <div class="flex items-center justify-between text-xs text-ink-light">
                                    <span class="text-mono">$${svc.price}</span>
                                    <span class="text-mono">${svc.durationMin} min</span>
                                </div>
                                <div class="flex justify-end gap-2 pt-1">
                                    <button type="button"
                                            class="edit-btn text-[11px] px-2.5 py-1.5 border border-stone-mid text-ink hover:bg-stone-warm transition-colors"
                                            data-id="${svc.serviceId}">
                                        Edit
                                    </button>
                                    <button type="button"
                                            class="delete-btn text-[11px] px-2.5 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 transition-colors"
                                            data-id="${svc.serviceId}">
                                        Delete
                                    </button>
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty serviceList}">
                            <div class="px-5 py-12 text-center">
                                <p class="text-sm text-ink-muted">No services yet</p>
                            </div>
                        </c:if>
                    </div>

                </div>
            </section>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <!-- Add Service Panel (slide-in) -->
    <div id="addPanelBackdrop" class="backdrop-overlay fixed inset-0 z-[200] opacity-0 invisible flex justify-end">
        <div id="addServicePanel"
             class="panel w-full sm:max-w-md bg-white border-l border-stone-mid px-7 py-7 transform translate-x-full flex flex-col gap-4 overflow-y-auto">

            <div class="flex items-center justify-between mb-2">
                <h2 class="font-serif text-xl font-medium text-ink">Add New Service</h2>
                <button type="button" id="closeAddPanelBtn" class="text-ink-muted hover:text-ink transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
            <p class="text-sm text-ink-light mb-4">
                Fill in the details below to create a new service listing.
            </p>

            <form id="addServiceForm" method="post" action="${pageContext.request.contextPath}/admin/services/create">
                <div class="space-y-4">
                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Service name</label>
                        <input type="text" name="service_name" class="form-input" required />
                    </div>

                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Category</label>
                        <select name="category_id" class="form-input">
                            <c:forEach items="${categoryList}" var="cat">
                                <option value="${cat.categoryId}">${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Price (SGD)</label>
                            <input type="number" step="0.01" min="0" name="price" class="form-input" required />
                        </div>
                        <div>
                            <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Duration (min)</label>
                            <input type="number" min="0" name="duration_min" class="form-input" required />
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Image path</label>
                        <input type="text" name="image_path" class="form-input" placeholder="e.g. images/services/homecare.jpg" />
                    </div>

                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Description</label>
                        <textarea name="description" rows="4" class="form-input"></textarea>
                    </div>
                </div>

                <div class="mt-8 flex items-center justify-end gap-3">
                    <button type="button" id="cancelAddBtn"
                            class="px-4 py-2 border border-stone-mid text-sm text-ink bg-white hover:bg-stone-warm transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="primary-btn px-5 py-2 bg-ink text-white text-sm font-medium hover:bg-ink-light transition-colors">
                        Save service
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Service Modal -->
    <div id="editModalBackdrop" class="backdrop-overlay fixed inset-0 z-[210] opacity-0 invisible flex items-center justify-center">
        <div id="editModal"
             class="panel w-full max-w-lg bg-white border border-stone-mid shadow-lg px-7 py-7 transform translate-y-6"
             style="max-height: calc(100vh - 120px); overflow-y: auto;">

            <div class="flex items-center justify-between mb-2">
                <h2 class="font-serif text-xl font-medium text-ink">Edit Service</h2>
                <button type="button" id="closeEditModalBtn" class="text-ink-muted hover:text-ink transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
            <p class="text-sm text-ink-light mb-4">Update the service details below.</p>

            <form id="editServiceForm" method="post" action="${pageContext.request.contextPath}/admin/services/edit">
                <input type="hidden" name="service_id" id="edit_service_id" />

                <div class="space-y-4">
                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Service name</label>
                        <input type="text" name="service_name" id="edit_service_name" class="form-input" required />
                    </div>

                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Category</label>
                        <select name="category_id" id="edit_category_id" class="form-input">
                            <c:forEach items="${categoryList}" var="cat">
                                <option value="${cat.categoryId}">${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Price (SGD)</label>
                            <input type="number" step="0.01" min="0" name="price" id="edit_price" class="form-input" required />
                        </div>
                        <div>
                            <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Duration (min)</label>
                            <input type="number" min="0" name="duration_min" id="edit_duration" class="form-input" required />
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Image path</label>
                        <input type="text" name="image_path" id="edit_image" class="form-input" />
                    </div>

                    <div>
                        <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Description</label>
                        <textarea name="description" id="edit_description" rows="4" class="form-input"></textarea>
                    </div>
                </div>

                <div class="mt-8 flex items-center justify-end gap-3">
                    <button type="button" id="cancelEditBtn"
                            class="px-4 py-2 border border-stone-mid text-sm text-ink bg-white hover:bg-stone-warm transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="primary-btn px-5 py-2 bg-ink text-white text-sm font-medium hover:bg-ink-light transition-colors">
                        Save changes
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div id="deleteModalBackdrop" class="backdrop-overlay fixed inset-0 z-[220] opacity-0 invisible flex items-center justify-center">
        <div id="deleteModal"
             class="panel w-full max-w-sm bg-white border border-stone-mid shadow-lg px-7 py-7 transform translate-y-6">

            <h2 class="font-serif text-xl font-medium text-ink">Delete Service</h2>
            <p class="mt-3 text-sm text-ink-light leading-relaxed">
                This action cannot be undone. The service will be removed from the admin area and the public services page.
            </p>

            <form id="deleteServiceForm" method="post" action="${pageContext.request.contextPath}/admin/services/delete">
                <input type="hidden" name="service_id" id="delete_service_id" />

                <div class="mt-6 flex items-center justify-end gap-3">
                    <button type="button" id="cancelDeleteBtn"
                            class="px-4 py-2 border border-stone-mid text-sm text-ink bg-white hover:bg-stone-warm transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-4 py-2 bg-red-600 text-white text-sm font-medium hover:bg-red-700 transition-colors">
                        Delete
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
    // Loading screen
    window.addEventListener('load', function() {
        setTimeout(function() {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 400);
    });

    document.addEventListener("DOMContentLoaded", () => {
        /* ========== Search ========== */
        const searchInput = document.getElementById("serviceSearch");
        const allRows = () => Array.from(document.querySelectorAll(".service-row"));

        if (searchInput) {
            searchInput.addEventListener("input", () => {
                const q = searchInput.value.toLowerCase();
                allRows().forEach(row => {
                    const name = (row.dataset.name || "").toLowerCase();
                    row.style.display = name.includes(q) ? "" : "none";
                });
            });
        }

        /* ========== Scroll Lock ========== */
        function lockScroll() { document.body.style.overflow = "hidden"; }
        function unlockScroll() { document.body.style.overflow = ""; }

        /* ========== ADD PANEL ========== */
        const addBackdrop = document.getElementById("addPanelBackdrop");
        const addPanel = document.getElementById("addServicePanel");

        function openAddPanel() {
            addBackdrop.classList.remove("invisible");
            addBackdrop.style.opacity = "0";
            lockScroll();
            gsap.to(addBackdrop, { opacity: 1, duration: 0.25 });
            gsap.fromTo(addPanel, { x: "100%" }, { x: 0, duration: 0.35, ease: "power3.out" });
        }

        function closeAddPanel() {
            gsap.to(addPanel, {
                x: "100%", duration: 0.3, ease: "power3.inOut",
                onComplete: () => { addBackdrop.classList.add("invisible"); unlockScroll(); }
            });
            gsap.to(addBackdrop, { opacity: 0, duration: 0.25 });
        }

        document.getElementById("openAddPanelBtn")?.addEventListener("click", openAddPanel);
        document.getElementById("closeAddPanelBtn")?.addEventListener("click", closeAddPanel);
        document.getElementById("cancelAddBtn")?.addEventListener("click", closeAddPanel);
        addBackdrop.addEventListener("click", (e) => { if (e.target === addBackdrop) closeAddPanel(); });

        /* ========== EDIT MODAL ========== */
        const editBackdrop = document.getElementById("editModalBackdrop");
        const editModal = document.getElementById("editModal");
        const editId = document.getElementById("edit_service_id");
        const editName = document.getElementById("edit_service_name");
        const editCategory = document.getElementById("edit_category_id");
        const editPrice = document.getElementById("edit_price");
        const editDuration = document.getElementById("edit_duration");
        const editImage = document.getElementById("edit_image");
        const editDescription = document.getElementById("edit_description");

        function openEditModalForRow(row) {
            const d = row.dataset;
            editId.value = d.id || "";
            editName.value = d.name || "";
            editCategory.value = d.categoryId || "";
            editPrice.value = d.price || "";
            editDuration.value = d.duration || "";
            editImage.value = d.image || "";
            editDescription.value = d.description || "";

            editBackdrop.classList.remove("invisible");
            editBackdrop.style.opacity = "0";
            lockScroll();
            gsap.to(editBackdrop, { opacity: 1, duration: 0.25 });
            gsap.fromTo(editModal, { y: 24, opacity: 0 }, { y: 0, opacity: 1, duration: 0.3, ease: "power2.out" });
        }

        function closeEditModal() {
            gsap.to(editModal, {
                y: 16, opacity: 0, duration: 0.25,
                onComplete: () => { editBackdrop.classList.add("invisible"); unlockScroll(); }
            });
            gsap.to(editBackdrop, { opacity: 0, duration: 0.25 });
        }

        document.getElementById("closeEditModalBtn")?.addEventListener("click", closeEditModal);
        document.getElementById("cancelEditBtn")?.addEventListener("click", closeEditModal);
        editBackdrop.addEventListener("click", (e) => { if (e.target === editBackdrop) closeEditModal(); });

        document.addEventListener("click", (e) => {
            const editBtn = e.target.closest(".edit-btn");
            if (!editBtn) return;
            const row = editBtn.closest(".service-row");
            if (row) openEditModalForRow(row);
        });

        /* ========== DELETE MODAL ========== */
        const deleteBackdrop = document.getElementById("deleteModalBackdrop");
        const deleteModal = document.getElementById("deleteModal");
        const deleteIdInput = document.getElementById("delete_service_id");

        function openDeleteModal(id) {
            deleteIdInput.value = id;
            deleteBackdrop.classList.remove("invisible");
            deleteBackdrop.style.opacity = "0";
            lockScroll();
            gsap.to(deleteBackdrop, { opacity: 1, duration: 0.25 });
            gsap.fromTo(deleteModal, { y: 20, opacity: 0 }, { y: 0, opacity: 1, duration: 0.3 });
        }

        function closeDeleteModal() {
            gsap.to(deleteModal, {
                y: 14, opacity: 0, duration: 0.25,
                onComplete: () => { deleteBackdrop.classList.add("invisible"); unlockScroll(); }
            });
            gsap.to(deleteBackdrop, { opacity: 0, duration: 0.25 });
        }

        document.getElementById("cancelDeleteBtn")?.addEventListener("click", closeDeleteModal);
        deleteBackdrop.addEventListener("click", (e) => { if (e.target === deleteBackdrop) closeDeleteModal(); });

        document.addEventListener("click", (e) => {
            const delBtn = e.target.closest(".delete-btn");
            if (delBtn) openDeleteModal(delBtn.dataset.id);
        });

        /* Escape key closes any open modal */
        document.addEventListener("keydown", (e) => {
            if (e.key !== "Escape") return;
            if (!addBackdrop.classList.contains("invisible")) closeAddPanel();
            if (!editBackdrop.classList.contains("invisible")) closeEditModal();
            if (!deleteBackdrop.classList.contains("invisible")) closeDeleteModal();
        });
    });
    </script>
</body>
</html>
