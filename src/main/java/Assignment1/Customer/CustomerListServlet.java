package Assignment1.Customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.util.UUID;
import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.google.i18n.phonenumbers.Phonenumber;

import Assignment1.DBUtil;

/**
 * Servlet implementation class customersServlet
 */
@WebServlet("/customersServlet")
public class CustomerListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public CustomerListServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	private boolean isValidPhoneNumber(String phone, String countryCode) {
		PhoneNumberUtil phoneUtil = PhoneNumberUtil.getInstance();

		try {
			Phonenumber.PhoneNumber number = phoneUtil.parse(phone, countryCode);
			return phoneUtil.isValidNumber(number);
		} catch (Exception e) {
			return false;
		}
	}

	private boolean isValidEmail(String email) {
		if (email == null)
			return false;

		return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		String action = request.getParameter("action");
		if ("login".equals(action)) {
			loginUser(request, response);
		} else if ("retrieveUser".equals(action)) {
			retrieveUser(request, response);
		} else if ("logout".equals(action)) {
			logoutUser(request, response);
		} else {
			System.out.println("get error");
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		String action = request.getParameter("action");
		if ("create".equals(action)) {
			addUser(request, response);
		} else if ("update".equals(action)) {
			updateUser(request, response);
		} else if ("delete".equals(action)) {
			deleteUser(request, response);
		} else if ("password".equals(action)) {
			editPasswordUser(request, response);
		}
	}

	private void updateUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		System.out.print("Update");
		HttpSession session = request.getSession(false);

		// Check session
		if (session == null || session.getAttribute("sessId") == null) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
			return;
		}

		// Convert user id from session to UUID
		UUID userId;
		try {
			userId = UUID.fromString(session.getAttribute("sessId").toString());
		} catch (Exception e) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=InvalidSession");
			return;
		}

		// Get updated values from form
		String fullName = request.getParameter("name");
		String email = request.getParameter("email");
		String phone = request.getParameter("Phone");
		String street = request.getParameter("Street");
		String postalCode = request.getParameter("postal_code");
		String blockNo = request.getParameter("block_no");
		String unitNo = request.getParameter("unit_no");
		int countryId = Integer.parseInt(request.getParameter("country")); // <-- from dropdown
		if (!isValidEmail(email)) {
			response.sendRedirect(request.getContextPath() + "/public/edit_profile.jsp?errCode=InvalidEmailFormat");
			return;
		}

		try (Connection conn = DBUtil.getConnection()) {
			String countryStr = "select iso2 from country_code where id = ?";
			PreparedStatement cstmt = conn.prepareStatement(countryStr);
			cstmt.setInt(1, countryId);
			ResultSet crs = cstmt.executeQuery();
			if (crs.next()) {
				String countryISO = crs.getString("iso2").toUpperCase();
				System.out.print(countryISO);
				System.out.print(phone);
				if (!isValidPhoneNumber(phone, countryISO)) {
					response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?errCode=InvalidPhone");
					return;
				}
			}
			String sqlStr = "UPDATE users SET " + "name = ?, " + "email = ?, " + "phone = ?, " + "street = ?, "
					+ "postal_code = ?, " + "country_id = ?, " + // ✅ UPDATE COUNTRY
					"block = ?, " + "unit_number = ? " + "WHERE user_id = ?";

			PreparedStatement pstmt = conn.prepareStatement(sqlStr);

			pstmt.setString(1, fullName);
			pstmt.setString(2, email);
			pstmt.setString(3, phone);
			pstmt.setString(4, street);
			pstmt.setString(5, postalCode);
			pstmt.setInt(6, countryId); // ✅ Country from hidden input
			pstmt.setString(7, blockNo);
			pstmt.setString(8, unitNo);
			pstmt.setObject(9, userId); // UUID

			int rowsUpdated = pstmt.executeUpdate();

			if (rowsUpdated == 0) {
				System.out.print("fail");
				response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?errCode=UpdateFailed");
				return;
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?errCode=UpdateFailed");
			return;
		}

		// Reload updated profile info
		response.sendRedirect(request.getContextPath() + "/customersServlet?action=retrieveUser&msg=updated");
	}

	private void deleteUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("user") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		UUID userId = (UUID) session.getAttribute("sessId");

		String passwordInput = request.getParameter("password");

		try (Connection conn = DBUtil.getConnection()) {

			// 1️⃣ Check if password is correct
			String checkSQL = "SELECT password FROM users WHERE id = ?";
			PreparedStatement checkStmt = conn.prepareStatement(checkSQL);
			checkStmt.setObject(1, userId);

			ResultSet rs = checkStmt.executeQuery();

			if (rs.next()) {
				String dbPassword = rs.getString("password");

				if (!dbPassword.equals(passwordInput)) {
					response.sendRedirect(
							request.getContextPath() + "/customer/delete_account.jsp?errCode=Incorrectpassword.");
					return;
				}
			} else {
				response.sendRedirect("login.jsp");
				return;
			}

			// 2️⃣ Delete user
			String deleteSQL = "DELETE FROM users WHERE id = ?";
			PreparedStatement deleteStmt = conn.prepareStatement(deleteSQL);
			deleteStmt.setObject(1, userId);
			deleteStmt.executeUpdate();

			// 3️⃣ Clear session
			session.invalidate();

			// 4️⃣ Redirect
			response.sendRedirect("account_deleted.jsp");

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void addUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String fullName = request.getParameter("name");
		String email = request.getParameter("email");
		String password = request.getParameter("password");
		String phone = request.getParameter("Phone");
		String street = request.getParameter("Street");
		String postal_code = request.getParameter("postal_code");
		int country = Integer.parseInt(request.getParameter("country"));
		String block_no = request.getParameter("block_no");
		String unit_no = request.getParameter("unit_no");
		String building_name = request.getParameter("building_name");
		String city = request.getParameter("city");
		String state = request.getParameter("state");
		String address_line2 = request.getParameter("address_line2");
		if (!isValidEmail(email)) {
			response.sendRedirect(request.getContextPath() + "/public/register.jsp?errCode=InvalidEmailFormat");
			return;
		}
		try {
			// 2. Load MySQL JDBC
			Connection conn = DBUtil.getConnection();
			String countryStr = "select iso2 from country_code where id = ?";
			PreparedStatement cstmt = conn.prepareStatement(countryStr);
			cstmt.setInt(1, country);
			ResultSet crs = cstmt.executeQuery();
			if (crs.next()) {
				String countryISO = crs.getString("iso2").toUpperCase();
				System.out.print(countryISO);
				System.out.print(phone);
				if (!isValidPhoneNumber(phone, countryISO)) {
					response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?errCode=InvalidPhone");
					return;
				}
			}

			// 4. Query database
			String sqlStr = "INSERT INTO users (name, email, password, phone, street, postal_code, country_id, block, unit_number, state, address_line2, building_name, city) "
					+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " + "ON CONFLICT (email) DO NOTHING";
			PreparedStatement pstmt = conn.prepareStatement(sqlStr);

			// Set parameters
			pstmt.setString(1, fullName);
			pstmt.setString(2, email);
			pstmt.setString(3, password);
			pstmt.setString(4, phone);
			pstmt.setString(5, street);
			pstmt.setString(6, postal_code);
			pstmt.setInt(7, country);
			pstmt.setString(8, block_no);
			pstmt.setString(9, unit_no);
			pstmt.setString(10, state);
			pstmt.setString(11, address_line2);
			pstmt.setString(12, building_name);
			pstmt.setString(13, city);

			// Execute insert
			int rowsInserted = pstmt.executeUpdate();
			if (rowsInserted > 0) {
				response.sendRedirect(request.getContextPath() + "/public/login.jsp?msgCode=RegisterSuccess");
			} else {
				response.sendRedirect(request.getContextPath() + "/public/register.jsp?errCode=NameExists");
			}

			// 7. Cleanup
			conn.close();

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/countryCodeServlet?errCode=" + e);
			return;
		}
	}

	private void loginUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String email = request.getParameter("email");
		String password = request.getParameter("password");
		try {
			// 2. Load MySQL JDBC
			Connection conn = DBUtil.getConnection();

			// 4. Query database
			String sql = "SELECT user_id, user_role FROM users WHERE email = ? AND password = ?";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, email);
			pstmt.setString(2, password);

			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				HttpSession session = request.getSession();
				session.setMaxInactiveInterval(30 * 60);
				session.setAttribute("sessId", rs.getString("user_id"));
				session.setAttribute("sessRole", rs.getString("user_role"));
				response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
				conn.close();
				return;
			} else {
				response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=invalidLogin");
				conn.close();
				return;
			}
			// 7. Cleanup

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=" + e);
			return;
		}

	}

	private void retrieveUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		boolean userFound = false;
		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("sessId") == null) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
			return;
		}
		UUID userId;
		try {
			userId = UUID.fromString(session.getAttribute("sessId").toString());
		} catch (IllegalArgumentException e) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=invalidSession");
			return;
		}
		try {
			Connection conn = DBUtil.getConnection();

			String sqlStr = "SELECT " + "users.name AS name, " + "users.email AS email, "
					+ "users.password AS password, " + "users.phone AS phone, " + "users.street AS street, "
					+ "users.postal_code AS postal_code, " + "country_code.country_name AS country_name, "
					+ "users.block AS block_no, " + "users.unit_number AS unit_no," + "users.country_id as country_id "
					+ " FROM users INNER JOIN " + "country_code ON users.country_id = country_code.id "
					+ " WHERE users.user_id = ?";

			PreparedStatement pstmt = conn.prepareStatement(sqlStr);
			// pstmt.setObject(1, userId);
			pstmt.setObject(1, userId);
			ResultSet rs = pstmt.executeQuery();
			if (rs.next()) {
				Customer user = new Customer(rs.getString("name"), rs.getString("email"), rs.getString("password"),
						rs.getString("phone"), rs.getString("street"), rs.getString("postal_code"),
						rs.getString("country_name"), rs.getString("block_no"), rs.getString("unit_no"),
						rs.getInt("country_id"));

				userFound = true;

				// ✅ Store object instead of many attributes
				session.setAttribute("user", user);

				// Forward to JSP

				response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
			}
			if (!userFound) {
				System.out.print("Fail");
				response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=invalidUserId");
			}

			conn.close();

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=Exception");
			return;
		}

	}

	private void editPasswordUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("sessId") == null) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoSession");
			return;
		}

		UUID userId;
		try {
			userId = UUID.fromString(session.getAttribute("sessId").toString());
		} catch (IllegalArgumentException e) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=invalidSession");
			return;
		}

		String oldPassword = request.getParameter("oldPassword");
		String newPassword = request.getParameter("newPassword");
		String confirmPassword = request.getParameter("confirmPassword");

		// 1. Check if new password matches confirm password
		if (!newPassword.equals(confirmPassword)) {
			response.sendRedirect(
					request.getContextPath() + "/customer/edit_profile.jsp?error=New passwords do not match");
			return;
		}

		try (Connection conn = DBUtil.getConnection()) {

			// 2. Get existing password
			String sql = "SELECT password FROM users WHERE user_id = ?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setObject(1, userId);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				String dbPassword = rs.getString("password");

				// 3. Compare old password
				if (!dbPassword.equals(oldPassword)) {
					response.sendRedirect(
							request.getContextPath() + "/customer/edit_profile.jsp?error=Old password is incorrect");
					return;
				}

				// 4. Update new password
				String update = "UPDATE users SET password = ? WHERE user_id = ?";
				PreparedStatement ps2 = conn.prepareStatement(update);
				ps2.setString(1, newPassword);
				ps2.setObject(2, userId);

				int rows = ps2.executeUpdate();

				if (rows > 0) {
					response.sendRedirect(request.getContextPath()
							+ "/customer/edit_profile.jsp?success=Password updated successfully");
				} else {
					response.sendRedirect(
							request.getContextPath() + "/customer/edit_profile.jsp?error=Password update failed");
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/customer/edit_profile.jsp?error=Server error");
		}
	}

	private void logoutUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false); // don't create new

		if (session != null) {
			session.invalidate(); // DESTROY session
		}

		response.sendRedirect(request.getContextPath() + "/public/login.jsp");
	}

}