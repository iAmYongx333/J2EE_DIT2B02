package Assignment1.Admin;

import Assignment1.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminDashboardServlet() {
		super();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try (Connection conn = DBUtil.getConnection()) {

			// ===== TOTAL CUSTOMERS =====
			int totalCustomers = 0;
			String q1 = "SELECT COUNT(*) FROM users WHERE user_role = 'customer'";
			try (PreparedStatement ps = conn.prepareStatement(q1)) {
				ResultSet rs = ps.executeQuery();
				if (rs.next())
					totalCustomers = rs.getInt(1);
			}

			// ===== TOTAL SERVICES =====
			int totalServices = 0;
			String q2 = "SELECT COUNT(*) FROM service";
			try (PreparedStatement ps = conn.prepareStatement(q2)) {
				ResultSet rs = ps.executeQuery();
				if (rs.next())
					totalServices = rs.getInt(1);
			}

			// ===== TOTAL FEEDBACK =====
			int totalFeedback = 0;
			String q3 = "SELECT COUNT(*) FROM feedback";
			try (PreparedStatement ps = conn.prepareStatement(q3)) {
				ResultSet rs = ps.executeQuery();
				if (rs.next())
					totalFeedback = rs.getInt(1);
			}

			// ===== RECENT USERS (last 30 days) =====
			int recentUsers = 0;
			String q4 = "SELECT COUNT(*) FROM users WHERE created_at >= NOW() - INTERVAL '30 days'";
			try (PreparedStatement ps = conn.prepareStatement(q4)) {
				ResultSet rs = ps.executeQuery();
				if (rs.next())
					recentUsers = rs.getInt(1);
			}

			// ===== RECENT FEEDBACK (latest 5) =====
			ArrayList<HashMap<String, String>> recentFeedback = new ArrayList<>();
			String q5 = "SELECT f.comments, f.created_at, u.name AS user_name, s.service_name " + "FROM feedback f "
					+ "JOIN users u ON u.user_id = f.user_id " + "JOIN service s ON s.service_id = f.service_id "
					+ "ORDER BY f.created_at DESC " + "LIMIT 5";

			try (PreparedStatement ps = conn.prepareStatement(q5)) {
				ResultSet rs = ps.executeQuery();
				while (rs.next()) {
					HashMap<String, String> map = new HashMap<>();
					map.put("comments", rs.getString("comments"));
					map.put("created_at", rs.getString("created_at"));
					map.put("user_name", rs.getString("user_name"));
					map.put("service_name", rs.getString("service_name"));
					recentFeedback.add(map);
				}
			}

			// SEND DATA TO JSP
			request.setAttribute("totalCustomers", totalCustomers);
			request.setAttribute("totalServices", totalServices);
			request.setAttribute("totalFeedback", totalFeedback);
			request.setAttribute("recentUsers", recentUsers);
			request.setAttribute("recentFeedback", recentFeedback);

			request.getRequestDispatcher("/admin/admin_dashboard.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/error.jsp?err=dashboard");
		}
	}
}