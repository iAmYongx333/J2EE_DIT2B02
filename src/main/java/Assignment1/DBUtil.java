package Assignment1;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBUtil {

	// Your existing Neon URL (kept in-code as per your project)
	private static final String URL = "jdbc:postgresql://ep-blue-tooth-a166h612-pooler.ap-southeast-1.aws.neon.tech/neondb"
			+ "?user=neondb_owner&password=npg_iGbI0Sg9CRMH&sslmode=require";

	// Load driver ONCE (not every call)
	static {
		try {
			Class.forName("org.postgresql.Driver");
		} catch (ClassNotFoundException e) {
			throw new ExceptionInInitializerError("PostgreSQL JDBC driver not found: " + e.getMessage());
		}
	}

	private DBUtil() {
	}

	// Return a fresh connection (safe for concurrent requests).
	// With Neon "pooler" in your hostname, server-side pooling is already being
	// used.
	public static Connection getConnection() throws SQLException {
		return DriverManager.getConnection(URL);
	}
}