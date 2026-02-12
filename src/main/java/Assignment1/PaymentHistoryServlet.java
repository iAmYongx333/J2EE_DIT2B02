package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
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
import jakarta.json.JsonValue;

/**
 * Servlet for customer payment history.
 * Fetches payments from the backend API by user ID.
 * URL: /customer/payments
 */
@WebServlet("/customer/payments")
public class PaymentHistoryServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String BACKEND_API = "http://localhost:8081/api";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("sessId") == null) {
			response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
			return;
		}

		String userId = session.getAttribute("sessId").toString();
		ArrayList<HashMap<String, String>> payments = new ArrayList<>();

		Client client = ClientBuilder.newClient();
		try {
			Response apiResp = client.target(BACKEND_API + "/payments/history/" + userId)
					.request(MediaType.APPLICATION_JSON).get();

			String json = apiResp.readEntity(String.class);
			System.out.println("[PaymentHistory] API status " + apiResp.getStatus()
					+ ", response length: " + (json != null ? json.length() : 0));

			if (apiResp.getStatus() == 200 && json != null && !json.isBlank()) {
				JsonReader reader = Json.createReader(new StringReader(json));
				JsonValue root = reader.read();
				reader.close();

				JsonArray dataArr = null;
				if (root.getValueType() == JsonValue.ValueType.ARRAY) {
					dataArr = root.asJsonArray();
				} else if (root.getValueType() == JsonValue.ValueType.OBJECT) {
					JsonObject obj = root.asJsonObject();
					if (obj.containsKey("data") && !obj.isNull("data")
							&& obj.get("data").getValueType() == JsonValue.ValueType.ARRAY) {
						dataArr = obj.getJsonArray("data");
					}
				}

				if (dataArr != null) {
					for (int i = 0; i < dataArr.size(); i++) {
						JsonObject p = dataArr.getJsonObject(i);
						HashMap<String, String> map = new HashMap<>();

						map.put("paymentId", safeString(p, "paymentId"));
						map.put("paymentIntentId", safeString(p, "paymentIntentId"));
						map.put("amount", safeString(p, "amount"));
						String currency = safeString(p, "currency");
						map.put("currency", currency.toUpperCase());
						map.put("status", safeString(p, "status"));
						map.put("bookingId", safeString(p, "bookingId"));
						map.put("createdAt", safeString(p, "createdAt"));

						// Sum refunds from the refunds list if present
						long totalRefunded = 0;
						if (p.containsKey("refunds") && !p.isNull("refunds")
								&& p.get("refunds").getValueType() == JsonValue.ValueType.ARRAY) {
							JsonArray refunds = p.getJsonArray("refunds");
							for (int j = 0; j < refunds.size(); j++) {
								JsonObject r = refunds.getJsonObject(j);
								if (r.containsKey("amount") && !r.isNull("amount")) {
									totalRefunded += r.getJsonNumber("amount").longValue();
								}
							}
						}
						// Fallback: use amountRefunded if present directly
						if (totalRefunded == 0 && p.containsKey("amountRefunded") && !p.isNull("amountRefunded")) {
							totalRefunded = p.getJsonNumber("amountRefunded").longValue();
						}
						map.put("totalRefunded", String.valueOf(totalRefunded));

						payments.add(map);
					}
				}
			}

			System.out.println("[PaymentHistory] Found " + payments.size()
					+ " payments for user " + userId);

		} catch (Exception e) {
			System.out.println("[PaymentHistory] ERROR: " + e.getMessage());
			e.printStackTrace();
		} finally {
			client.close();
		}

		request.setAttribute("payments", payments);
		request.getRequestDispatcher("/customer/payment_history.jsp").forward(request, response);
	}

	private String safeString(JsonObject obj, String key) {
		if (!obj.containsKey(key) || obj.isNull(key)) return "";
		JsonValue val = obj.get(key);
		switch (val.getValueType()) {
			case STRING: return obj.getString(key);
			case NUMBER: return String.valueOf(obj.getJsonNumber(key));
			case TRUE: return "true";
			case FALSE: return "false";
			default: return val.toString();
		}
	}
}
