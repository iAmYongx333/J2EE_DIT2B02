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
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import jakarta.json.JsonValue;

/**
 * Servlet for customer payment history.
 * Fetches the user's bookingIds from the backend API, then fetches
 * PaymentIntents from Stripe and filters by matching bookingId in metadata.
 * URL: /customer/payments
 */
@WebServlet("/customer/payments")
public class PaymentHistoryServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String BACKEND_API = "http://localhost:8081/api";
	private static final String STRIPE_API = "https://api.stripe.com/v1";
	private static final String STRIPE_SECRET_KEY = System.getenv("STRIPE_SECRET_KEY");

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
			// Step 1: Get the user's booking IDs from backend
			Set<String> userBookingIds = new HashSet<>();
			Response bookingsResp = client.target(BACKEND_API + "/bookings/user/" + userId)
					.request(MediaType.APPLICATION_JSON).get();

			if (bookingsResp.getStatus() == 200) {
				String bookingsJson = bookingsResp.readEntity(String.class);
				if (bookingsJson != null && !bookingsJson.isBlank()) {
					JsonReader br = Json.createReader(new StringReader(bookingsJson));
					JsonValue bRoot = br.read();
					br.close();

					JsonArray bArr = null;
					if (bRoot.getValueType() == JsonValue.ValueType.ARRAY) {
						bArr = bRoot.asJsonArray();
					} else if (bRoot.getValueType() == JsonValue.ValueType.OBJECT) {
						JsonObject bObj = bRoot.asJsonObject();
						if (bObj.containsKey("data") && !bObj.isNull("data")) {
							bArr = bObj.getJsonArray("data");
						}
					}

					if (bArr != null) {
						for (int i = 0; i < bArr.size(); i++) {
							JsonObject b = bArr.getJsonObject(i);
							if (b.containsKey("bookingId")) {
								userBookingIds.add(String.valueOf(b.getInt("bookingId")));
							}
						}
					}
				}
			}

			System.out.println("[PaymentHistory] User " + userId + " has "
					+ userBookingIds.size() + " booking IDs: " + userBookingIds);

			// Step 2: Fetch PaymentIntents from Stripe
			Response stripeResp = client
					.target(STRIPE_API + "/payment_intents")
					.queryParam("limit", "100")
					.queryParam("expand[]", "data.latest_charge")
					.request(MediaType.APPLICATION_JSON)
					.header("Authorization", "Bearer " + STRIPE_SECRET_KEY)
					.get();

			if (stripeResp.getStatus() == 200) {
				String json = stripeResp.readEntity(String.class);
				JsonReader reader = Json.createReader(new StringReader(json));
				JsonObject root = reader.readObject();
				reader.close();

				JsonArray dataArr = root.getJsonArray("data");
				DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'")
						.withZone(ZoneId.of("UTC"));

				if (dataArr != null) {
					for (int i = 0; i < dataArr.size(); i++) {
						JsonObject pi = dataArr.getJsonObject(i);

						// Check metadata bookingId matches this user's bookings
						String bookingId = "";
						if (pi.containsKey("metadata") && !pi.isNull("metadata")) {
							JsonObject meta = pi.getJsonObject("metadata");
							bookingId = safeString(meta, "bookingId");
						}

						// Only include payments linked to this user's bookings
						if (bookingId.isEmpty() || !userBookingIds.contains(bookingId)) {
							continue;
						}

						HashMap<String, String> map = new HashMap<>();
						String piId = safeString(pi, "id");
						long amount = pi.containsKey("amount") ? pi.getJsonNumber("amount").longValue() : 0;
						String currency = safeString(pi, "currency");
						String status = safeString(pi, "status");
						long created = pi.containsKey("created") ? pi.getJsonNumber("created").longValue() : 0;

						// Get refund info from expanded charge
						long refundedAmount = 0;
						if (pi.containsKey("latest_charge") && !pi.isNull("latest_charge")) {
							JsonValue lcVal = pi.get("latest_charge");
							if (lcVal.getValueType() == JsonValue.ValueType.OBJECT) {
								JsonObject charge = lcVal.asJsonObject();
								refundedAmount = charge.containsKey("amount_refunded")
										? charge.getJsonNumber("amount_refunded").longValue() : 0;
							}
						}

						String createdAt = created > 0
								? dtf.format(Instant.ofEpochSecond(created)) : "";

						map.put("paymentIntentId", piId);
						map.put("amount", String.valueOf(amount));
						map.put("currency", currency.toUpperCase());
						map.put("status", status);
						map.put("bookingId", bookingId);
						map.put("createdAt", createdAt);
						map.put("totalRefunded", String.valueOf(refundedAmount));
						map.put("refundCount", refundedAmount > 0 ? "1" : "0");
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
