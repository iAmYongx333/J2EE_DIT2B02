package Assignment1;

public class CartItem {
	private int serviceId;
	private String serviceName;
	private String categoryName;
	private double unitPrice;
	private int quantity;

	public CartItem(int serviceId, String serviceName, String categoryName, double unitPrice, int quantity) {
		this.serviceId = serviceId;
		this.serviceName = serviceName;
		this.categoryName = categoryName;
		this.unitPrice = unitPrice;
		this.quantity = quantity;
	}

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

	public String getCategoryName() {
		return categoryName;
	}

	public void setCategoryName(String categoryName) {
		this.categoryName = categoryName;
	}

	public double getUnitPrice() {
		return unitPrice;
	}

	public void setUnitPrice(double unitPrice) {
		this.unitPrice = unitPrice;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}

	public double getLineTotal() {
		return unitPrice * quantity;
	}
}