package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

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

			// 1) Get service details from DB
			String sql = "SELECT s.service_id, s.service_name, s.price, " + "c.category_name " + "FROM service s "
					+ "JOIN service_category c ON s.category_id = c.category_id " + "WHERE s.service_id = ?";

			Connection conn = DBUtil.getConnection();
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, serviceId);
			ResultSet rs = pstmt.executeQuery();

			if (!rs.next()) {
				// Service not found – just redirect back or show error
				rs.close();
				pstmt.close();
				conn.close();
				response.sendRedirect(request.getHeader("Referer")); // back to previous page
				return;
			}

			String serviceName = rs.getString("service_name");
			String categoryName = rs.getString("category_name");
			double unitPrice = rs.getDouble("price");

			rs.close();
			pstmt.close();
			conn.close();

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