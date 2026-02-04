package Assignment1.Service;

public class Service {
	private int serviceId;
	private int categoryId;
	private String serviceName;
	private String description;
	private double price;
	private int durationMin;
	private String imagePath;

	public Service(int serviceId, int categoryId, String serviceName, String description, double price, int durationMin,
			String imagePath) {
		this.serviceId = serviceId;
		this.categoryId = categoryId;
		this.serviceName = serviceName;
		this.description = description;
		this.price = price;
		this.durationMin = durationMin;
		this.imagePath = imagePath;
	}

	public int getServiceId() {
		return serviceId;
	}

	public int getCategoryId() {
		return categoryId;
	}

	public String getServiceName() {
		return serviceName;
	}

	public String getDescription() {
		return description;
	}

	public double getPrice() {
		return price;
	}

	public int getDurationMin() {
		return durationMin;
	}

	public String getImagePath() {
		return imagePath;
	}
}
