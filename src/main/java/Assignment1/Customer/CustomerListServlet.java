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
        System.out.print(action);
        if ("retrieveUser".equals(action)) {
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

        if ("login".equals(action)) {
            loginUser(request, response);
        } 
        else if ("create".equals(action)) {
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
    	System.out.println("loginUser has been called");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        LoginRequest req = new LoginRequest();
        req.setEmail(email);
        req.setPassword(password);

        try {
            Customer user = ApiClient.post("/customers/login", req, Customer.class);
            if (user != null) {
                System.out.println("Login successful for user: " + user.getName());
                HttpSession session = request.getSession();
                
                session.setAttribute("sessId", user.getUserId().toString());
                session.setAttribute("sessRole", user.getUserRole());
                session.setAttribute("sessEmail", user.getEmail());
                session.setAttribute("sessName", user.getName());
                session.setAttribute("sessCustomerId", user.getCustomerId());

                response.sendRedirect(request.getContextPath() + "/customersServlet?action=retrieveUser");
            } else {
                response.sendRedirect(request.getContextPath() + "/login?errCode=invalidLogin");
            }
        } catch (Exception e) {
            System.err.println("Login error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login?errCode=invalidLogin");
        }
    }

    private void registerUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
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
                response.sendRedirect(request.getContextPath() + "/login?msgCode=RegisterSuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/register?errCode=RegisterFail");
            }
        } catch (Exception e) {
            System.err.println("Registration error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/register?errCode=RegisterFail");
        }
    }

    private void retrieveUser(HttpServletRequest request, HttpServletResponse response)
        throws IOException {

    HttpSession session = request.getSession(false);

    if (session == null || session.getAttribute("sessId") == null) {
        response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
        return;
    }

    try {
        UUID userId = UUID.fromString(session.getAttribute("sessId").toString());

        Customer user = ApiClient.get("/customers/" + userId, Customer.class);

        if (user != null) {
            session.setAttribute("user", user);
            session.setAttribute("sessEmail", user.getEmail());
            session.setAttribute("sessName", user.getName());
            session.setAttribute("sessCustomerId", user.getCustomerId());
            System.out.println(".() User Country retrieved: " + user.getCountryName());
            response.sendRedirect(request.getContextPath() + "/profile");
        } else {
            response.sendRedirect(request.getContextPath() + "/login?errCode=UserNotFound");
        }
    } catch (Exception e) {
        System.err.println("Retrieve user error: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/login?errCode=UserNotFound");
    }
}

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
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
                response.sendRedirect(request.getContextPath() + "/profile?errCode=UpdateFailed");
            }
        } catch (Exception e) {
            System.err.println("Update user error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/profile?errCode=UpdateFailed");
        }
    }

    private void updatePassword(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            HttpSession session = request.getSession(false);
            UUID userId = UUID.fromString(session.getAttribute("sessId").toString());

            PasswordRequest pr = new PasswordRequest();
            pr.setNewPassword(request.getParameter("newPassword"));

            int status = ApiClient.put("/customers/" + userId + "/password", pr);

            if (status == 200) {
                response.sendRedirect(request.getContextPath() + "/profile/edit?success=PasswordUpdated");
            } else {
                response.sendRedirect(request.getContextPath() + "/profile/edit?error=PasswordUpdateFailed");
            }
        } catch (Exception e) {
            System.err.println("Update password error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/profile/edit?error=PasswordUpdateFailed");
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            HttpSession session = request.getSession(false);
            UUID userId = UUID.fromString(session.getAttribute("sessId").toString());

            int status = ApiClient.delete("/customers/" + userId);

            if (status == 200) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login?msg=AccountDeleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/profile?errCode=DeleteFailed");
            }
        } catch (Exception e) {
            System.err.println("Delete user error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/profile?errCode=DeleteFailed");
        }
    }

    private void logoutUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) session.invalidate();

        response.sendRedirect(request.getContextPath() + "/login");
    }
}
