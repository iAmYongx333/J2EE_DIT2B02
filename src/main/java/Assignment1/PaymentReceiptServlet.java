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
import java.util.HashMap;

import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import jakarta.json.JsonValue;

/**
 * Servlet for viewing a payment receipt.
 * GET /api/payments/receipts/{paymentId}
 * URL: /customer/payments/receipt?id={paymentId}
 */
@WebServlet("/customer/payments/receipt")
public class PaymentReceiptServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String API_BASE = "http://localhost:8081/api";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("sessId") == null) {
			response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
			return;
		}

		String paymentId = request.getParameter("id");
		if (paymentId == null || paymentId.isBlank()) {
			response.sendRedirect(request.getContextPath() + "/customer/payments");
			return;
		}

		HashMap<String, String> receipt = new HashMap<>();
		Client client = ClientBuilder.newClient();

		try {
			Response apiResp = client.target(API_BASE + "/payments/receipts/" + paymentId)
					.request(MediaType.APPLICATION_JSON).get();

			if (apiResp.getStatus() == 200) {
				String json = apiResp.readEntity(String.class);
				JsonReader reader = Json.createReader(new StringReader(json));
				JsonObject root = reader.readObject();
				reader.close();

				JsonObject data = root;
				if (root.containsKey("data") && !root.isNull("data")) {
					data = root.getJsonObject("data");
				}

				receipt.put("paymentId", safeString(data, "paymentId"));
				receipt.put("paymentIntentId", safeString(data, "paymentIntentId"));
				receipt.put("amount", safeString(data, "amount"));
				receipt.put("currency", safeString(data, "currency"));
				receipt.put("status", safeString(data, "status"));
				receipt.put("createdAt", safeString(data, "createdAt"));
				receipt.put("customerName", safeString(data, "customerName"));
				receipt.put("customerEmail", safeString(data, "customerEmail"));
				receipt.put("serviceName", safeString(data, "serviceName"));
				receipt.put("quantity", safeString(data, "quantity"));
				receipt.put("unitPrice", safeString(data, "unitPrice"));
				receipt.put("amountRefunded", safeString(data, "amountRefunded"));
				receipt.put("remainingBalance", safeString(data, "remainingBalance"));

			} else if (apiResp.getStatus() == 404) {
				request.setAttribute("errorMessage", "Payment receipt not found.");
			} else {
				request.setAttribute("errorMessage", "Failed to load receipt.");
			}

		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("errorMessage", "Error loading receipt.");
		} finally {
			client.close();
		}

		request.setAttribute("receipt", receipt);
		request.getRequestDispatcher("/customer/payment_receipt.jsp").forward(request, response);
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
