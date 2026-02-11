package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import Assignment1.Service.Service;
import Assignment1.api.ApiClient;

/**
 * Admin servlet for creating a new service via API.
 * URL: /admin/services/create
 */
@WebServlet("/admin/services/create")
public class AdminServiceCreateServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminServiceCreateServlet() {
		super();
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			int categoryId = Integer.parseInt(request.getParameter("category_id"));
			String name = request.getParameter("service_name");
			String description = request.getParameter("description");
			double price = Double.parseDouble(request.getParameter("price"));
			int duration = Integer.parseInt(request.getParameter("duration_min"));
			String imagePath = request.getParameter("image_path");

			// Build service object
			Service service = new Service(0, categoryId, name, description, price, duration, imagePath);

			// POST to API
			int status = ApiClient.post("/services", service);

			if (status == 200 || status == 201) {
				response.sendRedirect(request.getContextPath() + "/admin/services/list");
			} else {
				response.sendRedirect(request.getContextPath() + "/admin/adminAddService.jsp?errCode=CreateFailed");
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/adminAddService.jsp?errCode=API_ERROR");
		}
	}
}