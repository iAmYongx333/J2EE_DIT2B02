package Assignment1.dto;

import java.sql.Timestamp;

public class BookingDetailDTO {
    private int bookingId;
    private String customerId;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private int serviceId;
    private String serviceName;
    private double price;
    private String status;
    private Timestamp bookingDate;
    private Timestamp createdAt;

    public BookingDetailDTO(int bookingId, String customerId, String customerName, String customerEmail,
                            String customerPhone, int serviceId, String serviceName, double price,
                            String status, Timestamp bookingDate, Timestamp createdAt) {
        this.bookingId = bookingId;
        this.customerId = customerId;
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.customerPhone = customerPhone;
        this.serviceId = serviceId;
        this.serviceName = serviceName;
        this.price = price;
        this.status = status;
        this.bookingDate = bookingDate;
        this.createdAt = createdAt;
    }

    // Getters and setters...
}
