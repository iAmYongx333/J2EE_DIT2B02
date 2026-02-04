<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Manage Customers | SilverCare Admin</title>

    <%
        Object userRole = session.getAttribute("sessRole");
        if (userRole == null) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
            return;
        } else {
            String userRoleString = userRole.toString();
            if (!"admin".equals(userRoleString)) {
                response.sendRedirect(request.getContextPath() + "/index.jsp");
                return;
            }
        }
    %>

    <!-- Tailwind via CDN -->
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        html, body { height: 100%; }
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

        .pill {
            font-size: 11px;
            padding: 0.25rem 0.6rem;
            border-radius: 999px;
        }

        .text-mono {
            font-variant-numeric: tabular-nums;
        }
    </style>
</head>

<body class="bg-[#f7f4ef] text-slate-900">
    <%@ include file="../includes/header.jsp" %>

    <main class="mt-12 min-h-screen pt-24 pb-16 px-6 sm:px-10 lg:px-16">
        <div class="max-w-6xl xl:max-w-7xl mx-auto space-y-10">

            <!-- HEADER -->
            <section class="flex flex-col md:flex-row md:items-end md:justify-between gap-6">
                <div class="space-y-2">
                    <h1 class="text-3xl sm:text-4xl font-semibold tracking-tight">
                        Manage Customers
                    </h1>
                    <p class="max-w-xl text-sm sm:text-base text-slate-700">
                        View registered customers, check their contact details, and remove accounts if needed.
                    </p>
                </div>

                <div class="flex items-center gap-3">
                    <a href="${pageContext.request.contextPath}/admin/dashboard"
                       class="text-xs sm:text-sm text-slate-600 hover:text-slate-800 underline">
                        ← Back to dashboard
                    </a>
                </div>
            </section>

            <!-- TABLE WRAPPER -->
            <section class="table-card bg-white/90 border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
                <!-- Toolbar -->
                <div class="px-4 sm:px-6 py-4 border-b border-slate-200 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                    <div>
                        <p class="text-xs uppercase tracking-wide text-slate-500 font-medium">Customers</p>
                        <p class="text-xs text-slate-500 mt-1">
                            <c:choose>
                                <c:when test="${not empty customers}">
                                    <c:out value="${fn:length(customers)}" /> customers loaded.
                                </c:when>
                                <c:otherwise>No customers found.</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <div class="flex items-center gap-2">
                        <input type="text"
                               id="customerSearch"
                               placeholder="Search by name or email..."
                               class="w-full sm:w-64 px-3 py-2 rounded-lg border border-slate-200 text-xs sm:text-sm bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50 focus:border-slate-400" />
                    </div>
                </div>

                <!-- TABLE (desktop) -->
                <div class="hidden md:block overflow-x-auto">
                    <table class="min-w-full table-fixed text-sm">
					    <thead class="bg-[#f9f7f3] border-b border-slate-200 text-xs uppercase tracking-wide text-slate-500">
					        <tr>
					            <!-- CUSTOMER -->
					            <th class="w-[26%] px-6 py-3 text-left">
					                CUSTOMER
					            </th>
					
					            <!-- EMAIL -->
					            <th class="w-[26%] px-6 py-3 text-left">
					                EMAIL
					            </th>
					
					            <!-- PHONE -->
					            <th class="w-[14%] px-6 py-3 text-left">
					                PHONE
					            </th>
					
					            <!-- COUNTRY -->
					            <th class="w-[14%] px-6 py-3 text-left">
					                COUNTRY
					            </th>
					
					            <!-- JOINED -->
					            <th class="w-[14%] px-6 py-3 text-left">
					                JOINED
					            </th>
					
					            <!-- ACTIONS -->
					            <th class="w-[6%] px-6 py-3 text-right">
					                ACTIONS
					            </th>
					        </tr>
					    </thead>
					
					    <tbody class="divide-y divide-slate-100 text-xs sm:text-sm">
					        <c:forEach var="cust" items="${customers}">
					            <tr class="hover:bg-[#faf7f2]">
					                <!-- CUSTOMER -->
					                <td class="w-[26%] px-6 py-4 align-middle text-left">
					                    <div class="flex flex-col">
					                        <span class="font-medium text-slate-900">${cust.name}</span>
					                        <span class="text-[11px] text-slate-500 break-all">
					                            ID: ${cust.user_id}
					                        </span>
					                    </div>
					                </td>
					
					                <!-- EMAIL -->
					                <td class="w-[26%] px-6 py-4 align-middle text-left">
					                    <span class="text-slate-800 break-all">${cust.email}</span>
					                </td>
					
					                <!-- PHONE -->
					                <td class="w-[14%] px-6 py-4 align-middle text-left">
					                    <span class="text-slate-800">${cust.phone}</span>
					                </td>
					
					                <!-- COUNTRY -->
					                <td class="w-[14%] px-6 py-4 align-middle text-left">
					                    <c:choose>
					                        <c:when test="${not empty cust.countryName}">
					                            <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-slate-50 border border-slate-200">
					                                <c:if test="${not empty cust.flagImage}">
					                                    <img src="${pageContext.request.contextPath}/images/flags/${cust.flagImage}"
					                                         alt="${cust.countryName}"
					                                         class="w-5 h-5 rounded-full object-cover" />
					                                </c:if>
					                                <span class="text-xs text-slate-700">${cust.countryName}</span>
					                            </div>
					                        </c:when>
					                        <c:otherwise>
					                            <span class="text-xs text-slate-400">Unknown</span>
					                        </c:otherwise>
					                    </c:choose>
					                </td>
					
					                <!-- JOINED -->
					                <td class="w-[14%] px-6 py-4 align-middle text-left">
					                    <span class="text-xs sm:text-sm text-slate-800">
					                        <fmt:formatDate value="${cust.created_at}" pattern="dd MMM yyyy, HH:mm" />
					                    </span>
					                </td>
					
					                <!-- ACTIONS -->
					                <td class="w-[6%] px-6 py-4 align-middle text-right">
					                    <button type="button"
					                            class="open-delete-modal text-xs px-3 py-1.5 rounded-full border border-red-200 text-red-600 bg-white hover:bg-red-50"
					                            data-id="${cust.user_id}"
					                            data-name="${cust.name}"
					                            data-email="${cust.email}">
					                        Delete
					                    </button>
					                </td>
					            </tr>
					        </c:forEach>
					    </tbody>
					</table>
                </div>

                <!-- CARDS (mobile) -->
                <div class="md:hidden divide-y divide-slate-100" id="customersCards">
                    <c:forEach items="${customers}" var="cust">
                        <div class="customer-row px-4 py-4 space-y-2"
                             data-name="${fn:toLowerCase(cust.name)}"
                             data-email="${fn:toLowerCase(cust.email)}">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="font-medium text-sm">${cust.name}</p>
                                    <p class="text-[11px] text-slate-500 break-all">${cust.email}</p>
                                </div>
                                <span class="pill bg-slate-100 text-slate-700 text-mono">
                                   <c:choose>
								    <c:when test="${not empty cust.countryName}">
								      <c:if test="${not empty cust.flagImage}">
								        <img src="${pageContext.request.contextPath}/images/flags/${cust.flagImage}"
								             alt="${cust.countryName}"
								             class="w-4 h-4 rounded-full object-cover" />
								      </c:if>
								      <span>${cust.countryName}</span>
								    </c:when>
								    <c:otherwise>
								      <span class="text-slate-400">Country unknown</span>
								    </c:otherwise>
								  </c:choose>
                                </span>
                            </div>
                            <div class="flex items-center justify-between text-xs text-slate-600">
                                <span>${cust.phone}</span>
                                <span class="text-mono">${cust.created_at}</span>
                            </div>
							<div class="flex justify-end pt-2">
							    <button type="button"
							            class="open-delete-modal text-[11px] px-2.5 py-1.5 rounded-lg border border-red-200 text-red-600 bg-white hover:bg-red-50"
							            data-id="${cust.user_id}"
							            data-name="${cust.name}"
							            data-email="${cust.email}">
							        Delete
							    </button>
							</div>
						</div>
                    </c:forEach>

                    <c:if test="${empty customers}">
                        <div class="px-4 py-5 text-center text-sm text-slate-500">
                            No customers yet. New accounts will appear here after registration.
                        </div>
                    </c:if>
                </div>
            </section>
        </div>
    </main>
    
    <!-- DELETE CUSTOMER MODAL -->
	<div id="deleteModalBackdrop"
	     class="fixed inset-0 z-[220] bg-black/30 backdrop-blur-sm
	            flex items-center justify-center
	            opacity-0 invisible transition-opacity duration-200">
	  <div id="deleteModal"
	       class="w-full max-w-md mx-4 rounded-2xl bg-[#fdfaf5]
	              border border-[#ecd9d6]
	              shadow-[0_18px_50px_rgba(15,23,42,0.30)]
	              px-6 py-6 sm:px-7 sm:py-7
	              transform translate-y-4
	              transition-all duration-250 ease-out">
	
	    <h2 class="text-lg font-semibold text-[#1e2a38] tracking-tight">
	      Delete customer
	    </h2>
	    <p class="mt-2 text-[13px] text-slate-600">
	      This action will permanently remove this customer account from SilverCare.
	      Bookings tied to this account may also be affected depending on how your
	      database is configured. This cannot be undone.
	    </p>
	
	    <!-- Customer summary -->
	    <div class="mt-4 rounded-xl border border-[#e5d5d2] bg-white px-4 py-3">
	      <p class="text-[13px] font-medium text-[#1e2a38]" id="deleteCustomerName">
	        Customer name
	      </p>
	      <p class="text-[12px] text-slate-600 mt-1 break-all" id="deleteCustomerEmail">
	        customer@example.com
	      </p>
	      <p class="text-[11px] text-slate-500 mt-1" id="deleteCustomerId">
	        ID: —
	      </p>
	    </div>
	
	    <!-- Form that actually deletes -->
	    <form id="deleteCustomerForm"
	          method="post"
	          action="${pageContext.request.contextPath}/admin/customers/delete"
	          class="mt-6 flex items-center justify-end gap-3 text-xs sm:text-sm">
	      <input type="hidden" name="user_id" id="deleteUserId" />
	
	      <button type="button"
	              id="cancelDeleteBtn"
	              class="px-3 py-2 rounded-full border border-slate-200
	                     text-slate-700 bg-white hover:bg-slate-50
	                     transition-colors duration-150">
	        Cancel
	      </button>
	
	      <button type="submit"
	              class="px-4 py-2 rounded-full bg-red-600 text-white font-medium
	                     shadow-[0_12px_30px_rgba(220,38,38,0.45)]
	                     hover:bg-red-700 active:scale-[0.98]
	                     transition-all duration-170">
	        Delete customer
	      </button>
	    </form>
	  </div>
	</div>

    <%@ include file="../includes/footer.jsp" %>

    <script>
        // Simple client-side search by name/email
        document.addEventListener("DOMContentLoaded", () => {
            const input = document.getElementById("customerSearch");
            if (!input) return;

            const rows = Array.from(document.querySelectorAll(".customer-row"));

            input.addEventListener("input", () => {
                const q = input.value.toLowerCase();
                rows.forEach(row => {
                    const name = row.dataset.name || "";
                    const email = row.dataset.email || "";
                    const visible = name.includes(q) || email.includes(q);
                    row.style.display = visible ? "" : "none";
                });
            });
        });
        document.addEventListener("DOMContentLoaded", () => {
        	  const backdrop   = document.getElementById("deleteModalBackdrop");
        	  const modal      = document.getElementById("deleteModal");
        	  const nameSpan   = document.getElementById("deleteCustomerName");
        	  const emailSpan  = document.getElementById("deleteCustomerEmail");
        	  const idSpan     = document.getElementById("deleteCustomerId");
        	  const userIdInput = document.getElementById("deleteUserId");
        	  const cancelBtn  = document.getElementById("cancelDeleteBtn");

        	  function openDeleteModal(userId, name, email) {
        	    nameSpan.textContent  = name || "Unknown customer";
        	    emailSpan.textContent = email || "No email";
        	    idSpan.textContent    = "ID: " + (userId || "—");
        	    userIdInput.value     = userId || "";

        	    backdrop.classList.remove("invisible");
        	    backdrop.style.opacity = "0";

        	    // Small delay lets the browser apply initial styles before animating
        	    requestAnimationFrame(() => {
        	      backdrop.style.opacity = "1";
        	      modal.style.transform = "translateY(0)";
        	    });
        	  }

        	  function closeDeleteModal() {
        	    backdrop.style.opacity = "0";
        	    modal.style.transform  = "translateY(16px)";
        	    setTimeout(() => {
        	      backdrop.classList.add("invisible");
        	    }, 180);
        	  }

        	  // Hook up all delete buttons
        	  document.querySelectorAll(".open-delete-modal").forEach(btn => {
        	    btn.addEventListener("click", () => {
        	      const id    = btn.dataset.id;
        	      const name  = btn.dataset.name;
        	      const email = btn.dataset.email;
        	      openDeleteModal(id, name, email);
        	    });
        	  });

        	  // Cancel button
        	  if (cancelBtn) {
        	    cancelBtn.addEventListener("click", closeDeleteModal);
        	  }

        	  // Click outside the modal closes it
        	  backdrop.addEventListener("click", (e) => {
        	    if (e.target === backdrop) {
        	      closeDeleteModal();
        	    }
        	  });

        	  // Escape key closes it
        	  document.addEventListener("keydown", (e) => {
        	    if (e.key === "Escape" && !backdrop.classList.contains("invisible")) {
        	      closeDeleteModal();
        	    }
        	  });
        	});
    </script>
</body>
</html>