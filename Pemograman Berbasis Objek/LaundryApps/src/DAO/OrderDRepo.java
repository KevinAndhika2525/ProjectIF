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

import Model.OrderDetailModel;
import config.Database;

public class OrderDRepo implements OrderDDAO{
	private Connection connection;
	final String insert = "INSERT INTO order_detail (jenis, qty, total) VALUES (?,?,?);";
	final String select = "SELECT * FROM order_detail;";
	final String delete = "DELETE FROM order_detail WHERE id=?;";
	final String update = "UPDATE order_detail SET jenis=?, qty=?, total=? WHERE id=?;";
	
	public OrderDRepo() {
		connection = Database.koneksi();
	}
	
	@Override
	public void save(OrderDetailModel ordd) {
		PreparedStatement st = null;
		try {
			st = connection.prepareStatement(insert);
			st.setString(1, ordd.getJenis());
			st.setString(2, ordd.getQty());
			st.setString(3, ordd.getTotal());
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
	public List<OrderDetailModel> show(){
		List<OrderDetailModel> ls2 = null;
		try {
			ls2 = new ArrayList<OrderDetailModel>();
			Statement st = connection.createStatement();
			ResultSet rs = st.executeQuery(select);
			while(rs.next()) {
				OrderDetailModel ordd = new OrderDetailModel();
				ordd.setId(rs.getString("id"));
				ordd.setJenis(rs.getString("jenis"));
				ordd.setQty(rs.getString("qty"));
				ordd.setTotal(rs.getString("total"));
				ls2.add(ordd);
			}
		}catch(SQLException e) {
			Logger.getLogger(OrderDDAO.class.getName()).log(Level.SEVERE, null, e);
		}
		return ls2;
	}
	@Override
	public void update(OrderDetailModel odm) {
		PreparedStatement st = null;
		try {
			st = connection.prepareStatement(update);
			st.setString(1,  odm.getJenis());;
			st.setString(2,  odm.getQty());;
			st.setString(3,  odm.getTotal());;
			st.setString(4,  odm.getId());;
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
