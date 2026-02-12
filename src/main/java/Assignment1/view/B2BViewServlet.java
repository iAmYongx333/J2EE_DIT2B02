package Assignment1.view;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * B2B Partner Portal View Servlet
 * This simulates a third-party (B2B) website that dynamically consumes
 * the SilverCare REST web services via the /api/b2b/ endpoints.
 * 
 * Requirement C(b): Third-Party B2B website consuming RESTful web services.
 */
@WebServlet(urlPatterns = {"/b2b", "/b2b/services"})
public class B2BViewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // B2B portal is public — no session checks required
        // It consumes the REST API directly from the client side (JavaScript fetch)
        request.getRequestDispatcher("/b2b/index.jsp").forward(request, response);
    }
}
