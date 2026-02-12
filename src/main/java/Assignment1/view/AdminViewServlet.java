package Assignment1.view;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/admin", "/admin/services", "/admin/customers", "/admin/bookings"})
public class AdminViewServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		Object role = session != null ? session.getAttribute("sessRole") : null;
		
		// Check if user is admin
		if (role == null || !"admin".equalsIgnoreCase(role.toString())) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		String path = request.getServletPath();
		String jspPath;

		switch (path) {
			case "/admin/services":
				jspPath = "/admin/admin_services.jsp";
				break;
			case "/admin/customers":
				jspPath = "/admin/manage_customers.jsp";
				break;
			case "/admin/bookings":
				jspPath = "/admin/admin_booking.jsp";
				break;
			case "/admin":
				// Redirect to dashboard servlet so it fetches API data first
				response.sendRedirect(request.getContextPath() + "/admin/dashboard");
				return;
			default:
				jspPath = "/admin/admin_dashboard.jsp";
		}

		request.getRequestDispatcher(jspPath).forward(request, response);
	}
}
