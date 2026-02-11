package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import Assignment1.api.ApiClient;
import Assignment1.dto.CheckoutRequest;
import Assignment1.dto.CheckoutRequest.CheckoutItem;

/**
 * Servlet for processing checkout via API.
 * URL: /cart/checkout
 */
@WebServlet("/cart/checkout")
public class CheckoutServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@SuppressWarnings("unchecked")
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// 1) Session / role checks
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("sessId") == null) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
			return;
		}

		UUID userId;
		try {
			userId = UUID.fromString(session.getAttribute("sessId").toString());
		} catch (Exception e) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=InvalidSession");
			return;
		}

		String userRole = String.valueOf(session.getAttribute("sessRole"));
		if (!"customer".equalsIgnoreCase(userRole)) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NotCustomer");
			return;
		}

		// 2) Cart + form data
		List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
		if (cart == null || cart.isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?errCode=EmptyCart");
			return;
		}

		String serviceDateStr = request.getParameter("service_date");
		if (serviceDateStr == null || serviceDateStr.isBlank()) {
			response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?errCode=DateNull");
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

		// 3) Build checkout request
		List<CheckoutItem> checkoutItems = new ArrayList<>();
		for (CartItem item : cart) {
			checkoutItems.add(new CheckoutItem(
				item.getServiceId(),
				item.getQuantity(),
				item.getUnitPrice()
			));
		}

		CheckoutRequest checkoutRequest = new CheckoutRequest(
			userId,
			serviceDateStr,
			finalNotes,
			checkoutItems
		);

		// 4) POST to API
		try {
			int status = ApiClient.post("/bookings/checkout", checkoutRequest);

			if (status == 200 || status == 201) {
				// Clear cart and redirect to bookings
				session.removeAttribute("cart");
				response.sendRedirect(request.getContextPath() + "/customer/bookings");
			} else {
				response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?errCode=CheckoutFailed");
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?errCode=CheckoutError");
		}
	}
}