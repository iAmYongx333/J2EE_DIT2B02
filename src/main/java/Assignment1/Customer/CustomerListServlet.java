package Assignment1.Customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.UUID;

import Assignment1.api.ApiClient;

@WebServlet("/customersServlet")
public class CustomerListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // =========================
    // GET
    // =========================
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("login".equals(action)) {
            loginUser(request, response);
        } 
        else if ("retrieveUser".equals(action)) {
            retrieveUser(request, response);
        } 
        else if ("logout".equals(action)) {
            logoutUser(request, response);
        } 
        else {
            System.out.println("Unknown action");
        }
    }

    // =========================
    // POST
    // =========================
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            registerUser(request, response);
        } 
        else if ("update".equals(action)) {
            updateUser(request, response);
        } 
        else if ("delete".equals(action)) {
            deleteUser(request, response);
        } 
        else if ("password".equals(action)) {
            updatePassword(request, response);
        }
    }

    // =========================
    // METHODS
    // =========================

    private void loginUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        LoginRequest req = new LoginRequest();
        req.setEmail(email);
        req.setPassword(password);

        Customer user = ApiClient.post("/customers/login", req, Customer.class);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("sessId", user.getUserId().toString());
            session.setAttribute("sessName", user.getName());
            session.setAttribute("sessRole", user.getUserRole());

            response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=invalidLogin");
        }
    }

    private void registerUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Customer c = new Customer();

        c.setName(request.getParameter("name"));
        c.setEmail(request.getParameter("email"));
        c.setPassword(request.getParameter("password"));
        c.setPhone(request.getParameter("Phone"));
        c.setCountryId(Integer.parseInt(request.getParameter("country")));
        c.setStreet(request.getParameter("Street"));
        c.setPostalCode(request.getParameter("postal_code"));
        c.setBlock(request.getParameter("block_no"));
        c.setUnitNumber(request.getParameter("unit_no"));
        c.setBuildingName(request.getParameter("building_name"));
        c.setCity(request.getParameter("city"));
        c.setState(request.getParameter("state"));
        c.setAddressLine2(request.getParameter("address_line2"));

        Integer result = ApiClient.post("/customers/register", c, Integer.class);

        if (result != null && result > 0) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp?msgCode=RegisterSuccess");
        } else {
            response.sendRedirect(request.getContextPath() + "/public/register.jsp?errCode=RegisterFail");
        }
    }

    private void retrieveUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessId") == null) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
            return;
        }

        UUID userId = UUID.fromString(session.getAttribute("sessId").toString());

        Customer user = ApiClient.get("/customers/" + userId, Customer.class);

        if (user != null) {
            session.setAttribute("user", user);
            response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=UserNotFound");
        }
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        UUID userId = UUID.fromString(session.getAttribute("sessId").toString());

        Customer c = new Customer();

        c.setName(request.getParameter("name"));
        c.setEmail(request.getParameter("email"));
        c.setPhone(request.getParameter("Phone"));
        c.setStreet(request.getParameter("Street"));
        c.setPostalCode(request.getParameter("postal_code"));
        c.setCountryId(Integer.parseInt(request.getParameter("country")));
        c.setBlock(request.getParameter("block_no"));
        c.setUnitNumber(request.getParameter("unit_no"));

        int status = ApiClient.put("/customers/" + userId, c);

        if (status == 200) {
            response.sendRedirect(request.getContextPath() + "/customersServlet?action=retrieveUser&msg=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?errCode=UpdateFailed");
        }
    }

    private void updatePassword(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        UUID userId = UUID.fromString(session.getAttribute("sessId").toString());

        PasswordRequest pr = new PasswordRequest();
        pr.setNewPassword(request.getParameter("newPassword"));

        int status = ApiClient.put("/customers/" + userId + "/password", pr);

        if (status == 200) {
            response.sendRedirect(request.getContextPath() + "/customer/edit_profile.jsp?success=PasswordUpdated");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/edit_profile.jsp?error=PasswordUpdateFailed");
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        UUID userId = UUID.fromString(session.getAttribute("sessId").toString());

        int status = ApiClient.delete("/customers/" + userId);

        if (status == 200) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/account_deleted.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?errCode=DeleteFailed");
        }
    }

    private void logoutUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) session.invalidate();

        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
    }
}
