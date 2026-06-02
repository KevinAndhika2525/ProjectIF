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

import Model.Service;
import config.Database;

public class ServiceRepo implements ServiceDAO{
	private Connection connection;
	final String insert = "INSERT INTO service (jenis, harga, status) VALUES (?,?,?);";
	final String select = "SELECT * FROM service;";
	final String delete = "DELETE FROM service WHERE id=?;";
	final String update = "UPDATE service SET jenis=?, harga=?, status=? WHERE id=?;";
	
	public ServiceRepo() {
		connection = Database.koneksi();
	}
	
	@Override
	public void save(Service srv) {
		PreparedStatement st = null;
		try {
			st = connection.prepareStatement(insert);
			st.setString(1, srv.getJenis());
			st.setString(2, srv.getHarga());
			st.setString(3, srv.getStatus());
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
	public List<Service> show(){
		List<Service> ls = null;
		try {
			ls = new ArrayList<Service>();
			Statement st = connection.createStatement();
			ResultSet rs = st.executeQuery(select);
			while(rs.next()) {
				Service srv = new Service();
				srv.setId(rs.getString("id"));
				srv.setJenis(rs.getString("jenis"));
				srv.setHarga(rs.getString("harga"));
				srv.setStatus(rs.getString("status"));
				ls.add(srv);
			}
		}catch(SQLException e) {
			Logger.getLogger(ServiceDAO.class.getName()).log(Level.SEVERE, null, e);
		}
		return ls;
	}
	@Override
	public void update(Service srv) {
		PreparedStatement st = null;
		try {
			st = connection.prepareStatement(update);
			st.setString(1,  srv.getJenis());;
			st.setString(2,  srv.getHarga());;
			st.setString(3,  srv.getStatus());;
			st.setString(4,  srv.getId());;
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
