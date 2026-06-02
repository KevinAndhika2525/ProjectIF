package UI;

import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;

import DAO.OrderDRepo;
import DAO.OrderRepo;
import DAO.ServiceRepo;

import Model.OrderDetailModel;
import Model.Service;
import Model.Order;
import table.TableOrderD;
import table.TableService;

import javax.swing.JScrollPane;
import javax.swing.ScrollPaneConstants;
import javax.swing.JTable;
import java.awt.Color;
import java.awt.Font;
import javax.swing.JLabel;
import javax.swing.JOptionPane;

import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.List;

import javax.swing.JTextField;
import javax.swing.JComboBox;
import javax.swing.JButton;
import javax.swing.DefaultComboBoxModel;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.awt.event.FocusAdapter;
import java.awt.event.FocusEvent;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;

public class OrderDetail extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTable tableServices;
	private JTable tableOrderDetails;
	private JTextField txtOrderID;
	private JTextField txtTanggal;
	private JTextField txtPengambilan;
	private JTextField txtTotalRp;
	private JTextField txtHargaKg;
	private JTextField txtJumlah;
	private JTextField txtTotal2;
	private JTextField txtJenis;
	public JComboBox<String> cbPelanggan;
	
	ServiceRepo srvr = new ServiceRepo();
	List<Service> ls1;
	String id;
	
	public void loadTableservice() {
		ls1 = srvr.show();
		TableService ts1 = new TableService(ls1);
		tableServices.setModel(ts1);;
		tableServices.getTableHeader().setVisible(true);
	}
	private double total(double harga, double qty) {
		return harga * qty;
	}
	public double hargabagi(double harga, double qty) {
		return harga / qty;
	}
	
	OrderDRepo odr = new OrderDRepo();
	List<OrderDetailModel> ls;
	
	public void loadTable() {
		ls = odr.show();
		TableOrderD ts = new TableOrderD(ls);
		tableOrderDetails.setModel(ts);;
		tableOrderDetails.getTableHeader().setVisible(true);
	}
	public void reset() {
		txtHargaKg.setText("");
		txtJenis.setText("");
		txtJumlah.setText("");
		txtTotal2.setText("");
	}
	public void loadDataRp() {
		int total = 0;
		for (int i = 0; i < tableOrderDetails.getRowCount(); i++) {
		    Object value = tableOrderDetails.getValueAt(i, 3); 

		    total += Integer.parseInt(value.toString());
		}
	    txtTotalRp.setText("Rp. " + String.valueOf(total)); 
	}
	
	public void onCustomerSelected(String customer) {
		String x = customer;
        cbPelanggan.addItem(x);
    }
	
	OrderRepo ordr = new OrderRepo();
	
	public void trxCount() {
		OrderFrame of = new OrderFrame();
		String id2 = of.id;
		int tempId = 0;
		if (id2==null) {
			tempId = 1;
		}else {
			tempId = Integer.parseInt(id2)+1;
		}
		
		if (tempId < 10) {
			txtOrderID.setText("TRX-00"+tempId);
		}else if (tempId < 100) {
			txtOrderID.setText("TRX-0"+tempId);
		}else {
			txtOrderID.setText("TRX-"+tempId);
		}
	}
	
	LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd - MMMM - yyyy");
    String formattedDate = today.format(formatter);
    
    LocalDate dateNew = today.plusDays(7);
    String deliveryDate = dateNew.format(formatter);
    
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					OrderDetail frame = new OrderDetail();
					frame.setVisible(true);
					frame.loadTableservice();
					frame.loadTable();
					frame.loadDataRp();
					frame.trxCount();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	public OrderDetail() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 754, 677);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JScrollPane scrollPane = new JScrollPane();
		scrollPane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
		scrollPane.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
		scrollPane.setBounds(261, 40, 469, 182);
		contentPane.add(scrollPane);
		
		tableServices = new JTable();
		tableServices.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				txtHargaKg.setText(tableServices.getValueAt(tableServices.getSelectedRow(),2).toString());
				txtJenis.setText(tableServices.getValueAt(tableServices.getSelectedRow(),1).toString());
				txtJumlah.setText("");
				txtTotal2.setText("");
			}
		});
		tableServices.setToolTipText("");
		tableServices.setFont(new Font("SansSerif", Font.PLAIN, 12));
		tableServices.setFillsViewportHeight(true);
		tableServices.setBackground(Color.WHITE);
		scrollPane.setViewportView(tableServices);
		
		JScrollPane scrollPane_1 = new JScrollPane();
		scrollPane_1.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
		scrollPane_1.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
		scrollPane_1.setBounds(261, 418, 469, 212);
		contentPane.add(scrollPane_1);
		
		tableOrderDetails = new JTable();
		tableOrderDetails.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				id = tableOrderDetails.getValueAt(tableOrderDetails.getSelectedRow(),0).toString();
				txtJenis.setText(tableOrderDetails.getValueAt(tableOrderDetails.getSelectedRow(),1).toString());
				txtJumlah.setText(tableOrderDetails.getValueAt(tableOrderDetails.getSelectedRow(),2).toString());
				txtTotal2.setText(tableOrderDetails.getValueAt(tableOrderDetails.getSelectedRow(),3).toString()+".0");
			}
		});
		tableOrderDetails.setToolTipText("");
		tableOrderDetails.setFont(new Font("SansSerif", Font.PLAIN, 12));
		tableOrderDetails.setFillsViewportHeight(true);
		tableOrderDetails.setBackground(Color.WHITE);
		scrollPane_1.setViewportView(tableOrderDetails);
		
		JPanel panel = new JPanel();
		panel.setBounds(261, 232, 469, 176);
		contentPane.add(panel);
		panel.setLayout(null);
		
		JLabel lblHargakg = new JLabel("Harga/Kg");
		lblHargakg.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblHargakg.setBounds(10, 10, 92, 25);
		panel.add(lblHargakg);
		
		txtHargaKg = new JTextField();
		txtHargaKg.setEditable(false);
		txtHargaKg.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtHargaKg.setColumns(10);
		txtHargaKg.setBounds(10, 33, 199, 25);
		panel.add(txtHargaKg);
		
		JLabel lblJumlah = new JLabel("Jumlah");
		lblJumlah.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblJumlah.setBounds(10, 68, 168, 25);
		panel.add(lblJumlah);
		
		txtJumlah = new JTextField();
		txtJumlah.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				txtHargaKg.setText(""+hargabagi(Double.parseDouble(txtTotal2.getText()), Double.parseDouble(txtJumlah.getText())));
			}
		});
		txtJumlah.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {
				if (txtJumlah.getText().isEmpty()) {
					txtTotal2.setText("");
				}else {
					txtTotal2.setText(""+total(Double.parseDouble(txtHargaKg.getText()), Double.parseDouble(txtJumlah.getText())));
				}
			}
		});
		txtJumlah.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtJumlah.setColumns(10);
		txtJumlah.setBounds(10, 91, 199, 25);
		panel.add(txtJumlah);
		
		JLabel lblTotal2 = new JLabel("Total");
		lblTotal2.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblTotal2.setBounds(249, 68, 168, 25);
		panel.add(lblTotal2);
		
		txtTotal2 = new JTextField();
		txtTotal2.setEditable(false);
		txtTotal2.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtTotal2.setColumns(10);
		txtTotal2.setBounds(249, 91, 199, 25);
		panel.add(txtTotal2);
		
		JButton btnSimpan2 = new JButton("Simpan");
		btnSimpan2.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				OrderDetailModel ordd = new OrderDetailModel();
				ordd.setJenis(txtJenis.getText());
				ordd.setQty(txtJumlah.getText());
				ordd.setTotal(txtTotal2.getText());
				reset();
				odr.save(ordd);
				loadTable();
				loadDataRp();
			}
		});
		btnSimpan2.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnSimpan2.setBounds(16, 141, 92, 25);
		panel.add(btnSimpan2);
		
		JButton btnUbah2 = new JButton("Ubah");
		btnUbah2.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				OrderDetailModel ordd = new OrderDetailModel();
				ordd.setJenis(txtJenis.getText());
				ordd.setQty(txtJumlah.getText());
				ordd.setTotal(txtTotal2.getText());
				ordd.setId(id);
				odr.update(ordd);
				reset();
				loadTable();
				loadDataRp();
			}
		});
		btnUbah2.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnUbah2.setBounds(117, 141, 92, 25);
		panel.add(btnUbah2);
		
		JButton btnHapus2 = new JButton("Hapus");
		btnHapus2.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if(id != null) {
					odr.delete(id);
					reset();
					loadTable();
					loadDataRp();
				}else {
					JOptionPane.showMessageDialog(null, "Silahkan pilih data yang akan di hapus");
				}
			}
		});
		btnHapus2.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnHapus2.setBounds(218, 141, 92, 25);
		panel.add(btnHapus2);
		
		JButton btnBatal2 = new JButton("Batal");
		btnBatal2.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				reset();
			}
		});
		btnBatal2.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnBatal2.setBounds(320, 141, 92, 25);
		panel.add(btnBatal2);
		
		JLabel lblJenisLayanan = new JLabel("Jenis Layanan");
		lblJenisLayanan.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblJenisLayanan.setBounds(249, 10, 92, 25);
		panel.add(lblJenisLayanan);
		
		txtJenis = new JTextField();
		txtJenis.setEditable(false);
		txtJenis.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtJenis.setColumns(10);
		txtJenis.setBounds(249, 33, 199, 25);
		panel.add(txtJenis);
		
		JPanel panel_1 = new JPanel();
		panel_1.setBounds(10, 10, 241, 620);
		contentPane.add(panel_1);
		panel_1.setLayout(null);
		
		JLabel lblOrderID = new JLabel("Order ID");
		lblOrderID.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblOrderID.setBounds(10, 31, 92, 25);
		panel_1.add(lblOrderID);
		
		txtOrderID = new JTextField();
		txtOrderID.setEditable(false);
		txtOrderID.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtOrderID.setColumns(10);
		txtOrderID.setBounds(10, 54, 221, 25);
		panel_1.add(txtOrderID);
		
		JLabel lblPelanggan = new JLabel("Pelanggan");
		lblPelanggan.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblPelanggan.setBounds(10, 89, 92, 25);
		panel_1.add(lblPelanggan);
		
		JLabel lblTanggal = new JLabel("Tanggal");
		lblTanggal.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblTanggal.setBounds(10, 170, 92, 25);
		panel_1.add(lblTanggal);
		
		txtTanggal = new JTextField();
	    txtTanggal.setText(formattedDate);
		txtTanggal.setEditable(false);
		txtTanggal.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtTanggal.setColumns(10);
		txtTanggal.setBounds(10, 193, 221, 25);
		panel_1.add(txtTanggal);
		
		JLabel lblPengambilan = new JLabel("Tanggal Pengambilan");
		lblPengambilan.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblPengambilan.setBounds(10, 228, 168, 25);
		panel_1.add(lblPengambilan);
		
		txtPengambilan = new JTextField();
	    txtPengambilan.setText(deliveryDate);
		txtPengambilan.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtPengambilan.setColumns(10);
		txtPengambilan.setBounds(10, 251, 221, 25);
		panel_1.add(txtPengambilan);
		
		cbPelanggan = new JComboBox();
		cbPelanggan.addFocusListener(new FocusAdapter() {
			@Override
			public void focusGained(FocusEvent e) {
				DialogCustomer dc = new DialogCustomer();
				dc.setVisible(true);
				dc.loadTable();
				dispose();
			}
		});
		cbPelanggan.setFont(new Font("SansSerif", Font.BOLD, 12));
		cbPelanggan.setBounds(10, 113, 221, 24);
		panel_1.add(cbPelanggan);
		
		JLabel lblStatus = new JLabel("Status");
		lblStatus.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblStatus.setBounds(10, 286, 92, 25);
		panel_1.add(lblStatus);
		
		JComboBox cbStatus = new JComboBox();
		cbStatus.setModel(new DefaultComboBoxModel(new String[] {"Proses", "Selesai"}));
		cbStatus.setFont(new Font("SansSerif", Font.BOLD, 12));
		cbStatus.setBounds(10, 310, 221, 24);
		panel_1.add(cbStatus);
		
		JLabel lblPembayaran = new JLabel("Pembayaran");
		lblPembayaran.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblPembayaran.setBounds(10, 426, 92, 25);
		panel_1.add(lblPembayaran);
		
		JComboBox cbPembayaran = new JComboBox();
		cbPembayaran.setModel(new DefaultComboBoxModel(new String[] {"Cash", "Credit"}));
		cbPembayaran.setFont(new Font("SansSerif", Font.BOLD, 12));
		cbPembayaran.setBounds(10, 450, 221, 24);
		panel_1.add(cbPembayaran);
		
		JLabel lblSPembayaran = new JLabel("Status Pembayaran");
		lblSPembayaran.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblSPembayaran.setBounds(10, 484, 168, 25);
		panel_1.add(lblSPembayaran);
		
		JComboBox cbSPembayaran = new JComboBox();
		cbSPembayaran.setModel(new DefaultComboBoxModel(new String[] {"Belum Dibayar", "Lunas"}));
		cbSPembayaran.setFont(new Font("SansSerif", Font.BOLD, 12));
		cbSPembayaran.setBounds(10, 508, 221, 24);
		panel_1.add(cbSPembayaran);
		
		txtTotalRp = new JTextField();
		txtTotalRp.setEditable(false);
		txtTotalRp.setFont(new Font("SansSerif", Font.BOLD, 12));
		txtTotalRp.setColumns(10);
		txtTotalRp.setBounds(10, 391, 221, 25);
		panel_1.add(txtTotalRp);
		
		JLabel lblTotal = new JLabel("Total");
		lblTotal.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblTotal.setBounds(10, 368, 92, 25);
		panel_1.add(lblTotal);
		
		JButton btnSimpan = new JButton("Simpan");
		btnSimpan.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				Order ord = new Order();
				ord.setNama(cbPelanggan.getSelectedItem().toString());
				ord.setQtyTotal("10");
				ord.setTotal(txtTotal2.getText());
				ord.setTanggal(txtTanggal.getText());
//				reset();
				ordr.save(ord);
				
				OrderFrame of = new OrderFrame();
				of.loadTableOrder();
				of.setVisible(true);
				dispose();
				of.trxCount();
			}
		});
		btnSimpan.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnSimpan.setBounds(24, 585, 92, 25);
		panel_1.add(btnSimpan);
		
		JButton btnBatal = new JButton("Batal");
		btnBatal.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				OrderFrame of = new OrderFrame();
				of.setVisible(true);
				dispose();
			}
		});
		btnBatal.setFont(new Font("SansSerif", Font.BOLD, 12));
		btnBatal.setBounds(125, 585, 92, 25);
		panel_1.add(btnBatal);
		
		JLabel lblServiceList = new JLabel("Service List");
		lblServiceList.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblServiceList.setBounds(261, 10, 119, 25);
		contentPane.add(lblServiceList);
	}
}
