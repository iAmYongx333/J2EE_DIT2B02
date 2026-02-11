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

import Assignment1.api.ApiClient;
import Assignment1.Service.Service;

/**
 * Servlet for adding items to cart via API.
 * URL: /cart/add
 */
@WebServlet("/cart/add")
public class CartAddServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			int serviceId = Integer.parseInt(request.getParameter("serviceId"));
			int quantity = 1;
			String quantityParam = request.getParameter("quantity");
			if (quantityParam != null && !quantityParam.isEmpty()) {
				quantity = Integer.parseInt(quantityParam);
			}

			// 1) Get service details from API
			Service service = ApiClient.get("/services/" + serviceId, Service.class);

			if (service == null) {
				// Service not found – redirect back
				response.sendRedirect(request.getHeader("Referer"));
				return;
			}

			String serviceName = service.getServiceName();
			double unitPrice = service.getPrice();

			// Get category name from API (optional, use categoryId as fallback)
			String categoryName = "Category " + service.getCategoryId();
			Category category = ApiClient.get("/categories/" + service.getCategoryId(), Category.class);
			if (category != null) {
				categoryName = category.getCategoryName();
			}

			// 2) Get or create cart from session
			HttpSession session = request.getSession(true);
			List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
			if (cart == null) {
				cart = new ArrayList<>();
				session.setAttribute("cart", cart);
			}

			// 3) If service already in cart, increase quantity; else add new item
			boolean found = false;
			for (CartItem item : cart) {
				if (item.getServiceId() == serviceId) {
					item.setQuantity(item.getQuantity() + quantity);
					found = true;
					break;
				}
			}

			if (!found) {
				CartItem newItem = new CartItem(serviceId, serviceName, categoryName, unitPrice, quantity);
				cart.add(newItem);
			}

			// 4) Redirect to cart page
			response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");

		} catch (Exception e) {
			throw new ServletException("Error adding item to cart", e);
		}
	}
}