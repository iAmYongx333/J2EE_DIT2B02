package Assignment1.Customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

import Assignment1.api.ApiClient;

@WebServlet("/customersServlet")
public class CustomerRegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // =========================
    // Validation Patterns
    // =========================
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", Pattern.CASE_INSENSITIVE
    );
    private static final Pattern PASSWORD_UPPER = Pattern.compile(".*[A-Z].*");
    private static final Pattern PASSWORD_LOWER = Pattern.compile(".*[a-z].*");
    private static final Pattern PASSWORD_DIGIT = Pattern.compile(".*\\d.*");
    private static final Pattern PASSWORD_SPECIAL = Pattern.compile(".*[^A-Za-z0-9].*");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[+]?[- 0-9]{7,20}$");
    private static final Pattern SG_POSTAL_PATTERN = Pattern.compile("^\\d{6}$");

    // =========================
    // GET → show register form
    // =========================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/customer/register.jsp").forward(request, response);
    }

    // =========================
    // POST → handle registration
    // =========================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();

        // ---- Read + trim inputs ----
        String fullName = trim(request.getParameter("fullName"));
        String emailRaw = trim(request.getParameter("email"));
        String email = emailRaw != null ? emailRaw.toLowerCase() : null;
        String password = request.getParameter("password"); // don't trim passwords
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = trim(request.getParameter("phone"));
        String street = trim(request.getParameter("street"));
        String postalCode = trim(request.getParameter("postalCode"));
        String country = trim(request.getParameter("country"));
        String blockNo = trim(request.getParameter("blockNo"));
        String unitNo = trim(request.getParameter("unitNo"));
        int countryId = parseIntSafe(request.getParameter("countryId"), 0);

        // ---- Validation ----
        if (isBlank(fullName)) {
            errors.put("fullName", "Full name is required.");
        } else if (fullName.length() < 2 || fullName.length() > 100) {
            errors.put("fullName", "Full name must be between 2 and 100 characters.");
        }

        if (isBlank(email)) {
            errors.put("email", "Email is required.");
        } else if (!EMAIL_PATTERN.matcher(email).matches()) {
            errors.put("email", "Enter a valid email (e.g., name@example.com).");
        }

        if (password == null || password.isEmpty()) {
            errors.put("password", "Password is required.");
        } else {
            if (password.length() < 8) errors.put("password", "Password must be at least 8 characters.");
            else if (!PASSWORD_UPPER.matcher(password).matches()) errors.put("password", "Must include an uppercase letter.");
            else if (!PASSWORD_LOWER.matcher(password).matches()) errors.put("password", "Must include a lowercase letter.");
            else if (!PASSWORD_DIGIT.matcher(password).matches()) errors.put("password", "Must include a number.");
            else if (!PASSWORD_SPECIAL.matcher(password).matches()) errors.put("password", "Must include a special character.");
        }

        if (confirmPassword != null && !confirmPassword.equals(password)) {
            errors.put("confirmPassword", "Passwords do not match.");
        }

        if (!isBlank(phone) && !PHONE_PATTERN.matcher(phone).matches()) {
            errors.put("phone", "Enter a valid phone number.");
        }

        if (!isBlank(postalCode) && !SG_POSTAL_PATTERN.matcher(postalCode).matches()) {
            errors.put("postalCode", "Postal code must be 6 digits.");
        }

        if (countryId <= 0) {
            errors.put("countryId", "Please select a country.");
        }

        // If validation failed, forward back
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/customer/register.jsp").forward(request, response);
            return;
        }

        // ---- Build Customer object ----
        Customer customer = new Customer();
        customer.setName(fullName);
        customer.setEmail(email);
        customer.setPassword(password);
        customer.setPhone(phone);
        customer.setStreet(street);
        customer.setPostalCode(postalCode);
        customer.setBlock(blockNo);
        customer.setUnitNumber(unitNo);
        customer.setCountryId(countryId);

        try {
            // ---- Call API to register ----
            Integer result = ApiClient.post("/customers", customer, Integer.class);

            if (result != null && result > 0) {
                // PRG → redirect to login
                response.sendRedirect(request.getContextPath() + "/public/login.jsp?msg=Registered");
            } else {
                errors.put("global", "Registration failed. Try again.");
                request.setAttribute("errors", errors);
                request.getRequestDispatcher("/customer/register.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            errors.put("global", "Unexpected error occurred. Please try again.");
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/customer/register.jsp").forward(request, response);
        }
    }

    // =========================
    // Helper Methods
    // =========================
    private static String trim(String s) {
        return s == null ? null : s.trim();
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static int parseIntSafe(String s, int fallback) {
        try {
            if (s == null) return fallback;
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return fallback;
        }
    }
}
