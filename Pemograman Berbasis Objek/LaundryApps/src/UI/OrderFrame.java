package UI;

import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;

import DAO.OrderRepo;
import Model.Order;
import table.TableOrder;

import javax.swing.JLabel;
import java.awt.Font;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.util.List;
import java.awt.event.ActionEvent;
import javax.swing.JScrollPane;
import javax.swing.ScrollPaneConstants;
import javax.swing.JTable;
import java.awt.Color;
import javax.swing.JTextField;
import javax.swing.SwingConstants;

public class OrderFrame extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTable tableOrders;
	private JTextField txtTrxCount;

	OrderRepo ordr = new OrderRepo();
	List<Order> ls;
//	static String id = null;
	String id;
	
	public void trxCount() {
//		int tempId = 0;
//		if (id==null) {
//			tempId = 1;
//		}else {
//			tempId = Integer.parseInt(id)+1;
//		}
//		
		
//		int tempId = 1;
//		if (tempId < 10) {
//			txtTrxCount.setText("TRX-00"+tempId);
//		}else if (tempId < 100) {
//			txtTrxCount.setText("TRX-0"+tempId);
//		}else {
//			txtTrxCount.setText("TRX-"+tempId);
//		}
	}
	
	public void loadTableOrder() {
		ls = ordr.show();
		TableOrder to = new TableOrder(ls);
		tableOrders.setModel(to);;
		tableOrders.getTableHeader().setVisible(true);
	}
	
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					OrderFrame frame = new OrderFrame();
					frame.setVisible(true);
					frame.trxCount();
					frame.loadTableOrder();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}
	
	public OrderFrame() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 732, 449);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JLabel lblDataOrderan = new JLabel("DATA ORDERAN");
		lblDataOrderan.setFont(new Font("Serif", Font.BOLD, 20));
		lblDataOrderan.setBounds(23, 42, 685, 38);
		contentPane.add(lblDataOrderan);
		
		JButton btnCustomer = new JButton("Edit/Detail");
		btnCustomer.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnCustomer.setBounds(598, 83, 110, 21);
		contentPane.add(btnCustomer);
		
		JButton btnDelete = new JButton("Delete");
		btnDelete.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnDelete.setBounds(478, 84, 110, 21);
		contentPane.add(btnDelete);
		
		JButton btnOrder = new JButton("Order");
		btnOrder.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				OrderDetail odf = new OrderDetail();
				odf.setVisible(true);
				odf.loadTableservice();
				odf.loadTable();
				odf.loadDataRp();
				odf.trxCount();
				
//				OrderDRepo odr = new OrderDRepo();
//				String lastOrderId = odr.getLastOrderIdFromDatabase(); 
//		        String newOrderId = generateOrderID(lastOrderId); 
				dispose();
			}
//			private String generateOrderID (String lastOrderId) {
//				int idNumber;
//				if (lastOrderId == null || lastOrderId.length() <4) {
//					idNumber = 1;
//				} else {
//					idNumber = Integer.parseInt(lastOrderId.substring(4));
//					idNumber++7
//					return String.format("TRX-406d", idNumber);
//				}
//			}
		});
		btnOrder.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnOrder.setBounds(23, 91, 139, 21);
		contentPane.add(btnOrder);
		
		JScrollPane scrollPane = new JScrollPane();
		scrollPane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
		scrollPane.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
		scrollPane.setBounds(10, 119, 698, 254);
		contentPane.add(scrollPane);
		
		tableOrders = new JTable();
		tableOrders.setToolTipText("");
		tableOrders.setFont(new Font("SansSerif", Font.PLAIN, 12));
		tableOrders.setFillsViewportHeight(true);
		tableOrders.setBackground(Color.WHITE);
		scrollPane.setViewportView(tableOrders);
		
		JButton btnBack = new JButton("Back");
		btnBack.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				MainFrame mf = new MainFrame();
				mf.setVisible(true);
				dispose();
			}
		});
		btnBack.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnBack.setBounds(598, 383, 110, 21);
		contentPane.add(btnBack);
		
		txtTrxCount = new JTextField();
		txtTrxCount.setHorizontalAlignment(SwingConstants.CENTER);
		txtTrxCount.setFont(new Font("SansSerif", Font.BOLD, 25));
		txtTrxCount.setEditable(false);
		txtTrxCount.setColumns(10);
		txtTrxCount.setBounds(478, 10, 230, 50);
		contentPane.add(txtTrxCount);
	}
}
