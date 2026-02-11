package Assignment1.Service;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Entity;
import jakarta.ws.rs.client.Invocation;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.GenericType;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.IOException;
import java.util.ArrayList;
import java.util.UUID;

import Assignment1.Feedback;

@WebServlet("/serviceDetailServlet")
public class ServiceDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String SERVICE_API  = "http://localhost:8081/api/services";
    private static final String FEEDBACK_API = "http://localhost:8081/api/feedback";

    // =========================
    // GET → Load service + feedback
    // =========================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Client client = ClientBuilder.newClient();

        try {
			System.out.println(request.getParameter("serviceId"));
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));

            /* ---------- Fetch service ---------- */
            WebTarget serviceTarget = client.target(SERVICE_API + "/" + serviceId);
            Invocation.Builder serviceBuilder = serviceTarget.request(MediaType.APPLICATION_JSON);
            Response serviceResp = serviceBuilder.get();
			
            Service service = null;
            if (serviceResp.getStatus() == Response.Status.OK.getStatusCode()) {
                service = serviceResp.readEntity(Service.class);
            }
			 if (service == null) {
                request.setAttribute("errCode", "SERVICE_NOT_FOUND");
                request.getRequestDispatcher("/public/services.jsp").forward(request, response);
                return;
            }

           

            /* ---------- Fetch feedback ---------- */
            WebTarget feedbackTarget = client.target(FEEDBACK_API + "/service/" + serviceId);
            Invocation.Builder feedbackBuilder = feedbackTarget.request(MediaType.APPLICATION_JSON);
            Response feedbackResp = feedbackBuilder.get();

            ArrayList<Feedback> feedbackList = new ArrayList<>();
            if (feedbackResp.getStatus() == Response.Status.OK.getStatusCode()) {
                feedbackList = feedbackResp.readEntity(new GenericType<ArrayList<Feedback>>() {});
            }

            /* ---------- Set request attributes ---------- */
            request.setAttribute("service", service);
            request.setAttribute("feedbackList", feedbackList);

            System.out.println("Loaded service: " + service);
            System.out.println("Loaded feedback count: " + feedbackList.size());

            /* ---------- Forward to JSP ---------- */
            request.getRequestDispatcher("/public/service_details.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errCode", "SERVICE_DETAIL_API_ERROR");
            request.getRequestDispatcher("/public/services.jsp").forward(request, response);
        } finally {
            client.close();
        }
    }

    // =========================
    // POST → Submit feedback
    // =========================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Client client = ClientBuilder.newClient();

        try {
            /* ---------- Auth check ---------- */
            if (session == null || session.getAttribute("sessId") == null) {
                response.sendRedirect(
                    request.getContextPath() + "/serviceDetailServlet?serviceId=" +
                    request.getParameter("serviceId") + "&errCode=notLoggedIn"
                );
                return;
            }

            UUID userId   = UUID.fromString(session.getAttribute("sessId").toString());
            String userName   = session.getAttribute("sessId").toString();
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            int rating    = Integer.parseInt(request.getParameter("rating"));
            String comments = request.getParameter("comments");

            if (rating < 1 || rating > 5) {
                response.sendRedirect(
                    request.getContextPath() + "/serviceDetailServlet?serviceId=" +
                    serviceId + "&errCode=invalidRating"
                );
                return;
            }

            /* ---------- Build feedback ---------- */
           /* ---------- Build feedback ---------- */
Feedback feedback = new Feedback(
    0,
    userId.toString(),
    serviceId,
    rating,
    comments,
    null,
    userName
);

/* ---------- POST to API ---------- */
WebTarget feedbackTarget = client.target(FEEDBACK_API);
Invocation.Builder feedbackBuilder = feedbackTarget.request(MediaType.APPLICATION_JSON);
Response feedbackResp = feedbackBuilder.post(
    Entity.entity(feedback, MediaType.APPLICATION_JSON)
);

if (feedbackResp.getStatus() != Response.Status.OK.getStatusCode() &&
    feedbackResp.getStatus() != Response.Status.CREATED.getStatusCode()) {

    response.sendRedirect(
        request.getContextPath() + "/serviceDetailServlet?serviceId=" +
        serviceId + "&errCode=feedbackError"
    );
    return;
}


            /* ---------- Reload page ---------- */
            response.sendRedirect(
                request.getContextPath() + "/serviceDetailServlet?serviceId=" + serviceId
            );

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                request.getContextPath() + "/public/services.jsp?errCode=feedbackException"
            );
        } finally {
            client.close();
        }
    }
}
