package Assignment1.Customer;

import java.io.Serializable;

public class Customer implements Serializable {
	private static final long serialVersionUID = 1L;

	private String userId;

	private String fullName;
	private String email;
	private String password;
	private String phone;
	private String street;
	private String postalCode;
	private String country;
	private String blockNo;
	private String unitNo;
	private int countryId;

	public Customer() {
	}

	public Customer(String fullName, String email, String password, String phone, String street, String postalCode,
			String country, String blockNo, String unitNo, int countryId) {
		this.fullName = fullName;
		this.email = email;
		this.password = password;
		this.phone = phone;
		this.street = street;
		this.postalCode = postalCode;
		this.country = country;
		this.blockNo = blockNo;
		this.unitNo = unitNo;
		this.countryId = countryId;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getFullName() {
		return fullName;
	}

	public void setFullName(String fullName) {
		this.fullName = fullName;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getStreet() {
		return street;
	}

	public void setStreet(String street) {
		this.street = street;
	}

	public String getPostalCode() {
		return postalCode;
	}

	public void setPostalCode(String postalCode) {
		this.postalCode = postalCode;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public String getBlockNo() {
		return blockNo;
	}

	public void setBlockNo(String blockNo) {
		this.blockNo = blockNo;
	}

	public String getUnitNo() {
		return unitNo;
	}

	public void setUnitNo(String unitNo) {
		this.unitNo = unitNo;
	}

	public int getCountryId() {
		return countryId;
	}

	public void setCountryId(int countryId) {
		this.countryId = countryId;
	}
}