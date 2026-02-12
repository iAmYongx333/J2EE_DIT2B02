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
import java.io.PrintWriter;

/**
 * Admin Reports Servlet
 * Proxies reporting API calls from JSP to Spring Boot backend
 */
@WebServlet("/api/admin/reports/*")
public class AdminReportsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String API_BASE = "http://localhost:8081/api";
    private Client client;

    @Override
    public void init() throws ServletException {
        super.init();
        client = ClientBuilder.newClient();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check admin session
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("sessRole"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        // Get the path after /api/admin/reports/
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid endpoint\"}");
            return;
        }

        // Build the API URL
        String queryString = request.getQueryString();
        String apiPath = "/admin/reports" + pathInfo + (queryString != null ? "?" + queryString : "");

        try {
            // Call Spring Boot API
            WebTarget target = client.target(API_BASE + apiPath);
            Response apiResponse = target.request(MediaType.APPLICATION_JSON).get();

            // Forward the response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setStatus(apiResponse.getStatus());

            String jsonResponse = apiResponse.readEntity(String.class);
            PrintWriter out = response.getWriter();
            out.print(jsonResponse);
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Error calling API: " + e.getMessage() + "\"}");
        }
    }

    @Override
    public void destroy() {
        if (client != null) {
            client.close();
        }
        super.destroy();
    }
}
