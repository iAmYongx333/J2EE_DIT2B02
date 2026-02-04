<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*, Assignment1.Country" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Register – SilverCare</title>

  <%
    String errText = "";
    String errCode = request.getParameter("errCode");
    if (errCode != null) {
        errText = errCode;
    }

    ArrayList<Country> countryList = (ArrayList<Country>) session.getAttribute("countryList");
    if (countryList == null) {
        response.sendRedirect(request.getContextPath() + "/countryCodeServlet?origin=public/register.jsp");
        return;
    }

    Object userRole = session.getAttribute("sessRole");
    if (userRole != null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
  %>

  <!-- Tailwind (remove if already loaded globally) -->
  <script src="https://cdn.tailwindcss.com"></script>

  <style>
    body {
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text",
                   "Helvetica Neue", Arial, sans-serif;
    }

    /* Prague / Nordic paper background */
    .page-shell {
      background: linear-gradient(
        to bottom,
        #f6f1e9 0%,
        #f9f4ec 45%,
        #faf7f1 100%
      );
    }

    /* Card animation */
    @keyframes softFadeUp {
      0% {
        opacity: 0;
        transform: translateY(14px);
      }
      100% {
        opacity: 1;
        transform: translateY(0);
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

    /* Custom dropdown – aligned with inputs */
    .custom-dropdown {
      position: relative;
      width: 100%;
      user-select: none;
      font-size: 13px;
    }

    .custom-dropdown .selected {
      display: flex;
      align-items: center;
      gap: 8px;
      border-radius: 14px;
      border: 1px solid #ddd5c7;
      background-color: #fbf7f1;
      padding: 10px 12px;
      cursor: pointer;
      color: #0f172a;
    }

    .custom-dropdown .selected span.placeholder {
      color: #9ca3af;
    }

    .custom-dropdown .dropdown-list {
      position: absolute;
      top: calc(100% + 4px);
      left: 0;
      right: 0;
      border-radius: 14px;
      border: 1px solid #ddd5c7;
      max-height: 230px;
      overflow-y: auto;
      background-color: #fefcf8;
      display: none;
      z-index: 100;
      box-shadow: 0 18px 40px rgba(15, 23, 42, 0.22);
    }

    .custom-dropdown .dropdown-item {
      padding: 7px 12px;
      display: flex;
      align-items: center;
      gap: 8px;
      cursor: pointer;
      color: #0f172a;
      font-size: 13px;
      white-space: nowrap;
    }

    .custom-dropdown .dropdown-item:hover {
      background-color: #f3ede3;
    }
  </style>

  <script>
    document.addEventListener("DOMContentLoaded", function () {
      /* =====================
         Country dropdown
         ===================== */
      const dropdown = document.querySelector(".custom-dropdown");
      if (dropdown) {
        const selected = dropdown.querySelector(".selected");
        const dropdownList = dropdown.querySelector(".dropdown-list");
        const hiddenInput = document.getElementById("countryInput");
        const contextPath = '<%= request.getContextPath() %>';

        selected.addEventListener("click", function () {
          dropdownList.style.display =
            dropdownList.style.display === "block" ? "none" : "block";
        });

        const items = dropdown.querySelectorAll(".dropdown-item");
        items.forEach(item => {
          item.addEventListener("click", function () {
            const name = item.getAttribute("data-name");
            const code = item.getAttribute("data-code");
            const id = item.getAttribute("data-id");
            const flag_image = item.getAttribute("data-image");

            selected.innerHTML =
              '<img src="' + contextPath + '/images/flags/' + flag_image + '" width="22" class="rounded-sm">' +
              '<span>+' + code + ' ' + name + '</span>';

            hiddenInput.value = id;
            dropdownList.style.display = "none";
          });
        });

        document.addEventListener("click", function (e) {
          if (!dropdown.contains(e.target)) {
            dropdownList.style.display = "none";
          }
        });
      }

      /* =====================
         Multi-step logic
         ===================== */
      const form = document.getElementById("registerForm");
      const step1 = document.getElementById("step-1");
      const step2 = document.getElementById("step-2");
      const nextBtn = document.getElementById("nextStepBtn");
      const backBtn = document.getElementById("backStepBtn");
      const primaryLabel = document.getElementById("primaryButtonLabel");
      const helperText = document.getElementById("stepHelperText");
      const dot1 = document.getElementById("dot-step-1");
      const dot2 = document.getElementById("dot-step-2");
      const label1 = document.getElementById("label-step-1");
      const label2 = document.getElementById("label-step-2");

      let currentStep = 1;

      function setStep(step) {
        currentStep = step;

        if (step === 1) {
          step1.classList.remove("hidden");
          step2.classList.add("hidden");

          primaryLabel.textContent = "Next step";
          helperText.textContent = "Step 1 of 2 · Account & contact";
          backBtn.classList.add("hidden");

          dot1.className =
            "w-6 h-6 rounded-full flex items-center justify-center text-[11px] " +
            "font-semibold bg-[#1e2a38] text-[#fdfaf5]";
          label1.className = "text-[12px] font-medium text-[#1e2a38]";

          dot2.className =
            "w-6 h-6 rounded-full flex items-center justify-center text-[11px] " +
            "font-semibold bg-transparent border border-[#d3cec4] text-[#9ca3af]";
          label2.className = "text-[12px] font-medium text-slate-500";
        } else {
          step1.classList.add("hidden");
          step2.classList.remove("hidden");

          primaryLabel.textContent = "Create account";
          helperText.textContent = "Step 2 of 2 · Address";
          backBtn.classList.remove("hidden");

          dot1.className =
            "w-6 h-6 rounded-full flex items-center justify-center text-[11px] " +
            "font-semibold bg-[#1e2a38] text-[#fdfaf5]";
          label1.className = "text-[12px] font-medium text-[#1e2a38]";

          dot2.className =
            "w-6 h-6 rounded-full flex items-center justify-center text-[11px] " +
            "font-semibold bg-[#1e2a38] text-[#fdfaf5]";
          label2.className = "text-[12px] font-medium text-[#1e2a38]";
        }
      }

      function canGoToStep2() {
        const name = document.getElementById("name");
        const email = document.getElementById("email");
        const password = document.getElementById("password");

        let ok = true;
        [name, email, password].forEach(field => {
          if (field && !field.value.trim()) {
            ok = false;
            field.classList.add("ring-1", "ring-rose-400", "border-rose-300");
          } else {
            field.classList.remove("ring-1", "ring-rose-400", "border-rose-300");
          }
        });

        return ok;
      }

      if (nextBtn) {
        nextBtn.addEventListener("click", function () {
          if (currentStep === 1) {
            if (!canGoToStep2()) return;
            setStep(2);
          } else {
            // On step 2: submit explicitly
            if (form) form.submit();
          }
        });
      }

      if (backBtn) {
        backBtn.addEventListener("click", function (e) {
          e.preventDefault();
          setStep(1);
        });
      }

      setStep(1);
    });
  </script>
</head>

<body class="page-shell min-h-screen text-[#1e2a38]">
  <%@ include file = "../includes/header.jsp"%>

  <main class="pt-28 pb-20">
    <div class="max-w-7xl mx-auto px-6 md:px-8">
      <div class="grid md:grid-cols-2 gap-12 lg:gap-16 items-start">

        <!-- Left side copy -->
        <section class="space-y-4 md:space-y-5">
          <p class="text-[11px] tracking-[0.18em] uppercase text-slate-500">
            SilverCare platform
          </p>

          <h1 class="text-[26px] md:text-[30px] font-serif font-semibold tracking-tight text-[#1e2a38]">
            Create a SilverCare account.
          </h1>

          <div class="accent-line"></div>

          <p class="max-w-md text-[14px] leading-relaxed text-slate-700">
            We’ve split registration into two light steps so you can breeze
            through your details without feeling overwhelmed.
          </p>

          <p class="max-w-md text-[13px] leading-relaxed text-slate-600">
            Step 1 sets up your account and contact details. Step 2 stores your
            address so bookings and services stay consistent.
          </p>
        </section>

        <!-- Right side: multi-step card -->
        <section class="flex justify-center md:justify-end">
          <div class="w-full max-w-xl card-appear
                      rounded-[24px] bg-[#fdfaf5]
                      border border-[#e0dcd4]
                      shadow-[0_14px_40px_rgba(15,23,42,0.10)]
                      px-6 py-6 md:px-7 md:py-7">

            <!-- Small pill -->
            <span class="inline-flex items-center rounded-full
                         border border-[#e0dcd4]
                         bg-[#faf6ef]
                         px-3 py-1 mb-3
                         text-[11px] uppercase tracking-[0.18em]
                         text-slate-600">
              Register
            </span>

            <!-- Header -->
            <header class="space-y-1.5 mb-4">
              <h2 class="text-[20px] md:text-[21px] font-semibold tracking-tight text-[#1e2a38]">
                Personal details
              </h2>
              <p class="text-[12.5px] text-slate-600 leading-relaxed">
                We’ll use this information to contact you about bookings and services.
                All fields are required unless stated otherwise.
              </p>
            </header>

            <!-- Step indicator -->
            <div class="mb-4">
              <div class="flex items-center gap-3">
                <div class="flex items-center gap-2">
                  <div id="dot-step-1"
                       class="w-6 h-6 rounded-full flex items-center justify-center text-[11px] font-semibold">
                    1
                  </div>
                  <span id="label-step-1"
                        class="text-[12px] font-medium">
                    Account
                  </span>
                </div>
                <div class="flex-1 h-px bg-[#e0dcd4]"></div>
                <div class="flex items-center gap-2">
                  <div id="dot-step-2"
                       class="w-6 h-6 rounded-full flex items-center justify-center text-[11px] font-semibold">
                    2
                  </div>
                  <span id="label-step-2"
                        class="text-[12px] font-medium">
                    Address
                  </span>
                </div>
              </div>
              <p id="stepHelperText"
                 class="mt-2 text-[11.5px] text-slate-500 tracking-wide uppercase">
                Step 1 of 2 · Account & contact
              </p>
            </div>

            <!-- Error message -->
            <%
              if (errText != null && !errText.trim().isEmpty()) {
            %>
              <div class="mb-4 rounded-[18px] border border-rose-200 bg-rose-50/80
                          px-4 py-2.5 text-[12px] text-rose-700">
                <%= errText %>
              </div>
            <%
              }
            %>

            <!-- Form -->
            <form id="registerForm"
                  method="post"
                  action="<%= request.getContextPath() %>/customersServlet"
                  class="space-y-6">
              <input type="hidden" name="action" value="create">
              <input type="hidden" name="origin" value="public/login.jsp">

              <!-- STEP 1: Account & contact -->
              <div id="step-1" class="space-y-5">
                <div class="grid md:grid-cols-2 gap-4">
                  <div class="space-y-1">
                    <label for="name"
                           class="block text-[12.5px] font-medium text-slate-700">
                      Full name
                    </label>
                    <input type="text"
                           id="name"
                           name="name"
                           class="w-full rounded-[14px]
                                  border border-[#ddd5c7]
                                  bg-[#fbf7f1]
                                  px-3 py-2.5 text-[13px]
                                  text-slate-900 placeholder:text-slate-400
                                  outline-none
                                  focus:border-[#1e2a38]
                                  focus:ring-1 focus:ring-[#1e2a38]
                                  transition-all duration-200"
                           placeholder="Jane Tan">
                  </div>

                  <div class="space-y-1">
                    <label for="email"
                           class="block text-[12.5px] font-medium text-slate-700">
                      Email address
                    </label>
                    <input type="email"
                           id="email"
                           name="email"
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
                </div>

                <div class="space-y-1">
                  <label for="password"
                         class="block text-[12.5px] font-medium text-slate-700">
                    Password
                  </label>
                  <input type="password"
                         id="password"
                         name="password"
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

                <div class="grid md:grid-cols-[1.2fr_1fr] gap-4">
                  <div class="space-y-1">
                    <label class="block text-[12.5px] font-medium text-slate-700">
                      Country
                    </label>
                    <div class="custom-dropdown">
                      <div class="selected">
                        <span class="placeholder">Select country</span>
                      </div>
                      <div class="dropdown-list">
                        <%
                          if (countryList != null) {
                              for (int c = 0; c < countryList.size(); c++) {
                        %>
                        <div class="dropdown-item"
                             data-id="<%= countryList.get(c).getId() %>"
                             data-code="<%= countryList.get(c).getCountryCode() %>"
                             data-name="<%= countryList.get(c).getCountryName() %>"
                             data-image="<%= countryList.get(c).getFlagImage() %>">
                          <img src="<%= request.getContextPath() %>/images/flags/<%= countryList.get(c).getFlagImage() %>"
                               alt="<%= countryList.get(c).getCountryName() %>"
                               width="20"
                               class="rounded-sm">
                          <span>
                            +<%= countryList.get(c).getCountryCode() %>
                            <%= countryList.get(c).getCountryName() %>
                          </span>
                        </div>
                        <%
                              }
                          }
                        %>
                      </div>
                      <input type="hidden" name="country" id="countryInput">
                    </div>
                  </div>

                  <div class="space-y-1">
                    <label for="Phone"
                           class="block text-[12.5px] font-medium text-slate-700">
                      Phone
                    </label>
                    <input type="number"
                           id="Phone"
                           name="Phone"
                           class="w-full rounded-[14px]
                                  border border-[#ddd5c7]
                                  bg-[#fbf7f1]
                                  px-3 py-2.5 text-[13px]
                                  text-slate-900 placeholder:text-slate-400
                                  outline-none
                                  focus:border-[#1e2a38]
                                  focus:ring-1 focus:ring-[#1e2a38]
                                  transition-all duration-200"
                           placeholder="81234567">
                  </div>
                </div>
              </div>

              <!-- STEP 2: Address -->
              <div id="step-2" class="space-y-4 hidden">
                <div class="space-y-1">
                  <label for="Street"
                         class="block text-[12.5px] font-medium text-slate-700">
                    Street
                  </label>
                  <input type="text"
                         id="Street"
                         name="Street"
                         class="w-full rounded-[14px]
                                border border-[#ddd5c7]
                                bg-[#fbf7f1]
                                px-3 py-2.5 text-[13px]
                                text-slate-900 placeholder:text-slate-400
                                outline-none
                                focus:border-[#1e2a38]
                                focus:ring-1 focus:ring-[#1e2a38]
                                transition-all duration-200"
                         placeholder="123 Harmony Avenue">
                </div>

                <div class="grid md:grid-cols-3 gap-4">
                  <div class="space-y-1">
                    <label for="postal_code"
                           class="block text-[12.5px] font-medium text-slate-700">
                      Postal code
                    </label>
                    <input type="text"
                           id="postal_code"
                           name="postal_code"
                           class="w-full rounded-[14px]
                                  border border-[#ddd5c7]
                                  bg-[#fbf7f1]
                                  px-3 py-2.5 text-[13px]
                                  text-slate-900 placeholder:text-slate-400
                                  outline-none
                                  focus:border-[#1e2a38]
                                  focus:ring-1 focus:ring-[#1e2a38]
                                  transition-all duration-200"
                           placeholder="123456">
                  </div>

                  <div class="space-y-1">
                    <label for="block_no"
                           class="block text-[12.5px] font-medium text-slate-700">
                      Block no.
                    </label>
                    <input type="text"
                           id="block_no"
                           name="block_no"
                           class="w-full rounded-[14px]
                                  border border-[#ddd5c7]
                                  bg-[#fbf7f1]
                                  px-3 py-2.5 text-[13px]
                                  text-slate-900 placeholder:text-slate-400
                                  outline-none
                                  focus:border-[#1e2a38]
                                  focus:ring-1 focus:ring-[#1e2a38]
                                  transition-all duration-200"
                           placeholder="123A">
                  </div>

                  <div class="space-y-1">
                    <label for="unit_no"
                           class="block text-[12.5px] font-medium text-slate-700">
                      Unit no.
                    </label>
                    <input type="text"
                           id="unit_no"
                           name="unit_no"
                           class="w-full rounded-[14px]
                                  border border-[#ddd5c7]
                                  bg-[#fbf7f1]
                                  px-3 py-2.5 text-[13px]
                                  text-slate-900 placeholder:text-slate-400
                                  outline-none
                                  focus:border-[#1e2a38]
                                  focus:ring-1 focus:ring-[#1e2a38]
                                  transition-all duration-200"
                           placeholder="#01-01">
                  </div>
                </div>

                <div class="grid md:grid-cols-2 gap-4">
                  <div class="space-y-1">
                    <label for="building_name"
                           class="block text-[12.5px] font-medium text-slate-700">
                      Building name
                    </label>
                    <input type="text"
                           id="building_name"
                           name="building_name"
                           class="w-full rounded-[14px]
                                  border border-[#ddd5c7]
                                  bg-[#fbf7f1]
                                  px-3 py-2.5 text-[13px]
                                  text-slate-900 placeholder:text-slate-400
                                  outline-none
                                  focus:border-[#1e2a38]
                                  focus:ring-1 focus:ring-[#1e2a38]
                                  transition-all duration-200"
                           placeholder="Optional">
                  </div>

                  <div class="space-y-1">
                    <label for="city"
                           class="block text-[12.5px] font-medium text-slate-700">
                      City
                    </label>
                    <input type="text"
                           id="city"
                           name="city"
                           class="w-full rounded-[14px]
                                  border border-[#ddd5c7]
                                  bg-[#fbf7f1]
                                  px-3 py-2.5 text-[13px]
                                  text-slate-900 placeholder:text-slate-400
                                  outline-none
                                  focus:border-[#1e2a38]
                                  focus:ring-1 focus:ring-[#1e2a38]
                                  transition-all duration-200"
                           placeholder="Singapore">
                  </div>
                </div>

                <div class="grid md:grid-cols-2 gap-4">
                  <div class="space-y-1">
                    <label for="state"
                           class="block text-[12.5px] font-medium text-slate-700">
                      State / region
                    </label>
                    <input type="text"
                           id="state"
                           name="state"
                           class="w-full rounded-[14px]
                                  border border-[#ddd5c7]
                                  bg-[#fbf7f1]
                                  px-3 py-2.5 text-[13px]
                                  text-slate-900 placeholder:text-slate-400
                                  outline-none
                                  focus:border-[#1e2a38]
                                  focus:ring-1 focus:ring-[#1e2a38]
                                  transition-all duration-200"
                           placeholder="Optional">
                  </div>

                  <div class="space-y-1">
                    <label for="address_line2"
                           class="block text-[12.5px] font-medium text-slate-700">
                      Address line 2
                    </label>
                    <input type="text"
                           id="address_line2"
                           name="address_line2"
                           class="w-full rounded-[14px]
                                  border border-[#ddd5c7]
                                  bg-[#fbf7f1]
                                  px-3 py-2.5 text-[13px]
                                  text-slate-900 placeholder:text-slate-400
                                  outline-none
                                  focus:border-[#1e2a38]
                                  focus:ring-1 focus:ring-[#1e2a38]
                                  transition-all duration-200"
                           placeholder="Optional">
                  </div>
                </div>
              </div>

              <!-- Buttons -->
              <div class="pt-1 flex flex-col gap-3">
                <div class="flex items-center justify-between gap-3">
                  <button id="backStepBtn"
                          type="button"
                          class="hidden px-4 py-2.5 rounded-full
                                 border border-[#ddd5c7]
                                 bg-transparent
                                 text-[13px] font-medium text-slate-700
                                 hover:bg-[#f4ede3]
                                 active:scale-[0.99]
                                 transition-all duration-200">
                    Back
                  </button>

                  <button id="nextStepBtn"
                          type="button"
                          class="flex-1 inline-flex items-center justify-center
                                 rounded-full bg-[#1e2a38] text-[#fdfaf5]
                                 text-[14px] font-medium
                                 px-4 py-3.5
                                 shadow-[0_14px_36px_rgba(15,23,42,0.32)]
                                 hover:bg-[#253447]
                                 active:scale-[0.99]
                                 transition-all duration-200">
                    <span id="primaryButtonLabel">Next step</span>
                  </button>
                </div>

                <p class="text-[12px] text-slate-600 text-center">
                  Already have an account?
                  <a href="<%= request.getContextPath() %>/public/login.jsp"
                     class="font-medium text-[#1e2a38] underline underline-offset-4">
                    Log in instead
                  </a>
                </p>
              </div>
            </form>
          </div>
        </section>
      </div>
    </div>
  </main>

  <%@ include file = "../includes/footer.jsp"%>
</body>
</html>