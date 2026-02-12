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
 * Servlet for client inquiry & reporting.
 * Serves the admin JSP page and proxies API calls to the Spring Boot backend.
 * 
 * URL patterns:
 *   /admin/client-inquiry      -> serves the JSP page
 *   /api/admin/clients/*       -> proxies API calls to Spring Boot
 */
@WebServlet(urlPatterns = {"/admin/client-inquiry", "/api/admin/clients/*"})
public class AdminClientInquiryServlet extends HttpServlet {

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
        if (uri.endsWith("/admin/client-inquiry")) {
            request.getRequestDispatcher("/admin/client_inquiry.jsp").forward(request, response);
            return;
        }

        // Proxy API calls to Spring Boot
        String pathInfo = request.getPathInfo();
        String queryString = request.getQueryString();
        String apiPath = "/admin/clients" + (pathInfo != null ? pathInfo : "") + 
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
    public void destroy() {
        if (client != null) {
            client.close();
        }
        super.destroy();
    }
}
