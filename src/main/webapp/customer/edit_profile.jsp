<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*,Assignment1.Customer.Customer, Assignment1.Country" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile – SilverCare</title>

    <%
        String errText = "";
        String errCode = request.getParameter("errCode");
        if (errCode != null) { errText = errCode; }
        
        String pwdError = request.getParameter("error");
        String pwdSuccess = request.getParameter("success");
        
        Customer u = (Customer) session.getAttribute("user");
        ArrayList<Country> countryList = (ArrayList<Country>) session.getAttribute("countryList");

        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/customersServlet?action=retrieveUser");
            return;
        }
        if (countryList == null) {
            response.sendRedirect(request.getContextPath() + "/countryCodeServlet?origin=profile/edit");
            return;
        }

        String userFlagImage = null;
        String userCountryName = "";
        int userCountryCode = 0;
        for (Country c : countryList) {
            if (c.getId() == u.getCountryId()) {
                userFlagImage = c.getFlagImage();
                userCountryName = c.getCountryName();
                userCountryCode = c.getCountryCode();
                break;
            }
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
        position: fixed;
        inset: 0;
        background: #f5f3ef;
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        transition: opacity 0.5s ease, visibility 0.5s ease;
    }
    .loader.hidden { opacity: 0; visibility: hidden; }
    .loader-bar {
        width: 120px;
        height: 2px;
        background: #e8e4dc;
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

    .input-field {
        transition: border-color 0.2s ease;
    }
    .input-field:focus {
        border-color: #2c2c2c;
    }

    .custom-dropdown {
        position: relative;
        width: 100%;
        user-select: none;
    }
    .custom-dropdown .selected {
        display: flex;
        align-items: center;
        gap: 10px;
        border: 1px solid #e8e4dc;
        background-color: white;
        padding: 12px 16px;
        cursor: pointer;
        color: #2c2c2c;
        min-height: 48px;
        transition: border-color 0.2s;
    }
    .custom-dropdown .selected:hover {
        border-color: #2c2c2c;
    }
    .custom-dropdown .dropdown-list {
        position: absolute;
        top: calc(100% + 4px);
        left: 0;
        right: 0;
        border: 1px solid #e8e4dc;
        max-height: 240px;
        overflow-y: auto;
        background-color: white;
        display: none;
        z-index: 100;
        box-shadow: 0 12px 32px rgba(44, 44, 44, 0.12);
    }
    .custom-dropdown .dropdown-item {
        padding: 10px 16px;
        display: flex;
        align-items: center;
        gap: 10px;
        cursor: pointer;
        color: #2c2c2c;
        font-size: 14px;
        transition: background-color 0.15s;
    }
    .custom-dropdown .dropdown-item:hover {
        background-color: #f5f3ef;
    }

    .card-section {
        transition: transform 0.2s ease;
    }
    .card-section:hover {
        transform: translateY(-1px);
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
        <div class="max-w-3xl mx-auto">

            <!-- Page Header -->
            <header class="mb-10">
                <span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Account Settings</span>
                <h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-3 mb-4 stagger-2">
                    Edit Profile
                </h1>
                <p class="text-ink-light text-base max-w-xl leading-relaxed stagger-3">
                    Update your personal information and address details used for care service bookings.
                </p>
            </header>

            <!-- Global Error -->
            <% if (errText != null && !errText.trim().isEmpty()) { %>
            <div class="mb-6 border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700 stagger-3">
                <div class="flex items-center gap-3">
                    <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                    </svg>
                    <%= errText %>
                </div>
            </div>
            <% } %>

            <!-- Profile Information Card -->
            <section class="card-section bg-white border border-stone-mid mb-6 stagger-3">
                <div class="px-6 py-5 border-b border-stone-mid">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 bg-stone-mid flex items-center justify-center">
                            <span class="font-serif text-xl text-ink"><%= u.getName().substring(0, 1).toUpperCase() %></span>
                        </div>
                        <div>
                            <h2 class="font-serif text-xl font-medium text-ink"><%= u.getName() %></h2>
                            <p class="text-sm text-ink-muted"><%= u.getEmail() %></p>
                        </div>
                    </div>
                </div>

                <form method="post" action="<%= request.getContextPath() %>/customersServlet" class="p-6 space-y-6">
                    <input type="hidden" name="action" value="update" />

                    <!-- Name + Email -->
                    <div class="grid md:grid-cols-2 gap-5">
                        <div>
                            <label for="name" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                Full Name <span class="text-copper">*</span>
                            </label>
                            <input type="text" id="name" name="name" value="<%= u.getName() %>" required
                                   class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                        </div>
                        <div>
                            <label for="email" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                Email Address <span class="text-copper">*</span>
                            </label>
                            <input type="email" id="email" name="email" value="<%= u.getEmail() %>" required
                                   class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                        </div>
                    </div>

                    <!-- Phone + Country -->
                    <div class="grid md:grid-cols-2 gap-5">
                        <div>
                            <label for="phone" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                Phone Number
                            </label>
                            <input type="text" id="phone" name="Phone" value="<%= u.getPhone() %>"
                                   class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                        </div>
                        <div>
                            <label class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                Country
                            </label>
                            <div class="custom-dropdown">
                                <div class="selected">
                                    <% if (userFlagImage != null) { %>
                                        <img src="<%= request.getContextPath() %>/images/flags/<%= userFlagImage %>" width="20" alt="">
                                        <span>+<%= userCountryCode %> <%= userCountryName %></span>
                                    <% } else { %>
                                        <span class="text-ink-muted">Select country</span>
                                    <% } %>
                                    <svg class="w-4 h-4 ml-auto text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 9l-7 7-7-7"/>
                                    </svg>
                                </div>
                                <div class="dropdown-list">
                                    <% for (Country c : countryList) { %>
                                    <div class="dropdown-item" data-id="<%= c.getId() %>" data-code="<%= c.getCountryCode() %>" data-name="<%= c.getCountryName() %>" data-image="<%= c.getFlagImage() %>">
                                        <img src="<%= request.getContextPath() %>/images/flags/<%= c.getFlagImage() %>" width="20" alt="<%= c.getCountryName() %>">
                                        +<%= c.getCountryCode() %> <%= c.getCountryName() %>
                                    </div>
                                    <% } %>
                                </div>
                                <input type="hidden" name="country" id="countryInput" value="<%= u.getCountryId() %>">
                            </div>
                        </div>
                    </div>

                    <!-- Street -->
                    <div>
                        <label for="street" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                            Street Address
                        </label>
                        <input type="text" id="street" name="Street" value="<%= u.getStreet() %>"
                               class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                    </div>

                    <!-- Postal / Block / Unit -->
                    <div class="grid md:grid-cols-3 gap-5">
                        <div>
                            <label for="postal_code" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                Postal Code
                            </label>
                            <input type="text" id="postal_code" name="postal_code" value="<%= u.getPostalCode() != null ? u.getPostalCode() : "" %>"
                                   class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                        </div>
                        <div>
                            <label for="block_no" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                Block No.
                            </label>
                            <input type="text" id="block_no" name="block_no" value="<%= u.getBlock() != null ? u.getBlock() : "" %>"
                                   class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                        </div>
                        <div>
                            <label for="unit_no" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                Unit No.
                            </label>
                            <input type="text" id="unit_no" name="unit_no" value="<%= u.getUnitNumber() != null ? u.getUnitNumber() : "" %>"
                                   class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                        </div>
                    </div>

                    <!-- Personal Information -->
                    <div class="pt-4 border-t border-stone-mid">
                        <h3 class="text-xs uppercase tracking-wide text-ink-muted mb-4">Personal Information</h3>
                        
                        <div class="grid md:grid-cols-2 gap-5">
                            <div>
                                <label for="date_of_birth" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                    Date of Birth
                                </label>
                                <input type="date" id="date_of_birth" name="date_of_birth" 
                                       value="<%= u.getDateOfBirth() != null ? u.getDateOfBirth() : "" %>"
                                       class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                            </div>
                            <div>
                                <label for="gender" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                    Gender
                                </label>
                                <select id="gender" name="gender"
                                        class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                                    <option value="">Select gender</option>
                                    <option value="Male" <%= "Male".equals(u.getGender()) ? "selected" : "" %>>Male</option>
                                    <option value="Female" <%= "Female".equals(u.getGender()) ? "selected" : "" %>>Female</option>
                                    <option value="Other" <%= "Other".equals(u.getGender()) ? "selected" : "" %>>Other</option>
                                    <option value="Prefer not to say" <%= "Prefer not to say".equals(u.getGender()) ? "selected" : "" %>>Prefer not to say</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Emergency Contact -->
                    <div class="pt-4 border-t border-stone-mid">
                        <h3 class="text-xs uppercase tracking-wide text-ink-muted mb-4">Emergency Contact</h3>
                        
                        <div class="grid md:grid-cols-2 gap-5">
                            <div>
                                <label for="emergency_contact_name" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                    Contact Name
                                </label>
                                <input type="text" id="emergency_contact_name" name="emergency_contact_name" 
                                       value="<%= u.getEmergencyContactName() != null ? u.getEmergencyContactName() : "" %>"
                                       placeholder="e.g. John Smith (Son)"
                                       class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                            </div>
                            <div>
                                <label for="emergency_contact_phone" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                    Contact Phone
                                </label>
                                <input type="tel" id="emergency_contact_phone" name="emergency_contact_phone" 
                                       value="<%= u.getEmergencyContactPhone() != null ? u.getEmergencyContactPhone() : "" %>"
                                       placeholder="+65 9123 4567"
                                       class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                            </div>
                        </div>
                    </div>

                    <!-- Medical & Care Information -->
                    <div class="pt-4 border-t border-stone-mid">
                        <h3 class="text-xs uppercase tracking-wide text-ink-muted mb-4">Medical & Care Information</h3>
                        
                        <div class="space-y-5">
                            <div>
                                <label for="medical_notes" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                    Medical Notes
                                </label>
                                <textarea id="medical_notes" name="medical_notes" rows="4"
                                          placeholder="Any medical conditions, allergies, medications, or health considerations our caregivers should know about..."
                                          class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none resize-none"><%= u.getMedicalNotes() != null ? u.getMedicalNotes() : "" %></textarea>
                                <p class="text-xs text-ink-muted mt-1">This information helps our caregivers provide better care.</p>
                            </div>

                            <div>
                                <label for="care_preferences" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                    Care Preferences
                                </label>
                                <textarea id="care_preferences" name="care_preferences" rows="4"
                                          placeholder="Any specific preferences for care (e.g. preferred language, dietary restrictions, preferred caregiver gender, etc.)..."
                                          class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none resize-none"><%= u.getCarePreferences() != null ? u.getCarePreferences() : "" %></textarea>
                                <p class="text-xs text-ink-muted mt-1">Help us match you with the right caregiver.</p>
                            </div>
                        </div>
                    </div>

                    <!-- Save Button -->
                    <div class="pt-4 flex items-center justify-between border-t border-stone-mid">
                        <a href="<%= request.getContextPath() %>/profile" class="text-sm text-ink-muted hover:text-ink transition-colors inline-flex items-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 16l-4-4m0 0l4-4m-4 4h18"/>
                            </svg>
                            Back to Profile
                        </a>
                        <button type="submit" class="bg-ink text-stone-warm px-6 py-3 text-sm font-normal hover:bg-ink-light transition-colors inline-flex items-center gap-2">
                            Save Changes
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M5 13l4 4L19 7"/>
                            </svg>
                        </button>
                    </div>
                </form>
            </section>

            <!-- Security Card -->
            <section class="card-section bg-white border border-stone-mid mb-6 stagger-4">
                <div class="px-6 py-5 border-b border-stone-mid">
                    <div class="flex items-center gap-3">
                        <svg class="w-5 h-5 text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                        </svg>
                        <div>
                            <h2 class="font-serif text-xl font-medium text-ink">Password & Security</h2>
                            <p class="text-sm text-ink-muted">Update your account password</p>
                        </div>
                    </div>
                </div>

                <% if (pwdError != null && !pwdError.trim().isEmpty()) { %>
                <div class="mx-6 mt-6 border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                    <%= pwdError %>
                </div>
                <% } else if (pwdSuccess != null && !pwdSuccess.trim().isEmpty()) { %>
                <div class="mx-6 mt-6 border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700">
                    <%= pwdSuccess %>
                </div>
                <% } %>

                <form method="post" action="<%= request.getContextPath() %>/customersServlet" class="p-6 space-y-5">
                    <input type="hidden" name="action" value="password" />

                    <div class="max-w-md">
                        <label for="oldPassword" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                            Current Password <span class="text-copper">*</span>
                        </label>
                        <input type="password" id="oldPassword" name="oldPassword" required
                               class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                    </div>

                    <div class="grid md:grid-cols-2 gap-5 max-w-md">
                        <div>
                            <label for="newPassword" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                New Password <span class="text-copper">*</span>
                            </label>
                            <input type="password" id="newPassword" name="newPassword" required
                                   class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                        </div>
                        <div>
                            <label for="confirmPassword" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
                                Confirm Password <span class="text-copper">*</span>
                            </label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required
                                   class="input-field w-full border border-stone-mid px-4 py-3 text-sm text-ink bg-white focus:outline-none">
                        </div>
                    </div>

                    <div class="pt-2">
                        <button type="submit" class="border border-ink text-ink px-5 py-2.5 text-sm font-normal hover:bg-ink hover:text-stone-warm transition-colors">
                            Update Password
                        </button>
                    </div>
                </form>
            </section>

            <!-- Danger Zone -->
            <section class="border border-red-200 bg-red-50/50 stagger-4">
                <div class="px-6 py-5 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div>
                        <h3 class="text-sm font-medium text-red-800">Delete Account</h3>
                        <p class="text-sm text-red-700 mt-1">
                            Permanently remove your SilverCare account and all associated data. This cannot be undone.
                        </p>
                    </div>
                    <form method="get" action="<%= request.getContextPath() %>/profile/delete">
                        <button type="submit" class="border border-red-300 bg-white text-red-700 px-5 py-2.5 text-sm font-normal hover:bg-red-100 transition-colors whitespace-nowrap">
                            Delete Account
                        </button>
                    </form>
                </div>
            </section>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <script>
    window.addEventListener('load', function() {
        setTimeout(function() {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 400);
    });

    document.addEventListener("DOMContentLoaded", function() {
        const dropdown = document.querySelector(".custom-dropdown");
        if (!dropdown) return;

        const selected = dropdown.querySelector(".selected");
        const dropdownList = dropdown.querySelector(".dropdown-list");
        const hiddenInput = document.getElementById("countryInput");

        selected.addEventListener("click", function() {
            dropdownList.style.display = dropdownList.style.display === "block" ? "none" : "block";
        });

        dropdown.querySelectorAll(".dropdown-item").forEach(function(item) {
            item.addEventListener("click", function() {
                const name = item.getAttribute("data-name");
                const code = item.getAttribute("data-code");
                const id = item.getAttribute("data-id");
                const flagImage = item.getAttribute("data-image");

                selected.innerHTML = 
                    '<img src="<%= request.getContextPath() %>/images/flags/' + flagImage + '" width="20" alt="">' +
                    '<span>+' + code + ' ' + name + '</span>' +
                    '<svg class="w-4 h-4 ml-auto text-ink-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 9l-7 7-7-7"/></svg>';

                hiddenInput.value = id;
                dropdownList.style.display = "none";
            });
        });

        document.addEventListener("click", function(e) {
            if (!dropdown.contains(e.target)) {
                dropdownList.style.display = "none";
            }
        });
    });
    </script>
</body>
</html>
