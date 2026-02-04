
package Assignment1.Service;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import Assignment1.Category;
import Assignment1.DBUtil;

/**
 * Servlet implementation class serviceServlet
 */
@WebServlet("/serviceServlet")
public class ServiceListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ServiceListServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		HttpSession session = request.getSession(false);

		try {
			String errCode = request.getParameter("errCode");

			// 2. Load MySQL JDBC
			Connection conn = DBUtil.getConnection();
			ArrayList<Service> serviceList = new ArrayList<Service>();
			// 4. Query database
			String sqlStr = "SELECT * FROM service";
			PreparedStatement pstmt = conn.prepareStatement(sqlStr);
			ResultSet rs = pstmt.executeQuery();
			while (rs.next()) {
				Service s = new Service(rs.getInt("service_id"), rs.getInt("category_id"), rs.getString("service_name"),
						rs.getString("description"), rs.getDouble("price"), rs.getInt("duration_min"),
						rs.getString("image_path"));

				serviceList.add(s);
			}
			ArrayList<Category> categoryList = new ArrayList<Category>();

			String catSql = "SELECT * FROM service_category";
			PreparedStatement catPstmt = conn.prepareStatement(catSql);
			ResultSet catRs = catPstmt.executeQuery();

			while (catRs.next()) {
				Category c = new Category(catRs.getInt("category_id"), catRs.getString("category_name"),
						catRs.getString("description"));
				categoryList.add(c);
			}
			session.setAttribute("serviceList", serviceList);
			session.setAttribute("categoryList", categoryList);
			// 7. Cleanup
			conn.close();
			if (errCode != null) {
				response.sendRedirect(request.getContextPath() + "/public/services.jsp?errCode=" + errCode);
			} else {
				response.sendRedirect(request.getContextPath() + "/public/services.jsp");
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/public/services.jsp?errCode=" + e);
			return;
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
