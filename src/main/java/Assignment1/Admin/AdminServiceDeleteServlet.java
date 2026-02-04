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

@WebServlet("/admin/services/delete")
public class AdminServiceDeleteServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public AdminServiceDeleteServlet() {
		super();
	}

	// Use POST for deletes from your modal
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			// this matches your JSP: name="service_id"
			int serviceId = Integer.parseInt(request.getParameter("service_id"));

			Connection conn = DBUtil.getConnection();

			String sqlStr = "DELETE FROM service WHERE service_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sqlStr);
			pstmt.setInt(1, serviceId);

			pstmt.executeUpdate();
			conn.close();

			response.sendRedirect(request.getContextPath() + "/admin/services/list");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=" + e.getMessage());
		}
	}

	// Optional: keep GET working as well (e.g. /admin/services/delete?id=1)
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			String idParam = request.getParameter("service_id");
			if (idParam == null || idParam.isBlank()) {
				idParam = request.getParameter("id");
			}

			int serviceId = Integer.parseInt(idParam);

			Connection conn = DBUtil.getConnection();
			String sqlStr = "DELETE FROM service WHERE service_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sqlStr);
			pstmt.setInt(1, serviceId);

			pstmt.executeUpdate();
			conn.close();

			response.sendRedirect(request.getContextPath() + "/admin/services/list");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/services/list?errCode=" + e.getMessage());
		}
	}
}