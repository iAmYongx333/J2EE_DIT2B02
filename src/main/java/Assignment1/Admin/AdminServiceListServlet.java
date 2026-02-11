package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.ws.rs.core.GenericType;

import java.io.IOException;
import java.util.ArrayList;

import Assignment1.Category;
import Assignment1.Service.Service;
import Assignment1.api.ApiClient;

/**
 * Admin servlet for listing all services via API.
 * URL: /admin/services/list
 */
@WebServlet("/admin/services/list")
public class AdminServiceListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminServiceListServlet() {
		super();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			// Fetch services from API
			ArrayList<Service> serviceList = ApiClient.getList(
				"/services",
				new GenericType<ArrayList<Service>>() {}
			);

			// Fetch categories from API
			ArrayList<Category> categoryList = ApiClient.getList(
				"/categories",
				new GenericType<ArrayList<Category>>() {}
			);

			request.setAttribute("serviceList", serviceList);
			request.setAttribute("categoryList", categoryList);

			request.getRequestDispatcher("/admin/admin_services.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/admin_services.jsp?errCode=API_ERROR");
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}