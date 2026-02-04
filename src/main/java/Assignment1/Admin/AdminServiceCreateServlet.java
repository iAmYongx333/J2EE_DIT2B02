package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import Assignment1.DBUtil;

@WebServlet("/admin/services/create")
public class AdminServiceCreateServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminServiceCreateServlet() {
		super();
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			Connection conn = DBUtil.getConnection();

			int categoryId = Integer.parseInt(request.getParameter("category_id"));
			String name = request.getParameter("service_name");
			String description = request.getParameter("description");
			double price = Double.parseDouble(request.getParameter("price"));
			int duration = Integer.parseInt(request.getParameter("duration_min"));
			String imagePath = request.getParameter("image_path");

			String sqlStr = "INSERT INTO service (category_id, service_name, description, price, duration_min, image_path) "
					+ "VALUES (?, ?, ?, ?, ?, ?)";

			PreparedStatement pstmt = conn.prepareStatement(sqlStr);
			pstmt.setInt(1, categoryId);
			pstmt.setString(2, name);
			pstmt.setString(3, description);
			pstmt.setDouble(4, price);
			pstmt.setInt(5, duration);
			pstmt.setString(6, imagePath);

			pstmt.executeUpdate();
			conn.close();

			response.sendRedirect(request.getContextPath() + "/admin/services/list");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/adminAddService.jsp?errCode=" + e);
		}
	}
}