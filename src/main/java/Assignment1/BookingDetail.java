package Assignment1;

import java.math.BigDecimal;

public class BookingDetail {
	private int serviceId;
	private String serviceName;
	private int quantity;
	private BigDecimal unitPrice;

	public BookingDetail(int serviceId, String serviceName, int quantity, BigDecimal unitPrice) {
		this.serviceId = serviceId;
		this.serviceName = serviceName;
		this.quantity = quantity;
		this.unitPrice = unitPrice;
	}

	// Getters and setters
	public int getServiceId() {
		return serviceId;
	}

	public void setServiceId(int serviceId) {
		this.serviceId = serviceId;
	}

	public String getServiceName() {
		return serviceName;
	}

	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}

	public BigDecimal getUnitPrice() {
		return unitPrice;
	}

	public void setUnitPrice(BigDecimal unitPrice) {
		this.unitPrice = unitPrice;
	}

}
