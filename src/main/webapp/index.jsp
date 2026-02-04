<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="utils/db.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>SilverCare | Home</title>
  <script src="https://cdn.tailwindcss.com"></script>

  <style>
    @keyframes softFadeUp { 0% {opacity:0; transform:translateY(20px);} 100% {opacity:1; transform:translateY(0);} }
    @keyframes softFade { 0% {opacity:0;} 100% {opacity:1;} }

    .reveal-up{ opacity:0; animation:softFadeUp 1.2s ease-out forwards; }
    .reveal{ opacity:0; animation:softFade 1.4s ease-out forwards; }

    /* Prevent animation before scroll trigger */
    .reveal, .reveal-up { animation-play-state: paused; }
  </style>
</head>

<body class="bg-[#f7f4ef] text-slate-900 font-sans overflow-x-hidden">

<%@ include file="includes/header.jsp" %>

<!-- MAIN CONTAINER -->
<div class="w-full max-w-[1800px] mx-auto">

<!-- HERO SECTION -->
<section class="relative px-6 sm:px-10 lg:px-24 
                pt-28 sm:pt-32 lg:pt-40 
                pb-20 lg:pb-32
                flex flex-col lg:flex-row items-center gap-14 lg:gap-24">

  <!-- LEFT TEXT -->
  <div class="flex-1 text-center lg:text-left reveal">
    <h1 class="text-4xl sm:text-5xl lg:text-6xl font-serif font-bold text-[#1e2a38] leading-tight mb-6">
      Caring with Dignity,<br>
      Living with Comfort.
    </h1>

    <p class="text-base sm:text-lg text-slate-700 leading-relaxed mb-10 max-w-xl mx-auto lg:mx-0">
      A modern approach to elderly care. Where empathy, trust and design meet to support your loved ones.
    </p>

    <div class="flex flex-col sm:flex-row justify-center lg:justify-start gap-4">
      <a href="<%=request.getContextPath()%>/public/services.jsp"
         class="px-8 py-3 bg-[#1e2a38] text-white rounded-lg shadow-sm hover:shadow-md transition-all duration-300">
         Explore Services
      </a>

      <a href="#about"
         class="px-8 py-3 border border-[#1e2a38] text-[#1e2a38] rounded-lg hover:bg-[#1e2a3810] transition-all duration-300">
         Learn More
      </a>
    </div>
  </div>

  <!-- RIGHT IMAGE -->
  <div class="flex-1 flex justify-center reveal-up relative">
    <div class="absolute inset-0 bg-gradient-radial from-[#d8cbb8]/40 to-transparent blur-3xl scale-110 pointer-events-none"></div>

    <img src="images/elderlycarehero.png"
         alt="Elderly Care Illustration"
         class="relative w-full max-w-xl rounded-3xl shadow-xl object-cover" />
  </div>

</section>


<!-- ABOUT SECTION -->
<section id="about" class="py-20 sm:py-24 bg-[#fdfbf7] px-6 sm:px-10 lg:px-24 reveal">
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20 items-center max-w-6xl mx-auto">

    <!-- ABOUT IMAGE -->
    <img src="images/elderlycarehero.png"
         class="rounded-3xl shadow-md border border-[#e6e1da] w-full">

    <!-- ABOUT TEXT -->
    <div>
      <h2 class="text-3xl sm:text-4xl font-serif font-semibold text-[#1e2a38] mb-6">
        A Tradition of Care, Evolved for Today
      </h2>

      <p class="text-slate-700 leading-relaxed mb-6">
        Inspired by the timeless charm of Prague and the minimalism of Scandinavian design,
        SilverCare blends warmth, elegance and practicality to create a care experience built on trust.
      </p>

      <ul class="space-y-3 text-slate-700">
        <li>• Trusted caregivers with verified training</li>
        <li>• Personalised support tailored to each family</li>
        <li>• Transparent communication and real-time updates</li>
      </ul>
    </div>
  </div>
</section>


<!-- SERVICES SECTION -->
<section id="services" class="py-20 sm:py-24 px-6 sm:px-10 lg:px-24 reveal">
  <div class="max-w-6xl mx-auto text-center">

    <h2 class="text-3xl sm:text-4xl font-serif font-semibold text-[#1e2a38] mb-4">Our Services</h2>
    <p class="text-slate-600 max-w-2xl mx-auto mb-12">
      Designed to deliver calm, confidence and comfort — with a consistent Scandinavian simplicity.
    </p>

	<%
	  Connection conn = (Connection) request.getAttribute("conn");
	  String sql = "SELECT service_id, service_name, description, image_path FROM service ORDER BY service_id LIMIT 3";
	  PreparedStatement ps = conn.prepareStatement(sql);
	  ResultSet rs = ps.executeQuery();
	  String ctx = request.getContextPath();
	%>
	
	<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-10">
	  <% while (rs.next()) {
	       String img = rs.getString("image_path");
	
	       // Normalise: if null/blank, use default; ensure leading slash
	       if (img == null || img.trim().isEmpty()) {
	         img = "/images/default-service.png";
	       } else if (!img.startsWith("/")) {
	         img = "/" + img;
	       }
	
	       String imgSrc = ctx + img;
	  %>
	    <div class="group bg-white rounded-3xl shadow-sm border border-[#e9e5df]
	                hover:shadow-xl hover:-translate-y-2 transition-all duration-500 overflow-hidden">
	      <img src="<%= imgSrc %>"
	           class="w-full h-56 object-cover transition-transform duration-500 group-hover:scale-105">
	
	      <div class="p-8 text-left">
	        <h3 class="text-xl sm:text-2xl font-serif font-semibold text-[#1e2a38] mb-3">
	          <%= rs.getString("service_name") %>
	        </h3>
	        <p class="text-slate-600 text-sm leading-relaxed">
	          <%= rs.getString("description") %>
	        </p>
	      </div>
	    </div>
	  <% } %>
	</div>
	<%
	  conn.close();
	%>

    <div class="mt-12">
      <a href="<%=request.getContextPath()%>/public/services.jsp" class="text-[#1e2a38] font-medium hover:underline">View all services →</a>
    </div>

  </div>
</section>


<!-- CTA -->
<section class="bg-[#1e2a38] text-white py-20 sm:py-24 px-6 sm:px-10 lg:px-24 reveal-up">
  <div class="max-w-5xl mx-auto text-center">

    <h2 class="text-3xl sm:text-4xl font-serif font-semibold mb-4">Care That Feels Like Home</h2>
    <p class="text-[#e0e6ed] max-w-2xl mx-auto mb-10">
      Simple, honest, and made for families — a digital experience built for real care.
    </p>

    <a href="<%=request.getContextPath()%>/public/register.jsp"
       class="bg-white text-[#1e2a38] px-10 py-3 rounded-lg shadow hover:bg-[#f2f4f7] transition-all duration-300">
       Get Started
    </a>
  </div>
</section>

</div>

<%@ include file="includes/footer.jsp" %>

<script>
  const revealEls = document.querySelectorAll('.reveal, .reveal-up');
  function revealOnScroll() {
    const trigger = window.innerHeight * 0.90;
    revealEls.forEach(el => {
      const rect = el.getBoundingClientRect();
      if (rect.top < trigger) el.style.animationPlayState = 'running';
    });
  }
  window.addEventListener('scroll', revealOnScroll);
  window.addEventListener('load', revealOnScroll);
</script>

</body>
</html>