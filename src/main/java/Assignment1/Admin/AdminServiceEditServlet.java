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
 * Admin servlet for editing a service via API.
 * URL: /admin/services/edit
 */
@WebServlet("/admin/services/edit")
public class AdminServiceEditServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminServiceEditServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			int serviceId = Integer.parseInt(request.getParameter("id"));

			// Fetch service from API
			Service service = ApiClient.get("/services/" + serviceId, Service.class);

			if (service != null) {
				request.setAttribute("service", service);
			}

			request.getRequestDispatcher("/admin/adminEditService.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=API_ERROR");
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			int serviceId = Integer.parseInt(request.getParameter("service_id"));
			int categoryId = Integer.parseInt(request.getParameter("category_id"));
			String name = request.getParameter("service_name");
			String description = request.getParameter("description");
			double price = Double.parseDouble(request.getParameter("price"));
			int duration = Integer.parseInt(request.getParameter("duration_min"));
			String imagePath = request.getParameter("image_path");

			// Build service object
			Service service = new Service(serviceId, categoryId, name, description, price, duration, imagePath);

			// PUT to API
			int status = ApiClient.put("/services/" + serviceId, service);

			if (status == 200) {
				response.sendRedirect(request.getContextPath() + "/admin/services/list");
			} else {
				response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=UpdateFailed");
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=API_ERROR");
		}
	}
}