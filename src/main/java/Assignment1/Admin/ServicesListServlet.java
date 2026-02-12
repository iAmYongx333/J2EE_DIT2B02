package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Services List Servlet
 * Returns list of all services for dropdown population
 */
@WebServlet("/api/services")
public class ServicesListServlet extends HttpServlet {

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

        try {
            // Call Spring Boot API
            WebTarget target = client.target(API_BASE + "/services");
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
            response.getWriter().write("[]");
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
