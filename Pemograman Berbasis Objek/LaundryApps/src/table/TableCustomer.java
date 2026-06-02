package table;

import java.util.List;

import javax.swing.table.AbstractTableModel;

import Model.Customer;

public class TableCustomer extends AbstractTableModel {
	List<Customer> ls;
	private String[] columnNames = {"ID", "Nama", "Alamat", "noHp"};
	public TableCustomer(List<Customer> ls) {
		this.ls = ls;
	}
	
	public int getRowCount() {
		return ls.size();
	}
	
	public int getColumnCount() {
		return 4;
	}
	
	public String getColumnName(int column) {
		return columnNames[column];
	}
	
	public Object getValueAt(int rowIndex, int columnIndex) {
		switch(columnIndex) {
		case 0:
			return ls.get(rowIndex).getId();
		case 1:
			return ls.get(rowIndex).getNama();
		case 2:
			return ls.get(rowIndex).getAlamat();
		case 3:
			return ls.get(rowIndex).getNoHp();
		default:
			return null;
		}
	}
}
