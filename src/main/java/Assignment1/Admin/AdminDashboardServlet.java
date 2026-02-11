package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.ws.rs.core.GenericType;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import Assignment1.api.ApiClient;
import Assignment1.dto.DashboardStats;

/**
 * Admin servlet for dashboard statistics via API.
 * URL: /admin/dashboard
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminDashboardServlet() {
		super();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			// Fetch dashboard stats from API
			DashboardStats stats = ApiClient.get("/admin/dashboard/stats", DashboardStats.class);

			if (stats != null) {
				request.setAttribute("totalCustomers", stats.getTotalCustomers());
				request.setAttribute("totalServices", stats.getTotalServices());
				request.setAttribute("totalFeedback", stats.getTotalFeedback());
				request.setAttribute("recentUsers", stats.getRecentUsers());
			} else {
				request.setAttribute("totalCustomers", 0);
				request.setAttribute("totalServices", 0);
				request.setAttribute("totalFeedback", 0);
				request.setAttribute("recentUsers", 0);
			}

			// Fetch recent feedback from API
			ArrayList<HashMap<String, Object>> recentFeedback = ApiClient.getList(
				"/feedback/recent?limit=5",
				new GenericType<ArrayList<HashMap<String, Object>>>() {}
			);

			request.setAttribute("recentFeedback", recentFeedback != null ? recentFeedback : new ArrayList<>());

			request.getRequestDispatcher("/admin/admin_dashboard.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/error.jsp?err=dashboard");
		}
	}
}