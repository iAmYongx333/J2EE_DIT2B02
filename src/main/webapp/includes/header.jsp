<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    HttpSession sess = request.getSession(false);
    String userRoleStringHeader = null;
    boolean isLoggedInHeader = false;

    if (sess != null) {
        Object roleObj = sess.getAttribute("sessRole");
        if (roleObj != null) {
            userRoleStringHeader = roleObj.toString();
        }
        isLoggedInHeader = (sess.getAttribute("sessId") != null);
    }
%>

<header id="navbar"
        class="fixed top-0 left-0 w-full z-[100] transition-all duration-300">
  <div class="nav-container">
    <div class="max-w-7xl mx-auto px-6 md:px-8 py-4 flex items-center justify-between">

      <!-- BRAND -->
      <a href="<%=request.getContextPath()%>/index.jsp"
         class="flex items-center gap-3 group select-none">
        <img src="<%=request.getContextPath()%>/images/logo.png"
             class="h-9 w-9 rounded-[18px]
                    border border-[#e0dcd4]
                    bg-[#f7f3ec]
                    object-contain
                    transition-transform duration-300 group-hover:scale-105" />

        <span class="text-[22px] md:text-[24px] font-serif font-semibold tracking-tight text-[#1e2a38]
                     group-hover:text-[#121825]
                     transition-colors duration-200">
          SilverCare
        </span>
      </a>

      <!-- HAMBURGER (MOBILE ONLY) -->
      <button id="menuBtn"
              class="md:hidden flex flex-col justify-center items-center space-y-1.5
                     rounded-full px-2.5 py-1.5
                     bg-[#fdf9f3] border border-[#e0dcd4]
                     shadow-[0_6px_18px_rgba(15,23,42,0.12)]
                     transition-all duration-200 active:scale-95">
        <span class="line w-5 h-0.5 bg-[#1e2a38] rounded-full transition-all duration-200"></span>
        <span class="line w-5 h-0.5 bg-[#1e2a38] rounded-full transition-all duration-200"></span>
        <span class="line w-5 h-0.5 bg-[#1e2a38] rounded-full transition-all duration-200"></span>
      </button>

      <!-- DESKTOP NAV -->
      <nav class="hidden md:flex items-center space-x-8 text-[14px] font-medium">
        <a href="<%=request.getContextPath()%>/index.jsp" class="nav-link">Home</a>
        <a href="<%=request.getContextPath()%>/public/services.jsp" class="nav-link">Services</a>

        <% if ("admin".equals(userRoleStringHeader)) { %>
          <a href="<%=request.getContextPath()%>/admin/dashboard" class="nav-link">Admin</a>
        <% } %>
        
        <% if ("customer".equals(userRoleStringHeader) || "admin".equals(userRoleStringHeader)) { %>
          <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="nav-link">Profile</a>
        <% } %>

        <% if (!isLoggedInHeader) { %>
          <a href="<%=request.getContextPath()%>/public/register.jsp" class="nav-link">Register</a>

          <a href="<%=request.getContextPath()%>/public/login.jsp"
             class="ml-3 inline-flex items-center justify-center
                    px-4 py-2 rounded-full
                    bg-[#1e2a38] text-[#fdfaf5]
                    text-[13px] font-medium
                    shadow-[0_10px_28px_rgba(15,23,42,0.30)]
                    hover:bg-[#253447]
                    active:scale-[0.98]
                    transition-all duration-200">
            Login
          </a>
        <% } else { %>
          <a href="<%=request.getContextPath()%>/customer/cart.jsp" class="nav-link">Cart</a>
          <a href="<%=request.getContextPath()%>/customer/bookings" class="nav-link">My Bookings</a>

          <a href="<%=request.getContextPath()%>/customersServlet?action=logout"
             class="ml-3 inline-flex items-center justify-center
                    px-4 py-2 rounded-full
                    bg-[#1e2a38] text-[#fdfaf5]
                    text-[13px] font-medium
                    shadow-[0_10px_28px_rgba(15,23,42,0.30)]
                    hover:bg-[#253447]
                    active:scale-[0.98]
                    transition-all duration-200">
            Logout
          </a>
        <% } %>
      </nav>
    </div>
  </div>

  <!-- FULLSCREEN MOBILE MENU -->
  <div id="fullscreenMenu"
       class="fixed inset-0 z-[90]
              bg-[rgba(250,248,244,0.98)] backdrop-blur-xl
              flex flex-col items-center justify-center
              opacity-0 pointer-events-none
              transition-all duration-300 ease-out
              transform translate-y-2">

    <button id="closeMenuBtn"
            class="absolute top-5 right-6 p-3 rounded-full
                   bg-[#fdf9f3] border border-[#e0dcd4]
                   shadow-[0_8px_24px_rgba(15,23,42,0.18)]
                   transition-all duration-200 hover:scale-105 active:scale-95">
      <svg xmlns="http://www.w3.org/2000/svg"
           class="w-4 h-4 text-[#1e2a38]"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round">
        <line x1="18" y1="6" x2="6" y2="18" />
        <line x1="6" y1="6" x2="18" y2="18" />
      </svg>
    </button>

    <div class="flex flex-col items-center space-y-7">
      <!-- All base links: consistent mobile typography -->
      <a href="<%=request.getContextPath()%>/index.jsp"
         class="mobile-link text-xl md:text-2xl tracking-tight text-[#1e2a38] font-medium">
        Home
      </a>
      <a href="<%=request.getContextPath()%>/public/services.jsp"
         class="mobile-link text-xl md:text-2xl tracking-tight text-[#1e2a38] font-medium">
        Services
      </a>

      <% if ("admin".equals(userRoleStringHeader)) { %>
        <a href="<%=request.getContextPath()%>/admin/dashboard"
           class="mobile-link text-xl md:text-2xl tracking-tight text-[#1e2a38] font-medium">
          Admin
        </a>
      <% } %>

      <% if (!isLoggedInHeader) { %>
        <a href="<%=request.getContextPath()%>/public/register.jsp"
           class="mobile-link text-xl md:text-2xl tracking-tight text-[#1e2a38] font-medium">
          Register
        </a>

        <a href="<%=request.getContextPath()%>/public/login.jsp"
           class="mobile-link inline-flex items-center justify-center
                  px-8 py-3 rounded-full
                  bg-[#1e2a38] text-[#fdfaf5] text-[15px] font-medium
                  shadow-[0_12px_32px_rgba(15,23,42,0.32)]
                  hover:bg-[#253447] transition-all duration-200">
          Login
        </a>
      <% } else { %>

        <% if ("customer".equals(userRoleStringHeader) || "admin".equals(userRoleStringHeader)) { %>
          <a href="<%=request.getContextPath()%>/customer/profile.jsp"
             class="mobile-link text-xl md:text-2xl tracking-tight text-[#1e2a38] font-medium">
            Profile
          </a>
        <% } %>

        <a href="<%=request.getContextPath()%>/customer/cart.jsp"
           class="mobile-link text-xl md:text-2xl tracking-tight text-[#1e2a38] font-medium">
          Cart
        </a>
        <a href="<%=request.getContextPath()%>/customer/bookings"
           class="mobile-link text-xl md:text-2xl tracking-tight text-[#1e2a38] font-medium">
          My Bookings
        </a>

        <a href="<%=request.getContextPath()%>/customersServlet?action=logout"
           class="mobile-link inline-flex items-center justify-center
                  px-8 py-3 rounded-full
                  bg-[#1e2a38] text-[#fdfaf5] text-[15px] font-medium
                  shadow-[0_12px_32px_rgba(15,23,42,0.32)]
                  hover:bg-[#253447] transition-all duration-200">
          Logout
        </a>
      <% } %>
    </div>
  </div>

  <style>
    .nav-container {
      background-color: #faf8f4;
      border-bottom: 1px solid #e0dcd4;
      transition:
        background-color 0.25s ease,
        box-shadow 0.25s ease,
        border-color 0.25s ease;
    }

    .nav-scrolled {
      box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
      border-bottom-color: #d6d0c6;
    }

    .nav-link {
      position: relative;
      color: #64748b;
      padding-bottom: 2px;
      transition: color 0.2s ease, transform 0.2s ease;
    }

    .nav-link::after {
      content: "";
      position: absolute;
      left: 0;
      bottom: -4px;
      width: 0;
      height: 2px;
      border-radius: 999px;
      background: #1e2a38;
      transition: width 0.22s ease-out;
    }

    .nav-link:hover {
      color: #1e2a38;
      transform: translateY(-1px);
    }

    .nav-link:hover::after {
      width: 100%;
    }

    .mobile-link {
      opacity: 0;
      transform: translateY(10px);
      letter-spacing: 0.03em;
      transition:
        opacity 0.28s ease-out,
        transform 0.28s ease-out;
    }

    .mobile-link.show {
      opacity: 1;
      transform: translateY(0);
    }
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

  // Scroll behaviour – tiny lift + shadow
  window.addEventListener("scroll", () => {
    if (window.scrollY > 40) {
      container.classList.add("nav-scrolled");
    } else {
      container.classList.remove("nav-scrolled");
    }
  });

  function openMenu() {
    lines[0].style.transform = "translateY(6px) rotate(45deg)";
    lines[1].style.opacity = "0";
    lines[2].style.transform = "translateY(-6px) rotate(-45deg)";

    fullscreenMenu.style.pointerEvents = "auto";
    fullscreenMenu.style.opacity = "1";
    fullscreenMenu.style.transform = "translateY(0)";

    mobileLinks.forEach((link, i) => {
      setTimeout(() => link.classList.add("show"), i * 70);
    });
  }

  function closeMenu() {
    lines[0].style.transform = "translateY(0) rotate(0)";
    lines[1].style.opacity = "1";
    lines[2].style.transform = "translateY(0) rotate(0)";

    fullscreenMenu.style.opacity = "0";
    fullscreenMenu.style.transform = "translateY(8px)";
    fullscreenMenu.style.pointerEvents = "none";

    mobileLinks.forEach(link => link.classList.remove("show"));
  }

  let isOpen = false;

  menuBtn.addEventListener("click", () => {
    isOpen ? closeMenu() : openMenu();
    isOpen = !isOpen;
  });

  closeMenuBtn.addEventListener("click", () => {
    if (isOpen) {
      closeMenu();
      isOpen = false;
    }
  });

  mobileLinks.forEach(link => {
    link.addEventListener("click", () => {
      if (isOpen) {
        closeMenu();
        isOpen = false;
      }
    });
  });
</script>