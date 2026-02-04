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

import Assignment1.DBUtil;
import Assignment1.Service.Service;

@WebServlet("/admin/services/edit")
public class AdminServiceEditServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminServiceEditServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			int serviceId = Integer.parseInt(request.getParameter("id"));
			Connection conn = DBUtil.getConnection();

			String sqlStr = "SELECT * FROM service WHERE service_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sqlStr);
			pstmt.setInt(1, serviceId);

			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				Service s = new Service(rs.getInt("service_id"), rs.getInt("category_id"), rs.getString("service_name"),
						rs.getString("description"), rs.getDouble("price"), rs.getInt("duration_min"),
						rs.getString("image_path"));

				request.setAttribute("service", s);
			}

			conn.close();
			request.getRequestDispatcher("/admin/adminEditService.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=" + e);
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			Connection conn = DBUtil.getConnection();

			int serviceId = Integer.parseInt(request.getParameter("service_id"));
			int categoryId = Integer.parseInt(request.getParameter("category_id"));
			String name = request.getParameter("service_name");
			String description = request.getParameter("description");
			double price = Double.parseDouble(request.getParameter("price"));
			int duration = Integer.parseInt(request.getParameter("duration_min"));
			String imagePath = request.getParameter("image_path");

			String sqlStr = "UPDATE service SET category_id=?, service_name=?, description=?, price=?, duration_min=?, image_path=? "
					+ "WHERE service_id=?";

			PreparedStatement pstmt = conn.prepareStatement(sqlStr);

			pstmt.setInt(1, categoryId);
			pstmt.setString(2, name);
			pstmt.setString(3, description);
			pstmt.setDouble(4, price);
			pstmt.setInt(5, duration);
			pstmt.setString(6, imagePath);
			pstmt.setInt(7, serviceId);

			pstmt.executeUpdate();
			conn.close();

			response.sendRedirect(request.getContextPath() + "/admin/services/list");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=" + e);
		}
	}
}