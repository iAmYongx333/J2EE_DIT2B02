package Assignment1.Customer;

import java.sql.Timestamp;
import java.util.UUID;

public class Customer {

    private UUID userId;
    private String name;
    private String email;
    private String password;
    private String userRole;
    private String phone;
    private int countryId;
    private Timestamp createdAt;
    private String block;
    private String street;
    private String unitNumber;
    private String buildingName;
    private String postalCode;
    private String city;
    private String state;
    private String addressLine2;

    // ✅ Required for JSON mapping
    public Customer() {}

    // Optional full constructor
    public Customer(UUID userId, String name, String email, String password, String userRole,
                    String phone, int countryId, Timestamp createdAt, String block,
                    String street, String unitNumber, String buildingName,
                    String postalCode, String city, String state, String addressLine2) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.password = password;
        this.userRole = userRole;
        this.phone = phone;
        this.countryId = countryId;
        this.createdAt = createdAt;
        this.block = block;
        this.street = street;
        this.unitNumber = unitNumber;
        this.buildingName = buildingName;
        this.postalCode = postalCode;
        this.city = city;
        this.state = state;
        this.addressLine2 = addressLine2;
    }

    // ===== Getters =====
    public UUID getUserId() { return userId; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public String getUserRole() { return userRole; }
    public String getPhone() { return phone; }
    public int getCountryId() { return countryId; }
    public Timestamp getCreatedAt() { return createdAt; }
    public String getBlock() { return block; }
    public String getStreet() { return street; }
    public String getUnitNumber() { return unitNumber; }
    public String getBuildingName() { return buildingName; }
    public String getPostalCode() { return postalCode; }
    public String getCity() { return city; }
    public String getState() { return state; }
    public String getAddressLine2() { return addressLine2; }

    // ===== Setters =====
    public void setUserId(UUID userId) { this.userId = userId; }
    public void setName(String name) { this.name = name; }
    public void setEmail(String email) { this.email = email; }
    public void setPassword(String password) { this.password = password; }
    public void setUserRole(String userRole) { this.userRole = userRole; }
    public void setPhone(String phone) { this.phone = phone; }
    public void setCountryId(int countryId) { this.countryId = countryId; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public void setBlock(String block) { this.block = block; }
    public void setStreet(String street) { this.street = street; }
    public void setUnitNumber(String unitNumber) { this.unitNumber = unitNumber; }
    public void setBuildingName(String buildingName) { this.buildingName = buildingName; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }
    public void setCity(String city) { this.city = city; }
    public void setState(String state) { this.state = state; }
    public void setAddressLine2(String addressLine2) { this.addressLine2 = addressLine2; }

    @Override
    public String toString() {
        return "Customer{" +
                "userId=" + userId +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", userRole='" + userRole + '\'' +
                ", phone='" + phone + '\'' +
                ", countryId=" + countryId +
                ", city='" + city + '\'' +
                ", state='" + state + '\'' +
                '}';
    }
}
