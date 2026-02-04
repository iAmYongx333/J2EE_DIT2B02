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
import java.sql.SQLException;

import Assignment1.DBUtil;

@WebServlet("/admin/feedback/delete")
public class AdminFeedbackDeleteServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		// ✅ Check admin session
		if (session == null || session.getAttribute("sessRole") == null
				|| !"admin".equals(session.getAttribute("sessRole"))) {

			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
			return;
		}

		String idParam = request.getParameter("feedback_id");

		if (idParam == null || idParam.trim().isEmpty()) {
			session.setAttribute("flashMessage", "Missing feedback ID.");
			response.sendRedirect(request.getContextPath() + "/admin/feedback/list");
			return;
		}

		try {
			int feedbackId = Integer.parseInt(idParam);

			String sql = "DELETE FROM feedback WHERE feedback_id = ?";

			try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

				pstmt.setInt(1, feedbackId);
				int rows = pstmt.executeUpdate();

				if (rows > 0) {
					session.setAttribute("flashMessage", "Feedback deleted successfully.");
				} else {
					session.setAttribute("flashMessage", "Feedback not found.");
				}
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		} catch (NumberFormatException e) {
			session.setAttribute("flashMessage", "Invalid feedback ID.");
		}

		response.sendRedirect(request.getContextPath() + "/admin/feedback/list");
	}

	// 🚫 Optional: Prevent delete using GET
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.sendRedirect(request.getContextPath() + "/admin/feedback/list");
	}
}
