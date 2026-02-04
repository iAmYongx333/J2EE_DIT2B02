package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import Assignment1.DBUtil;

@WebServlet("/admin/customers/delete")
public class AdminCustomerDeleteServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		Object role = (session != null) ? session.getAttribute("sessRole") : null;
		if (role == null || !"admin".equals(role.toString())) {
			response.sendRedirect(request.getContextPath() + "/public/login.jsp?errCode=NoAdmin");
			return;
		}

		String userId = request.getParameter("user_id");
		if (userId == null || userId.isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/admin/customers/list?errCode=MissingUserId");
			return;
		}

		try (Connection conn = DBUtil.getConnection()) {
			String sql = "DELETE FROM users WHERE user_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setObject(1, java.util.UUID.fromString(userId));
			pstmt.executeUpdate();

			response.sendRedirect(request.getContextPath() + "/admin/customers/list?msg=Deleted");
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/admin/customers/list?errCode=DeleteFailed");
		}
	}
}