<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <% HttpSession sess=request.getSession(false); String userRoleStringHeader=null; boolean isLoggedInHeader=false; if
    (sess !=null) { Object roleObj=sess.getAttribute("sessRole"); if (roleObj !=null) {
    userRoleStringHeader=roleObj.toString(); } isLoggedInHeader=(sess.getAttribute("sessId") !=null); } %>

    <header id="navbar" class="fixed top-0 left-0 w-full z-[100] transition-all duration-300">
      <div class="nav-container">
        <div class="max-w-6xl mx-auto px-5 md:px-12 py-4 flex items-center justify-between">

          <!-- BRAND -->
          <a href="<%=request.getContextPath()%>/" class="flex items-center gap-2 group select-none">
            <span class="font-serif text-xl md:text-2xl font-medium tracking-tight text-ink
                     group-hover:text-copper
                     transition-colors duration-200">
              SilverCare
            </span>
          </a>

          <!-- HAMBURGER (MOBILE ONLY) -->
          <button id="menuBtn" class="md:hidden flex flex-col justify-center items-center gap-1.5
                     p-2
                     transition-all duration-200 active:scale-95">
            <span class="line w-5 h-px bg-ink transition-all duration-200"></span>
            <span class="line w-5 h-px bg-ink transition-all duration-200"></span>
          </button>

          <!-- DESKTOP NAV -->
          <nav class="hidden md:flex items-center gap-8 text-sm font-light">
            <a href="<%=request.getContextPath()%>/" class="nav-link">Home</a>
            <a href="<%=request.getContextPath()%>/services" class="nav-link">Services</a>
            <a href="<%=request.getContextPath()%>/b2b" class="nav-link">B2B Portal</a>

            <% if ("admin".equals(userRoleStringHeader)) { %>
              <a href="<%=request.getContextPath()%>/admin" class="nav-link">Admin</a>
              <a href="<%=request.getContextPath()%>/admin/service-visits" class="nav-link">Service Visits</a>
            <% } %>

            <% if ("customer".equals(userRoleStringHeader) || "admin".equals(userRoleStringHeader)) { %>
              <a href="<%=request.getContextPath()%>/profile" class="nav-link">Profile</a>
            <% } %>

            <% if ("admin".equals(userRoleStringHeader)) { %>
              <a href="<%=request.getContextPath()%>/admin/client-inquiry" class="nav-link">Client Inquiry</a>
            <% } %>

            <% if (!isLoggedInHeader) { %>
              <a href="<%=request.getContextPath()%>/register" class="nav-link">Register</a>
              <a href="<%=request.getContextPath()%>/login" 
                 class="ml-2 px-5 py-2 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                Login
              </a>
            <% } else { %>
              <a href="<%=request.getContextPath()%>/cart" class="nav-link">Cart</a>
              <a href="<%=request.getContextPath()%>/bookings" class="nav-link">Bookings</a>
              <a href="<%=request.getContextPath()%>/customer/service-visits" class="nav-link">Visit Status</a>
              <a href="<%=request.getContextPath()%>/customer/payments" class="nav-link">Payments</a>
              <a href="<%=request.getContextPath()%>/customersServlet?action=logout" 
                 class="ml-2 px-5 py-2 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                Logout
              </a>
            <% } %>
          </nav>
        </div>
      </div>

      <!-- MOBILE MENU -->
      <div id="fullscreenMenu" class="fixed inset-0 z-[90]
              bg-stone-warm
              flex flex-col
              opacity-0 pointer-events-none
              transition-all duration-300 ease-out">

        <div class="flex items-center justify-between px-5 py-4 border-b border-stone-mid">
          <span class="font-serif text-xl font-medium text-ink">SilverCare</span>
          <button id="closeMenuBtn" class="p-2 transition-all duration-200 hover:opacity-60">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 text-ink" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <div class="flex-1 flex flex-col px-5 py-8 gap-1">
          <a href="<%=request.getContextPath()%>/" class="mobile-link">Home</a>
          <a href="<%=request.getContextPath()%>/services" class="mobile-link">Services</a>
          <a href="<%=request.getContextPath()%>/b2b" class="mobile-link">B2B Portal</a>

          <% if ("admin".equals(userRoleStringHeader)) { %>
            <a href="<%=request.getContextPath()%>/admin" class="mobile-link">Admin</a>
            <a href="<%=request.getContextPath()%>/admin/service-visits" class="mobile-link">Service Visits</a>
            <a href="<%=request.getContextPath()%>/admin/client-inquiry" class="mobile-link">Client Inquiry</a>
          <% } %>

          <% if (!isLoggedInHeader) { %>
            <a href="<%=request.getContextPath()%>/register" class="mobile-link">Register</a>
            <div class="mt-6 pt-6 border-t border-stone-mid">
              <a href="<%=request.getContextPath()%>/login" 
                 class="block text-center px-6 py-3 bg-ink text-stone-warm text-sm font-normal">
                Login
              </a>
            </div>
          <% } else { %>
            <% if ("customer".equals(userRoleStringHeader) || "admin".equals(userRoleStringHeader)) { %>
              <a href="<%=request.getContextPath()%>/profile" class="mobile-link">Profile</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/cart" class="mobile-link">Cart</a>
            <a href="<%=request.getContextPath()%>/bookings" class="mobile-link">Bookings</a>
            <a href="<%=request.getContextPath()%>/customer/service-visits" class="mobile-link">Visit Status</a>
            <a href="<%=request.getContextPath()%>/customer/payments" class="mobile-link">Payments</a>
            <div class="mt-6 pt-6 border-t border-stone-mid">
              <a href="<%=request.getContextPath()%>/customersServlet?action=logout" 
                 class="block text-center px-6 py-3 bg-ink text-stone-warm text-sm font-normal">
                Logout
              </a>
            </div>
          <% } %>
        </div>
      </div>

      <style>
        .nav-container {
          background-color: #f5f3ef;
          border-bottom: 1px solid #e8e4dc;
          transition: all 0.25s ease;
        }

        .nav-scrolled {
          background-color: rgba(245, 243, 239, 0.95);
          backdrop-filter: blur(8px);
          -webkit-backdrop-filter: blur(8px);
        }

        .nav-link {
          color: #5a5a5a;
          transition: color 0.2s ease;
        }

        .nav-link:hover {
          color: #2c2c2c;
        }

        .mobile-link {
          display: block;
          padding: 12px 0;
          font-size: 1.125rem;
          color: #2c2c2c;
          border-bottom: 1px solid #e8e4dc;
          opacity: 0;
          transform: translateX(-8px);
          transition: opacity 0.2s ease, transform 0.2s ease, color 0.2s ease;
        }

        .mobile-link:hover {
          color: #b87a4b;
        }

        .mobile-link.show {
          opacity: 1;
          transform: translateX(0);
        }

        .ink { color: #2c2c2c; }
        .bg-ink { background-color: #2c2c2c; }
        .text-ink { color: #2c2c2c; }
        .text-ink-light { color: #5a5a5a; }
        .bg-ink-light { background-color: #5a5a5a; }
        .text-stone-warm { color: #f5f3ef; }
        .bg-stone-warm { background-color: #f5f3ef; }
        .text-copper { color: #b87a4b; }
        .border-stone-mid { border-color: #e8e4dc; }
      </style>
    </header>

    <script>
      const navbar = document.getElementById("navbar");
      const container = navbar.querySelector(".nav-container");
      const menuBtn = document.getElementById("menuBtn");
      const fullscreenMenu = document.getElementById("fullscreenMenu");
      const closeMenuBtn = document.getElementById("closeMenuBtn");
      const lines = menuBtn.querySelectorAll(".line");
      const mobileLinks = document.querySelectorAll(".mobile-link");

      window.addEventListener("scroll", function() {
        if (window.scrollY > 40) {
          container.classList.add("nav-scrolled");
        } else {
          container.classList.remove("nav-scrolled");
        }
      });

      function openMenu() {
        lines[0].style.transform = "translateY(4px) rotate(45deg)";
        lines[1].style.transform = "translateY(-4px) rotate(-45deg)";

        fullscreenMenu.style.pointerEvents = "auto";
        fullscreenMenu.style.opacity = "1";

        mobileLinks.forEach(function(link, i) {
          setTimeout(function() { link.classList.add("show"); }, i * 50);
        });
      }

      function closeMenu() {
        lines[0].style.transform = "translateY(0) rotate(0)";
        lines[1].style.transform = "translateY(0) rotate(0)";

        fullscreenMenu.style.opacity = "0";
        fullscreenMenu.style.pointerEvents = "none";

        mobileLinks.forEach(function(link) { link.classList.remove("show"); });
      }

      var isOpen = false;

      menuBtn.addEventListener("click", function() {
        isOpen ? closeMenu() : openMenu();
        isOpen = !isOpen;
      });

      closeMenuBtn.addEventListener("click", function() {
        if (isOpen) {
          closeMenu();
          isOpen = false;
        }
      });

      mobileLinks.forEach(function(link) {
        link.addEventListener("click", function() {
          if (isOpen) {
            closeMenu();
            isOpen = false;
          }
        });
      });
    </script>