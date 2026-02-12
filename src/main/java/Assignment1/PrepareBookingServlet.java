package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Entity;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import jakarta.json.JsonValue;

/**
 * Creates a pending booking before payment intent creation.
 * Returns the bookingId so checkout.jsp can pass it to the
 * Stripe payment intent endpoint (which now requires bookingId).
 *
 * POST /payment/prepare → { "success": true, "bookingId": "..." }
 */
@WebServlet("/payment/prepare")
public class PrepareBookingServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String API_BASE = "http://localhost:8081/api";

	@Override
	@SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("sessId") == null) {
			response.setStatus(401);
			out.print("{\"success\":false,\"error\":\"No session\"}");
			return;
		}

		// Read checkout data stored by CheckoutServlet
		String userId = (String) session.getAttribute("checkoutUserId");
		String serviceDate = (String) session.getAttribute("checkoutServiceDate");
		String notes = (String) session.getAttribute("checkoutNotes");
		List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");

		if (userId == null) {
			userId = String.valueOf(session.getAttribute("sessId"));
		}

		// Try to get numeric customerId from session (stored during login)
		int customerId = 0;
		Object sessCustomerId = session.getAttribute("sessCustomerId");
		if (sessCustomerId != null) {
			try {
				customerId = Integer.parseInt(sessCustomerId.toString());
			} catch (NumberFormatException e) {
				System.out.println("[PrepareBooking] Could not parse sessCustomerId: " + sessCustomerId);
			}
		}

		if (cart == null || cart.isEmpty()) {
			response.setStatus(400);
			out.print("{\"success\":false,\"error\":\"Cart is empty\"}");
			return;
		}

		// Build bookingDetails array from all cart items
		List<Map<String, Object>> bookingDetails = new ArrayList<>();
		for (CartItem item : cart) {
			Map<String, Object> detail = new HashMap<>();
			detail.put("serviceId", item.getServiceId());
			detail.put("serviceName", item.getServiceName());
			detail.put("quantity", item.getQuantity());
			detail.put("unitPrice", item.getUnitPrice());
			bookingDetails.add(detail);
		}

		// If serviceDate is null/empty, use tomorrow's date as fallback
		if (serviceDate == null || serviceDate.isBlank()) {
			java.time.LocalDate tomorrow = java.time.LocalDate.now().plusDays(1);
			serviceDate = tomorrow.toString(); // yyyy-MM-dd
			System.out.println("[PrepareBooking] No service date in session, using fallback: " + serviceDate);
		}

		// Build booking payload matching backend DTO:
		// userId (UUID string), scheduledAt, status, notes, bookingDetails
		Map<String, Object> bookingData = new HashMap<>();
		bookingData.put("userId", userId);
		bookingData.put("scheduledAt", serviceDate);
		bookingData.put("status", "pending");
		bookingData.put("notes", notes != null ? notes : "");
		bookingData.put("bookingDetails", bookingDetails);

		System.out.println("[PrepareBooking] Sending payload: userId=" + userId
				+ ", scheduledAt=" + serviceDate
				+ ", details=" + bookingDetails.size() + " items");

		Client client = ClientBuilder.newClient();
		try {
			Response apiResp = client.target(API_BASE + "/bookings")
					.request(MediaType.APPLICATION_JSON)
					.post(Entity.json(bookingData));

			String json = apiResp.readEntity(String.class);
			System.out.println("[PrepareBooking] API response " + apiResp.getStatus() + ": " + json);

			if (apiResp.getStatus() == 200 || apiResp.getStatus() == 201) {
				String bookingId = extractBookingId(json);

				if (bookingId != null && !bookingId.isEmpty()) {
					// Store in session so PaymentServlet can reference it later
					session.setAttribute("checkoutBookingId", bookingId);
					out.print("{\"success\":true,\"bookingId\":\"" + bookingId + "\"}");
				} else {
					// Booking created but couldn't extract ID — still return success
					System.out.println("[PrepareBooking] Could not extract bookingId from response");
					out.print("{\"success\":false,\"error\":\"Could not extract booking ID\"}");
				}
			} else {
				System.out.println("[PrepareBooking] API returned " + apiResp.getStatus());
				out.print("{\"success\":false,\"error\":\"Failed to create booking: " + apiResp.getStatus() + "\"}");
			}

		} catch (Exception e) {
			System.out.println("[PrepareBooking] Error: " + e.getMessage());
			e.printStackTrace();
			response.setStatus(500);
			out.print("{\"success\":false,\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
		} finally {
			client.close();
		}
	}

	/**
	 * Tries to extract bookingId from various possible response formats:
	 *   { "data": { "bookingId": "..." } }
	 *   { "data": { "id": "..." } }
	 *   { "bookingId": "..." }
	 *   { "id": "..." }
	 */
	private String extractBookingId(String json) {
		try {
			JsonReader reader = Json.createReader(new StringReader(json));
			JsonObject root = reader.readObject();
			reader.close();

			// Check envelope: { data: { bookingId|id } }
			if (root.containsKey("data") && !root.isNull("data")) {
				JsonValue dataVal = root.get("data");
				if (dataVal.getValueType() == JsonValue.ValueType.OBJECT) {
					JsonObject data = root.getJsonObject("data");
					if (data.containsKey("bookingId") && !data.isNull("bookingId")) {
						return getStringValue(data, "bookingId");
					}
					if (data.containsKey("id") && !data.isNull("id")) {
						return getStringValue(data, "id");
					}
				}
				// data might be a plain value (number/string)
				if (dataVal.getValueType() == JsonValue.ValueType.STRING) {
					return root.getString("data");
				}
				if (dataVal.getValueType() == JsonValue.ValueType.NUMBER) {
					return String.valueOf(root.getJsonNumber("data"));
				}
			}

			// Direct: { bookingId | id }
			if (root.containsKey("bookingId") && !root.isNull("bookingId")) {
				return getStringValue(root, "bookingId");
			}
			if (root.containsKey("id") && !root.isNull("id")) {
				return getStringValue(root, "id");
			}

		} catch (Exception e) {
			System.out.println("[PrepareBooking] Failed to parse response: " + e.getMessage());
		}
		return null;
	}

	private String getStringValue(JsonObject obj, String key) {
		JsonValue val = obj.get(key);
		switch (val.getValueType()) {
			case STRING: return obj.getString(key);
			case NUMBER: return String.valueOf(obj.getJsonNumber(key));
			default: return val.toString();
		}
	}
}
