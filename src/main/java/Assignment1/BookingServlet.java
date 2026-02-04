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
import java.util.UUID;

@WebServlet("/customer/bookings")
public class BookingServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("sessId") == null) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
			return;
		}

		UUID userId = UUID.fromString(session.getAttribute("sessId").toString());
		ArrayList<Booking> bookings = new ArrayList<>();

		try (Connection conn = DBUtil.getConnection()) {
			String sql = "SELECT b.booking_id, b.scheduled_at, b.status, b.notes, "
					+ "       bd.service_id, s.service_name, bd.quantity, bd.unit_price " + "FROM booking b "
					+ "JOIN booking_detail bd ON bd.booking_id = b.booking_id "
					+ "JOIN service s ON s.service_id = bd.service_id " + "WHERE b.user_id = ? "
					+ "ORDER BY b.scheduled_at DESC, b.booking_id DESC, bd.booking_detail_id";

			PreparedStatement stmt = conn.prepareStatement(sql);
			stmt.setObject(1, userId);
			ResultSet rs = stmt.executeQuery();

			Booking current = null;

			while (rs.next()) {
				int bookingId = rs.getInt("booking_id");

				if (current == null || current.getBookingId() != bookingId) {
					current = new Booking(bookingId, rs.getDate("scheduled_at"), rs.getString("status"),
							rs.getString("notes"));
					bookings.add(current);
				}

				BookingDetail detail = new BookingDetail(rs.getInt("service_id"), rs.getString("service_name"),
						rs.getInt("quantity"), rs.getBigDecimal("unit_price"));
				current.getBookingDetails().add(detail);
			}

			rs.close();
			stmt.close();
		} catch (Exception e) {
			e.printStackTrace();
			throw new ServletException("Error retrieving bookings", e);
		}

		request.setAttribute("bookings", bookings);
		request.getRequestDispatcher("/customer/bookings.jsp").forward(request, response);
	}
}