package table;

import java.util.List;

import javax.swing.table.AbstractTableModel;

import Model.Service;

public class TableService extends AbstractTableModel{
	List<Service> ls;
	private String[] columnNames = {"ID", "Jenis", "Harga", "Status"};
	public TableService(List<Service> ls) {
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
			return ls.get(rowIndex).getJenis();
		case 2:
			return ls.get(rowIndex).getHarga();
		case 3:
			return ls.get(rowIndex).getStatus();
		default:
			return null;
		}
	}
}
