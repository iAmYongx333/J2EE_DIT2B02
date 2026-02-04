package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.UUID;

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

		// Optionally fold preferred time into notes so you still capture it
		String finalNotes = notes;
		if (preferredTime != null && !preferredTime.isBlank()) {
			if (finalNotes == null || finalNotes.isBlank()) {
				finalNotes = "Preferred time: " + preferredTime;
			} else {
				finalNotes = finalNotes + " (Preferred time: " + preferredTime + ")";
			}
		}

		// 3) DB insert
		try (Connection conn = DBUtil.getConnection()) {
			conn.setAutoCommit(false);

			// Insert booking header
			String insertBookingSql = "INSERT INTO booking (user_id, scheduled_at, status, notes) "
					+ "VALUES (?, ?, ?, ?) RETURNING booking_id";

			int bookingId;
			try (PreparedStatement bookingStmt = conn.prepareStatement(insertBookingSql)) {
				bookingStmt.setObject(1, userId);
				bookingStmt.setDate(2, Date.valueOf(serviceDateStr)); // yyyy-MM-dd from <input type="date">
				bookingStmt.setString(3, "PENDING");
				bookingStmt.setString(4, finalNotes);

				try (ResultSet rs = bookingStmt.executeQuery()) {
					if (!rs.next()) {
						conn.rollback();
						throw new ServletException("Failed to create booking header");
					}
					bookingId = rs.getInt("booking_id");
				}
			}

			// Insert booking_detail rows
			String insertDetailSql = "INSERT INTO booking_detail (booking_id, service_id, quantity, unit_price) "
					+ "VALUES (?, ?, ?, ?)";

			try (PreparedStatement detailStmt = conn.prepareStatement(insertDetailSql)) {
				for (CartItem item : cart) {
					detailStmt.setInt(1, bookingId);
					detailStmt.setInt(2, item.getServiceId());
					detailStmt.setInt(3, item.getQuantity());
					detailStmt.setBigDecimal(4, BigDecimal.valueOf(item.getUnitPrice()));
					detailStmt.addBatch();
				}
				detailStmt.executeBatch();
			}

			conn.commit();
			conn.setAutoCommit(true);

			// 4) Clear cart + go to bookings page (servlet)
			session.removeAttribute("cart");
			response.sendRedirect(request.getContextPath() + "/customer/bookings");

		} catch (Exception e) {
			e.printStackTrace(); // check your Tomcat console if it still fails
			response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?errCode=CheckoutError");
		}
	}
}