package config;

import java.sql.*;
import javax.swing.JOptionPane;

public class Database {
	private static Connection connection;
	
	public static Connection koneksi() {
		if (connection == null) {
			try {
				Class.forName("com.mysql.cj.jdbc.Driver");
				connection = DriverManager.getConnection("jdbc:mysql://localhost/laundry_apps","root","");
			} catch(Exception e){
				JOptionPane.showMessageDialog(null, e);
			}
		}
		return connection;
	}
}
