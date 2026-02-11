package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.ws.rs.core.GenericType;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import Assignment1.api.ApiClient;

/**
 * Admin servlet for listing all customers via API.
 * URL: /admin/customers/list
 */
@WebServlet("/admin/customers/list")
public class AdminCustomerListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminCustomerListServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			// Fetch customers from API
			ArrayList<HashMap<String, Object>> customers = ApiClient.getList(
				"/customers",
				new GenericType<ArrayList<HashMap<String, Object>>>() {}
			);

			request.setAttribute("customers", customers);
			request.getRequestDispatcher("/admin/manage_customers.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/manage_customers.jsp?errCode=API_ERROR");
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}