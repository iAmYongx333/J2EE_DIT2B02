package Assignment1;

public class Country {

    private int id;
    private int countryCode;
    private String countryName;
    private String iso2;
    private String flagImage;

    // ✅ Required for JSON mapping
    public Country() {}

    // Optional constructor
    public Country(int id, int countryCode, String countryName, String iso2, String flagImage) {
        this.id = id;
        this.countryCode = countryCode;
        this.countryName = countryName;
        this.iso2 = iso2;
        this.flagImage = flagImage;
    }

    // ===== Getters =====
    public int getId() { return id; }
    public int getCountryCode() { return countryCode; }
    public String getCountryName() { return countryName; }
    public String getIso2() { return iso2; }
    public String getFlagImage() { return flagImage; }

    // ===== Setters =====
    public void setId(int id) { this.id = id; }
    public void setCountryCode(int countryCode) { this.countryCode = countryCode; }
    public void setCountryName(String countryName) { this.countryName = countryName; }
    public void setIso2(String iso2) { this.iso2 = iso2; }
    public void setFlagImage(String flagImage) { this.flagImage = flagImage; }

    @Override
    public String toString() {
        return "Country{" +
                "id=" + id +
                ", countryCode=" + countryCode +
                ", countryName='" + countryName + '\'' +
                ", iso2='" + iso2 + '\'' +
                ", flagImage='" + flagImage + '\'' +
                '}';
    }
}
