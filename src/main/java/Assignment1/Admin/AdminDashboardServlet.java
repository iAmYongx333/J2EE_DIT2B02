package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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
 * Admin servlet for dashboard statistics via API.
 * Fetches data from GET /api/admin/dashboard (Spring Boot API)
 * Response format: {"success":true,"message":"...","data":{totalCustomers,totalServices,...,recentFeedback:[...]}}
 * URL: /admin/dashboard
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String API_URL = "http://localhost:8081/api/admin/dashboard";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			Client client = ClientBuilder.newClient();
			WebTarget target = client.target(API_URL);
			Response apiResp = target.request(MediaType.APPLICATION_JSON).get();

			if (apiResp.getStatus() == 200) {
				String json = apiResp.readEntity(String.class);
				JsonReader reader = Json.createReader(new StringReader(json));
				JsonObject root = reader.readObject();
				reader.close();

				if (root.getBoolean("success", false)) {
					JsonObject data = root.getJsonObject("data");

					request.setAttribute("totalCustomers", data.getInt("totalCustomers", 0));
					request.setAttribute("totalServices", data.getInt("totalServices", 0));
					request.setAttribute("totalFeedback", data.getInt("totalFeedback", 0));
					request.setAttribute("recentUsers", data.getInt("recentUsers", 0));

					// Parse recent feedback array
					ArrayList<HashMap<String, String>> feedbackList = new ArrayList<>();
					if (data.containsKey("recentFeedback") && !data.isNull("recentFeedback")) {
						JsonArray fbArray = data.getJsonArray("recentFeedback");
						for (int i = 0; i < fbArray.size(); i++) {
							JsonObject fb = fbArray.getJsonObject(i);
							HashMap<String, String> map = new HashMap<>();
							map.put("userName", fb.getString("userName", ""));
							map.put("serviceName", fb.getString("serviceName", ""));
							map.put("comments", fb.getString("comments", ""));
							map.put("createdAt", fb.getString("createdAt", ""));
							feedbackList.add(map);
						}
					}
					request.setAttribute("recentFeedback", feedbackList);
				} else {
					setDefaults(request);
				}
			} else {
				setDefaults(request);
			}
			client.close();

		} catch (Exception e) {
			e.printStackTrace();
			setDefaults(request);
		}

		request.getRequestDispatcher("/admin/admin_dashboard.jsp").forward(request, response);
	}

	private void setDefaults(HttpServletRequest request) {
		request.setAttribute("totalCustomers", 0);
		request.setAttribute("totalServices", 0);
		request.setAttribute("totalFeedback", 0);
		request.setAttribute("recentUsers", 0);
		request.setAttribute("recentFeedback", new ArrayList<>());
	}
}