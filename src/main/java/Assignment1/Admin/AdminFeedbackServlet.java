package Assignment1.Admin;

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
import java.util.HashMap;

import Assignment1.DBUtil;

@WebServlet("/admin/feedback")
public class AdminFeedbackServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminFeedbackServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession sess = request.getSession(false);
		if (sess == null || sess.getAttribute("sessRole") == null
				|| !"admin".equals(sess.getAttribute("sessRole").toString())) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
			return;
		}

		try (Connection conn = DBUtil.getConnection()) {

			String sql = "SELECT f.feedback_id, f.rating, f.comments, f.created_at, "
					+ "       u.name AS user_name, s.service_name " + "FROM feedback f "
					+ "JOIN users   u ON f.user_id    = u.user_id " + "JOIN service s ON f.service_id = s.service_id "
					+ "ORDER BY f.created_at DESC";

			PreparedStatement ps = conn.prepareStatement(sql);
			ResultSet rs = ps.executeQuery();

			ArrayList<HashMap<String, Object>> feedbackList = new ArrayList<>();

			while (rs.next()) {
				HashMap<String, Object> row = new HashMap<>();
				row.put("feedbackId", rs.getInt("feedback_id"));
				row.put("rating", rs.getInt("rating"));
				row.put("comments", rs.getString("comments"));
				row.put("createdAt", rs.getTimestamp("created_at"));
				row.put("userName", rs.getString("user_name"));
				row.put("serviceName", rs.getString("service_name"));
				feedbackList.add(row);
			}

			request.setAttribute("feedbackList", feedbackList);
			request.getRequestDispatcher("/admin/manage_feedback.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/dashboard?errCode=FeedbackError");
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}