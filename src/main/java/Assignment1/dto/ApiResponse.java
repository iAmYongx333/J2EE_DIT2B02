package Assignment1.dto;

import java.util.HashMap;

/**
 * Generic API response wrapper.
 * The Spring Boot API wraps all responses in: {"success":true,"message":"...","data":{...}}
 */
public class ApiResponse {
    private boolean success;
    private String message;
    private HashMap<String, Object> data;

    public ApiResponse() {}

    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public HashMap<String, Object> getData() { return data; }
    public void setData(HashMap<String, Object> data) { this.data = data; }
}
