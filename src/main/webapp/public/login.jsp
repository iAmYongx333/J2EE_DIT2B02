<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Login – SilverCare</title>

<%
String errText = "";
String errCode = request.getParameter("errCode");
if (errCode != null) {
	errText = errCode;
}

Object userRole = session.getAttribute("sessRole");
if (userRole != null) {
	response.sendRedirect(request.getContextPath() + "/index.jsp");
	return;
}
%>

<!-- Tailwind (remove if you already load this globally) -->
<script src="https://cdn.tailwindcss.com"></script>

<style>
body {
	font-family: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text",
		"Helvetica Neue", Arial, sans-serif;
}

/* Prague / Scandinavian paper background */
.page-shell {
	background: linear-gradient(to bottom, #f6f1e9 0%, #f9f4ec 45%, #faf7f1 100%);
}

/* Card fade up */
@
keyframes softFadeUp { 0% {
	opacity: 0;
	transform: translateY(14px);
}

100
%
{
opacity
:
1;
transform
:
translateY(
0
);
}
}
.card-appear {
	opacity: 0;
	animation: softFadeUp 0.45s ease-out 0.12s forwards;
}

/* Small accent underline used in text column */
.accent-line {
	width: 44px;
	height: 2px;
	border-radius: 999px;
	background: #1e2a38;
}
</style>
</head>

<body class="page-shell min-h-screen text-[#1e2a38]">
	<%@ include file="../includes/header.jsp"%>

	<main class="pt-28 pb-20">
		<div class="max-w-7xl mx-auto px-6 md:px-8">
			<div class="grid md:grid-cols-2 gap-12 lg:gap-16 items-start">

				<!-- Left: copy that matches footer tone -->
				<section class="space-y-4 md:space-y-5">
					<p class="text-[11px] tracking-[0.18em] uppercase text-slate-500">
						SilverCare platform</p>

					<h1
						class="text-[26px] md:text-[30px] font-serif font-semibold tracking-tight text-[#1e2a38]">
						Quiet, organised elderly care.</h1>

					<div class="accent-line"></div>

					<p class="max-w-md text-[14px] leading-relaxed text-slate-700">
						Manage visits, bookings, and support in a calm space that feels
						closer to a home.</p>

					<p class="max-w-md text-[13px] leading-relaxed text-slate-600">
						Log in to review upcoming services, confirm appointments, and keep
						family members aligned without noise or clutter.</p>
				</section>

				<!-- Right: login card -->
				<section class="flex justify-center md:justify-end">
					<div
						class="w-full max-w-sm card-appear
                      rounded-[24px] bg-[#fdfaf5]
                      border border-[#e0dcd4]
                      shadow-[0_10px_32px_rgba(15,23,42,0.08)]
                      px-6 py-6 md:px-7 md:py-7">

						<!-- Card header -->
						<header class="space-y-1.5 mb-5">
							<span
								class="inline-flex items-center rounded-full
                           border border-[#e0dcd4]
                           bg-[#faf6ef]
                           px-3 py-1
                           text-[11px] uppercase tracking-[0.18em]
                           text-slate-600">
								Log in </span>

							<h2
								class="text-[20px] md:text-[21px] font-semibold tracking-tight text-[#1e2a38]">
								Welcome back</h2>
							<p class="text-[12.5px] text-slate-600 leading-relaxed">Sign
								in to access your SilverCare account and keep your loved ones’
								care details together in one simple overview.</p>
						</header>

						<!-- Form -->
						<form method="get"
							action="<%=request.getContextPath()%>/customersServlet"
							class="space-y-4">
							<input type="hidden" name="action" value="login">

							<!-- Email -->
							<div class="space-y-1">
								<label for="email"
									class="block text-[12.5px] font-medium text-slate-700">
									Email address </label> <input type="text" id="email" name="email"
									autocomplete="email"
									class="w-full rounded-[14px]
                              border border-[#ddd5c7]
                              bg-[#fbf7f1]
                              px-3 py-2.5 text-[13px]
                              text-slate-900 placeholder:text-slate-400
                              outline-none
                              focus:border-[#1e2a38]
                              focus:ring-1 focus:ring-[#1e2a38]
                              transition-all duration-200"
									placeholder="you@example.com">
							</div>

							<!-- Password -->
							<div class="space-y-1">
								<label for="password"
									class="block text-[12.5px] font-medium text-slate-700">
									Password </label> <input type="password" id="password" name="password"
									autocomplete="current-password"
									class="w-full rounded-[14px]
                              border border-[#ddd5c7]
                              bg-[#fbf7f1]
                              px-3 py-2.5 text-[13px]
                              text-slate-900 placeholder:text-slate-400
                              outline-none
                              focus:border-[#1e2a38]
                              focus:ring-1 focus:ring-[#1e2a38]
                              transition-all duration-200"
									placeholder="••••••••">
							</div>

							<!-- Error text -->
							<%
							if (errText != null && !errText.trim().isEmpty()) {
							%>
							<p class="text-[12px] text-rose-600">
								<%=errText%>
							</p>
							<%
							}
							%>

							<!-- Submit + helper text -->
							<div class="pt-1.5 space-y-3">
								<button type="submit" name="btnSubmit" value="login"
									class="w-full inline-flex items-center justify-center
                               rounded-full bg-[#1e2a38] text-[#fdfaf5]
                               text-[13px] font-medium
                               px-4 py-2.5
                               shadow-[0_10px_28px_rgba(15,23,42,0.22)]
                               hover:bg-[#253447]
                               active:scale-[0.99]
                               transition-all duration-200">
									Continue</button>

								<p class="text-[12px] text-slate-600 text-center">
									Don’t have an account yet? <a
										href="<%=request.getContextPath()%>/public/register.jsp"
										class="font-medium text-[#1e2a38] underline underline-offset-4">
										Create one </a>
								</p>
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>
	</main>

	<%@ include file="../includes/footer.jsp"%>
</body>
</html>