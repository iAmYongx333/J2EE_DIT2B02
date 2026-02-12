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
import jakarta.ws.rs.core.Response;

import java.io.IOException;

/**
 * Admin servlet for deleting bookings
 * Calls DELETE /admin/bookings/{id}
 * URL: /admin/bookings/delete
 */
@WebServlet("/admin/bookings/delete")
public class AdminBookingDeleteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String API_BASE_URL = "http://localhost:8081/api/admin/bookings";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Object role = session != null ? session.getAttribute("sessRole") : null;
        if (role == null || !"admin".equalsIgnoreCase(role.toString())) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=InvalidBookingId");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            
            // Call Spring Boot API to delete booking
            Client client = ClientBuilder.newClient();
            WebTarget target = client.target(API_BASE_URL + "/" + bookingId);
            Response apiResp = target.request().delete();

            client.close();

            if (apiResp.getStatus() == 200) {
                // Success - redirect back to bookings list
                response.sendRedirect(request.getContextPath() + "/admin/bookings?success=BookingDeleted");
            } else {
                // Failed - redirect with error
                response.sendRedirect(request.getContextPath() + "/admin/bookings?error=DeleteFailed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=InvalidBookingId");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=ServerError");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to bookings list
        response.sendRedirect(request.getContextPath() + "/admin/bookings");
    }
}
