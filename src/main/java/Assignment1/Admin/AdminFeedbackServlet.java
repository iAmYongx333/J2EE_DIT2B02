package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.core.GenericType;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import Assignment1.api.ApiClient;

/**
 * Admin servlet for listing all feedback via API.
 * URL: /admin/feedback
 */
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

		try {
			// Fetch feedback from API
			ArrayList<HashMap<String, Object>> feedbackList = ApiClient.getList(
				"/feedback",
				new GenericType<ArrayList<HashMap<String, Object>>>() {}
			);

			request.setAttribute("feedbackList", feedbackList);
			request.getRequestDispatcher("/admin/manage_feedback.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/dashboard?errCode=API_ERROR");
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}