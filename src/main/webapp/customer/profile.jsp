<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.util.*,Assignment1.Customer.Customer, Assignment1.Country"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My Profile – SilverCare</title>

<%
String errText = "";
String errCode = request.getParameter("errCode");
if (errCode != null) {
	errText = errCode;
}
Customer u = (Customer) session.getAttribute("user");
if (u == null) {
	response.sendRedirect(request.getContextPath() + "/customersServlet?action=retrieveUser");
	return;
}
ArrayList<Country> countryList = (ArrayList<Country>) session.getAttribute("countryList");
if (countryList == null) {
	response.sendRedirect(request.getContextPath() + "/countryCodeServlet?origin=customer/profile.jsp");
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

<!-- Tailwind CDN (remove if already included globally) -->
<script src="https://cdn.tailwindcss.com"></script>

<style>
body {
	font-family: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text",
		"Helvetica Neue", Arial, sans-serif;
}

.page-shell {
	background: linear-gradient(to bottom, #f6f1e9 0%, #f9f4ec 45%, #faf7f1 100%);
}

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


1
;


transform


:


translateY
(


0


)
;


}
}
.card-appear {
	opacity: 0;
	animation: softFadeUp 0.45s ease-out 0.12s forwards;
}

.accent-line {
	width: 44px;
	height: 2px;
	border-radius: 999px;
	background: #1e2a38;
}

.profile-label {
	font-size: 12.5px;
	letter-spacing: 0.08em;
}
</style>
</head>

<body class="page-shell min-h-screen text-[#1e2a38]">
	<%@ include file="../includes/header.jsp"%>

	<main class="pt-28 pb-20">
		<div class="max-w-5xl mx-auto px-6 md:px-8">

			<!-- Page heading -->
			<section class="mb-6 md:mb-8">
				<p class="text-[11px] tracking-[0.18em] uppercase text-slate-500">
					SilverCare account</p>
				<h1
					class="mt-1 text-[26px] md:text-[30px] font-serif font-semibold tracking-tight text-[#1e2a38]">
					My profile</h1>
				<div class="mt-3 accent-line"></div>
			</section>

			<!-- Error banner (if any) -->
			<%
			if (errText != null && !errText.trim().isEmpty()) {
			%>
			<div
				class="mb-5 rounded-[18px] border border-rose-200 bg-rose-50/85
                    px-4 py-2.5 text-[12.5px] text-rose-700">
				<%=errText%>
			</div>
			<%
			}
			%>

			<!-- Profile card -->
			<section
				class="card-appear rounded-[24px] bg-[#fdfaf5]
                      border border-[#e0dcd4]
                      shadow-[0_14px_40px_rgba(15,23,42,0.10)]
                      px-6 py-6 md:px-8 md:py-7">

				<!-- Top: name + edit button -->
				<div
					class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-5">
					<div>
						<h2
							class="text-[20px] md:text-[22px] font-semibold tracking-tight text-[#1e2a38]">
							<%=u.getFullName()%>
						</h2>
						<p class="text-[13px] text-slate-600 mt-1">Account details and
							contact information for your SilverCare bookings.</p>
					</div>

					<button type="button"
						onclick="window.location.href='<%=request.getContextPath()%>/customer/edit_profile.jsp'"
						class="inline-flex items-center justify-center
                   rounded-full border border-[#ddd5c7]
                   bg-[#f8f2e8]
                   px-4 py-2.5 text-[13px] font-medium text-slate-800
                   hover:bg-[#f2e7d7]
                   active:scale-[0.98]
                   transition-all duration-200">
						Edit profile</button>
				</div>

				<div
					class="border-t border-[#e4dfd6] pt-5 grid md:grid-cols-2 gap-8">

					<!-- Column 1: contact -->
					<div class="space-y-4">
						<div class="space-y-1">
							<div class="profile-label text-[11px] uppercase text-slate-500">
								Email</div>
							<p class="text-[14px] text-[#111827] break-all">
								<%=u.getEmail()%>
							</p>
						</div>

						<div class="space-y-1">
							<div class="profile-label text-[11px] uppercase text-slate-500">
								Phone</div>
							<p class="text-[14px] text-[#111827]">
								<%=u.getPhone()%>
							</p>
						</div>

						<div class="space-y-1">
							<div class="profile-label text-[11px] uppercase text-slate-500">
								Country</div>
							<p class="text-[14px] text-[#111827] flex items-center gap-2">
								<%
								if (userFlagImage != null) {
								%>
								<img
									src="<%=request.getContextPath()%>/images/flags/<%=userFlagImage%>"
									alt="<%=u.getCountry()%>" class="w-[20px] h-auto rounded-[3px]">
								<%
								}
								%>
								<span><%=u.getCountry()%></span>
							</p>
						</div>

						<!-- Column 2: address -->
						<div class="space-y-4">
							<div class="space-y-1">
								<div class="profile-label text-[11px] uppercase text-slate-500">
									Street address</div>
								<p class="text-[14px] text-[#111827]">
									<%=u.getStreet()%>
								</p>
							</div>

							<div class="grid grid-cols-2 gap-4">
								<div class="space-y-1">
									<div class="profile-label text-[11px] uppercase text-slate-500">
										Postal code</div>
									<p class="text-[14px] text-[#111827]">
										<%=u.getPostalCode()%>
									</p>
								</div>
								<div class="space-y-1">
									<div class="profile-label text-[11px] uppercase text-slate-500">
										Block / unit</div>
									<p class="text-[14px] text-[#111827]">
										<%
										String block = u.getBlockNo() != null ? u.getBlockNo() : "";
										String unit = u.getUnitNo() != null ? u.getUnitNo() : "";
										%>
										<%=block%><%=(!block.isEmpty() && !unit.isEmpty()) ? ", " : ""%><%=unit%>
									</p>
								</div>
							</div>
						</div>
					</div>
			</section>
		</div>
	</main>

	<%@ include file="../includes/footer.jsp"%>
</body>
</html>