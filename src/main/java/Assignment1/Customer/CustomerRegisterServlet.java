package Assignment1.Customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

@WebServlet("/customer/register")
public class CustomerRegisterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private final CustomerDB customerDB = new CustomerDB();

	// Email Validation
	private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$",
			Pattern.CASE_INSENSITIVE);

	// Password rules (adjust to your assignment requirement if needed)
	// >= 8 chars, at least 1 uppercase, 1 lowercase, 1 digit, 1 special
	private static final Pattern PASSWORD_UPPER = Pattern.compile(".*[A-Z].*");
	private static final Pattern PASSWORD_LOWER = Pattern.compile(".*[a-z].*");
	private static final Pattern PASSWORD_DIGIT = Pattern.compile(".*\\d.*");
	private static final Pattern PASSWORD_SPECIAL = Pattern.compile(".*[^A-Za-z0-9].*");

	// Loose phone validation: digits with optional +, spaces, hyphens
	private static final Pattern PHONE_PATTERN = Pattern.compile("^[+]?[- 0-9]{7,20}$");

	// Singapore postal code (6 digits). If multi-country, relax this.
	private static final Pattern SG_POSTAL_PATTERN = Pattern.compile("^\\d{6}$");

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		request.getRequestDispatcher("/customer/register.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		Map<String, String> errors = new HashMap<>();

		// Read + trim inputs
		String fullName = trim(request.getParameter("fullName"));
		String emailRaw = trim(request.getParameter("email"));
		String email = emailRaw == null ? null : emailRaw.toLowerCase();
		String password = request.getParameter("password"); // do NOT trim password
		String confirmPassword = request.getParameter("confirmPassword"); // add this input in JSP if not present

		String phone = trim(request.getParameter("phone"));
		String street = trim(request.getParameter("street"));
		String postalCode = trim(request.getParameter("postalCode"));
		String country = trim(request.getParameter("country"));
		String blockNo = trim(request.getParameter("blockNo"));
		String unitNo = trim(request.getParameter("unitNo"));

		int countryId = parseIntSafe(request.getParameter("countryId"), 0);

		// Populate bean (without password) so the form can refill fields after errors
		Customer c = new Customer();
		c.setFullName(fullName);
		c.setEmail(email);
		c.setPhone(phone);
		c.setStreet(street);
		c.setPostalCode(postalCode);
		c.setCountry(country);
		c.setBlockNo(blockNo);
		c.setUnitNo(unitNo);
		c.setCountryId(countryId);

		// ---- Validation ----

		// Name
		if (isBlank(fullName)) {
			errors.put("fullName", "Full name is required.");
		} else if (fullName.length() < 2 || fullName.length() > 100) {
			errors.put("fullName", "Full name must be between 2 and 100 characters.");
		}

		// Email
		if (isBlank(email)) {
			errors.put("email", "Email is required.");
		} else if (email.length() > 254) {
			errors.put("email", "Email is too long.");
		} else if (!EMAIL_PATTERN.matcher(email).matches()) {
			errors.put("email", "Please enter a valid email address (e.g., name@example.com).");
		}

		// Password
		if (password == null || password.isEmpty()) {
			errors.put("password", "Password is required.");
		} else {
			if (password.length() < 8) {
				errors.put("password", "Password must be at least 8 characters.");
			} else if (!PASSWORD_UPPER.matcher(password).matches()) {
				errors.put("password", "Password must include at least 1 uppercase letter.");
			} else if (!PASSWORD_LOWER.matcher(password).matches()) {
				errors.put("password", "Password must include at least 1 lowercase letter.");
			} else if (!PASSWORD_DIGIT.matcher(password).matches()) {
				errors.put("password", "Password must include at least 1 number.");
			} else if (!PASSWORD_SPECIAL.matcher(password).matches()) {
				errors.put("password", "Password must include at least 1 special character.");
			}
		}

		// Confirm password (only if you include confirmPassword field)
		if (confirmPassword != null) {
			if (confirmPassword.isEmpty()) {
				errors.put("confirmPassword", "Please confirm your password.");
			} else if (password != null && !password.equals(confirmPassword)) {
				errors.put("confirmPassword", "Passwords do not match.");
			}
		}

		// Phone (optional in some apps; enforce if your assignment needs it)
		if (!isBlank(phone) && !PHONE_PATTERN.matcher(phone).matches()) {
			errors.put("phone", "Please enter a valid phone number.");
		}

		// Postal code (adjust rule if not SG-only)
		if (!isBlank(postalCode) && !SG_POSTAL_PATTERN.matcher(postalCode).matches()) {
			errors.put("postalCode", "Postal code must be 6 digits.");
		}

		// CountryId (if required)
		if (countryId <= 0) {
			errors.put("countryId", "Please select a country.");
		}

		// If basic validation failed, forward back immediately
		if (!errors.isEmpty()) {
			forwardBackWithErrors(request, response, c, errors);
			return;
		}

		// ---- Business validation: unique email ----
		try {
			Customer existing = customerDB.getCustomerByEmail(email);
			if (existing != null) {
				errors.put("email", "This email is already registered. Try logging in instead.");
				forwardBackWithErrors(request, response, c, errors);
				return;
			}

			// Only set password after validation passes
			c.setPassword(password);

			String newId = customerDB.createCustomer(c);

			// PRG redirect on success
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?msg=Registered");

		} catch (Exception e) {
			e.printStackTrace();
			errors.put("global", "Something went wrong while creating your account. Please try again.");
			forwardBackWithErrors(request, response, c, errors);
		}
	}

	private void forwardBackWithErrors(HttpServletRequest request, HttpServletResponse response, Customer customer,
			Map<String, String> errors) throws ServletException, IOException {
		request.setAttribute("customer", customer);
		request.setAttribute("errors", errors);
		request.getRequestDispatcher("/customer/register.jsp").forward(request, response);
	}

	private static String trim(String s) {
		return s == null ? null : s.trim();
	}

	private static boolean isBlank(String s) {
		return s == null || s.trim().isEmpty();
	}

	private static int parseIntSafe(String s, int fallback) {
		try {
			if (s == null)
				return fallback;
			return Integer.parseInt(s.trim());
		} catch (Exception e) {
			return fallback;
		}
	}
}