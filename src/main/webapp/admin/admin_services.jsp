<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Manage Services | SilverCare Admin</title>
	<%
	Object userRole = session.getAttribute("sessRole");
    if(userRole == null){
    	response.sendRedirect(request.getContextPath()+"/public/login.jsp?errCode=NoSession");
    }
    else{
    	String userRoleString = session.getAttribute("sessRole").toString();
    	 if(!"admin".equals(userRole)){
    		 System.out.print(userRole);
    	    	response.sendRedirect(request.getContextPath()+"/index.jsp");
    	    	return;
    	  }
    }
    %>
    <!-- Tailwind via CDN -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- GSAP -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>

    <style>
        html, body {
            height: 100%;
        }

        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        .table-card {
            transition:
                box-shadow 0.25s ease,
                border-color 0.22s ease,
                background-color 0.22s ease,
                transform 0.2s ease;
        }
        .table-card:hover {
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.12);
            border-color: rgba(148, 163, 184, 0.7);
        }

        .primary-btn {
            transition:
                transform 0.2s cubic-bezier(0.16, 1, 0.3, 1),
                box-shadow 0.2s ease,
                background-color 0.2s ease;
        }
        .primary-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 14px 30px rgba(15, 23, 42, 0.18);
        }
        .primary-btn:active {
            transform: translateY(0);
            box-shadow: 0 6px 16px rgba(15, 23, 42, 0.24);
        }

        .pill {
            font-size: 11px;
            padding: 0.25rem 0.6rem;
            border-radius: 999px;
        }

        .text-mono {
            font-variant-numeric: tabular-nums;
        }

        .panel {
            transition:
                transform 0.35s cubic-bezier(0.22, 1, 0.26, 1),
                opacity 0.25s ease;
        }

        .backdrop {
            background: rgba(15, 23, 42, 0.25);
            transition:
                opacity 0.25s ease,
                visibility 0.25s ease;
        }

        /* Slide-in panel needs to start below fixed header (~96px high) */
        #addServicePanel {
            margin-top: 96px;
            height: calc(100vh - 96px);
        }

        /* Disable textarea resizing for nicer UX */
        textarea {
            resize: none;
        }
    </style>
</head>

<body class="bg-[#f7f4ef] text-slate-900">

    <%@ include file="../includes/header.jsp" %>

    <main id="servicesRoot" class="mt-12 min-h-screen pt-24 pb-16 px-6 sm:px-10 lg:px-16">
        <div class="max-w-6xl xl:max-w-7xl mx-auto space-y-10">

            <!-- HEADER -->
            <section id="servicesHeader" class="flex flex-col md:flex-row md:items-end md:justify-between gap-6">
                <div class="space-y-2">
                    <h1 class="text-3xl sm:text-4xl font-semibold tracking-tight">
                        Manage Services
                    </h1>
                    <p class="max-w-xl text-sm sm:text-base text-slate-700">
                        Add, edit and remove SilverCare services. Each update is reflected on the public services page.
                    </p>
                </div>

                <div class="flex items-center gap-3">
                    <a href="${pageContext.request.contextPath}/admin/dashboard"
                       class="text-xs sm:text-sm text-slate-600 hover:text-slate-800 underline">
                        ← Back to dashboard
                    </a>
                    <button id="openAddPanelBtn"
                            class="primary-btn bg-slate-900 text-white rounded-xl px-4 py-2.5 text-xs sm:text-sm font-medium flex items-center gap-2">
                        <span class="inline-block text-lg leading-none">＋</span>
                        <span>Add service</span>
                    </button>
                </div>
            </section>

            <!-- TABLE WRAPPER -->
            <section id="servicesTableSection"
                     class="table-card bg-white/90 border border-slate-200 rounded-2xl shadow-sm overflow-hidden">

                <!-- Toolbar -->
                <div class="px-4 sm:px-6 py-4 border-b border-slate-200 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                    <div>
                        <p class="text-xs uppercase tracking-wide text-slate-500 font-medium">Services</p>
                        <p class="text-xs text-slate-500 mt-1">
                            <c:choose>
                                <c:when test="${not empty serviceList}">
                                    <c:out value="${fn:length(serviceList)}" /> services loaded.
                                </c:when>
                                <c:otherwise>No services found.</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <div class="flex items-center gap-2">
                        <input type="text"
                               id="serviceSearch"
                               placeholder="Search by name..."
                               class="w-full sm:w-56 px-3 py-2 rounded-lg border border-slate-200 text-xs sm:text-sm bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50 focus:border-slate-400" />
                    </div>
                </div>

                <!-- TABLE (desktop) -->
                <div class="hidden md:block overflow-x-auto">
                    <table class="min-w-full text-sm">
                        <thead class="bg-[#f9f7f3] border-b border-slate-200 text-xs uppercase tracking-wide text-slate-500">
                            <tr>
                                <th class="text-left px-6 py-3">Service</th>
                                <th class="text-left px-4 py-3">Category</th>
                                <th class="text-right px-4 py-3">Price</th>
                                <th class="text-right px-4 py-3">Duration</th>
                                <th class="text-right px-6 py-3">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="servicesTableBody" class="divide-y divide-slate-100 text-xs sm:text-sm">
                            <c:forEach items="${serviceList}" var="svc">
<tr class="service-row hover:bg-[#faf7f2]"
    data-id="${svc.serviceId}"
    data-name="${svc.serviceName}"
    data-category-id="${svc.categoryId}"
    data-description="${fn:escapeXml(svc.description)}"
    data-price="${svc.price}"
    data-duration="${svc.durationMin}"
    data-image="${svc.imagePath}">
                                    <!-- Service info -->
                                    <td class="px-6 py-3 align-middle">
                                        <div class="flex flex-col">
                                            <span class="font-medium text-slate-900">${svc.serviceName}</span>
                                            <span class="text-[11px] text-slate-500">ID: ${svc.serviceId}</span>
                                        </div>
                                    </td>

                                    <!-- Category -->
                                    <td class="px-4 py-3 align-middle">
                                        <span class="pill bg-slate-100 text-slate-700">
                                            <c:set var="catName" value="Unknown" />
                                            <c:forEach items="${categoryList}" var="cat">
                                                <c:if test="${cat.categoryId == svc.categoryId}">
                                                    <c:set var="catName" value="${cat.categoryName}" />
                                                </c:if>
                                            </c:forEach>
                                            ${catName}
                                        </span>
                                    </td>

                                    <!-- Price -->
                                    <td class="px-4 py-3 text-right align-middle text-mono">
                                        $${svc.price}
                                    </td>

                                    <!-- Duration -->
                                    <td class="px-4 py-3 text-right align-middle text-mono">
                                        ${svc.durationMin} min
                                    </td>

                                    <!-- Actions -->
                                    <td class="px-6 py-3 text-right align-middle">
                                        <div class="inline-flex items-center gap-2">
                                            <button type="button"
                                                    class="edit-btn text-xs px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50"
                                                    data-id="${svc.serviceId}">
                                                Edit
                                            </button>
                                            <button type="button"
                                                    class="delete-btn text-xs px-2.5 py-1.5 rounded-lg border border-red-200 text-red-600 bg-white hover:bg-red-50"
                                                    data-id="${svc.serviceId}">
                                                Delete
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty serviceList}">
                                <tr>
                                    <td colspan="5" class="px-6 py-6 text-center text-sm text-slate-500">
                                        No services yet. Use “Add service” to create the first one.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- CARDS (mobile) -->
                <div class="md:hidden divide-y divide-slate-100" id="servicesCards">
                    <c:forEach items="${serviceList}" var="svc">
<div class="service-row px-4 py-4 space-y-2"
     data-id="${svc.serviceId}"
     data-name="${svc.serviceName}"
     data-category-id="${svc.categoryId}"
     data-description="${fn:escapeXml(svc.description)}"
     data-price="${svc.price}"
     data-duration="${svc.durationMin}"
     data-image="${svc.imagePath}">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="font-medium text-sm">${svc.serviceName}</p>
                                    <p class="text-[11px] text-slate-500">ID: ${svc.serviceId}</p>
                                </div>
                                <span class="pill bg-slate-100 text-slate-700">
                                    <c:set var="catName" value="Unknown" />
                                    <c:forEach items="${categoryList}" var="cat">
                                        <c:if test="${cat.categoryId == svc.categoryId}">
                                            <c:set var="catName" value="${cat.categoryName}" />
                                        </c:if>
                                    </c:forEach>
                                    ${catName}
                                </span>
                            </div>
                            <div class="flex items-center justify-between text-xs text-slate-600">
                                <span>$${svc.price}</span>
                                <span>${svc.durationMin} min</span>
                            </div>
                            <div class="flex justify-end gap-2 pt-1">
                                <button type="button"
                                        class="edit-btn text-[11px] px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white"
                                        data-id="${svc.serviceId}">
                                    Edit
                                </button>
                                <button type="button"
                                        class="delete-btn text-[11px] px-2.5 py-1.5 rounded-lg border border-red-200 text-red-600 bg-white"
                                        data-id="${svc.serviceId}">
                                    Delete
                                </button>
                            </div>
                        </div>
                    </c:forEach>

                    <c:if test="${empty serviceList}">
                        <div class="px-4 py-5 text-center text-sm text-slate-500">
                            No services yet. Use “Add service” to create the first one.
                        </div>
                    </c:if>
                </div>
            </section>
        </div>
    </main>

    <!-- ADD SERVICE PANEL (slide-in) -->
    <div id="addPanelBackdrop"
         class="backdrop fixed inset-0 z-[200] opacity-0 invisible flex justify-end">
        <div id="addServicePanel"
             class="panel w-full sm:max-w-md bg-white shadow-2xl border-l border-slate-200 px-6 py-6 sm:px-7 sm:py-7 transform translate-x-full flex flex-col gap-4 overflow-y-auto">
            <div class="flex items-center justify-between mb-2">
                <h2 class="text-lg font-semibold">Add new service</h2>
                <button type="button" id="closeAddPanelBtn" class="text-slate-500 hover:text-slate-800 text-sm">
                    ✕
                </button>
            </div>
            <p class="text-xs text-slate-600 mb-2">
                Fill in the details below to create a new service. Point this form to your create-service servlet.
            </p>

            <form id="addServiceForm"
      method="post"
      action="${pageContext.request.contextPath}/admin/services/create">
    <div class="space-y-3 text-xs sm:text-sm">
        <div>
            <label class="block mb-1 text-slate-700">Service name</label>
            <input type="text" name="service_name"
                   class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50" />
        </div>

        <div>
            <label class="block mb-1 text-slate-700">Category</label>
            <select name="category_id"
                    class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50">
                <c:forEach items="${categoryList}" var="cat">
                    <option value="${cat.categoryId}">${cat.categoryName}</option>
                </c:forEach>
            </select>
        </div>

        <div class="grid grid-cols-2 gap-3">
            <div>
                <label class="block mb-1 text-slate-700">Price (SGD)</label>
                <input type="number" step="0.01" min="0" name="price"
                       class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50" />
            </div>
            <div>
                <label class="block mb-1 text-slate-700">Duration (min)</label>
                <input type="number" min="0" name="duration_min"
                       class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50" />
            </div>
        </div>

        <div>
            <label class="block mb-1 text-slate-700">Image path</label>
            <input type="text" name="image_path"
                   class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50"
                   placeholder="e.g. images/services/homecare.jpg" />
        </div>

        <div>
            <label class="block mb-1 text-slate-700">Description</label>
            <textarea name="description" rows="3"
                      class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50 resize-none"></textarea>
        </div>
    </div>

    <div class="mt-6 flex items-center justify-end gap-3 text-xs sm:text-sm">
        <button type="button"
                id="cancelAddBtn"
                class="px-3 py-2 rounded-lg border border-slate-200 text-slate-700 bg-white hover:bg-slate-50">
            Cancel
        </button>
        <button type="submit"
                class="primary-btn px-4 py-2 rounded-lg bg-slate-900 text-white font-medium">
            Save service
        </button>
    </div>
</form>
        </div>
    </div>

    <!-- EDIT SERVICE MODAL -->
    <div id="editModalBackdrop"
         class="backdrop fixed inset-0 z-[210] opacity-0 invisible flex items-center justify-center">
        <div id="editModal"
             class="panel w-full max-w-lg bg-white rounded-2xl shadow-2xl border border-slate-200 px-6 py-6 sm:px-7 sm:py-7 transform translate-y-6"
             style="max-height: calc(100vh - 120px); overflow-y: auto;">
            <div class="flex items-center justify-between mb-2">
                <h2 class="text-lg font-semibold">Edit service</h2>
                <button type="button" id="closeEditModalBtn"
                        class="text-slate-500 hover:text-slate-800 text-sm">
                    ✕
                </button>
            </div>
            <p class="text-xs text-slate-600 mb-3">
                Update the details below. Point this form to your update-service servlet.
            </p>

            <form id="editServiceForm"
                  method="post"
                  action="${pageContext.request.contextPath}/admin/services/edit">
                <input type="hidden" name="service_id" id="edit_service_id" />

                <div class="space-y-3 text-xs sm:text-sm">
                    <div>
                        <label class="block mb-1 text-slate-700">Service name</label>
                        <input type="text" name="service_name" id="edit_service_name"
                               class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50" />
                    </div>

                    <div>
                        <label class="block mb-1 text-slate-700">Category</label>
                        <select name="category_id" id="edit_category_id"
                                class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50">
                            <c:forEach items="${categoryList}" var="cat">
                                <option value="${cat.categoryId}">${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="grid grid-cols-2 gap-3">
                        <div>
                            <label class="block mb-1 text-slate-700">Price (SGD)</label>
                            <input type="number" step="0.01" min="0" name="price" id="edit_price"
                                   class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50" />
                        </div>
                        <div>
                            <label class="block mb-1 text-slate-700">Duration (min)</label>
                            <input type="number" min="0" name="duration_min" id="edit_duration"
                                   class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50" />
                        </div>
                    </div>

                    <div>
                        <label class="block mb-1 text-slate-700">Image path</label>
                        <input type="text" name="image_path" id="edit_image"
                               class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50" />
                    </div>

                    <div>
                        <label class="block mb-1 text-slate-700">Description</label>
                        <textarea name="description" id="edit_description" rows="3"
                                  class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50 resize-none"></textarea>
                    </div>
                </div>

                <div class="mt-6 flex items-center justify-end gap-3 text-xs sm:text-sm">
                    <button type="button"
                            id="cancelEditBtn"
                            class="px-3 py-2 rounded-lg border border-slate-200 text-slate-700 bg-white hover:bg-slate-50">
                        Cancel
                    </button>
                    <button type="submit"
                            class="primary-btn px-4 py-2 rounded-lg bg-slate-900 text-white font-medium">
                        Save changes
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- DELETE CONFIRMATION MODAL -->
    <div id="deleteModalBackdrop"
         class="backdrop fixed inset-0 z-[210] opacity-0 invisible flex items-center justify-center">
        <div id="deleteModal"
             class="panel w-full max-w-sm bg-white rounded-2xl shadow-2xl border border-slate-200 px-6 py-6 sm:px-7 sm:py-7 transform translate-y-6"
             style="max-height: calc(100vh - 120px); overflow-y: auto;">
            <h2 class="text-lg font-semibold mb-2">Delete service</h2>
            <p class="text-xs text-slate-600 mb-4">
                This action cannot be undone. The service will be removed from the admin area and public services page.
            </p>

            <form id="deleteServiceForm"
                  method="post"
                  action="${pageContext.request.contextPath}/admin/services/delete">
                <input type="hidden" name="service_id" id="delete_service_id" />

                <div class="flex items-center justify-end gap-3 text-xs sm:text-sm">
                    <button type="button"
                            id="cancelDeleteBtn"
                            class="px-3 py-2 rounded-lg border border-slate-200 text-slate-700 bg-white hover:bg-slate-50">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-4 py-2 rounded-lg bg-red-600 text-white font-medium hover:bg-red-700">
                        Delete
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
    document.addEventListener("DOMContentLoaded", () => {
        /* GSAP Entrance */
        const tl = gsap.timeline({ defaults: { duration: 0.55, ease: "power2.out" } });
        tl.from("#servicesHeader", { y: 20, opacity: 0 })
          .from("#servicesTableSection", { y: 22, opacity: 0 }, "-=0.25");

        /* Search (table + cards) */
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

        /* Utility: lock / unlock body scroll when overlays open */
        function lockScroll() { document.body.style.overflow = "hidden"; }
        function unlockScroll() { document.body.style.overflow = ""; }

        /* ======================
           ADD SERVICE PANEL
           ====================== */
        const addBackdrop = document.getElementById("addPanelBackdrop");
        const addPanel = document.getElementById("addServicePanel");
        const openAddBtn = document.getElementById("openAddPanelBtn");
        const closeAddBtn = document.getElementById("closeAddPanelBtn");
        const cancelAddBtn = document.getElementById("cancelAddBtn");

        function openAddPanel() {
            addBackdrop.classList.remove("invisible");
            addBackdrop.style.opacity = "0";
            lockScroll();

            gsap.to(addBackdrop, { opacity: 1, duration: 0.25 });
            gsap.fromTo(addPanel,
                { x: "100%" },
                { x: 0, duration: 0.35, ease: "power3.out" }
            );
        }

        function closeAddPanel() {
            gsap.to(addPanel, {
                x: "100%",
                duration: 0.3,
                ease: "power3.inOut",
                onComplete: () => {
                    addBackdrop.classList.add("invisible");
                    unlockScroll();
                }
            });
            gsap.to(addBackdrop, { opacity: 0, duration: 0.25 });
        }

        if (openAddBtn) openAddBtn.addEventListener("click", openAddPanel);
        if (closeAddBtn) closeAddBtn.addEventListener("click", closeAddPanel);
        if (cancelAddBtn) cancelAddBtn.addEventListener("click", closeAddPanel);
        addBackdrop.addEventListener("click", (e) => {
            if (e.target === addBackdrop) closeAddPanel();
        });

        /* ======================
           EDIT MODAL
           ====================== */
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
            editCategory.value = d.categoryId || "";   // from data-category-id
            editPrice.value = d.price || "";
            editDuration.value = d.duration || "";     // from data-duration
            editImage.value = d.image || "";
            editDescription.value = d.description || "";

            editBackdrop.classList.remove("invisible");
            editBackdrop.style.opacity = "0";
            lockScroll();

            gsap.to(editBackdrop, { opacity: 1, duration: 0.25 });
            gsap.fromTo(
                editModal,
                { y: 24, opacity: 0 },
                { y: 0, opacity: 1, duration: 0.3, ease: "power2.out" }
            );
        }

        function closeEditModal() {
            gsap.to(editModal, {
                y: 16,
                opacity: 0,
                duration: 0.25,
                onComplete: () => {
                    editBackdrop.classList.add("invisible");
                    unlockScroll();
                }
            });
            gsap.to(editBackdrop, { opacity: 0, duration: 0.25 });
        }

        document.getElementById("closeEditModalBtn")?.addEventListener("click", closeEditModal);
        document.getElementById("cancelEditBtn")?.addEventListener("click", closeEditModal);
        editBackdrop.addEventListener("click", (e) => {
            if (e.target === editBackdrop) closeEditModal();
        });

        // Event delegation: works for table + mobile cards
// Event delegation: works for table + mobile cards
document.addEventListener("click", (e) => {
    const editBtn = e.target.closest(".edit-btn");
    if (!editBtn) return;

    // Directly climb up to the parent service-row instead of re-querying by data-id
    const row = editBtn.closest(".service-row");

    if (!row) {
        console.error("No .service-row ancestor found for edit button:", editBtn);
        return;
    }

    openEditModalForRow(row);
});

        /* ======================
           DELETE MODAL
           ====================== */
        const deleteBackdrop = document.getElementById("deleteModalBackdrop");
        const deleteModal = document.getElementById("deleteModal");
        const deleteIdInput = document.getElementById("delete_service_id");
        const cancelDeleteBtn = document.getElementById("cancelDeleteBtn");

        function openDeleteModal(id) {
            deleteIdInput.value = id;
            deleteBackdrop.classList.remove("invisible");
            deleteBackdrop.style.opacity = "0";
            lockScroll();

            gsap.to(deleteBackdrop, { opacity: 1, duration: 0.25 });
            gsap.fromTo(deleteModal,
                { y: 20, opacity: 0 },
                { y: 0, opacity: 1, duration: 0.3 }
            );
        }

        function closeDeleteModal() {
            gsap.to(deleteModal, {
                y: 14,
                opacity: 0,
                duration: 0.25,
                onComplete: () => {
                    deleteBackdrop.classList.add("invisible");
                    unlockScroll();
                }
            });
            gsap.to(deleteBackdrop, { opacity: 0, duration: 0.25 });
        }

        cancelDeleteBtn?.addEventListener("click", closeDeleteModal);
        deleteBackdrop.addEventListener("click", (e) => {
            if (e.target === deleteBackdrop) closeDeleteModal();
        });

        document.addEventListener("click", (e) => {
            const delBtn = e.target.closest(".delete-btn");
            if (delBtn) {
                const id = delBtn.dataset.id;
                openDeleteModal(id);
            }
        });
    });
    </script>

</body>
</html>