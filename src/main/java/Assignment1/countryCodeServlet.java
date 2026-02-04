package Assignment1;

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

/**
 * Servlet implementation class countryCodeServlet
 */
@WebServlet("/countryCodeServlet")
public class countryCodeServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public countryCodeServlet() {
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

		String errText = "";
		String errCode = request.getParameter("errCode");
		String origin = request.getParameter("origin");
		if (errCode != null) {
			errText = errCode;
		}

		try {
			// 2. Load MySQL JDBC
			Connection conn = DBUtil.getConnection();
			ArrayList<Country> countryList = new ArrayList<Country>();
			// 4. Query database
			String sqlStr = "SELECT * from country_code";
			PreparedStatement pstmt = conn.prepareStatement(sqlStr);
			ResultSet rs = pstmt.executeQuery();
			while (rs.next()) {
				Country c = new Country(rs.getInt("id"), rs.getString("country_code"), rs.getString("country_name"),
						rs.getString("iso2"), rs.getString("flag_image"));

				countryList.add(c);
			}
			session.setAttribute("countryList", countryList);
			// 7. Cleanup
			conn.close();
			response.sendRedirect(request.getContextPath() + "/" + origin + "?errCode=" + errText);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/" + origin + "?errCode=" + e);
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
