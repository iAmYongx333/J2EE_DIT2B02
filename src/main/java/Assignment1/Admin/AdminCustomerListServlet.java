package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;

import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;

/**
 * Admin servlet for listing all customers via API.
 * Calls GET /api/admin/customers — response wrapped in {success, message, data:[...]}
 * URL: /admin/customers/list
 */
@WebServlet("/admin/customers/list")
public class AdminCustomerListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String API_URL = "http://localhost:8081/api/admin/customers";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		Object role = session != null ? session.getAttribute("sessRole") : null;
		if (role == null || !"admin".equalsIgnoreCase(role.toString())) {
			response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
			return;
		}

		ArrayList<HashMap<String, String>> customers = new ArrayList<>();

		try {
			Client client = ClientBuilder.newClient();
			WebTarget target = client.target(API_URL);
			Response apiResp = target.request(MediaType.APPLICATION_JSON).get();

			if (apiResp.getStatus() == 200) {
				String json = apiResp.readEntity(String.class);
				JsonReader reader = Json.createReader(new StringReader(json));
				JsonObject root = reader.readObject();
				reader.close();

				if (root.getBoolean("success", false) && !root.isNull("data")) {
					JsonArray dataArr = root.getJsonArray("data");
					for (int i = 0; i < dataArr.size(); i++) {
						JsonObject c = dataArr.getJsonObject(i);
						HashMap<String, String> map = new HashMap<>();
						map.put("userId", c.getString("userId", ""));
						map.put("name", c.getString("name", ""));
						map.put("email", c.getString("email", ""));
						map.put("phone", c.getString("phone", ""));
						map.put("createdAt", c.getString("createdAt", ""));
						map.put("countryName", c.getString("countryName", ""));
						map.put("flagImage", c.getString("flagImage", ""));
						customers.add(map);
					}
				}
			}
			client.close();

		} catch (Exception e) {
			e.printStackTrace();
		}

		request.setAttribute("customers", customers);
		request.getRequestDispatcher("/admin/manage_customers.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}