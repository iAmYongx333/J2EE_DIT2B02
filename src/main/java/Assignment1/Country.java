package Assignment1;

public class Country {
	private int id;
	private String countryCode;
	private String countryName;
	private String iso2;
	private String flagImage;

	public Country(int id, String countryCode, String countryName, String iso2, String flagImage) {
		this.id = id;
		this.countryCode = countryCode;
		this.countryName = countryName;
		this.iso2 = iso2;
		this.flagImage = flagImage;
	}

	public int getId() {
		return id;
	}

	public String getCountryCode() {
		return countryCode;
	}

	public String getCountryName() {
		return countryName;
	}

	public String getIso2() {
		return iso2;
	}

	public String getFlagImage() {
		return flagImage;
	}
}
