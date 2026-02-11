<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
  import="java.util.*,Assignment1.Customer.Customer, Assignment1.Country" %>
  <!DOCTYPE html>
  <html lang="en">

  <head>
    <meta charset="UTF-8">
    <title>Edit Profile – SilverCare</title>

    <% String errText="" ; 
    String errCode=request.getParameter("errCode"); 
    if (errCode !=null) { errText=errCode; }
    // Password messages from servlet String 
    pwdError=request.getParameter("error"); 
    String pwdSuccess=request.getParameter("success");
    Customer u=(Customer) 
    session.getAttribute("user"); 
    ArrayList<Country>
    countryList = (ArrayList<Country>) session.getAttribute("countryList");

        if (u == null) {
        response.sendRedirect(request.getContextPath() + "/customersServlet?action=retrieveUser");
        return;
        }
        if (countryList == null) {
        response.sendRedirect(request.getContextPath() + "/countryCodeServlet?origin=profile/edit");
        return;
        }

        // Find the flag image for this user's country_id (for dropdown default)
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
            background: linear-gradient(to bottom,
                #f6f1e9 0%,
                #f9f4ec 45%,
                #faf7f1 100%);
          }

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

          /* Country dropdown */
          .custom-dropdown {
            position: relative;
            width: 100%;
            user-select: none;
            font-size: 13px;
          }

          .custom-dropdown .selected {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border-radius: 14px;
            border: 1px solid #ddd5c7;
            background-color: #fbf7f1;
            padding: 10px 12px;
            cursor: pointer;
            color: #0f172a;
            min-height: 42px;
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

          .profile-label {
            font-size: 12.5px;
            letter-spacing: 0.08em;
          }
        </style>
  </head>

  <body class="page-shell min-h-screen text-[#1e2a38]">
    <%@ include file="../includes/header.jsp" %>

      <main class="pt-28 pb-20">
        <div class="max-w-5xl mx-auto px-6 md:px-8">

          <!-- Page heading -->
          <section class="mb-6 md:mb-8">
            <p class="text-[11px] tracking-[0.18em] uppercase text-slate-500">
              SilverCare account
            </p>
            <h1 class="mt-1 text-[26px] md:text-[30px] font-serif font-semibold tracking-tight text-[#1e2a38]">
              Edit profile
            </h1>
            <div class="mt-3 accent-line"></div>
          </section>

          <!-- Global error (profile update) -->
          <% if (errText !=null && !errText.trim().isEmpty()) { %>
            <div class="mb-5  border border-rose-200 bg-rose-50/85
                    px-4 py-2.5 text-[12.5px] text-rose-700">
              <%= errText %>
            </div>
            <% } %>

              <!-- Profile card -->
              <section class="card-appear  bg-[#fdfaf5]
                      border border-[#e0dcd4]
                      shadow-[0_14px_40px_rgba(15,23,42,0.10)]
                      px-6 py-6 md:px-8 md:py-7">

                <header class="mb-5 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                  <div>
                    <h2 class="text-[20px] md:text-[22px] font-semibold tracking-tight text-[#1e2a38]">
                      <%= u.getFullName() %>
                    </h2>
                    <p class="text-[13px] text-slate-600 mt-1">
                      Update your contact details and address for future bookings.
                    </p>
                  </div>
                </header>

                <div class="border-t border-[#e4dfd6] pt-5">
                  <form method="post" action="<%= request.getContextPath() %>/customersServlet" class="space-y-6">
                    <input type="hidden" name="action" value="update" />

                    <!-- Name + email -->
                    <div class="grid md:grid-cols-2 gap-4">
                      <div class="space-y-1">
                        <label for="name" class="profile-label block text-[11px] uppercase text-slate-500">
                          Full name
                        </label>
                        <input type="text" id="name" name="name" value="<%= u.getFullName() %>" class="w-full 
                              border border-[#ddd5c7]
                              bg-[#fbf7f1]
                              px-3 py-2.5 text-[13px]
                              text-slate-900
                              outline-none
                              focus:border-[#1e2a38]
                              focus:ring-1 focus:ring-[#1e2a38]
                              transition-all duration-200" required />
                      </div>

                      <div class="space-y-1">
                        <label for="email" class="profile-label block text-[11px] uppercase text-slate-500">
                          Email
                        </label>
                        <input type="email" id="email" name="email" value="<%= u.getEmail() %>" class="w-full 
                              border border-[#ddd5c7]
                              bg-[#fbf7f1]
                              px-3 py-2.5 text-[13px]
                              text-slate-900
                              outline-none
                              focus:border-[#1e2a38]
                              focus:ring-1 focus:ring-[#1e2a38]
                              transition-all duration-200" required />
                      </div>
                    </div>

                    <!-- Phone + country -->
                    <div class="grid md:grid-cols-[1.1fr_1.1fr] gap-4">
                      <div class="space-y-1">
                        <label for="phone" class="profile-label block text-[11px] uppercase text-slate-500">
                          Phone
                        </label>
                        <input type="text" id="phone" name="Phone" value="<%= u.getPhone() %>" class="w-full 
                              border border-[#ddd5c7]
                              bg-[#fbf7f1]
                              px-3 py-2.5 text-[13px]
                              text-slate-900
                              outline-none
                              focus:border-[#1e2a38]
                              focus:ring-1 focus:ring-[#1e2a38]
                              transition-all duration-200" />
                      </div>

                      <div class="space-y-1">
                        <span class="profile-label block text-[11px] uppercase text-slate-500">
                          Country
                        </span>
                        <div class="custom-dropdown">
                          <div class="selected">
                            <% if (userFlagImage !=null) { for (Country c : countryList) { if
                              (c.getId()==u.getCountryId()) { %>
                              <img src="<%= request.getContextPath() %>/images/flags/<%= c.getFlagImage() %>" width="22"
                                style="margin-right:8px;vertical-align:middle;">
                              +<%= c.getCountryCode() %>
                                <%= c.getCountryName() %>
                                  <% break; } } } else { %>
                                    Select country
                                    <% } %>
                          </div>
                          <div class="dropdown-list">
                            <% for (Country c : countryList) { %>
                              <div class="dropdown-item" data-id="<%= c.getId() %>"
                                data-code="<%= c.getCountryCode() %>" data-name="<%= c.getCountryName() %>"
                                data-image="<%= c.getFlagImage() %>">
                                <img src="<%= request.getContextPath() %>/images/flags/<%= c.getFlagImage() %>"
                                  alt="<%= c.getCountryName() %>" width="20" style="margin-right:8px;">
                                +<%= c.getCountryCode() %>
                                  <%= c.getCountryName() %>
                              </div>
                              <% } %>
                          </div>
                          <input type="hidden" name="country" id="countryInput" value="<%= u.getCountryId() %>">
                        </div>
                      </div>
                    </div>

                    <!-- Street -->
                    <div class="space-y-1">
                      <label for="street" class="profile-label block text-[11px] uppercase text-slate-500">
                        Street
                      </label>
                      <input type="text" id="street" name="Street" value="<%= u.getStreet() %>" class="w-full 
                            border border-[#ddd5c7]
                            bg-[#fbf7f1]
                            px-3 py-2.5 text-[13px]
                            text-slate-900
                            outline-none
                            focus:border-[#1e2a38]
                            focus:ring-1 focus:ring-[#1e2a38]
                            transition-all duration-200" />
                    </div>

                    <!-- Postal / block / unit -->
                    <div class="grid md:grid-cols-3 gap-4">
                      <div class="space-y-1">
                        <label for="postal_code" class="profile-label block text-[11px] uppercase text-slate-500">
                          Postal code
                        </label>
                        <input type="text" id="postal_code" name="postal_code" value="<%= u.getPostalCode() %>" class="w-full 
                              border border-[#ddd5c7]
                              bg-[#fbf7f1]
                              px-3 py-2.5 text-[13px]
                              text-slate-900
                              outline-none
                              focus:border-[#1e2a38]
                              focus:ring-1 focus:ring-[#1e2a38]
                              transition-all duration-200" />
                      </div>

                      <div class="space-y-1">
                        <label for="block_no" class="profile-label block text-[11px] uppercase text-slate-500">
                          Block no.
                        </label>
                        <input type="text" id="block_no" name="block_no" value="<%= u.getBlockNo() %>" class="w-full 
                              border border-[#ddd5c7]
                              bg-[#fbf7f1]
                              px-3 py-2.5 text-[13px]
                              text-slate-900
                              outline-none
                              focus:border-[#1e2a38]
                              focus:ring-1 focus:ring-[#1e2a38]
                              transition-all duration-200" />
                      </div>

                      <div class="space-y-1">
                        <label for="unit_no" class="profile-label block text-[11px] uppercase text-slate-500">
                          Unit no.
                        </label>
                        <input type="text" id="unit_no" name="unit_no" value="<%= u.getUnitNo() %>" class="w-full 
                              border border-[#ddd5c7]
                              bg-[#fbf7f1]
                              px-3 py-2.5 text-[13px]
                              text-slate-900
                              outline-none
                              focus:border-[#1e2a38]
                              focus:ring-1 focus:ring-[#1e2a38]
                              transition-all duration-200" />
                      </div>
                    </div>

                    <!-- Save button -->
                    <div class="pt-2 flex justify-end">
                      <button type="submit" class="inline-flex items-center justify-center
                              bg-[#1e2a38] text-[#fdfaf5]
                             text-[14px] font-medium
                             px-5 py-3.5
                             shadow-[0_14px_36px_rgba(15,23,42,0.32)]
                             hover:bg-[#253447]
                             active:scale-[0.99]
                             transition-all duration-200">
                        Save changes
                      </button>
                    </div>
                  </form>
                </div>
              </section>

              <!-- Security / change password card -->
              <section class="mt-6  bg-[#fdfaf5]
                      border border-[#e0dcd4]
                      shadow-[0_10px_30px_rgba(15,23,42,0.08)]
                      px-6 py-6 md:px-8 md:py-7">
                <header class="mb-3">
                  <h2 class="text-[18px] md:text-[20px] font-semibold tracking-tight text-[#1e2a38]">
                    Password & security
                  </h2>
                  <p class="text-[13px] text-slate-600 mt-1">
                    Change your account password. You’ll need your current password to confirm this change.
                  </p>
                </header>

                <!-- Password messages -->
                <% if (pwdError !=null && !pwdError.trim().isEmpty()) { %>
                  <div class="mb-4  border border-rose-200 bg-rose-50/90
                      px-4 py-2.5 text-[12.5px] text-rose-700">
                    <%= pwdError %>
                  </div>
                  <% } else if (pwdSuccess !=null && !pwdSuccess.trim().isEmpty()) { %>
                    <div class="mb-4  border border-emerald-200 bg-emerald-50/90
                      px-4 py-2.5 text-[12.5px] text-emerald-800">
                      <%= pwdSuccess %>
                    </div>
                    <% } %>

                      <form method="post" action="<%= request.getContextPath() %>/customersServlet"
                        class="space-y-4 max-w-md">
                        <input type="hidden" name="action" value="password" />

                        <div class="space-y-1">
                          <label for="oldPassword" class="profile-label block text-[11px] uppercase text-slate-500">
                            Current password
                          </label>
                          <input type="password" id="oldPassword" name="oldPassword" class="w-full 
                          border border-[#ddd5c7]
                          bg-[#fbf7f1]
                          px-3 py-2.5 text-[13px]
                          text-slate-900
                          outline-none
                          focus:border-[#1e2a38]
                          focus:ring-1 focus:ring-[#1e2a38]
                          transition-all duration-200" required />
                        </div>

                        <div class="space-y-1">
                          <label for="newPassword" class="profile-label block text-[11px] uppercase text-slate-500">
                            New password
                          </label>
                          <input type="password" id="newPassword" name="newPassword" class="w-full 
                          border border-[#ddd5c7]
                          bg-[#fbf7f1]
                          px-3 py-2.5 text-[13px]
                          text-slate-900
                          outline-none
                          focus:border-[#1e2a38]
                          focus:ring-1 focus:ring-[#1e2a38]
                          transition-all duration-200" required />
                        </div>

                        <div class="space-y-1">
                          <label for="confirmPassword" class="profile-label block text-[11px] uppercase text-slate-500">
                            Confirm new password
                          </label>
                          <input type="password" id="confirmPassword" name="confirmPassword" class="w-full 
                          border border-[#ddd5c7]
                          bg-[#fbf7f1]
                          px-3 py-2.5 text-[13px]
                          text-slate-900
                          outline-none
                          focus:border-[#1e2a38]
                          focus:ring-1 focus:ring-[#1e2a38]
                          transition-all duration-200" required />
                        </div>

                        <div class="pt-1 flex justify-start">
                          <button type="submit" class="inline-flex items-center justify-center
                            bg-[#1e2a38] text-[#fdfaf5]
                           text-[13px] font-medium
                           px-5 py-2.5
                           shadow-[0_12px_30px_rgba(15,23,42,0.28)]
                           hover:bg-[#253447]
                           active:scale-[0.99]
                           transition-all duration-200">
                            Update password
                          </button>
                        </div>
                      </form>
              </section>

              <!-- Danger zone: delete account -->
              <section class="mt-6  border border-[#ecd9d6] bg-[#fdf4f3] px-6 py-4 md:px-7 md:py-5">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                  <div>
                    <h3 class="text-[14px] font-semibold text-[#7f1d1d]">
                      Delete account
                    </h3>
                    <p class="text-[12.5px] text-[#7f1d1d] mt-1">
                      This will permanently remove your SilverCare account and all associated data.
                      This action cannot be undone.
                    </p>
                  </div>
                  <form method="get" action="<%= request.getContextPath() %>/profile/delete">
                    <button type="submit" class="inline-flex items-center justify-center
                            border border-[#fca5a5]
                           bg-[#fee2e2]
                           px-4 py-2.5 text-[13px] font-medium text-[#991b1b]
                           hover:bg-[#fecaca]
                           active:scale-[0.99]
                           transition-all duration-200">
                      Delete account
                    </button>
                  </form>
                </div>
              </section>

        </div>
      </main>

      <%@ include file="../includes/footer.jsp" %>

        <script>
          document.addEventListener("DOMContentLoaded", function () {
            const dropdown = document.querySelector(".custom-dropdown");
            if (!dropdown) return;

            const selected = dropdown.querySelector(".selected");
            const dropdownList = dropdown.querySelector(".dropdown-list");
            const hiddenInput = document.getElementById("countryInput");

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
                const flagImage = item.getAttribute("data-image");

                selected.innerHTML =
                  '<img src="<%= request.getContextPath() %>/images/flags/' +
                  flagImage +
                  '" width="22" style="margin-right:8px;vertical-align:middle;">' +
                  '+' + code + ' ' + name;

                hiddenInput.value = id;
                dropdownList.style.display = "none";
              });
            });

            document.addEventListener("click", function (e) {
              if (!dropdown.contains(e.target)) {
                dropdownList.style.display = "none";
              }
            });
          });
        </script>
  </body>

  </html>