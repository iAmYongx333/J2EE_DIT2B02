package Assignment1.dto;

import java.util.List;
import java.util.UUID;

/**
 * DTO for checkout request to the API.
 */
public class CheckoutRequest {
    
    private UUID userId;
    private String serviceDate;
    private String notes;
    private List<CheckoutItem> items;

    public CheckoutRequest() {}

    public CheckoutRequest(UUID userId, String serviceDate, String notes, List<CheckoutItem> items) {
        this.userId = userId;
        this.serviceDate = serviceDate;
        this.notes = notes;
        this.items = items;
    }

    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }

    public String getServiceDate() { return serviceDate; }
    public void setServiceDate(String serviceDate) { this.serviceDate = serviceDate; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public List<CheckoutItem> getItems() { return items; }
    public void setItems(List<CheckoutItem> items) { this.items = items; }

    /**
     * Nested class for cart items in checkout.
     */
    public static class CheckoutItem {
        private int serviceId;
        private int quantity;
        private double unitPrice;

        public CheckoutItem() {}

        public CheckoutItem(int serviceId, int quantity, double unitPrice) {
            this.serviceId = serviceId;
            this.quantity = quantity;
            this.unitPrice = unitPrice;
        }

        public int getServiceId() { return serviceId; }
        public void setServiceId(int serviceId) { this.serviceId = serviceId; }

        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }

        public double getUnitPrice() { return unitPrice; }
        public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
    }
}
