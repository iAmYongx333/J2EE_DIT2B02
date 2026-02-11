package Assignment1.dto;

/**
 * DTO for dashboard statistics from the API.
 */
public class DashboardStats {
    
    private int totalCustomers;
    private int totalServices;
    private int totalFeedback;
    private int recentUsers;

    public DashboardStats() {}

    public DashboardStats(int totalCustomers, int totalServices, int totalFeedback, int recentUsers) {
        this.totalCustomers = totalCustomers;
        this.totalServices = totalServices;
        this.totalFeedback = totalFeedback;
        this.recentUsers = recentUsers;
    }

    public int getTotalCustomers() { return totalCustomers; }
    public void setTotalCustomers(int totalCustomers) { this.totalCustomers = totalCustomers; }

    public int getTotalServices() { return totalServices; }
    public void setTotalServices(int totalServices) { this.totalServices = totalServices; }

    public int getTotalFeedback() { return totalFeedback; }
    public void setTotalFeedback(int totalFeedback) { this.totalFeedback = totalFeedback; }

    public int getRecentUsers() { return recentUsers; }
    public void setRecentUsers(int recentUsers) { this.recentUsers = recentUsers; }
}
