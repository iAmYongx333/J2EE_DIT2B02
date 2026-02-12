<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Feedback – SilverCare</title>

    <%
        Object userRole = session.getAttribute("sessRole");
        if (userRole == null || !"admin".equals(userRole.toString())) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
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

    .rating-star { color: #d4cec3; }
    .rating-star.filled { color: #b87a4b; }
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
                            Review Feedback
                        </h1>
                        <p class="text-ink-light text-base max-w-xl leading-relaxed stagger-3">
                            Read customer reviews and remove inappropriate or spam entries when necessary.
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
                            <h2 class="font-serif text-lg font-medium text-ink">Feedback Entries</h2>
                            <p class="text-xs text-ink-muted mt-1">
                                <c:choose>
                                    <c:when test="${not empty feedbackList}">
                                        ${fn:length(feedbackList)} entr<c:choose><c:when test="${fn:length(feedbackList) == 1}">y</c:when><c:otherwise>ies</c:otherwise></c:choose> found
                                    </c:when>
                                    <c:otherwise>No feedback found</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div>
                            <input type="text" id="feedbackSearch" placeholder="Search by service, user or comment..."
                                   class="w-full sm:w-72 px-4 py-2.5 border border-stone-mid text-sm bg-stone-warm text-ink placeholder:text-ink-muted focus:outline-none focus:border-ink transition-colors" />
                        </div>
                    </div>

                    <!-- Desktop Table -->
                    <div class="hidden md:block overflow-x-auto">
                        <table class="min-w-full">
                            <thead class="bg-stone-warm border-b border-stone-mid">
                                <tr class="text-xs uppercase tracking-[0.15em] text-ink-muted">
                                    <th class="text-left px-6 py-3 font-medium">Service</th>
                                    <th class="text-left px-4 py-3 font-medium">Customer</th>
                                    <th class="text-left px-4 py-3 font-medium">Rating</th>
                                    <th class="text-left px-4 py-3 font-medium">Comment</th>
                                    <th class="text-right px-4 py-3 font-medium">Date</th>
                                    <th class="text-right px-6 py-3 font-medium">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-stone-mid text-sm">
                                <c:forEach items="${feedbackList}" var="fb">
                                    <tr class="table-row-hover feedback-row"
                                        data-service="${fn:toLowerCase(fb.serviceName)}"
                                        data-user="${fn:toLowerCase(fb.userName)}"
                                        data-comment="${fn:toLowerCase(fb.comments)}">
                                        <td class="px-6 py-4 align-middle">
                                            <div>
                                                <p class="font-medium text-ink text-sm">${fb.serviceName}</p>
                                                <p class="text-[11px] text-ink-muted">ID: ${fb.feedbackId}</p>
                                            </div>
                                        </td>
                                        <td class="px-4 py-4 align-middle">
                                            <span class="text-ink-light text-sm">${fb.userName}</span>
                                        </td>
                                        <td class="px-4 py-4 align-middle">
                                            <div class="inline-flex items-center gap-0.5">
                                                <c:forEach begin="1" end="5" var="star">
                                                    <svg class="w-3.5 h-3.5 rating-star ${star <= fb.rating ? 'filled' : ''}" fill="currentColor" viewBox="0 0 20 20">
                                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                                    </svg>
                                                </c:forEach>
                                                <span class="text-xs text-ink-muted ml-1.5">${fb.rating}/5</span>
                                            </div>
                                        </td>
                                        <td class="px-4 py-4 align-middle max-w-xs">
                                            <p class="text-sm text-ink-light leading-relaxed truncate">
                                                <c:choose>
                                                    <c:when test="${fn:length(fb.comments) > 80}">
                                                        ${fn:substring(fb.comments, 0, 80)}...
                                                    </c:when>
                                                    <c:otherwise>${fb.comments}</c:otherwise>
                                                </c:choose>
                                            </p>
                                        </td>
                                        <td class="px-4 py-4 align-middle text-right">
                                            <time data-iso="${fb.createdAt}" class="text-xs text-ink-muted">${fb.createdAt}</time>
                                        </td>
                                        <td class="px-6 py-4 align-middle text-right">
                                            <button type="button"
                                                    class="open-delete-modal text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 hover:bg-red-50 transition-colors"
                                                    data-id="${fb.feedbackId}"
                                                    data-service="${fb.serviceName}"
                                                    data-user="${fb.userName}"
                                                    data-comment="${fb.comments}"
                                                    data-rating="${fb.rating}">
                                                Delete
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty feedbackList}">
                                    <tr>
                                        <td colspan="6" class="px-6 py-12 text-center">
                                            <svg class="w-10 h-10 text-stone-deep mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                                            </svg>
                                            <p class="text-sm text-ink-muted">No feedback yet</p>
                                            <p class="text-xs text-ink-muted mt-1">Reviews will appear here once customers submit them</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- Mobile Cards -->
                    <div class="md:hidden divide-y divide-stone-mid" id="feedbackCards">
                        <c:forEach items="${feedbackList}" var="fb">
                            <div class="feedback-row px-5 py-4 space-y-3"
                                 data-service="${fn:toLowerCase(fb.serviceName)}"
                                 data-user="${fn:toLowerCase(fb.userName)}"
                                 data-comment="${fn:toLowerCase(fb.comments)}">
                                <div class="flex items-start justify-between gap-3">
                                    <div>
                                        <p class="font-medium text-sm text-ink">${fb.serviceName}</p>
                                        <p class="text-[11px] text-ink-muted mt-0.5">${fb.userName}</p>
                                    </div>
                                    <div class="inline-flex items-center gap-0.5 flex-shrink-0">
                                        <c:forEach begin="1" end="5" var="star">
                                            <svg class="w-3 h-3 rating-star ${star <= fb.rating ? 'filled' : ''}" fill="currentColor" viewBox="0 0 20 20">
                                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                            </svg>
                                        </c:forEach>
                                    </div>
                                </div>
                                <p class="text-xs text-ink-light leading-relaxed">${fb.comments}</p>
                                <div class="flex items-center justify-between">
                                    <time data-iso="${fb.createdAt}" class="text-[11px] text-ink-muted">${fb.createdAt}</time>
                                    <button type="button"
                                            class="open-delete-modal text-[11px] px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 transition-colors"
                                            data-id="${fb.feedbackId}"
                                            data-service="${fb.serviceName}"
                                            data-user="${fb.userName}"
                                            data-comment="${fb.comments}"
                                            data-rating="${fb.rating}">
                                        Delete
                                    </button>
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty feedbackList}">
                            <div class="px-5 py-12 text-center">
                                <p class="text-sm text-ink-muted">No feedback yet</p>
                            </div>
                        </c:if>
                    </div>

                </div>
            </section>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <!-- Delete Feedback Modal -->
    <div id="deleteModalBackdrop"
         class="fixed inset-0 z-[220] bg-black/20 backdrop-blur-sm flex items-center justify-center opacity-0 invisible transition-opacity duration-200">
        <div id="deleteModal"
             class="w-full max-w-md mx-4 bg-white border border-stone-mid shadow-lg px-7 py-7 transform translate-y-4 transition-all duration-250 ease-out">

            <h2 class="font-serif text-xl font-medium text-ink">Delete Feedback</h2>
            <p class="mt-3 text-sm text-ink-light leading-relaxed">
                This will permanently remove this feedback entry. This action cannot be undone.
            </p>

            <div class="mt-5 border border-stone-mid bg-stone-warm px-5 py-4 space-y-2">
                <div class="flex items-center justify-between">
                    <p class="text-sm font-medium text-ink" id="deleteFeedbackService">Service name</p>
                    <div class="inline-flex items-center gap-0.5" id="deleteFeedbackStars"></div>
                </div>
                <p class="text-xs text-ink-muted" id="deleteFeedbackUser">Customer name</p>
                <p class="text-xs text-ink-light leading-relaxed mt-1" id="deleteFeedbackComment">Comment preview...</p>
            </div>

            <form id="deleteFeedbackForm" method="post"
                  action="${pageContext.request.contextPath}/admin/feedback/delete"
                  class="mt-6 flex items-center justify-end gap-3">
                <input type="hidden" name="feedback_id" id="deleteFeedbackId" />

                <button type="button" id="cancelDeleteBtn"
                        class="px-4 py-2 border border-stone-mid text-sm text-ink bg-white hover:bg-stone-warm transition-colors">
                    Cancel
                </button>
                <button type="submit"
                        class="px-4 py-2 bg-red-600 text-white text-sm font-medium hover:bg-red-700 transition-colors">
                    Delete feedback
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
            var mins = Math.floor(diff / 60000);
            var hrs = Math.floor(diff / 3600000);
            var days = Math.floor(diff / 86400000);
            if (mins < 1) { el.textContent = 'Just now'; }
            else if (mins < 60) { el.textContent = mins + ' min' + (mins !== 1 ? 's' : '') + ' ago'; }
            else if (hrs < 24) { el.textContent = hrs + ' hr' + (hrs !== 1 ? 's' : '') + ' ago'; }
            else if (days < 7) { el.textContent = days + ' day' + (days !== 1 ? 's' : '') + ' ago'; }
            else {
                el.textContent = d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
                    + ', ' + d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
            }
            el.title = d.toLocaleString();
        } catch(e) {}
    });

    document.addEventListener("DOMContentLoaded", () => {
        // Search
        const searchInput = document.getElementById("feedbackSearch");
        if (searchInput) {
            const rows = Array.from(document.querySelectorAll(".feedback-row"));
            searchInput.addEventListener("input", () => {
                const q = searchInput.value.toLowerCase();
                rows.forEach(row => {
                    const service = (row.dataset.service || "");
                    const user = (row.dataset.user || "");
                    const comment = (row.dataset.comment || "");
                    row.style.display = (service.includes(q) || user.includes(q) || comment.includes(q)) ? "" : "none";
                });
            });
        }

        // Delete Modal
        const backdrop = document.getElementById("deleteModalBackdrop");
        const modal = document.getElementById("deleteModal");
        const serviceSpan = document.getElementById("deleteFeedbackService");
        const userSpan = document.getElementById("deleteFeedbackUser");
        const commentSpan = document.getElementById("deleteFeedbackComment");
        const starsContainer = document.getElementById("deleteFeedbackStars");
        const feedbackIdInput = document.getElementById("deleteFeedbackId");
        const cancelBtn = document.getElementById("cancelDeleteBtn");

        function renderStars(rating) {
            let html = '';
            for (let i = 1; i <= 5; i++) {
                const filled = i <= rating ? 'filled' : '';
                html += '<svg class="w-3.5 h-3.5 rating-star ' + filled + '" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>';
            }
            return html;
        }

        function openDeleteModal(id, service, user, comment, rating) {
            serviceSpan.textContent = service || "Unknown service";
            userSpan.textContent = "By " + (user || "Unknown");
            commentSpan.textContent = comment && comment.length > 120 ? comment.substring(0, 120) + "..." : (comment || "No comment");
            starsContainer.innerHTML = renderStars(parseInt(rating) || 0);
            feedbackIdInput.value = id || "";

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
                openDeleteModal(btn.dataset.id, btn.dataset.service, btn.dataset.user, btn.dataset.comment, btn.dataset.rating);
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
