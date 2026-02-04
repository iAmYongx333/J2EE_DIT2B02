package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/cart/update")
public class CartUpdateServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null) {
			response.sendRedirect(request.getContextPath() + "/cart.jsp");
			return;
		}

		List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
		if (cart == null) {
			response.sendRedirect(request.getContextPath() + "/cart.jsp");
			return;
		}

		try {
			int serviceId = Integer.parseInt(request.getParameter("service_id"));
			String action = request.getParameter("action");
			String qtyParam = request.getParameter("quantity");
			int quantity = (qtyParam != null && !qtyParam.isEmpty()) ? Integer.parseInt(qtyParam) : 0;

			if ("remove".equalsIgnoreCase(action)) {
				cart.removeIf(item -> item.getServiceId() == serviceId);
			} else if ("update".equalsIgnoreCase(action)) {
				if (quantity <= 0) {
					cart.removeIf(item -> item.getServiceId() == serviceId);
				} else {
					for (CartItem item : cart) {
						if (item.getServiceId() == serviceId) {
							item.setQuantity(quantity);
							break;
						}
					}
				}
			}

			response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
		} catch (NumberFormatException e) {
			// Ignore bad input, just redirect back
			response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
		}
	}
}