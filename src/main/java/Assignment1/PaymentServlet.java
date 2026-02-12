package Assignment1;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
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
			String pendingBookingId = (String) session.getAttribute("checkoutBookingId");
			List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");

			// Fallback for missing serviceDate
			if (serviceDate == null || serviceDate.isBlank()) {
				serviceDate = java.time.LocalDate.now().plusDays(1).toString();
			}
			
			if (cart == null || cart.isEmpty()) {
				response.setStatus(400);
				out.print("{\"success\":false,\"error\":\"No cart items\"}");
				return;
			}
			
			boolean allSuccess = true;
			StringBuilder bookingIds = new StringBuilder();

			// If a pending booking was created during checkout, update it to confirmed
			if (pendingBookingId != null && !pendingBookingId.isBlank()) {
				Map<String, Object> updateData = new HashMap<>();
				updateData.put("status", "confirmed");
				updateData.put("paymentIntentId", paymentIntentId);
				int status = ApiClient.put("/bookings/" + pendingBookingId, updateData);
				if (status != 200) {
					// Non-fatal: booking exists, just status update failed
					// Payment was already charged by Stripe at this point
					System.out.println("[PaymentServlet] WARNING: Failed to update pending booking " + pendingBookingId + " to confirmed (status " + status + "). Booking still exists as pending.");
				} else {
					System.out.println("[PaymentServlet] Updated pending booking " + pendingBookingId + " to confirmed");
				}
			}

			// Create bookings for remaining cart items (skip the first if pending booking was created)
			boolean skipFirst = (pendingBookingId != null && !pendingBookingId.isBlank());
			int index = 0;
			for (CartItem item : cart) {
				if (skipFirst && index == 0) {
					index++;
					continue;
				}
				index++;

				// Build bookingDetails with this single item
				List<Map<String, Object>> details = new ArrayList<>();
				Map<String, Object> detail = new HashMap<>();
				detail.put("serviceId", item.getServiceId());
				detail.put("serviceName", item.getServiceName());
				detail.put("quantity", item.getQuantity());
				detail.put("unitPrice", item.getUnitPrice());
				details.add(detail);

				// Build booking payload matching backend entity structure
				Map<String, Object> bookingData = new HashMap<>();
				bookingData.put("userId", userId);
				bookingData.put("scheduledAt", serviceDate);
				bookingData.put("status", "confirmed");
				bookingData.put("notes", notes != null ? notes : "");
				bookingData.put("bookingDetails", details);
				
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
			session.removeAttribute("checkoutBookingId");
			
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
