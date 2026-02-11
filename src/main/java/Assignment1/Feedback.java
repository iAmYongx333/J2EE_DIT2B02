package Assignment1;

public class Feedback {

    private int feedbackId;
    private String userId;
    private int serviceId;
    private int rating;
    private String comments;
    private String createdAt;   // ✅ changed from Timestamp → String
	private String userName;

    public Feedback() {} // ✅ REQUIRED for JSON-B

    public Feedback(int feedbackId, String userId, int serviceId, int rating,
                    String comments, String createdAt, String userName) {
        this.feedbackId = feedbackId;
        this.userId = userId;
        this.serviceId = serviceId;
        this.rating = rating;
        this.comments = comments;
        this.userName = userName;
        this.createdAt = createdAt;
    }

    public int getFeedbackId() { return feedbackId; }
    public void setFeedbackId(int feedbackId) { this.feedbackId = feedbackId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComments() { return comments; }
    public void setComments(String comments) { this.comments = comments; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

	public String getUserName() { return userName; }
	public void setUserName(String userName) { this.userName = userName; }
}
