package Assignment1.Service;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.UUID;

import Assignment1.DBUtil;
import Assignment1.Feedback;

@WebServlet("/serviceDetailServlet")
public class ServiceDetailServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			HttpSession session = request.getSession();

			int serviceId = Integer.parseInt(request.getParameter("serviceId"));

			Connection conn = DBUtil.getConnection();

			/*
			 * ========================= GET SERVICE DETAILS =========================
			 */
			String sqlStr = "SELECT * FROM service WHERE service_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sqlStr);
			pstmt.setInt(1, serviceId);

			ResultSet rs = pstmt.executeQuery();
			Service s = null;

			if (rs.next()) {
				s = new Service(rs.getInt("service_id"), rs.getInt("category_id"), rs.getString("service_name"),
						rs.getString("description"), rs.getDouble("price"), rs.getInt("duration_min"),
						rs.getString("image_path"));
			}

			if (s == null) {
				response.sendRedirect(request.getContextPath() + "/serviceServlet?errCode=notfound");
				return;
			}

			/*
			 * ========================= GET SERVICE FEEDBACK =========================
			 */
			String feedbackSql = "SELECT f.feedback_id, f.user_id, f.service_id, f.rating, f.comments, f.created_at, u.name AS user_name "
					+ "FROM feedback f " + "JOIN users u ON f.user_id = u.user_id " + "WHERE f.service_id = ? "
					+ "ORDER BY f.created_at DESC";

			PreparedStatement feedbackStmt = conn.prepareStatement(feedbackSql);
			feedbackStmt.setInt(1, serviceId);

			ResultSet frs = feedbackStmt.executeQuery();

			ArrayList<Feedback> feedbackList = new ArrayList<>();

			while (frs.next()) {
				Feedback f = new Feedback(frs.getInt("feedback_id"), frs.getString("user_id"), frs.getInt("service_id"),
						frs.getInt("rating"), frs.getString("comments"), frs.getTimestamp("created_at"),
						frs.getString("user_name"));

				feedbackList.add(f);
			}

			/*
			 * ========================= STORE TO SESSION =========================
			 */
			session.setAttribute("service", s);
			session.setAttribute("feedbackList", feedbackList);

			conn.close();

			response.sendRedirect(request.getContextPath() + "/public/service_details.jsp");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/public/services.jsp?errCode=" + e);
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			HttpSession session = request.getSession(false);

			if (session == null || session.getAttribute("sessId") == null) {
				response.sendRedirect(request.getContextPath() + "/public/service_details.jsp?serviceId="
						+ request.getParameter("serviceId") + "&errCode=notLoggedIn");
				return;
			}

			UUID userId = UUID.fromString(session.getAttribute("sessId").toString());
			int serviceId = Integer.parseInt(request.getParameter("serviceId"));
			int rating = Integer.parseInt(request.getParameter("rating"));
			String comments = request.getParameter("comments");

			if (rating < 1 || rating > 5) {
				response.sendRedirect(request.getContextPath() + "/public/service_details.jsp?serviceId=" + serviceId
						+ "&errCode=invalidRating");
				return;
			}

			Connection conn = DBUtil.getConnection();

			String insertSql = "INSERT INTO feedback (user_id, service_id, rating, comments, created_at) "
					+ "VALUES (?, ?, ?, ?, NOW())";

			PreparedStatement pstmt = conn.prepareStatement(insertSql);
			pstmt.setObject(1, userId);
			pstmt.setInt(2, serviceId);
			pstmt.setInt(3, rating);
			pstmt.setString(4, comments);

			pstmt.executeUpdate();
			conn.close();

			// Reload page to show new feedback
			response.sendRedirect(request.getContextPath() + "/public/service_details.jsp?serviceId=" + serviceId);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/public/services.jsp?errCode=" + e);
		}
	}
}
