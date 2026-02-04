package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;

import Assignment1.DBUtil;

@WebServlet("/admin/customers/list")
public class AdminCustomerListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminCustomerListServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try (Connection conn = DBUtil.getConnection()) {

			ArrayList<HashMap<String, Object>> customers = new ArrayList<>();

			String sql = "SELECT u.user_id, u.name, u.email, u.phone, u.created_at, "
					+ "       u.country_id, cc.country_name, cc.flag_image " + "FROM users u "
					+ "LEFT JOIN country_code cc ON u.country_id = cc.id "
					+ "WHERE u.user_role IS NULL OR u.user_role = 'customer' " + "ORDER BY u.created_at DESC";

			PreparedStatement pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				HashMap<String, Object> row = new HashMap<>();
				row.put("user_id", rs.getString("user_id"));
				row.put("name", rs.getString("name"));
				row.put("email", rs.getString("email"));
				row.put("phone", rs.getString("phone"));
				row.put("created_at", rs.getTimestamp("created_at"));
				row.put("country_id", rs.getInt("country_id"));
				row.put("countryName", rs.getString("country_name"));
				row.put("flagImage", rs.getString("flag_image"));
				customers.add(row);
			}

			request.setAttribute("customers", customers);
			request.getRequestDispatcher("/admin/manage_customers.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/manage_customers.jsp?errCode=" + e);
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}