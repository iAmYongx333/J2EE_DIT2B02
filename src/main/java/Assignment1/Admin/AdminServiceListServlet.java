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

import Assignment1.Category;
import Assignment1.DBUtil;
import Assignment1.Service.Service;

@WebServlet("/admin/services/list")
public class AdminServiceListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminServiceListServlet() {
		super();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			Connection conn = DBUtil.getConnection();

			ArrayList<Service> serviceList = new ArrayList<>();
			ArrayList<Category> categoryList = new ArrayList<>();

			// Load all services
			String sqlStr = "SELECT * FROM service ORDER BY service_id";
			PreparedStatement pstmt = conn.prepareStatement(sqlStr);
			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				Service s = new Service(rs.getInt("service_id"), rs.getInt("category_id"), rs.getString("service_name"),
						rs.getString("description"), rs.getDouble("price"), rs.getInt("duration_min"),
						rs.getString("image_path"));
				serviceList.add(s);
			}

			// Load all categories so we can display category names
			String catSql = "SELECT * FROM service_category ORDER BY category_id";
			PreparedStatement catStmt = conn.prepareStatement(catSql);
			ResultSet catRs = catStmt.executeQuery();

			while (catRs.next()) {
				Category c = new Category(catRs.getInt("category_id"), catRs.getString("category_name"),
						catRs.getString("description"));
				categoryList.add(c);
			}

			conn.close();

			request.setAttribute("serviceList", serviceList);
			request.setAttribute("categoryList", categoryList);

			// NOTE: use the new file name
			request.getRequestDispatcher("/admin/admin_services.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/admin_services.jsp?errCode=" + e.getMessage());
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}