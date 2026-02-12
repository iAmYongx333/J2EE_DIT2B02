package Assignment1.Admin;

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
import java.io.StringReader;

import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;

/**
 * Admin servlet for refunding payments via Stripe API directly.
 * URL: /admin/payments/refund
 */
@WebServlet("/admin/payments/refund")
public class AdminPaymentRefundServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String STRIPE_API = "https://api.stripe.com/v1";
	private static final String STRIPE_SECRET_KEY = System.getenv("STRIPE_SECRET_KEY");

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		Object role = session != null ? session.getAttribute("sessRole") : null;
		if (role == null || !"admin".equalsIgnoreCase(role.toString())) {
			response.setStatus(403);
			response.setContentType("application/json");
			response.getWriter().print("{\"success\":false,\"message\":\"Unauthorized\"}");
			return;
		}

		String paymentIntentId = request.getParameter("paymentIntentId");
		String amountStr = request.getParameter("amount");
		String reason = request.getParameter("reason");

		if (paymentIntentId == null || paymentIntentId.isBlank()) {
			session.setAttribute("flashError", "Missing payment intent ID.");
			response.sendRedirect(request.getContextPath() + "/admin/payments/list");
			return;
		}

		Client client = ClientBuilder.newClient();
		try {
			// Build form body for Stripe refund API
			StringBuilder formBody = new StringBuilder();
			formBody.append("payment_intent=").append(paymentIntentId);
			if (amountStr != null && !amountStr.isBlank()) {
				formBody.append("&amount=").append(amountStr.trim());
			}
			if (reason != null && !reason.isBlank()) {
				formBody.append("&reason=").append(reason.trim());
			}

			Response stripeResp = client.target(STRIPE_API + "/refunds")
					.request(MediaType.APPLICATION_JSON)
					.header("Authorization", "Bearer " + STRIPE_SECRET_KEY)
					.post(Entity.entity(formBody.toString(),
							MediaType.APPLICATION_FORM_URLENCODED));

			String respBody = stripeResp.readEntity(String.class);
			System.out.println("[AdminRefund] Stripe status: " + stripeResp.getStatus()
					+ ", response: " + respBody);

			if (stripeResp.getStatus() == 200) {
				session.setAttribute("flashSuccess", "Refund processed successfully.");
			} else {
				String msg = "Refund failed.";
				try {
					JsonReader reader = Json.createReader(new StringReader(respBody));
					JsonObject obj = reader.readObject();
					reader.close();
					if (obj.containsKey("error") && !obj.isNull("error")) {
						JsonObject err = obj.getJsonObject("error");
						if (err.containsKey("message")) {
							msg = err.getString("message");
						}
					}
				} catch (Exception ignore) {}
				session.setAttribute("flashError", msg);
			}

		} catch (Exception e) {
			e.printStackTrace();
			session.setAttribute("flashError", "Error processing refund: " + e.getMessage());
		} finally {
			client.close();
		}

		response.sendRedirect(request.getContextPath() + "/admin/payments/list");
	}
}
