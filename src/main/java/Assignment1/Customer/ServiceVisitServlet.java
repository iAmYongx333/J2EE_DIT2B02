package Assignment1.Customer;

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
 * Servlet that proxies service visit API calls from the JSP frontend
 * to the Spring Boot backend, and also serves the visit tracking page.
 * 
 * URL patterns:
 *   /customer/service-visits   -> serves the JSP page
 *   /api/service-visits/*      -> proxies API calls to Spring Boot
 */
@WebServlet(urlPatterns = {"/customer/service-visits", "/api/service-visits/*"})
public class ServiceVisitServlet extends HttpServlet {

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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessId") == null) {
            String uri = request.getRequestURI();
            if (uri.startsWith(request.getContextPath() + "/api/")) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            }
            return;
        }

        String uri = request.getRequestURI();

        // Serve the JSP page
        if (uri.endsWith("/customer/service-visits")) {
            request.getRequestDispatcher("/customer/service_visits.jsp").forward(request, response);
            return;
        }

        // Proxy API calls to Spring Boot
        String pathInfo = request.getPathInfo();
        String queryString = request.getQueryString();
        String apiPath = "/service-visits" + (pathInfo != null ? pathInfo : "") + 
                         (queryString != null ? "?" + queryString : "");

        try {
            WebTarget target = client.target(API_BASE + apiPath);
            Response apiResponse = target.request(MediaType.APPLICATION_JSON).get();

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
            response.getWriter().write("{\"success\":false,\"message\":\"Error calling API: " + 
                                       e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        // Proxy POST calls (check-in, check-out, create)
        String pathInfo = request.getPathInfo();
        String apiPath = "/service-visits" + (pathInfo != null ? pathInfo : "");

        try {
            // Read request body
            StringBuilder body = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                body.append(line);
            }

            WebTarget target = client.target(API_BASE + apiPath);
            Response apiResponse = target.request(MediaType.APPLICATION_JSON)
                    .post(jakarta.ws.rs.client.Entity.json(body.toString()));

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
            response.getWriter().write("{\"success\":false,\"message\":\"Error calling API: " + 
                                       e.getMessage().replace("\"", "'") + "\"}");
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
