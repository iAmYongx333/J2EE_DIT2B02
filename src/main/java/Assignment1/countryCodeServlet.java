package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.core.GenericType;

import java.io.IOException;
import java.util.ArrayList;

import Assignment1.api.ApiClient;

/**
 * Servlet for fetching country codes via API.
 * URL: /countryCodeServlet
 */
@WebServlet("/countryCodeServlet")
public class CountryCodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String errText = "";
        String errCode = request.getParameter("errCode");
        String origin = request.getParameter("origin");
        if (errCode != null) {
            errText = errCode;
        }

        HttpSession session = request.getSession(true);

        try {
            // Fetch countries from API
            ArrayList<Country> countryList = ApiClient.getList(
                "/countries",
                new GenericType<ArrayList<Country>>() {}
            );

            session.setAttribute("countryList", countryList);

            // Safe redirect: fallback if origin is null
            String redirectPath = (origin != null && !origin.isBlank()) ? origin : "index.jsp";
            response.sendRedirect(request.getContextPath() + "/" + redirectPath + "?errCode=" + errText);

        } catch (Exception e) {
            e.printStackTrace();
            String redirectPath = (origin != null && !origin.isBlank()) ? origin : "index.jsp";
            response.sendRedirect(request.getContextPath() + "/" + redirectPath + "?errCode=APIError");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
