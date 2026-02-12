package Assignment1;

import java.util.ArrayList;
import java.util.Date;

public class Booking {
	private int bookingId;
	private String customerUserId;
	private Date scheduledAt;
	private String status;
	private String notes;
	private ArrayList<BookingDetail> bookingDetails;

	// Constructors
	public Booking() {
		this.bookingDetails = new ArrayList<>();
	}

	public Booking(int bookingId, Date scheduledAt, String status, String notes) {
		this.bookingId = bookingId;
		this.scheduledAt = scheduledAt;
		this.status = status;
		this.notes = notes;
		this.bookingDetails = new ArrayList<>();
	}

	// Getters and Setters
	public int getBookingId() {
		return bookingId;
	}

	public void setBookingId(int bookingId) {
		this.bookingId = bookingId;
	}

	public String getCustomerUserId() {
		return customerUserId;
	}

	public void setCustomerUserId(String customerUserId) {
		this.customerUserId = customerUserId;
	}

	public Date getScheduledAt() {
		return scheduledAt;
	}

	public void setScheduledAt(Date scheduledAt) {
		this.scheduledAt = scheduledAt;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getNotes() {
		return notes;
	}

	public void setNotes(String notes) {
		this.notes = notes;
	}

	// BookingDetails getter and setter
	public ArrayList<BookingDetail> getBookingDetails() {
		return bookingDetails;
	}

	public void setBookingDetails(ArrayList<BookingDetail> bookingDetails) {
		this.bookingDetails = bookingDetails;
	}

	@Override
public String toString() {
    return "Booking{" +
            "bookingId=" + bookingId +
            ", scheduledAt=" + scheduledAt +
            ", status='" + status + '\'' +
            ", notes='" + notes + '\'' +
            ", bookingDetails=" + bookingDetails +
            '}';
}

}
