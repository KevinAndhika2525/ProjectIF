package UI;

import java.awt.Color;
import java.awt.EventQueue;

import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;

import DAO.CustomerRepo;
import Model.Customer;
import table.TableCustomer;

import javax.swing.JScrollPane;
import javax.swing.JLabel;
import java.awt.Font;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.List;

import javax.swing.JTable;
import javax.swing.JTextField;

import java.awt.event.ActionListener;
import java.awt.event.ContainerAdapter;
import java.awt.event.ContainerEvent;

public class DialogCustomer extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTable tableCustomers;
	
	CustomerRepo cusr = new CustomerRepo();
	List<Customer> ls;
	String id;

	public void loadTable() {
		ls = cusr.show();
		TableCustomer tc = new TableCustomer(ls);
		tableCustomers.setModel(tc);;
		tableCustomers.getTableHeader().setVisible(true);
	}
	
//	public void loadPelangan() {
//		String cust;
//		cbPelanggan.addItem(String.valueOf(tableCustomers.getRowCount()));
////		for (int i = 0; i < tableCustomers.getRowCount(); i++) {
////		    Object value = tableCustomers.getValueAt(i, 1); 
////	
////            cust = value.toString();
////            cbPelanggan.addItem(cust); 
////	        
////		}
//	}
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					DialogCustomer frame = new DialogCustomer();
					frame.setVisible(true);
					frame.loadTable();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}
	
	public DialogCustomer() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 450, 300);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JScrollPane scrollPane = new JScrollPane();
		scrollPane.setBounds(10, 57, 416, 196);
		contentPane.add(scrollPane);
		
		tableCustomers = new JTable();
		tableCustomers.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				OrderDetail odf = new OrderDetail();
				odf.loadTableservice();
				odf.loadTable();
				odf.loadDataRp();
				odf.trxCount();
				
				String customer = tableCustomers.getValueAt(tableCustomers.getSelectedRow(), 1).toString();
		        odf.onCustomerSelected(customer);
				odf.setVisible(true);
		        dispose();
		        
		        
//				txtA.setText(tableCustomers.getValueAt(tableCustomers.getSelectedRow(),1).toString());
			}
		});
		tableCustomers.setToolTipText("");
		tableCustomers.setFillsViewportHeight(true);
		tableCustomers.setBackground(new Color(255, 255, 255));
		tableCustomers.setBounds(10, 200, 416, 232);
		scrollPane.setViewportView(tableCustomers);
		tableCustomers.setFont(new Font("SansSerif", Font.PLAIN, 12));
		
		JLabel lblCustomerList = new JLabel("Customer List");
		lblCustomerList.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblCustomerList.setBounds(10, 22, 119, 25);
		contentPane.add(lblCustomerList);
	}
}
