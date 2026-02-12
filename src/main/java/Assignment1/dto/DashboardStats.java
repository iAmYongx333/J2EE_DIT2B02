package Assignment1.dto;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * DTO for dashboard statistics from the API.
 * Maps to the DashboardStatsDTO returned by GET /admin/dashboard
 */
public class DashboardStats {
    
    private int totalCustomers;
    private int totalServices;
    private int totalFeedback;
    private int recentUsers;
    private ArrayList<HashMap<String, Object>> recentFeedback;

    public DashboardStats() {}

    public int getTotalCustomers() { return totalCustomers; }
    public void setTotalCustomers(int totalCustomers) { this.totalCustomers = totalCustomers; }

    public int getTotalServices() { return totalServices; }
    public void setTotalServices(int totalServices) { this.totalServices = totalServices; }

    public int getTotalFeedback() { return totalFeedback; }
    public void setTotalFeedback(int totalFeedback) { this.totalFeedback = totalFeedback; }

    public int getRecentUsers() { return recentUsers; }
    public void setRecentUsers(int recentUsers) { this.recentUsers = recentUsers; }

    public ArrayList<HashMap<String, Object>> getRecentFeedback() { return recentFeedback; }
    public void setRecentFeedback(ArrayList<HashMap<String, Object>> recentFeedback) { this.recentFeedback = recentFeedback; }
}
