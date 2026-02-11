package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import Assignment1.api.ApiClient;

/**
 * Admin servlet for deleting feedback via API.
 * URL: /admin/feedback/delete
 */
@WebServlet("/admin/feedback/delete")
public class AdminFeedbackDeleteServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		// Check admin session
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

			// DELETE via API
			int status = ApiClient.delete("/feedback/" + feedbackId);

			if (status == 200 || status == 204) {
				session.setAttribute("flashMessage", "Feedback deleted successfully.");
			} else {
				session.setAttribute("flashMessage", "Failed to delete feedback.");
			}

		} catch (NumberFormatException e) {
			session.setAttribute("flashMessage", "Invalid feedback ID.");
		} catch (Exception e) {
			e.printStackTrace();
			session.setAttribute("flashMessage", "API error occurred.");
		}

		response.sendRedirect(request.getContextPath() + "/admin/feedback/list");
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.sendRedirect(request.getContextPath() + "/admin/feedback/list");
	}
}
