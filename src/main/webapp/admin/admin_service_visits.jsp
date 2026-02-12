<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Service Visits – SilverCare</title>

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
                    forest: { DEFAULT: '#3d4f3d' },
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

    .data-table { width: 100%; border-collapse: collapse; }
    .data-table th {
        background-color: #e8e4dc; padding: 12px; text-align: left;
        font-weight: 500; border-bottom: 2px solid #2c2c2c;
        font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em;
    }
    .data-table td { padding: 16px 12px; border-bottom: 1px solid #e8e4dc; }
    .data-table tbody tr { transition: background-color 0.15s ease; }
    .data-table tbody tr:hover { background-color: #f5f3ef; }

    .status-badge {
        display: inline-block; padding: 4px 12px;
        font-size: 0.75rem; border-radius: 2px; font-weight: 500;
    }
    .status-scheduled { background: #e0e7ff; color: #3730a3; }
    .status-en_route { background: #fef3c7; color: #92400e; }
    .status-checked_in { background: #d1fae5; color: #065f46; }
    .status-in_progress { background: #dbeafe; color: #1e40af; }
    .status-checked_out { background: #e0e7ff; color: #4338ca; }
    .status-completed { background: #d1ecf1; color: #0c5460; }
    .status-cancelled { background: #f8d7da; color: #721c24; }

    .modal-overlay {
        position: fixed; inset: 0; z-index: 200;
        background: rgba(0,0,0,0.4); display: none;
        align-items: center; justify-content: center;
    }
    .modal-overlay.show { display: flex; }
    .modal-box {
        background: white; border: 1px solid #e8e4dc;
        width: 100%; max-width: 560px; max-height: 90vh; overflow-y: auto;
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
                <span class="text-copper text-xs uppercase tracking-[0.2em]">Administration</span>
                <h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-3 mb-4">
                    Service Visits
                </h1>
                <p class="text-ink-light text-base md:text-lg max-w-2xl">
                    Create, manage and monitor caregiver service visits for customer bookings.
                </p>
                <div class="flex items-center gap-4 mt-5">
                    <a href="${pageContext.request.contextPath}/admin"
                       class="text-xs text-ink-muted hover:text-copper transition-colors inline-flex items-center gap-1">
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                        </svg>
                        Back to Dashboard
                    </a>
                    <button onclick="openCreateModal()"
                            class="px-5 py-2 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                        + New Visit
                    </button>
                </div>
            </header>

            <!-- Success/Error Messages -->
            <%
                String successMsg = (String) session.getAttribute("successMsg");
                String errorMsg = (String) session.getAttribute("errorMsg");
                if (successMsg != null) { session.removeAttribute("successMsg"); %>
                <div class="bg-green-50 border border-green-200 text-green-800 px-5 py-3 text-sm mb-6"><%= successMsg %></div>
            <% } if (errorMsg != null) { session.removeAttribute("errorMsg"); %>
                <div class="bg-red-50 border border-red-200 text-red-800 px-5 py-3 text-sm mb-6"><%= errorMsg %></div>
            <% } %>

            <!-- Stats Cards -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Total Visits</p>
                    <p class="font-serif text-3xl font-medium text-ink">
                        <c:choose>
                            <c:when test="${not empty visits}">${fn:length(visits)}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Scheduled</p>
                    <p class="font-serif text-3xl font-medium" style="color:#3730a3;">
                        <c:set var="scheduledCount" value="0"/>
                        <c:forEach var="v" items="${visits}">
                            <c:if test="${v.status == 'SCHEDULED'}">
                                <c:set var="scheduledCount" value="${scheduledCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${scheduledCount}
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Active</p>
                    <p class="font-serif text-3xl font-medium text-forest">
                        <c:set var="activeCount" value="0"/>
                        <c:forEach var="v" items="${visits}">
                            <c:if test="${v.status == 'EN_ROUTE' || v.status == 'CHECKED_IN' || v.status == 'IN_PROGRESS'}">
                                <c:set var="activeCount" value="${activeCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${activeCount}
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Completed</p>
                    <p class="font-serif text-3xl font-medium" style="color:#0c5460;">
                        <c:set var="completedCount" value="0"/>
                        <c:forEach var="v" items="${visits}">
                            <c:if test="${v.status == 'COMPLETED'}">
                                <c:set var="completedCount" value="${completedCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${completedCount}
                    </p>
                </div>
            </div>

            <!-- Visits Table -->
            <section class="bg-white border border-stone-mid">
                <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                    <h2 class="font-serif text-xl font-medium text-ink">All Service Visits</h2>
                    <div class="flex items-center gap-3">
                        <select id="statusFilter" onchange="filterByStatus()"
                                class="text-sm border border-stone-mid px-3 py-1.5 bg-white text-ink focus:outline-none">
                            <option value="">All Statuses</option>
                            <option value="SCHEDULED">Scheduled</option>
                            <option value="EN_ROUTE">En Route</option>
                            <option value="CHECKED_IN">Checked In</option>
                            <option value="IN_PROGRESS">In Progress</option>
                            <option value="CHECKED_OUT">Checked Out</option>
                            <option value="COMPLETED">Completed</option>
                            <option value="CANCELLED">Cancelled</option>
                        </select>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="data-table" id="visitsTable">
                        <thead>
                            <tr>
                                <th>Visit ID</th>
                                <th>Customer</th>
                                <th>Caregiver</th>
                                <th>Scheduled</th>
                                <th>Status</th>
                                <th>Location</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${visits}">
                                <tr data-status="${v.status}">
                                    <td>
                                        <span class="font-medium text-sm">#${v.visitId}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink font-medium text-sm">${v.customerName}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink text-sm">${v.caregiverName}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink-light text-sm">${v.scheduledStart}</span>
                                    </td>
                                    <td>
                                        <c:set var="sKey" value="${fn:toLowerCase(v.status)}"/>
                                        <span class="status-badge status-${sKey}">${v.statusLabel}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink-light text-sm">${v.location}</span>
                                    </td>
                                    <td class="text-right">
                                        <div class="flex items-center justify-end gap-2">
                                            <button onclick="openStatusModal('${v.visitId}', '${v.status}')"
                                                    class="text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-copper hover:border-copper transition-colors">
                                                Status
                                            </button>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/service-visits/delete"
                                                  class="inline" onsubmit="return confirm('Delete visit #${v.visitId}?');">
                                                <input type="hidden" name="visitId" value="${v.visitId}">
                                                <button type="submit"
                                                        class="text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 hover:bg-red-50 transition-colors">
                                                    Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty visits}">
                                <tr id="emptyRow">
                                    <td colspan="7" class="text-center py-12">
                                        <svg class="w-10 h-10 text-stone-deep mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                                        </svg>
                                        <p class="text-sm text-ink-muted">No service visits found</p>
                                        <p class="text-xs text-ink-muted mt-1">Click "+ New Visit" to create a service visit</p>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </section>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <!-- ══════════════ Create Visit Modal ══════════════ -->
    <div class="modal-overlay" id="createModal">
        <div class="modal-box">
            <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                <h3 class="font-serif text-xl font-medium text-ink">Create Service Visit</h3>
                <button onclick="closeCreateModal()" class="text-ink-muted hover:text-ink transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/service-visits/create" class="p-6 space-y-5">
                <!-- Booking ID -->
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Booking ID</label>
                    <input type="number" name="bookingId" required min="1"
                           class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                </div>
                <!-- Customer -->
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Customer User ID</label>
                        <input type="text" name="customerUserId" required placeholder="UUID"
                               class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                    </div>
                    <div>
                        <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Customer Name</label>
                        <input type="text" name="customerName" required
                               class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                    </div>
                </div>
                <!-- Caregiver -->
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Caregiver User ID</label>
                        <input type="text" name="caregiverUserId" required placeholder="UUID"
                               class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                    </div>
                    <div>
                        <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Caregiver Name</label>
                        <input type="text" name="caregiverName" required
                               class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                    </div>
                </div>
                <!-- Schedule -->
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Start Time</label>
                        <input type="datetime-local" name="scheduledStartTime" required
                               class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                    </div>
                    <div>
                        <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">End Time</label>
                        <input type="datetime-local" name="scheduledEndTime" required
                               class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                    </div>
                </div>
                <!-- Location & Notes -->
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Location</label>
                    <input type="text" name="location" placeholder="Address or coordinates"
                           class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                </div>
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Notes</label>
                    <textarea name="notes" rows="2" placeholder="Optional notes"
                           class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink resize-none"></textarea>
                </div>
                <!-- Submit -->
                <div class="flex items-center justify-end gap-3 pt-2">
                    <button type="button" onclick="closeCreateModal()"
                            class="px-5 py-2 text-sm text-ink-muted border border-stone-mid hover:bg-stone-warm transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-5 py-2 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                        Create Visit
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- ══════════════ Update Status Modal ══════════════ -->
    <div class="modal-overlay" id="statusModal">
        <div class="modal-box">
            <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                <h3 class="font-serif text-xl font-medium text-ink">Update Visit Status</h3>
                <button onclick="closeStatusModal()" class="text-ink-muted hover:text-ink transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/service-visits/status" class="p-6 space-y-5">
                <input type="hidden" name="visitId" id="statusVisitId">
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">New Status</label>
                    <select name="status" id="statusSelect" required
                            class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                        <option value="SCHEDULED">Scheduled</option>
                        <option value="EN_ROUTE">En Route</option>
                        <option value="CHECKED_IN">Checked In</option>
                        <option value="IN_PROGRESS">In Progress</option>
                        <option value="CHECKED_OUT">Checked Out</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="CANCELLED">Cancelled</option>
                    </select>
                </div>
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Notes</label>
                    <textarea name="notes" rows="2" placeholder="Optional notes for status change"
                              class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink resize-none"></textarea>
                </div>
                <div class="flex items-center justify-end gap-3 pt-2">
                    <button type="button" onclick="closeStatusModal()"
                            class="px-5 py-2 text-sm text-ink-muted border border-stone-mid hover:bg-stone-warm transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-5 py-2 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                        Update Status
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
    // ── Loader ──
    window.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 500);
    });

    // ── Create Modal ──
    function openCreateModal() { document.getElementById('createModal').classList.add('show'); }
    function closeCreateModal() { document.getElementById('createModal').classList.remove('show'); }

    // ── Status Modal ──
    function openStatusModal(visitId, currentStatus) {
        document.getElementById('statusVisitId').value = visitId;
        document.getElementById('statusSelect').value = currentStatus;
        document.getElementById('statusModal').classList.add('show');
    }
    function closeStatusModal() { document.getElementById('statusModal').classList.remove('show'); }

    // ── Filter ──
    function filterByStatus() {
        const val = document.getElementById('statusFilter').value;
        const rows = document.querySelectorAll('#visitsTable tbody tr[data-status]');
        rows.forEach(row => {
            if (!val || row.dataset.status === val) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    // Close modals on overlay click
    document.querySelectorAll('.modal-overlay').forEach(m => {
        m.addEventListener('click', e => { if (e.target === m) m.classList.remove('show'); });
    });
    </script>
</body>
</html>
