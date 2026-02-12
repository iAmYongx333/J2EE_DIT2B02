package Assignment1.Admin;

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
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;

import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import jakarta.json.JsonValue;

/**
 * Admin servlet for listing all payments by querying Stripe API directly.
 * Fetches PaymentIntents with expanded latest_charge to get billing details.
 * URL: /admin/payments/list
 */
@WebServlet("/admin/payments/list")
public class AdminPaymentListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String STRIPE_API = "https://api.stripe.com/v1";
	private static final String STRIPE_SECRET_KEY = System.getenv("STRIPE_SECRET_KEY");

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		Object role = session != null ? session.getAttribute("sessRole") : null;
		if (role == null || !"admin".equalsIgnoreCase(role.toString())) {
			response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
			return;
		}

		ArrayList<HashMap<String, String>> payments = new ArrayList<>();
		HashMap<String, String> stats = new HashMap<>();

		Client client = ClientBuilder.newClient();

		try {
			// Fetch PaymentIntents from Stripe with expanded latest_charge
			Response stripeResp = client
					.target(STRIPE_API + "/payment_intents")
					.queryParam("limit", "100")
					.queryParam("expand[]", "data.latest_charge")
					.request(MediaType.APPLICATION_JSON)
					.header("Authorization", "Bearer " + STRIPE_SECRET_KEY)
					.get();

			String json = stripeResp.readEntity(String.class);
			System.out.println("[AdminPayments] Stripe status: " + stripeResp.getStatus()
					+ ", length: " + (json != null ? json.length() : 0));

			if (stripeResp.getStatus() == 200 && json != null) {
				JsonReader reader = Json.createReader(new StringReader(json));
				JsonObject root = reader.readObject();
				reader.close();

				JsonArray dataArr = root.getJsonArray("data");

				long totalAmountCents = 0;
				long totalRefundedCents = 0;
				int succeededCount = 0;

				DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'")
						.withZone(ZoneId.of("UTC"));

				if (dataArr != null) {
					for (int i = 0; i < dataArr.size(); i++) {
						JsonObject pi = dataArr.getJsonObject(i);
						HashMap<String, String> map = new HashMap<>();

						String piId = safeString(pi, "id");
						long amount = pi.containsKey("amount") ? pi.getJsonNumber("amount").longValue() : 0;
						long amountReceived = pi.containsKey("amount_received") ? pi.getJsonNumber("amount_received").longValue() : 0;
						String currency = safeString(pi, "currency");
						String status = safeString(pi, "status");
						String description = safeString(pi, "description");
						long created = pi.containsKey("created") ? pi.getJsonNumber("created").longValue() : 0;

						// Get billing details from expanded latest_charge
						String customerName = "";
						String customerEmail = "";
						long refundedAmount = 0;
						if (pi.containsKey("latest_charge") && !pi.isNull("latest_charge")) {
							JsonValue lcVal = pi.get("latest_charge");
							if (lcVal.getValueType() == JsonValue.ValueType.OBJECT) {
								JsonObject charge = lcVal.asJsonObject();
								if (charge.containsKey("billing_details") && !charge.isNull("billing_details")) {
									JsonObject bd = charge.getJsonObject("billing_details");
									customerName = safeString(bd, "name");
									customerEmail = safeString(bd, "email");
								}
								refundedAmount = charge.containsKey("amount_refunded")
										? charge.getJsonNumber("amount_refunded").longValue() : 0;
							}
						}

						// Get bookingId from metadata
						String bookingId = "";
						if (pi.containsKey("metadata") && !pi.isNull("metadata")) {
							JsonObject meta = pi.getJsonObject("metadata");
							bookingId = safeString(meta, "bookingId");
						}

						String createdAt = created > 0
								? dtf.format(Instant.ofEpochSecond(created)) : "";

						map.put("paymentIntentId", piId);
						map.put("amount", String.valueOf(amount));
						map.put("currency", currency.toUpperCase());
						map.put("status", status);
						map.put("customerName", customerName);
						map.put("customerEmail", customerEmail);
						map.put("bookingId", bookingId);
						map.put("createdAt", createdAt);
						map.put("description", description);
						map.put("refundedAmount", String.valueOf(refundedAmount));
						payments.add(map);

						// Accumulate stats
						if ("succeeded".equals(status)) {
							succeededCount++;
							totalAmountCents += amountReceived > 0 ? amountReceived : amount;
						}
						totalRefundedCents += refundedAmount;
					}
				}

				// Compute stats
				stats.put("totalPayments", String.valueOf(succeededCount));
				stats.put("totalAmount", String.valueOf(totalAmountCents));
				stats.put("totalRefunded", String.valueOf(totalRefundedCents));
				long avg = succeededCount > 0 ? totalAmountCents / succeededCount : 0;
				stats.put("averagePaymentAmount", String.valueOf(avg));
				stats.put("count", String.valueOf(payments.size()));

				System.out.println("[AdminPayments] Loaded " + payments.size()
						+ " payment intents, " + succeededCount + " succeeded");
			}

		} catch (Exception e) {
			System.out.println("[AdminPayments] ERROR: " + e.getMessage());
			e.printStackTrace();
		} finally {
			client.close();
		}

		request.setAttribute("payments", payments);
		request.setAttribute("paymentStats", stats);
		request.getRequestDispatcher("/admin/admin_payments.jsp").forward(request, response);
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
