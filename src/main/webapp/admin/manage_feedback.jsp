<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Manage Feedback | SilverCare Admin</title>

    <%
        Object userRole = session.getAttribute("sessRole");
        if (userRole == null || !"admin".equals(userRole.toString())) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
            return;
        }
    %>

    <script src="https://cdn.tailwindcss.com"></script>

    <style>
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
        .pill-rating {
            font-size: 11px;
            padding: 0.2rem 0.55rem;
            border-radius: 999px;
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
                    Review Feedback
                </h1>
                <p class="max-w-xl text-sm sm:text-base text-slate-700">
                    View comments from families and caregivers, and remove feedback if it is inappropriate or spam.
                </p>
            </div>

            <div class="flex items-center gap-3">
                <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="text-xs sm:text-sm text-slate-600 hover:text-slate-800 underline">
                    ← Back to dashboard
                </a>
            </div>
        </section>

        <!-- TABLE CARD -->
        <section class="table-card bg-white/90 border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
            <!-- Toolbar -->
            <div class="px-4 sm:px-6 py-4 border-b border-slate-200 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                <div>
                    <p class="text-xs uppercase tracking-wide text-slate-500 font-medium">Feedback</p>
                    <p class="text-xs text-slate-500 mt-1">
                        <c:choose>
                            <c:when test="${not empty feedbackList}">
                                ${fn:length(feedbackList)} feedback entr${fn:length(feedbackList) == 1 ? 'y' : 'ies'}.
                            </c:when>
                            <c:otherwise>No feedback found.</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="flex items-center gap-2">
                    <input type="text"
                           id="feedbackSearch"
                           placeholder="Search by service, user or comment..."
                           class="w-full sm:w-72 px-3 py-2 rounded-lg border border-slate-200 text-xs sm:text-sm bg-[#f9f7f3] focus:outline-none focus:ring-2 focus:ring-slate-400/50 focus:border-slate-400" />
                </div>
            </div>

            <!-- Desktop table -->
            <div class="hidden md:block overflow-x-auto">
                <table class="min-w-full text-sm">
                    <thead class="bg-[#f9f7f3] border-b border-slate-200 text-xs uppercase tracking-wide text-slate-500">
                        <tr>
                            <th class="text-left px-6 py-3">Service</th>
                            <th class="text-left px-4 py-3">Customer</th>
                            <th class="text-left px-4 py-3">Rating</th>
                            <th class="text-left px-4 py-3">Comment</th>
                            <th class="text-right px-4 py-3">Date</th>
                            <th class="text-right px-6 py-3">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="feedbackTableBody" class="divide-y divide-slate-100 text-xs sm:text-sm">
                        <c:forEach items="${feedbackList}" var="fb">
                            <tr class="feedback-row hover:bg-[#faf7f2]"
                                data-service="${fb.serviceName}"
                                data-user="${fb.userName}"
                                data-comment="${fb.comments}">
                                <td class="px-6 py-3 align-middle">
                                    <div class="flex flex-col">
                                        <span class="font-medium text-slate-900">${fb.serviceName}</span>
                                        <span class="text-[11px] text-slate-500">ID: ${fb.feedbackId}</span>
                                    </div>
                                </td>
                                <td class="px-4 py-3 align-middle text-slate-800">
                                    ${fb.userName}
                                </td>
                                <td class="px-4 py-3 align-middle">
                                    <span class="pill-rating bg-slate-100 text-slate-800">
                                        ${fb.rating} / 5
                                    </span>
                                </td>
                                <td class="px-4 py-3 align-middle text-slate-700">
                                    <c:choose>
                                        <c:when test="${fn:length(fb.comments) > 80}">
                                            ${fn:substring(fb.comments, 0, 80)}…
                                        </c:when>
                                        <c:otherwise>
                                            ${fb.comments}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="px-4 py-3 align-middle text-right text-[11px] text-slate-500">
                                    <fmt:formatDate value="${fb.createdAt}" pattern="dd MMM yyyy, HH:mm" />
                                </td>
                                <td class="px-6 py-3 align-middle text-right">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/admin/feedback/delete"
                                          onsubmit="return confirm('Delete this feedback?');">
                                        <input type="hidden" name="feedback_id" value="${fb.feedbackId}" />
                                        <button type="submit"
                                                class="text-[11px] px-3 py-1.5 rounded-full border border-red-200 text-red-600 bg-white hover:bg-red-50">
                                            Delete
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty feedbackList}">
                            <tr>
                                <td colspan="6" class="px-6 py-6 text-center text-sm text-slate-500">
                                    No feedback yet.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <!-- Mobile card view -->
            <div class="md:hidden divide-y divide-slate-100" id="feedbackCards">
                <c:forEach items="${feedbackList}" var="fb">
                    <div class="feedback-row px-4 py-4 space-y-2"
                         data-service="${fb.serviceName}"
                         data-user="${fb.userName}"
                         data-comment="${fb.comments}">
                        <div class="flex items-center justify-between gap-2">
                            <div>
                                <p class="font-medium text-sm">${fb.serviceName}</p>
                                <p class="text-[11px] text-slate-500">
                                    ${fb.userName} · ${fb.rating} / 5
                                </p>
                            </div>
                            <span class="text-[11px] text-slate-500">
                                <fmt:formatDate value="${fb.createdAt}" pattern="dd MMM yyyy" />
                            </span>
                        </div>
                        <p class="text-xs text-slate-700">
                            ${fb.comments}
                        </p>
                        <div class="flex justify-end pt-1">
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/feedback/delete"
                                  onsubmit="return confirm('Delete this feedback?');">
                                <input type="hidden" name="feedback_id" value="${fb.feedbackId}" />
                                <button type="submit"
                                        class="text-[11px] px-3 py-1.5 rounded-full border border-red-200 text-red-600 bg-white hover:bg-red-50">
                                    Delete
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty feedbackList}">
                    <div class="px-4 py-5 text-center text-sm text-slate-500">
                        No feedback yet.
                    </div>
                </c:if>
            </div>
        </section>
    </div>
</main>

<%@ include file="../includes/footer.jsp" %>

<!-- Search filter -->
<script>
document.addEventListener("DOMContentLoaded", () => {
    const searchInput = document.getElementById("feedbackSearch");
    const rows = Array.from(document.querySelectorAll(".feedback-row"));

    if (!searchInput) return;

    searchInput.addEventListener("input", () => {
        const q = searchInput.value.toLowerCase();

        rows.forEach(row => {
            const service = (row.dataset.service || "").toLowerCase();
            const user    = (row.dataset.user || "").toLowerCase();
            const comment = (row.dataset.comment || "").toLowerCase();

            const match = service.includes(q) || user.includes(q) || comment.includes(q);
            row.style.display = match ? "" : "none";
        });
    });
});
</script>

</body>
</html>