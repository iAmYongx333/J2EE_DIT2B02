package Assignment1.view;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * View servlet for payment success page
 * Route: /success
 */
@WebServlet("/success")
public class SuccessViewServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		// Pass through any parameters to JSP
		String bookingId = request.getParameter("bookingId");
		String paymentId = request.getParameter("paymentId");
		
		request.setAttribute("bookingId", bookingId);
		request.setAttribute("paymentId", paymentId);
		
		request.getRequestDispatcher("/success.jsp").forward(request, response);
	}
}
