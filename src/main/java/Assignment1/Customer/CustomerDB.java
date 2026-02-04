package Assignment1.Customer;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

import Assignment1.DBUtil;

public class CustomerDB {

	// Create a new customer (returns generated UUID as String if you use UUID PK)
	public String createCustomer(Customer c) throws Exception {
		// Adjust table/column names to match your schema.
		// Common pattern in your app: users table has user_id (UUID), name, email,
		// password, etc.
		String sql = "INSERT INTO users (user_id, name, email, password, phone, street, postal_code, country, block_no, unit_no, country_id, role) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

		String newId = UUID.randomUUID().toString();

		try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setObject(1, UUID.fromString(newId));
			ps.setString(2, c.getFullName());
			ps.setString(3, c.getEmail());
			ps.setString(4, c.getPassword());
			ps.setString(5, c.getPhone());
			ps.setString(6, c.getStreet());
			ps.setString(7, c.getPostalCode());
			ps.setString(8, c.getCountry());
			ps.setString(9, c.getBlockNo());
			ps.setString(10, c.getUnitNo());
			ps.setInt(11, c.getCountryId());
			ps.setString(12, "Customer"); // or whatever your role string is

			ps.executeUpdate();
		}

		return newId;
	}

	public Customer getCustomerByEmail(String email) throws Exception {
		String sql = "SELECT user_id, name, email, password, phone, street, postal_code, country, block_no, unit_no, country_id "
				+ "FROM users WHERE email = ?";

		try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setString(1, email);

			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next())
					return null;

				Customer c = new Customer();
				c.setUserId(rs.getObject("user_id").toString());
				c.setFullName(rs.getString("name"));
				c.setEmail(rs.getString("email"));
				c.setPassword(rs.getString("password"));
				c.setPhone(rs.getString("phone"));
				c.setStreet(rs.getString("street"));
				c.setPostalCode(rs.getString("postal_code"));
				c.setCountry(rs.getString("country"));
				c.setBlockNo(rs.getString("block_no"));
				c.setUnitNo(rs.getString("unit_no"));
				c.setCountryId(rs.getInt("country_id"));
				return c;
			}
		}
	}

	public Customer getCustomerById(String userId) throws Exception {
		String sql = "SELECT user_id, name, email, password, phone, street, postal_code, country, block_no, unit_no, country_id "
				+ "FROM users WHERE user_id = ?";

		try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setObject(1, UUID.fromString(userId));

			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next())
					return null;

				Customer c = new Customer();
				c.setUserId(rs.getObject("user_id").toString());
				c.setFullName(rs.getString("name"));
				c.setEmail(rs.getString("email"));
				c.setPassword(rs.getString("password"));
				c.setPhone(rs.getString("phone"));
				c.setStreet(rs.getString("street"));
				c.setPostalCode(rs.getString("postal_code"));
				c.setCountry(rs.getString("country"));
				c.setBlockNo(rs.getString("block_no"));
				c.setUnitNo(rs.getString("unit_no"));
				c.setCountryId(rs.getInt("country_id"));
				return c;
			}
		}
	}

	public void updateCustomer(Customer c) throws Exception {
		String sql = "UPDATE users SET name=?, phone=?, street=?, postal_code=?, country=?, block_no=?, unit_no=?, country_id=? "
				+ "WHERE user_id=?";

		try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setString(1, c.getFullName());
			ps.setString(2, c.getPhone());
			ps.setString(3, c.getStreet());
			ps.setString(4, c.getPostalCode());
			ps.setString(5, c.getCountry());
			ps.setString(6, c.getBlockNo());
			ps.setString(7, c.getUnitNo());
			ps.setInt(8, c.getCountryId());
			ps.setObject(9, UUID.fromString(c.getUserId()));

			ps.executeUpdate();
		}
	}
}