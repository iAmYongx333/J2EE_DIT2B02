package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.core.GenericType;

import java.io.IOException;
import java.util.ArrayList;
import java.util.UUID;

import Assignment1.api.ApiClient;

/**
 * Servlet for fetching user bookings via API.
 * URL: /customer/bookings
 */
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

		try {
			// Fetch bookings from API
			ArrayList<Booking> bookings = ApiClient.getList(
				"/bookings/user/" + userId,
				new GenericType<ArrayList<Booking>>() {}
			);

			request.setAttribute("bookings", bookings);
			request.getRequestDispatcher("/customer/bookings.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("errCode", "BOOKING_FETCH_ERROR");
			request.getRequestDispatcher("/customer/bookings.jsp").forward(request, response);
		}
	}
}