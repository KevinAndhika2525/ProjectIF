package UI;

import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;

import DAO.ServiceRepo;
import Model.Service;
import table.TableService;

import javax.swing.JScrollPane;
import javax.swing.JLabel;
import javax.swing.JOptionPane;

import java.awt.Font;
import javax.swing.JTextField;
import javax.swing.JButton;
import java.awt.Color;
import javax.swing.JTable;
import java.awt.event.ActionListener;
import java.util.List;
import java.awt.event.ActionEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

public class ServiceFrame extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTable tableServices;
	private JTextField txtHarga;
	private JTextField txtStatus;
	private JTextField txtJenis;
	
	ServiceRepo srvr = new ServiceRepo();
	List<Service> ls;
	String id;
	
	public void reset() {
		txtJenis.setText("");
		txtHarga.setText("");
		txtStatus.setText("Tersedia");
	}
	public void loadTable() {
		ls = srvr.show();
		TableService ts = new TableService(ls);
		tableServices.setModel(ts);;
		tableServices.getTableHeader().setVisible(true);
	}
	
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					ServiceFrame frame = new ServiceFrame();
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
	public ServiceFrame() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 450, 372);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JScrollPane scrollPane = new JScrollPane();
		scrollPane.setBounds(10, 138, 416, 152);
		contentPane.add(scrollPane);
		
		tableServices = new JTable();
		tableServices.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				id = tableServices.getValueAt(tableServices.getSelectedRow(),0).toString();
				txtJenis.setText(tableServices.getValueAt(tableServices.getSelectedRow(),1).toString());
				txtHarga.setText(tableServices.getValueAt(tableServices.getSelectedRow(),2).toString());
			}
		});
		scrollPane.setViewportView(tableServices);
		tableServices.setToolTipText("");
		tableServices.setFont(new Font("SansSerif", Font.PLAIN, 12));
		tableServices.setFillsViewportHeight(true);
		tableServices.setBackground(Color.WHITE);
		
		JButton btnCreate = new JButton("Create");
		btnCreate.setBackground(new Color(0, 255, 0));
		btnCreate.setBounds(192, 300, 75, 25);
		btnCreate.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				Service srv = new Service();
				srv.setJenis(txtJenis.getText());
				srv.setHarga(txtHarga.getText());
				srv.setStatus("Sedang Diproses");
				reset();
				srvr.save(srv);
				loadTable();
			}
		});
		btnCreate.setFont(new Font("SansSerif", Font.BOLD, 12));
		contentPane.add(btnCreate);
		
		JButton btnUpdate = new JButton("Update");
		btnUpdate.setBounds(272, 300, 75, 25);
		btnUpdate.setBackground(new Color(0, 128, 255));
		btnUpdate.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				Service srv = new Service();
				srv.setJenis(txtJenis.getText());
				srv.setHarga(txtHarga.getText());
				srv.setStatus(txtStatus.getText());
				srv.setId(id);
				srvr.update(srv);
				reset();
				loadTable();
			}
		});
		btnUpdate.setFont(new Font("SansSerif", Font.BOLD, 12));
		contentPane.add(btnUpdate);
		
		JButton btnDelete = new JButton("Delete");
		btnDelete.setBackground(new Color(255, 0, 0));
		btnDelete.setBounds(351, 300, 75, 25);
		btnDelete.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if(id != null) {
					srvr.delete(id);
					reset();
					loadTable();
				}else {
					JOptionPane.showMessageDialog(null, "Silahkan pilih data yang akan di hapus");
				}
			}
		});
		btnDelete.setFont(new Font("SansSerif", Font.BOLD, 12));
		contentPane.add(btnDelete);
		
		JLabel lblJenis = new JLabel("Jenis");
		lblJenis.setBounds(10, 31, 92, 25);
		lblJenis.setFont(new Font("SansSerif", Font.BOLD, 12));
		contentPane.add(lblJenis);
		
		JLabel lblHarga = new JLabel("Harga");
		lblHarga.setBounds(10, 68, 92, 25);
		lblHarga.setFont(new Font("SansSerif", Font.BOLD, 12));
		contentPane.add(lblHarga);
		
		txtHarga = new JTextField();
		txtHarga.setBounds(112, 68, 258, 25);
		txtHarga.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtHarga.setColumns(10);
		contentPane.add(txtHarga);
		
		JLabel lblStatus = new JLabel("Status");
		lblStatus.setBounds(10, 103, 92, 25);
		lblStatus.setFont(new Font("SansSerif", Font.BOLD, 12));
		contentPane.add(lblStatus);
		
		txtStatus = new JTextField();
		txtStatus.setText("Tersedia");
		txtStatus.setEditable(false);
		txtStatus.setBounds(112, 103, 314, 25);
		txtStatus.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtStatus.setColumns(10);
		contentPane.add(txtStatus);
		
		JLabel lblRp = new JLabel("Rp.");
		lblRp.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblRp.setBounds(384, 68, 42, 25);
		contentPane.add(lblRp);
		
		txtJenis = new JTextField();
		txtJenis.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtJenis.setColumns(10);
		txtJenis.setBounds(112, 31, 314, 25);
		contentPane.add(txtJenis);
		
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
		btnBack.setBounds(10, 300, 67, 25);
		contentPane.add(btnBack);
	}
}
