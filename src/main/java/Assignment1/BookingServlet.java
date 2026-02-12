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

import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import jakarta.json.JsonValue;

import java.io.IOException;
import java.io.StringReader;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

/**
 * Servlet for fetching user bookings via API.
 * URL: /customer/bookings
 */
@WebServlet("/customer/bookings")
public class BookingServlet extends HttpServlet {

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

		String userId = session.getAttribute("sessId").toString();
		ArrayList<Booking> bookings = new ArrayList<>();

		Client client = ClientBuilder.newClient();
		try {
			Response apiResp = client.target(API_BASE + "/bookings/user/" + userId)
					.request(MediaType.APPLICATION_JSON).get();

			String json = apiResp.readEntity(String.class);
			System.out.println("[BookingServlet] API status " + apiResp.getStatus()
					+ ", response length: " + (json != null ? json.length() : 0));

			if (apiResp.getStatus() == 200 && json != null && !json.isBlank()) {
				JsonReader reader = Json.createReader(new StringReader(json));
				JsonValue root = reader.read();
				reader.close();

				JsonArray arr = null;

				// Handle both raw array and envelope { data: [...] }
				if (root.getValueType() == JsonValue.ValueType.ARRAY) {
					arr = root.asJsonArray();
				} else if (root.getValueType() == JsonValue.ValueType.OBJECT) {
					JsonObject obj = root.asJsonObject();
					if (obj.containsKey("data") && !obj.isNull("data")
							&& obj.get("data").getValueType() == JsonValue.ValueType.ARRAY) {
						arr = obj.getJsonArray("data");
					}
				}

				if (arr != null) {
					for (int i = 0; i < arr.size(); i++) {
						JsonObject b = arr.getJsonObject(i);
						Booking booking = new Booking();

						booking.setBookingId(b.containsKey("bookingId") && !b.isNull("bookingId")
								? b.getInt("bookingId") : 0);
						booking.setCustomerUserId(safeString(b, "customerUserId"));
						booking.setStatus(safeString(b, "status"));
						booking.setNotes(safeString(b, "notes"));

						// Parse scheduledAt
						String dateStr = safeString(b, "scheduledAt");
						if (!dateStr.isEmpty()) {
							try {
								SimpleDateFormat sdf;
								if (dateStr.contains("T")) {
									sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
								} else {
									sdf = new SimpleDateFormat("yyyy-MM-dd");
								}
								booking.setScheduledAt(sdf.parse(dateStr));
							} catch (Exception e) {
								System.out.println("[BookingServlet] Date parse error: " + dateStr);
							}
						}

						// Parse bookingDetails
						if (b.containsKey("bookingDetails") && !b.isNull("bookingDetails")
								&& b.get("bookingDetails").getValueType() == JsonValue.ValueType.ARRAY) {
							JsonArray detailsArr = b.getJsonArray("bookingDetails");
							ArrayList<BookingDetail> details = new ArrayList<>();
							for (int j = 0; j < detailsArr.size(); j++) {
								JsonObject d = detailsArr.getJsonObject(j);
								int serviceId = d.containsKey("serviceId") ? d.getInt("serviceId") : 0;
								String serviceName = safeString(d, "serviceName");
								int quantity = d.containsKey("quantity") ? d.getInt("quantity") : 0;
								BigDecimal unitPrice = d.containsKey("unitPrice") && !d.isNull("unitPrice")
										? d.getJsonNumber("unitPrice").bigDecimalValue()
										: BigDecimal.ZERO;
								details.add(new BookingDetail(serviceId, serviceName, quantity, unitPrice));
							}
							booking.setBookingDetails(details);
						}

						bookings.add(booking);
					}
				}

				System.out.println("[BookingServlet] Parsed " + bookings.size() + " bookings for user " + userId);
			}
		} catch (Exception e) {
			System.out.println("[BookingServlet] ERROR: " + e.getClass().getName() + ": " + e.getMessage());
			e.printStackTrace();
		} finally {
			client.close();
		}

		request.setAttribute("bookings", bookings);
		request.getRequestDispatcher("/customer/bookings.jsp").forward(request, response);
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