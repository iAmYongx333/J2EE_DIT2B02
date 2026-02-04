<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<footer class="mt-24 bg-[#faf8f4] border-t border-[#e0dcd4]">
  <div class="max-w-7xl mx-auto px-8 py-14 grid grid-cols-1 md:grid-cols-3 gap-12">

    <!-- Branding -->
    <div>
      <h3 class="text-3xl font-serif font-semibold text-[#1e2a38] mb-3">
        SilverCare
      </h3>
      <p class="text-sm text-slate-600 leading-relaxed">
        Compassionate elderly care rooted in European calm and Scandinavian simplicity.
      </p>
    </div>

    <!-- Navigation -->
    <div>
      <h4 class="text-[#1e2a38] font-semibold mb-4">Navigation</h4>
      <ul class="space-y-2 text-sm">
        <li><a href="index.jsp" class="footer-link">Home</a></li>
        <li><a href="services.jsp" class="footer-link">Services</a></li>
        <li><a href="register_client.jsp" class="footer-link">Register</a></li>
        <li><a href="login.jsp" class="footer-link">Login</a></li>
      </ul>
    </div>

    <!-- Contact -->
    <div>
      <h4 class="text-[#1e2a38] font-semibold mb-4">Contact</h4>
      <ul class="space-y-2 text-sm">
        <li>Email: <a href="mailto:hello@silvercare.com" class="footer-link">hello@silvercare.com</a></li>
        <li>Phone: <span class="text-slate-700">+65 6789 1234</span></li>
        <li>Address: <span class="text-slate-700">123 Harmony Ave, Singapore</span></li>
      </ul>
    </div>

  </div>

  <!-- Bottom Bar -->
  <div class="border-t border-[#e0dcd4]">
    <div class="max-w-7xl mx-auto px-8 py-6 flex flex-col md:flex-row justify-between items-center text-xs text-slate-500">
      <p>&copy; 2025 SilverCare. All rights reserved.</p>

      <div class="mt-3 md:mt-0 space-x-4">
        <a href="#" class="footer-link">Privacy Policy</a>
        <a href="#" class="footer-link">Terms</a>
      </div>
    </div>
  </div>

  <style>
    .footer-link {
      color: #475569;
      transition: color 0.3s ease, transform 0.25s ease;
    }
    .footer-link:hover {
      color: #1e2a38;
      transform: translateX(2px);
    }
  </style>
</footer>
</html>