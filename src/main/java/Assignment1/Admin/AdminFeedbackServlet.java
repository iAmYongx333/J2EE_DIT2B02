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
 * Admin servlet for listing all feedback via API.
 * Calls GET /api/admin/feedback — response wrapped in {success, message, data:[...]}
 * URL: /admin/feedback
 */
@WebServlet("/admin/feedback")
public class AdminFeedbackServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String API_URL = "http://localhost:8081/api/admin/feedback";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession sess = request.getSession(false);
		if (sess == null || sess.getAttribute("sessRole") == null
				|| !"admin".equals(sess.getAttribute("sessRole").toString())) {
			response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
			return;
		}

		ArrayList<HashMap<String, String>> feedbackList = new ArrayList<>();

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
						JsonObject fb = dataArr.getJsonObject(i);
						HashMap<String, String> map = new HashMap<>();
						map.put("feedbackId", String.valueOf(fb.getInt("feedbackId", 0)));
						map.put("rating", String.valueOf(fb.getInt("rating", 0)));
						map.put("comments", fb.getString("comments", ""));
						map.put("createdAt", fb.getString("createdAt", ""));
						map.put("userName", fb.getString("userName", ""));
						map.put("serviceName", fb.getString("serviceName", ""));
						feedbackList.add(map);
					}
				}
			}
			client.close();

		} catch (Exception e) {
			e.printStackTrace();
		}

		request.setAttribute("feedbackList", feedbackList);
		request.getRequestDispatcher("/admin/manage_feedback.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}