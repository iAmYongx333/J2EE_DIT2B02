package Assignment1;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import org.json.JSONObject;

/**
 * Service class to communicate with Stripe backend API
 * Handles payment processing and status checks
 */
public class PaymentService {
    
    private static final String BACKEND_URL = "http://localhost:8081/api"; // Change to your backend URL
    private static final int TIMEOUT = 10000; // 10 seconds
    
    /**
     * Get Stripe publishable key from backend
     */
    public static String getStripePublishableKey() throws IOException {
        String url = BACKEND_URL + "/payments/config";
        String response = makeGetRequest(url);
        JSONObject json = new JSONObject(response);
        return json.getString("publishableKey");
    }
    
    /**
     * Create PaymentIntent at backend
     */
    public static PaymentIntentResponse createPaymentIntent(String bookingId, String currency, 
                                                            String customerEmail, String description) 
            throws IOException {
        String url = BACKEND_URL + "/payments/intents";
        
        JSONObject requestBody = new JSONObject();
        requestBody.put("bookingId", bookingId);
        requestBody.put("currency", currency);
        requestBody.put("customerEmail", customerEmail);
        requestBody.put("description", description);
        
        String response = makePostRequest(url, requestBody.toString());
        JSONObject json = new JSONObject(response);
        
        return new PaymentIntentResponse(
            json.getString("paymentIntentId"),
            json.getString("clientSecret"),
            json.getString("status"),
            json.getLong("amount"),
            json.getString("currency")
        );
    }
    
    /**
     * Get payment status from backend
     */
    public static PaymentStatusResponse getPaymentStatus(String paymentIntentId) throws IOException {
        String url = BACKEND_URL + "/payments/intents/" + paymentIntentId;
        String response = makeGetRequest(url);
        JSONObject json = new JSONObject(response);
        
        return new PaymentStatusResponse(
            json.getString("paymentIntentId"),
            json.getString("status"),
            json.getLong("amount"),
            json.getString("currency")
        );
    }
    
    /**
     * Refund a payment
     */
    public static RefundResponse refundPayment(String paymentIntentId, Long amount, String reason) 
            throws IOException {
        String url = BACKEND_URL + "/payments/refund";
        
        JSONObject requestBody = new JSONObject();
        requestBody.put("paymentIntentId", paymentIntentId);
        if (amount != null) {
            requestBody.put("amount", amount);
        }
        if (reason != null) {
            requestBody.put("reason", reason);
        }
        
        String response = makePostRequest(url, requestBody.toString());
        JSONObject json = new JSONObject(response);
        
        return new RefundResponse(
            json.getString("refundId"),
            json.getString("status"),
            json.getLong("amount"),
            json.getString("currency")
        );
    }
    
    /**
     * Make GET request to backend API
     */
    private static String makeGetRequest(String urlString) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setConnectTimeout(TIMEOUT);
        conn.setReadTimeout(TIMEOUT);
        
        int responseCode = conn.getResponseCode();
        if (responseCode < 200 || responseCode >= 300) {
            throw new IOException("HTTP Error " + responseCode);
        }
        
        return readResponse(conn);
    }
    
    /**
     * Make POST request to backend API
     */
    private static String makePostRequest(String urlString, String jsonPayload) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setConnectTimeout(TIMEOUT);
        conn.setReadTimeout(TIMEOUT);
        conn.setDoOutput(true);
        
        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonPayload.getBytes("utf-8");
            os.write(input, 0, input.length);
        }
        
        int responseCode = conn.getResponseCode();
        if (responseCode < 200 || responseCode >= 300) {
            throw new IOException("HTTP Error " + responseCode + ": " + readErrorResponse(conn));
        }
        
        return readResponse(conn);
    }
    
    /**
     * Read response from connection
     */
    private static String readResponse(HttpURLConnection conn) throws IOException {
        StringBuilder response = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"))) {
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
        }
        return response.toString();
    }
    
    /**
     * Read error response from connection
     */
    private static String readErrorResponse(HttpURLConnection conn) throws IOException {
        StringBuilder response = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), "utf-8"))) {
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
        } catch (Exception e) {
            return "Unknown error";
        }
        return response.toString();
    }
    
    /**
     * PaymentIntent Response DTO
     */
    public static class PaymentIntentResponse {
        public String paymentIntentId;
        public String clientSecret;
        public String status;
        public long amount;
        public String currency;
        
        public PaymentIntentResponse(String paymentIntentId, String clientSecret, String status, long amount, String currency) {
            this.paymentIntentId = paymentIntentId;
            this.clientSecret = clientSecret;
            this.status = status;
            this.amount = amount;
            this.currency = currency;
        }
    }
    
    /**
     * Payment Status Response DTO
     */
    public static class PaymentStatusResponse {
        public String paymentIntentId;
        public String status;
        public long amount;
        public String currency;
        
        public PaymentStatusResponse(String paymentIntentId, String status, long amount, String currency) {
            this.paymentIntentId = paymentIntentId;
            this.status = status;
            this.amount = amount;
            this.currency = currency;
        }
    }
    
    /**
     * Refund Response DTO
     */
    public static class RefundResponse {
        public String refundId;
        public String status;
        public long amount;
        public String currency;
        
        public RefundResponse(String refundId, String status, long amount, String currency) {
            this.refundId = refundId;
            this.status = status;
            this.amount = amount;
            this.currency = currency;
        }
    }
}
