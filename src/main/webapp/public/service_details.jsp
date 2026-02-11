<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="Assignment1.Service.Service, Assignment1.Feedback, java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Service Detail | SilverCare</title>

    <%
        // Pull request attributes (set by servlet)
        Service s = (Service) request.getAttribute("service");
        if (s == null) {
            response.sendRedirect(request.getContextPath() + "/public/services.jsp?errCode=ServiceNotFoundWithChanges");
            return;
        }

        ArrayList<Feedback> feedbackList =
            (ArrayList<Feedback>) request.getAttribute("feedbackList");

        String userRole = session.getAttribute("sessRole") != null
                ? session.getAttribute("sessRole").toString()
                : "";

        String errCode = request.getParameter("errCode");
    %>

    <!-- Tailwind CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI", sans-serif; }
        .detail-card { transition: box-shadow 0.25s ease, transform 0.22s ease, border-color 0.22s ease, background-color 0.22s ease; }
        .detail-card:hover { box-shadow: 0 24px 60px rgba(15, 23, 42, 0.18); transform: translateY(-2px); border-color: rgba(148, 163, 184, 0.7); }
        .feedback-card { transition: box-shadow 0.22s ease, transform 0.18s ease, border-color 0.18s ease; }
        .feedback-card:hover { box-shadow: 0 18px 40px rgba(15, 23, 42, 0.14); transform: translateY(-1px); border-color: rgba(148, 163, 184, 0.7); }
    </style>
</head>

<body class="bg-[#f7f4ef] text-slate-900">
<%@ include file="../includes/header.jsp" %>

<main class="mt-12 min-h-screen pt-24 pb-16 px-6 sm:px-10 lg:px-16">
    <div class="max-w-5xl mx-auto space-y-12">

        <!-- BACK LINK -->
        <div>
            <a href="<%= request.getContextPath() %>/public/services.jsp"
               class="inline-flex items-center gap-1 text-xs sm:text-sm text-slate-600 hover:text-slate-900">
                ← Back to services
            </a>
        </div>

        <!-- SERVICE HERO CARD -->
        <section class="detail-card bg-white/95 border border-slate-200 rounded-3xl shadow-sm overflow-hidden">
            <div class="grid md:grid-cols-[1.1fr_1.3fr]">
                <!-- Image -->
                <div class="relative h-56 md:h-full overflow-hidden bg-slate-100">
                    <img src="<%= request.getContextPath() %>/<%= s.getImagePath() %>"
                         alt="<%= s.getServiceName() %>"
                         class="w-full h-full object-cover" />
                    <div class="absolute inset-0 bg-gradient-to-t from-black/35 via-black/10 to-transparent pointer-events-none"></div>
                    <div class="absolute bottom-4 left-4 flex flex-col gap-2 text-[11px] text-slate-100">
                        <span class="inline-flex items-center gap-1.5 px-2 py-1 rounded-full bg-black/35 backdrop-blur">
                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                            Available service
                        </span>
                        <span class="inline-flex items-center gap-1.5 px-2 py-1 rounded-full bg-black/30 backdrop-blur">
                            <span>Duration:</span>
                            <span class="font-semibold"><%= s.getDurationMin() %> min</span>
                        </span>
                    </div>
                </div>

                <!-- Content -->
                <div class="px-6 py-6 sm:px-8 sm:py-7 flex flex-col gap-5">
                    <div class="space-y-2">
                        <div class="inline-flex items-center gap-2 rounded-full bg-[#f6efe2] border border-[#e4d5c0] px-3 py-1 text-[11px] tracking-[0.16em] uppercase text-slate-600">
                            SilverCare Service
                        </div>
                        <h1 class="text-2xl sm:text-3xl font-semibold tracking-tight">
                            <%= s.getServiceName() %>
                        </h1>
                        <p class="text-sm sm:text-[15px] text-slate-700 leading-relaxed">
                            <%= s.getDescription() %>
                        </p>
                    </div>

                    <div class="grid grid-cols-2 sm:grid-cols-3 gap-4 text-xs sm:text-sm">
                        <div class="space-y-0.5">
                            <p class="text-[11px] uppercase tracking-[0.16em] text-slate-500">Price</p>
                            <p class="text-[18px] font-semibold text-slate-900">
                                $<%= s.getPrice() %> <span class="text-[11px] font-normal text-slate-500">/ session</span>
                            </p>
                        </div>
                        <div class="space-y-0.5">
                            <p class="text-[11px] uppercase tracking-[0.16em] text-slate-500">Duration</p>
                            <p class="text-sm font-medium text-slate-900"><%= s.getDurationMin() %> minutes</p>
                        </div>
                        <div class="space-y-0.5">
                            <p class="text-[11px] uppercase tracking-[0.16em] text-slate-500">Service ID</p>
                            <p class="text-xs font-mono text-slate-700"><%= s.getServiceId() %></p>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="mt-2 flex flex-col sm:flex-row gap-2">
                        <!-- Add to cart -->
                        <form method="post"
                              action="<%= request.getContextPath() %>/cart/add"
                              class="flex-1">
                            <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                            <input type="hidden" name="serviceName" value="<%= s.getServiceName() %>">
                            <input type="hidden" name="price" value="<%= s.getPrice() %>">
                            <button type="submit"
                                    class="w-full inline-flex items-center justify-center px-4 py-2.5 rounded-xl bg-slate-900 text-white text-xs sm:text-sm font-medium shadow-sm hover:bg-slate-950 hover:shadow-lg transition-all">
                                Add to cart
                            </button>
                        </form>

                        <a href="<%= request.getContextPath() %>/public/services.jsp"
                           class="flex-1 inline-flex items-center justify-center px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-xs sm:text-sm text-slate-800 hover:bg-slate-50 transition-colors">
                            Back to services
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <!-- FEEDBACK LIST -->
        <section class="space-y-4" id="feedback">
            <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-2">
                <div class="space-y-1">
                    <h2 class="text-lg sm:text-xl font-semibold tracking-tight">
                        Customer feedback
                    </h2>
                    <p class="text-xs text-slate-600">
                        Read what families and caregivers have shared about this service.
                    </p>
                </div>

                <c:if test="${not empty feedbackList}">
                    <p class="text-[11px] text-slate-500">${fn:length(feedbackList)} review(s)</p>
                </c:if>
            </div>

            <c:choose>
                <c:when test="${empty feedbackList}">
                    <div class="rounded-2xl border border-dashed border-slate-300 bg-white/70 px-5 py-6 text-sm text-slate-500">
                        No feedback yet for this service. Be the first to share your experience.
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="space-y-4">
                        <c:forEach var="f" items="${feedbackList}">
                            <div class="feedback-card rounded-2xl border border-slate-200 bg-white px-4 py-4 sm:px-5 sm:py-5">
                                <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3">
                                    <div class="space-y-1.5">
                                        <p class="text-sm font-medium text-slate-900">${f.userName}</p>
                                        <p class="text-[11px] text-slate-500">
                                            Rating: <span class="font-semibold text-slate-900">${f.rating}</span>/5
                                        </p>
                                    </div>
                                    <p class="text-[11px] text-slate-500">
                                        <fmt:formatDate value="${f.createdAt}" pattern="dd MMM yyyy, HH:mm" />
                                    </p>
                                </div>
                                <p class="mt-3 text-sm text-slate-700 leading-relaxed">${f.comments}</p>

                                <c:if test="${userRole eq 'admin'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/feedback/delete"
                                          class="mt-4 flex justify-end">
                                        <input type="hidden" name="feedback_id" value="${f.feedbackId}" />
                                        <button type="submit"
                                                class="text-[11px] px-3 py-1.5 rounded-full border border-red-200 text-red-600 bg-white hover:bg-red-50 transition-colors">
                                            Delete feedback
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- FEEDBACK FORM -->
        <section class="space-y-4" id="leave-feedback">
            <h2 class="text-lg sm:text-xl font-semibold tracking-tight">Leave your feedback</h2>

            <!-- Error banners -->
            <c:if test="${param.errCode eq 'invalidRating'}">
                <div class="rounded-xl border border-amber-300 bg-amber-50 px-4 py-3 text-xs sm:text-sm text-amber-900">
                    Rating must be between 1 and 5.
                </div>
            </c:if>
            <c:if test="${param.errCode eq 'notLoggedIn'}">
                <div class="rounded-xl border border-rose-300 bg-rose-50 px-4 py-3 text-xs sm:text-sm text-rose-900">
                    You must be logged in to leave feedback.
                </div>
            </c:if>

            <div class="rounded-2xl border border-slate-200 bg-white px-5 py-5 sm:px-6 sm:py-6">
                <form action="<%= request.getContextPath() %>/serviceDetailServlet" method="post" class="space-y-4">
                    <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>" />

                    <div class="grid sm:grid-cols-[0.9fr_1.1fr] gap-4">
                        <!-- Rating -->
                        <div class="space-y-1">
                            <label class="block text-sm font-medium text-slate-800">Rating</label>
                            <p class="text-[11px] text-slate-500 mb-1">
                                Choose a rating from 1 (very poor) to 5 (excellent).
                            </p>
                            <select name="rating" required
                                    class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] text-sm focus:outline-none focus:ring-2 focus:ring-slate-400/50 focus:border-slate-400">
                                <option value="">-- Select rating --</option>
                                <option value="1">⭐ Very poor</option>
                                <option value="2">⭐⭐ Poor</option>
                                <option value="3">⭐⭐⭐ Average</option>
                                <option value="4">⭐⭐⭐⭐ Good</option>
                                <option value="5">⭐⭐⭐⭐⭐ Excellent</option>
                            </select>
                        </div>

                        <!-- Comments -->
                        <div class="space-y-1">
                            <label class="block text-sm font-medium text-slate-800">Comments on the service / caregiver</label>
                            <textarea name="comments" rows="4" required
                                      placeholder="Share what went well, what could be improved, and anything future families should know."
                                      class="w-full px-3 py-2 rounded-lg border border-slate-200 bg-[#f9f7f3] text-sm resize-none focus:outline-none focus:ring-2 focus:ring-slate-400/50 focus:border-slate-400"></textarea>
                        </div>
                    </div>

                    <div class="pt-2 flex justify-end">
                        <button type="submit"
                                class="px-5 py-2.5 rounded-xl bg-slate-900 text-white text-sm font-medium shadow-sm hover:bg-slate-950 hover:shadow-lg transition-all">
                            Submit feedback
                        </button>
                    </div>
                </form>
            </div>
        </section>

    </div>
</main>

<%@ include file="../includes/footer.jsp" %>
</body>
</html>
