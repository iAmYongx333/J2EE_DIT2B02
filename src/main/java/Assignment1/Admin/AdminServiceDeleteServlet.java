package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import Assignment1.api.ApiClient;

/**
 * Admin servlet for deleting a service via API.
 * URL: /admin/services/delete
 */
@WebServlet("/admin/services/delete")
public class AdminServiceDeleteServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminServiceDeleteServlet() {
		super();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			int serviceId = Integer.parseInt(request.getParameter("service_id"));

			// DELETE via API
			int status = ApiClient.delete("/services/" + serviceId);

			if (status == 200 || status == 204) {
				response.sendRedirect(request.getContextPath() + "/admin/services/list");
			} else {
				response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=DeleteFailed");
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=API_ERROR");
		}
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			String idParam = request.getParameter("service_id");
			if (idParam == null || idParam.isBlank()) {
				idParam = request.getParameter("id");
			}

			int serviceId = Integer.parseInt(idParam);

			// DELETE via API
			int status = ApiClient.delete("/services/" + serviceId);

			if (status == 200 || status == 204) {
				response.sendRedirect(request.getContextPath() + "/admin/services/list");
			} else {
				response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=DeleteFailed");
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=API_ERROR");
		}
	}
}