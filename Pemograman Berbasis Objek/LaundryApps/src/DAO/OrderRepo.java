package DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import Model.Order;
import config.Database;

public class OrderRepo implements OrderDAO{
	private Connection connection;
	final String insert = "INSERT INTO order (nama, qtytotal, total, tanggal) VALUES (?,?,?,?);";
	final String select = "SELECT * FROM order;";
	final String delete = "DELETE FROM order WHERE id=?;";
	final String update = "UPDATE order SET nama=?, qtytotal=?, total=?, tanggal=? WHERE id=?;";
	
	public OrderRepo() {
		connection = Database.koneksi();
	}
	
	@Override
	public void save(Order ord) {
		PreparedStatement st = null;
		try {
			st = connection.prepareStatement(insert);
			st.setString(1, ord.getNama());
			st.setString(2, ord.getQtyTotal());
			st.setString(3, ord.getTotal());
			st.setString(4, ord.getTanggal());
			st.executeUpdate();
		}catch(SQLException e) {
			e.printStackTrace();
		}finally {
			try {
				st.close();
			}catch(SQLException e) {
				e.printStackTrace();
			}
		}
	}
	@Override
	public List<Order> show(){
		List<Order> ls3 = null;
		try {
			ls3 = new ArrayList<Order>();
			Statement st = connection.createStatement();
			ResultSet rs = st.executeQuery(select);
			while(rs.next()) {
				Order ord = new Order();
				ord.setId(rs.getString("id"));
				ord.setNama(rs.getString("nama"));
				ord.setQtyTotal(rs.getString("qtyTotal"));
				ord.setTotal(rs.getString("total"));
				ord.setTanggal(rs.getString("tanggal"));
				ls3.add(ord);
			}
		}catch(SQLException e) {
			Logger.getLogger(OrderDAO.class.getName()).log(Level.SEVERE, null, e);
		}
		return ls3;
	}
	@Override
	public void update(Order oddr) {
		PreparedStatement st = null;
		try {
			st = connection.prepareStatement(update);
			st.setString(1,  oddr.getNama());
			st.setString(2,  oddr.getQtyTotal());
			st.setString(3,  oddr.getTotal());
			st.setString(4,  oddr.getTanggal());
			st.setString(5,  oddr.getId());
			st.executeUpdate();
		}catch(SQLException e) {
			e.printStackTrace();
		}finally {
			try {
				st.close();
			}catch(SQLException e) {
				e.printStackTrace();
			}
		}
	}
	@Override
	public void delete(String id) {
		PreparedStatement st = null;
		try {
			st = connection.prepareStatement(delete);
					st.setString(1,id);
			st.executeUpdate();
		}catch(SQLException e){
			e.printStackTrace();
		}finally {
			try {
				st.close();
			}catch(SQLException e) {
				e.printStackTrace();
			}
		}
	}
}
