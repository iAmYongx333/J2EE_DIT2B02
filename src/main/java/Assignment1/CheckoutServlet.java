package Assignment1;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet for handling checkout flow with Stripe payment integration
 * POST: Process checkout from cart and redirect to payment page
 */
@WebServlet("/cart/checkout")
public class CheckoutServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * POST: Process checkout from cart system
	 * Stores checkout data in session and redirects to payment page
	 */
	@SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		System.out.println("[CheckoutServlet] POST - Processing checkout from cart");

		// 1) Session / role checks
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("sessId") == null) {
			System.out.println("[CheckoutServlet] No session found");
			response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
			return;
		}

		UUID userId;
		try {
			userId = UUID.fromString(session.getAttribute("sessId").toString());
		} catch (Exception e) {
			System.out.println("[CheckoutServlet] Invalid session ID: " + e.getMessage());
			response.sendRedirect(request.getContextPath() + "/login?errCode=InvalidSession");
			return;
		}

		String userRole = String.valueOf(session.getAttribute("sessRole"));
		if (!"customer".equalsIgnoreCase(userRole)) {
			System.out.println("[CheckoutServlet] User is not a customer: " + userRole);
			response.sendRedirect(request.getContextPath() + "/login?errCode=NotCustomer");
			return;
		}

		// 2) Cart + form data
		List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
		if (cart == null || cart.isEmpty()) {
			System.out.println("[CheckoutServlet] Cart is empty");
			response.sendRedirect(request.getContextPath() + "/cart?errCode=EmptyCart");
			return;
		}

		String serviceDateStr = request.getParameter("service_date");
		if (serviceDateStr == null || serviceDateStr.isBlank()) {
			System.out.println("[CheckoutServlet] Service date is null/blank");
			response.sendRedirect(request.getContextPath() + "/cart?errCode=DateNull");
			return;
		}

		String notes = request.getParameter("notes");
		String preferredTime = request.getParameter("preferred_time");

		// Fold preferred time into notes
		String finalNotes = notes;
		if (preferredTime != null && !preferredTime.isBlank()) {
			if (finalNotes == null || finalNotes.isBlank()) {
				finalNotes = "Preferred time: " + preferredTime;
			} else {
				finalNotes = finalNotes + " (Preferred time: " + preferredTime + ")";
			}
		}

		// 3) Get customer email and name from session
		String customerEmail = (String) session.getAttribute("sessEmail");
		String customerName = (String) session.getAttribute("sessName");

		if (customerEmail == null || customerEmail.isBlank()) {
			customerEmail = "customer@example.com";
		}
		if (customerName == null || customerName.isBlank()) {
			customerName = "Customer";
		}

		// 4) Calculate total amount
		double totalAmount = 0.0;
		for (CartItem item : cart) {
			totalAmount += item.getLineTotal();
		}

		// 5) Store checkout data in session
		session.setAttribute("checkoutUserId", userId.toString());
		session.setAttribute("checkoutServiceDate", serviceDateStr);
		session.setAttribute("checkoutNotes", finalNotes);
		session.setAttribute("checkoutEmail", customerEmail);
		session.setAttribute("checkoutName", customerName);
		session.setAttribute("checkoutAmount", totalAmount);

		System.out.println("[CheckoutServlet] Checkout data stored. Total: $" + totalAmount);

		// 6) Redirect to payment page
		response.sendRedirect(request.getContextPath() + "/checkout");
	}
}
