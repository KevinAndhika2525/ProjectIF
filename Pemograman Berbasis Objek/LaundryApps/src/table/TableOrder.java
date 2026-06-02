package table;

import java.util.List;

import javax.swing.table.AbstractTableModel;

import Model.Order;

public class TableOrder extends AbstractTableModel{
	List<Order> ls;
	
	private String[] columnNames = {"ID", "Nama", "Qty Total", "Total", "Tanggal"};
	
	public TableOrder(List<Order> ls) {
		this.ls = ls;
	}
	
	public int getRowCount() {
		return ls.size();
	}
	
	public int getColumnCount() {
		return 5;
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
			return ls.get(rowIndex).getQtyTotal();
		case 3:
			return ls.get(rowIndex).getTotal();
		case 4:
			return ls.get(rowIndex).getTanggal();
		default:
			return null;
		}
	}
}
