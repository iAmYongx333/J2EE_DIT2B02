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
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;

import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;

/**
 * Admin servlet for managing service visits.
 * - GET  /admin/service-visits         → list all visits
 * - POST /admin/service-visits/create  → create a new visit
 * - POST /admin/service-visits/status  → update visit status
 * - POST /admin/service-visits/delete  → delete a visit
 */
@WebServlet(urlPatterns = {
    "/admin/service-visits",
    "/admin/service-visits/create",
    "/admin/service-visits/status",
    "/admin/service-visits/delete"
})
public class AdminServiceVisitServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String API_BASE = "http://localhost:8081/api/service-visits";

    private static final HashMap<String, String> STATUS_LABELS = new HashMap<>();
    static {
        STATUS_LABELS.put("SCHEDULED", "Scheduled");
        STATUS_LABELS.put("EN_ROUTE", "En Route");
        STATUS_LABELS.put("CHECKED_IN", "Checked In");
        STATUS_LABELS.put("IN_PROGRESS", "In Progress");
        STATUS_LABELS.put("CHECKED_OUT", "Checked Out");
        STATUS_LABELS.put("COMPLETED", "Completed");
        STATUS_LABELS.put("CANCELLED", "Cancelled");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAdmin(request, response)) return;

        ArrayList<HashMap<String, String>> visits = new ArrayList<>();

        try {
            Client client = ClientBuilder.newClient();
            WebTarget target = client.target(API_BASE);
            Response apiResp = target.request(MediaType.APPLICATION_JSON).get();

            if (apiResp.getStatus() == 200) {
                String json = apiResp.readEntity(String.class);
                JsonReader reader = Json.createReader(new StringReader(json));
                JsonObject root = reader.readObject();
                reader.close();

                if (root.getBoolean("success", false) && !root.isNull("data")) {
                    JsonArray dataArr = root.getJsonArray("data");
                    for (int i = 0; i < dataArr.size(); i++) {
                        JsonObject v = dataArr.getJsonObject(i);
                        HashMap<String, String> map = new HashMap<>();

                        map.put("visitId", String.valueOf(v.getInt("visitId", 0)));
                        map.put("bookingId", String.valueOf(v.getInt("bookingId", 0)));
                        map.put("customerName", v.getString("customerName", ""));
                        map.put("customerUserId", v.getString("customerUserId", ""));
                        map.put("caregiverName", v.getString("caregiverName", ""));
                        map.put("caregiverUserId", v.getString("caregiverUserId", ""));
                        map.put("status", v.getString("status", ""));
                        map.put("statusLabel", STATUS_LABELS.getOrDefault(v.getString("status", ""), v.getString("status", "")));
                        map.put("location", v.getString("location", ""));

                        // Format scheduled start time
                        String startTime = "";
                        if (!v.isNull("scheduledStartTime")) {
                            startTime = v.getString("scheduledStartTime", "");
                            if (startTime.contains("T")) {
                                startTime = startTime.replace("T", " ").substring(0, Math.min(16, startTime.length()));
                            }
                        }
                        map.put("scheduledStart", startTime);

                        String notes = "";
                        try { notes = v.getString("notes", ""); } catch (Exception e) { /* null */ }
                        map.put("notes", notes);

                        visits.add(map);
                    }
                }
            }
            client.close();
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "Failed to load service visits: " + e.getMessage());
        }

        request.setAttribute("visits", visits);
        request.getRequestDispatcher("/admin/admin_service_visits.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAdmin(request, response)) return;

        String path = request.getServletPath();
        if (request.getPathInfo() != null) {
            path += request.getPathInfo();
        }

        try {
            if (path.endsWith("/create")) {
                handleCreate(request, response);
            } else if (path.endsWith("/status")) {
                handleStatusUpdate(request, response);
            } else if (path.endsWith("/delete")) {
                handleDelete(request, response);
            } else {
                doGet(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/service-visits");
        }
    }

    // ── Create a new visit ──
    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String bookingId = request.getParameter("bookingId");
        String customerUserId = request.getParameter("customerUserId");
        String customerName = request.getParameter("customerName");
        String caregiverUserId = request.getParameter("caregiverUserId");
        String caregiverName = request.getParameter("caregiverName");
        String startTime = request.getParameter("scheduledStartTime");
        String endTime = request.getParameter("scheduledEndTime");
        String location = request.getParameter("location");
        String notes = request.getParameter("notes");

        // Build JSON body
        String jsonBody = Json.createObjectBuilder()
            .add("bookingId", Integer.parseInt(bookingId))
            .add("customerUserId", customerUserId)
            .add("customerName", customerName)
            .add("caregiverUserId", caregiverUserId)
            .add("caregiverName", caregiverName)
            .add("status", "SCHEDULED")
            .add("scheduledStartTime", startTime + ":00")
            .add("scheduledEndTime", endTime + ":00")
            .add("location", location != null ? location : "")
            .add("notes", notes != null ? notes : "")
            .build()
            .toString();

        Client client = ClientBuilder.newClient();
        Response apiResp = client.target(API_BASE)
            .request(MediaType.APPLICATION_JSON)
            .post(Entity.entity(jsonBody, MediaType.APPLICATION_JSON));

        if (apiResp.getStatus() == 200) {
            request.getSession().setAttribute("successMsg", "Service visit created successfully.");
        } else {
            String body = apiResp.readEntity(String.class);
            request.getSession().setAttribute("errorMsg", "Failed to create visit: " + body);
        }
        client.close();

        response.sendRedirect(request.getContextPath() + "/admin/service-visits");
    }

    // ── Update visit status ──
    private void handleStatusUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String visitId = request.getParameter("visitId");
        String status = request.getParameter("status");
        String notes = request.getParameter("notes");

        String jsonBody = Json.createObjectBuilder()
            .add("status", status)
            .add("notes", notes != null ? notes : "")
            .build()
            .toString();

        Client client = ClientBuilder.newClient();
        Response apiResp = client.target(API_BASE + "/" + visitId + "/status")
            .request(MediaType.APPLICATION_JSON)
            .put(Entity.entity(jsonBody, MediaType.APPLICATION_JSON));

        if (apiResp.getStatus() == 200) {
            request.getSession().setAttribute("successMsg", "Visit #" + visitId + " status updated to " + status + ".");
        } else {
            request.getSession().setAttribute("errorMsg", "Failed to update status.");
        }
        client.close();

        response.sendRedirect(request.getContextPath() + "/admin/service-visits");
    }

    // ── Delete a visit ──
    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String visitId = request.getParameter("visitId");

        Client client = ClientBuilder.newClient();
        Response apiResp = client.target(API_BASE + "/" + visitId)
            .request(MediaType.APPLICATION_JSON)
            .delete();

        if (apiResp.getStatus() == 200) {
            request.getSession().setAttribute("successMsg", "Visit #" + visitId + " deleted.");
        } else {
            request.getSession().setAttribute("errorMsg", "Failed to delete visit.");
        }
        client.close();

        response.sendRedirect(request.getContextPath() + "/admin/service-visits");
    }

    // ── Auth check ──
    private boolean checkAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object role = session != null ? session.getAttribute("sessRole") : null;
        if (role == null || !"admin".equalsIgnoreCase(role.toString())) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            return false;
        }
        return true;
    }
}
