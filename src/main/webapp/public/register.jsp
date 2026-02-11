<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, Assignment1.Country" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Register – SilverCare</title>

<%
String errText = "";
String errCode = request.getParameter("errCode");
if (errCode != null) {
	errText = errCode;
}

ArrayList<Country> countryList = (ArrayList<Country>) session.getAttribute("countryList");
if (countryList == null) {
	response.sendRedirect(request.getContextPath() + "/countryCodeServlet?origin=register");
	return;
}

Object userRole = session.getAttribute("sessRole");
if (userRole != null) {
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
        stone: {
          warm: '#f5f3ef',
          mid: '#e8e4dc',
          deep: '#d4cec3',
        },
        ink: {
          DEFAULT: '#2c2c2c',
          light: '#5a5a5a',
          muted: '#8a8a8a',
        },
        copper: {
          DEFAULT: '#b87a4b',
          light: '#d4a574',
        },
      }
    }
  }
}
</script>
<style>
html { scroll-behavior: smooth; }
body { -webkit-font-smoothing: antialiased; }

/* Loading screen */
.loader {
  position: fixed;
  inset: 0;
  background: #f5f3ef;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  transition: opacity 0.5s ease, visibility 0.5s ease;
}
.loader.hidden {
  opacity: 0;
  visibility: hidden;
}
.loader-bar {
  width: 120px;
  height: 2px;
  background: #e8e4dc;
  margin: 0 auto;
  overflow: hidden;
}
.loader-bar::after {
  content: '';
  display: block;
  width: 40%;
  height: 100%;
  background: #2c2c2c;
  animation: loadingBar 1s ease-in-out infinite;
}
@keyframes loadingBar {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(350%); }
}

.page-content {
  opacity: 0;
  transition: opacity 0.6s ease;
}
.page-content.visible {
  opacity: 1;
}

.stagger-1 { animation: fadeSlideIn 0.6s ease 0.1s both; }
.stagger-2 { animation: fadeSlideIn 0.6s ease 0.2s both; }
.stagger-3 { animation: fadeSlideIn 0.6s ease 0.3s both; }
.stagger-4 { animation: fadeSlideIn 0.6s ease 0.4s both; }

@keyframes fadeSlideIn {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}

.fade-in { animation: fadeIn 0.6s ease both; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

/* Custom dropdown */
.custom-dropdown { position: relative; user-select: none; }
.custom-dropdown .selected {
  display: flex;
  align-items: center;
  gap: 8px;
  border: 1px solid #e8e4dc;
  background: #f5f3ef;
  padding: 12px 16px;
  cursor: pointer;
  font-size: 14px;
  color: #2c2c2c;
  transition: border-color 0.2s;
}
.custom-dropdown .selected:hover { border-color: #2c2c2c; }
.custom-dropdown .selected span.placeholder { color: #8a8a8a; }
.custom-dropdown .dropdown-list {
  position: absolute;
  top: calc(100% + 4px);
  left: 0;
  right: 0;
  border: 1px solid #e8e4dc;
  max-height: 200px;
  overflow-y: auto;
  background: #fff;
  display: none;
  z-index: 100;
  box-shadow: 0 8px 24px rgba(0,0,0,0.08);
}
.custom-dropdown .dropdown-item {
  padding: 10px 16px;
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  font-size: 14px;
  color: #2c2c2c;
}
.custom-dropdown .dropdown-item:hover { background: #f5f3ef; }

/* Form input base */
.form-input {
  width: 100%;
  border: 1px solid #e8e4dc;
  background: #f5f3ef;
  padding: 12px 16px;
  font-size: 14px;
  color: #2c2c2c;
  outline: none;
  transition: border-color 0.2s;
}
.form-input::placeholder { color: #8a8a8a; }
.form-input:focus { border-color: #2c2c2c; }
.form-input.error { border-color: #dc2626; background: #fef2f2; }
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
	<%@ include file="../includes/header.jsp"%>

	<main class="pt-24 pb-20 px-5 md:px-12">
		<div class="max-w-6xl mx-auto">
			<div class="grid lg:grid-cols-5 gap-12 lg:gap-20 items-start">

				<!-- Left: Info section -->
				<section class="lg:col-span-2 hidden lg:block pt-8">
					<span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Join SilverCare</span>
					<h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-4 mb-6 stagger-2">
						Create your<br>account
					</h1>
					<p class="text-ink-light text-base leading-relaxed mb-8 stagger-3">
						Two simple steps to get started. First, your contact details. Then, your address for seamless bookings.
					</p>
					<div class="border-l-2 border-stone-deep pl-4 stagger-4">
						<p class="text-ink-muted text-sm">
							Already have an account?
						</p>
						<a href="<%=request.getContextPath()%>/login" 
						   class="text-copper text-sm hover:underline">
							Sign in instead
						</a>
					</div>
				</section>

				<!-- Right: Form card -->
				<section class="lg:col-span-3 fade-in">
					<div class="bg-white border border-stone-mid p-8 md:p-10">
						
						<!-- Header -->
						<div class="mb-6">
							<h2 class="font-serif text-2xl font-medium text-ink mb-2">Personal details</h2>
							<p class="text-ink-muted text-sm">All fields required unless marked optional</p>
						</div>

						<!-- Step indicator -->
						<div class="flex items-center gap-4 mb-6 pb-6 border-b border-stone-mid">
							<div class="flex items-center gap-2">
								<div id="dot-step-1" class="w-7 h-7 flex items-center justify-center text-xs font-medium bg-ink text-stone-warm">1</div>
								<span id="label-step-1" class="text-xs uppercase tracking-wide text-ink">Account</span>
							</div>
							<div class="flex-1 h-px bg-stone-mid"></div>
							<div class="flex items-center gap-2">
								<div id="dot-step-2" class="w-7 h-7 flex items-center justify-center text-xs font-medium border border-stone-deep text-ink-muted">2</div>
								<span id="label-step-2" class="text-xs uppercase tracking-wide text-ink-muted">Address</span>
							</div>
						</div>

						<!-- Error message -->
						<% if (errText != null && !errText.trim().isEmpty()) { %>
						<div class="mb-6 border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
							<%= errText %>
						</div>
						<% } %>

						<!-- Form -->
						<form id="registerForm" method="post" action="<%= request.getContextPath() %>/customersServlet">
							<input type="hidden" name="action" value="create">
							<input type="hidden" name="origin" value="login">

							<!-- STEP 1: Account & Contact -->
							<div id="step-1" class="space-y-5">
								<div class="grid md:grid-cols-2 gap-4">
									<div>
										<label for="name" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Full name</label>
										<input type="text" id="name" name="name" class="form-input" placeholder="Jane Tan">
									</div>
									<div>
										<label for="email" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Email</label>
										<input type="email" id="email" name="email" class="form-input" placeholder="you@example.com">
									</div>
								</div>

								<div>
									<label for="password" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Password</label>
									<input type="password" id="password" name="password" class="form-input" placeholder="Create a password">
								</div>

								<div class="grid md:grid-cols-2 gap-4">
									<div>
										<label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Country</label>
										<div class="custom-dropdown">
											<div class="selected">
												<span class="placeholder">Select country</span>
											</div>
											<div class="dropdown-list">
												<% if (countryList != null) {
													for (int c = 0; c < countryList.size(); c++) { %>
												<div class="dropdown-item"
													 data-id="<%= countryList.get(c).getId() %>"
													 data-code="<%= countryList.get(c).getCountryCode() %>"
													 data-name="<%= countryList.get(c).getCountryName() %>"
													 data-image="<%= countryList.get(c).getFlagImage() %>">
													<img src="<%= request.getContextPath() %>/images/flags/<%= countryList.get(c).getFlagImage() %>" alt="" width="20">
													<span>+<%= countryList.get(c).getCountryCode() %> <%= countryList.get(c).getCountryName() %></span>
												</div>
												<% } } %>
											</div>
											<input type="hidden" name="country" id="countryInput">
										</div>
									</div>
									<div>
										<label for="Phone" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Phone</label>
										<input type="number" id="Phone" name="Phone" class="form-input" placeholder="81234567">
									</div>
								</div>
							</div>

							<!-- STEP 2: Address -->
							<div id="step-2" class="space-y-5 hidden">
								<div>
									<label for="Street" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Street</label>
									<input type="text" id="Street" name="Street" class="form-input" placeholder="123 Harmony Avenue">
								</div>

								<div class="grid md:grid-cols-3 gap-4">
									<div>
										<label for="postal_code" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Postal code</label>
										<input type="text" id="postal_code" name="postal_code" class="form-input" placeholder="123456">
									</div>
									<div>
										<label for="block_no" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Block no.</label>
										<input type="text" id="block_no" name="block_no" class="form-input" placeholder="123A">
									</div>
									<div>
										<label for="unit_no" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Unit no.</label>
										<input type="text" id="unit_no" name="unit_no" class="form-input" placeholder="#01-01">
									</div>
								</div>

								<div class="grid md:grid-cols-2 gap-4">
									<div>
										<label for="building_name" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Building name <span class="normal-case text-ink-muted">(optional)</span></label>
										<input type="text" id="building_name" name="building_name" class="form-input" placeholder="Optional">
									</div>
									<div>
										<label for="city" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">City</label>
										<input type="text" id="city" name="city" class="form-input" placeholder="Singapore">
									</div>
								</div>

								<div class="grid md:grid-cols-2 gap-4">
									<div>
										<label for="state" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">State / region <span class="normal-case text-ink-muted">(optional)</span></label>
										<input type="text" id="state" name="state" class="form-input" placeholder="Optional">
									</div>
									<div>
										<label for="address_line2" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">Address line 2 <span class="normal-case text-ink-muted">(optional)</span></label>
										<input type="text" id="address_line2" name="address_line2" class="form-input" placeholder="Optional">
									</div>
								</div>
							</div>

							<!-- Buttons -->
							<div class="mt-8 pt-6 border-t border-stone-mid">
								<div class="flex items-center gap-4">
									<button id="backStepBtn" type="button"
										class="hidden px-6 py-3 border border-stone-mid text-sm text-ink hover:bg-stone-warm transition-colors">
										Back
									</button>
									<button id="nextStepBtn" type="button"
										class="flex-1 bg-ink text-stone-warm text-sm font-normal px-6 py-3 hover:bg-ink-light transition-colors">
										<span id="primaryButtonLabel">Continue</span>
									</button>
								</div>

								<p class="mt-6 text-center text-ink-muted text-sm lg:hidden">
									Already have an account?
									<a href="<%=request.getContextPath()%>/login" class="text-copper hover:underline ml-1">Sign in</a>
								</p>
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>
	</main>

	<%@ include file="../includes/footer.jsp"%>
	</div>

	<script>
	window.addEventListener('load', function() {
		setTimeout(function() {
			document.getElementById('loader').classList.add('hidden');
			document.getElementById('pageContent').classList.add('visible');
		}, 600);
	});

	document.addEventListener("DOMContentLoaded", function() {
		// Country dropdown
		var dropdown = document.querySelector(".custom-dropdown");
		if (dropdown) {
			var selected = dropdown.querySelector(".selected");
			var dropdownList = dropdown.querySelector(".dropdown-list");
			var hiddenInput = document.getElementById("countryInput");
			var contextPath = '<%= request.getContextPath() %>';

			selected.addEventListener("click", function() {
				dropdownList.style.display = dropdownList.style.display === "block" ? "none" : "block";
			});

			var items = dropdown.querySelectorAll(".dropdown-item");
			items.forEach(function(item) {
				item.addEventListener("click", function() {
					var name = item.getAttribute("data-name");
					var code = item.getAttribute("data-code");
					var id = item.getAttribute("data-id");
					var flag_image = item.getAttribute("data-image");

					selected.innerHTML = '<img src="' + contextPath + '/images/flags/' + flag_image + '" width="20"><span>+' + code + ' ' + name + '</span>';
					hiddenInput.value = id;
					dropdownList.style.display = "none";
				});
			});

			document.addEventListener("click", function(e) {
				if (!dropdown.contains(e.target)) {
					dropdownList.style.display = "none";
				}
			});
		}

		// Multi-step logic
		var form = document.getElementById("registerForm");
		var step1 = document.getElementById("step-1");
		var step2 = document.getElementById("step-2");
		var nextBtn = document.getElementById("nextStepBtn");
		var backBtn = document.getElementById("backStepBtn");
		var primaryLabel = document.getElementById("primaryButtonLabel");
		var dot1 = document.getElementById("dot-step-1");
		var dot2 = document.getElementById("dot-step-2");
		var label1 = document.getElementById("label-step-1");
		var label2 = document.getElementById("label-step-2");

		var currentStep = 1;

		function setStep(step) {
			currentStep = step;
			if (step === 1) {
				step1.classList.remove("hidden");
				step2.classList.add("hidden");
				primaryLabel.textContent = "Continue";
				backBtn.classList.add("hidden");
				dot1.className = "w-7 h-7 flex items-center justify-center text-xs font-medium bg-ink text-stone-warm";
				label1.className = "text-xs uppercase tracking-wide text-ink";
				dot2.className = "w-7 h-7 flex items-center justify-center text-xs font-medium border border-stone-deep text-ink-muted";
				label2.className = "text-xs uppercase tracking-wide text-ink-muted";
			} else {
				step1.classList.add("hidden");
				step2.classList.remove("hidden");
				primaryLabel.textContent = "Create account";
				backBtn.classList.remove("hidden");
				dot1.className = "w-7 h-7 flex items-center justify-center text-xs font-medium bg-ink text-stone-warm";
				label1.className = "text-xs uppercase tracking-wide text-ink";
				dot2.className = "w-7 h-7 flex items-center justify-center text-xs font-medium bg-ink text-stone-warm";
				label2.className = "text-xs uppercase tracking-wide text-ink";
			}
		}

		function validateStep1() {
			var name = document.getElementById("name");
			var email = document.getElementById("email");
			var password = document.getElementById("password");
			var ok = true;
			[name, email, password].forEach(function(field) {
				if (!field.value.trim()) {
					ok = false;
					field.classList.add("error");
				} else {
					field.classList.remove("error");
				}
			});
			return ok;
		}

		nextBtn.addEventListener("click", function() {
			if (currentStep === 1) {
				if (validateStep1()) setStep(2);
			} else {
				form.submit();
			}
		});

		backBtn.addEventListener("click", function(e) {
			e.preventDefault();
			setStep(1);
		});

		setStep(1);
	});
	</script>
</body>
</html>
