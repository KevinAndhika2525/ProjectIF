package UI;

import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;

import DAO.CustomerRepo;
import Model.Customer;
import Model.CustomerBuilder;
import Model.User;
import table.TableCustomer;

import javax.swing.JLabel;
import javax.swing.JOptionPane;

import java.awt.Font;
import javax.swing.JTextField;
import javax.swing.ScrollPaneConstants;
import javax.swing.JButton;
import java.awt.Color;
import javax.swing.JTable;
import java.awt.event.ActionListener;
import java.util.List;
import java.awt.event.ActionEvent;
import javax.swing.JScrollPane;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.lang.System.Logger;
import java.lang.System.Logger.Level;

public class CustomerFrame extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTextField txtAddress;
	private JTextField txtName;
	private JTextField txtNoHP;
	private JTable tableCustomers;
	private JScrollPane scrollPane;
	
	CustomerRepo cusr = new CustomerRepo();
	List<Customer> ls;
	String id;
	
	public void reset() {
		txtName.setText("");
		txtAddress.setText("");
		txtNoHP.setText("");
	}
	public void loadTable() {
		ls = cusr.show();
		TableCustomer tc = new TableCustomer(ls);
		tableCustomers.setModel(tc);;
		tableCustomers.getTableHeader().setVisible(true);
	}
	
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					CustomerFrame frame = new CustomerFrame();
					frame.setVisible(true);
					frame.loadTable();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the frame.
	 */
	public CustomerFrame() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 450, 477);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JLabel lblName = new JLabel("Name");
		lblName.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblName.setBounds(10, 34, 92, 25);
		contentPane.add(lblName);
		
		JLabel lblAddress = new JLabel("Address");
		lblAddress.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblAddress.setBounds(10, 71, 92, 25);
		contentPane.add(lblAddress);
		
		txtAddress = new JTextField();
		txtAddress.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtAddress.setColumns(10);
		txtAddress.setBounds(112, 71, 314, 25);
		contentPane.add(txtAddress);
		
		txtName = new JTextField();
		txtName.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtName.setColumns(10);
		txtName.setBounds(112, 34, 314, 25);
		contentPane.add(txtName);
		
		txtNoHP = new JTextField();
		txtNoHP.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtNoHP.setColumns(10);
		txtNoHP.setBounds(112, 106, 314, 25);
		contentPane.add(txtNoHP);
		
		JLabel lblNoHp = new JLabel("No HP");
		lblNoHp.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblNoHp.setBounds(10, 106, 92, 25);
		contentPane.add(lblNoHp);
		
		JScrollPane scrollPane = new JScrollPane();
		scrollPane.setBounds(10, 200, 416, 232);
		scrollPane.setViewportView(tableCustomers);
		scrollPane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
		scrollPane.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
		contentPane.add(scrollPane);
		
		tableCustomers = new JTable();
		tableCustomers.setToolTipText("");
		tableCustomers.setFillsViewportHeight(true);
		tableCustomers.setBackground(new Color(255, 255, 255));
		tableCustomers.setBounds(10, 200, 416, 232);
		scrollPane.setViewportView(tableCustomers);
		tableCustomers.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				id = tableCustomers.getValueAt(tableCustomers.getSelectedRow(),0).toString();
				txtName.setText(tableCustomers.getValueAt(tableCustomers.getSelectedRow(),1).toString());
				txtAddress.setText(tableCustomers.getValueAt(tableCustomers.getSelectedRow(),2).toString());
				txtNoHP.setText(tableCustomers.getValueAt(tableCustomers.getSelectedRow(),3).toString());
			}
		});
		tableCustomers.setFont(new Font("SansSerif", Font.PLAIN, 12));
		
		JButton btnSign = new JButton("Add");
        btnSign.setBackground(new Color(0, 255, 0));
        btnSign.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                Customer cus = new CustomerBuilder()
                    .setNama(txtName.getText())
                    .setAlamat(txtAddress.getText())
                    .setNoHp(txtNoHP.getText())
                    .build();
                try {
                    cusr.save(cus);
                    reset();
                    loadTable();
                } catch (Exception ex) {
//                    Logger.getLogger(CustomerFrame.class.getName()).log(Level.SEVERE, null, ex);
                    JOptionPane.showMessageDialog(null, "Error saving customer: " + ex.getMessage());
                }
            }
        });
		btnSign.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnSign.setBounds(193, 157, 75, 25);
		contentPane.add(btnSign);
		
		JButton btnUpdate = new JButton("Update");
		btnUpdate.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
		        Customer cus = new CustomerBuilder()
		            .setNama(txtName.getText())
		            .setAlamat(txtAddress.getText())
		            .setNoHp(txtNoHP.getText())
		            .setId(id) 
		            .build();
		        try {
		            cusr.update(cus);
		            reset();
		            loadTable();
		        } catch (Exception ex) {
//		            Logger.getLogger(CustomerFrame.class.getName()).log(Level.SEVERE, null, ex);
		            JOptionPane.showMessageDialog(null, "Error updating customer: " + ex.getMessage());
		        }
		    }
		});
		btnUpdate.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnUpdate.setBackground(new Color(0, 128, 255));
		btnUpdate.setBounds(272, 157, 75, 25);
		contentPane.add(btnUpdate);
		
		JButton btnDelete = new JButton("Delete");
		btnDelete.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
		        if (id != null) {
	                try {
	                    cusr.delete(id);
	                    reset();
	                    loadTable();
	                } catch (Exception ex) {
//		                    Logger.getLogger(CustomerFrame.class.getName()).log(Level.SEVERE, null, ex);
	                    JOptionPane.showMessageDialog(null, "Error deleting customer: " + ex.getMessage());
	                }
		            
		        } else {
		            JOptionPane.showMessageDialog(null, "Silahkan pilih data yang akan dihapus");
		        }
		    }
		});
		btnDelete.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnDelete.setBackground(new Color(255, 0, 0));
		btnDelete.setBounds(351, 157, 75, 25);
		contentPane.add(btnDelete);
		
		JButton btnBack = new JButton("Back");
		btnBack.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				MainFrame mf = new MainFrame();
				mf.setVisible(true);
				dispose();
			}
		});
		btnBack.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnBack.setBackground(new Color(192, 192, 192));
		btnBack.setBounds(10, 157, 75, 25);
		contentPane.add(btnBack);
	}
}
