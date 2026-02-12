package Assignment1;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import Assignment1.api.ApiClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet for handling payment completion and booking creation
 * Called by frontend after successful Stripe payment
 * 
 * POST /payment/complete - Create booking after payment success
 */
@WebServlet("/payment/complete")
public class PaymentServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	@SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();
		
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("sessId") == null) {
			response.setStatus(401);
			out.print("{\"success\":false,\"error\":\"No session\"}");
			return;
		}
		
		try {
			// Get payment intent ID from request
			String paymentIntentId = request.getParameter("paymentIntentId");
			if (paymentIntentId == null || paymentIntentId.isBlank()) {
				response.setStatus(400);
				out.print("{\"success\":false,\"error\":\"Missing paymentIntentId\"}");
				return;
			}
			
			// Get checkout data from session
			String userId = (String) session.getAttribute("checkoutUserId");
			String serviceDate = (String) session.getAttribute("checkoutServiceDate");
			String notes = (String) session.getAttribute("checkoutNotes");
			List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
			
			if (cart == null || cart.isEmpty()) {
				response.setStatus(400);
				out.print("{\"success\":false,\"error\":\"No cart items\"}");
				return;
			}
			
			// Create booking via API for each cart item
			boolean allSuccess = true;
			StringBuilder bookingIds = new StringBuilder();
			
			for (CartItem item : cart) {
				Map<String, Object> bookingData = new HashMap<>();
				bookingData.put("userId", userId);
				bookingData.put("serviceId", item.getServiceId());
				bookingData.put("bookingDate", serviceDate);
				bookingData.put("quantity", item.getQuantity());
				bookingData.put("totalAmount", item.getLineTotal());
				bookingData.put("notes", notes != null ? notes : "");
				bookingData.put("paymentIntentId", paymentIntentId);
				bookingData.put("status", "confirmed");
				
				int status = ApiClient.post("/bookings", bookingData);
				if (status != 200 && status != 201) {
					allSuccess = false;
					System.out.println("[PaymentServlet] Failed to create booking for service " + item.getServiceId());
				}
			}
			
			// Clear cart and checkout data from session
			session.removeAttribute("cart");
			session.removeAttribute("checkoutUserId");
			session.removeAttribute("checkoutServiceDate");
			session.removeAttribute("checkoutNotes");
			session.removeAttribute("checkoutEmail");
			session.removeAttribute("checkoutName");
			session.removeAttribute("checkoutAmount");
			
			if (allSuccess) {
				out.print("{\"success\":true,\"message\":\"Booking created successfully\"}");
			} else {
				out.print("{\"success\":true,\"message\":\"Payment successful, but some bookings may need review\"}");
			}
			
		} catch (Exception e) {
			System.out.println("[PaymentServlet] Error: " + e.getMessage());
			e.printStackTrace();
			response.setStatus(500);
			out.print("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
		}
	}
}
