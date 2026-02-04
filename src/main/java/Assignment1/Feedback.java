package Assignment1;

import java.sql.Timestamp;

public class Feedback {

	private int feedbackId;
	private String userId;
	private int serviceId;
	private int rating;
	private String comments;
	private Timestamp createdAt;
	private String user_name;

	public Feedback(int feedbackId, String userId, int serviceId, int rating, String comments, Timestamp createdAt,
			String user_name) {
		this.feedbackId = feedbackId;
		this.userId = userId;
		this.serviceId = serviceId;
		this.rating = rating;
		this.comments = comments;
		this.createdAt = createdAt;
		this.user_name = user_name;
	}

	public int getFeedbackId() {
		return feedbackId;
	}

	public String getUserId() {
		return userId;
	}

	public int getServiceId() {
		return serviceId;
	}

	public int getRating() {
		return rating;
	}

	public String getComments() {
		return comments;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public String getUserName() {
		return user_name;
	}
}
