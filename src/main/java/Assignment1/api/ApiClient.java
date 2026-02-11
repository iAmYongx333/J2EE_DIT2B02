package Assignment1.api;

import jakarta.ws.rs.client.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

public class ApiClient {

    private static final String BASE_URL = "http://localhost:8081/api";

    private static Client client = ClientBuilder.newClient();

    // ---------- GET ----------
    public static <T> T get(String path, Class<T> responseType) {
        WebTarget target = client.target(BASE_URL + path);
        Response response = target.request(MediaType.APPLICATION_JSON).get();

        if (response.getStatus() == 200) {
            return response.readEntity(responseType);
        }
        return null;
    }

    // ---------- POST ----------
    public static <T> T post(String path, Object body, Class<T> responseType) {
        WebTarget target = client.target(BASE_URL + path);
        Response response = target.request(MediaType.APPLICATION_JSON)
                .post(Entity.entity(body, MediaType.APPLICATION_JSON));

        if (response.getStatus() == 200 || response.getStatus() == 201) {
            return response.readEntity(responseType);
        }
        return null;
    }

    // ---------- PUT ----------
    public static int put(String path, Object body) {
        WebTarget target = client.target(BASE_URL + path);
        Response response = target.request(MediaType.APPLICATION_JSON)
                .put(Entity.entity(body, MediaType.APPLICATION_JSON));

        return response.getStatus();
    }

    // ---------- DELETE ----------
    public static int delete(String path) {
        WebTarget target = client.target(BASE_URL + path);
        Response response = target.request().delete();
        return response.getStatus();
    }
}
