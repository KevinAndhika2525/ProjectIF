package TugasAkhir;

import java.awt.BorderLayout;
import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.JLabel;
import javax.swing.JOptionPane;

import java.awt.Font;
import javax.swing.SwingConstants;
import javax.swing.JTextField;
import javax.swing.JComboBox;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JTextArea;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

public class TinggiRata2 extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTextField tfNama;
	private JTextField tfTinggi;
	
	private String[] nama = new String[99];
	private int[] tinggi = new int[99];
	private String[] jurusan = new String[99];

	private int num = 0;
	private int count = 0;
	
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					TinggiRata2 frame = new TinggiRata2();
					frame.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	public TinggiRata2() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 450, 300);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JLabel lblJudul = new JLabel("Tinggi Rata-Rata Mahasiswa");
		lblJudul.setHorizontalAlignment(SwingConstants.CENTER);
		lblJudul.setFont(new Font("SansSerif", Font.BOLD, 16));
		lblJudul.setBounds(10, 10, 416, 38);
		contentPane.add(lblJudul);
		
		JLabel lblNama = new JLabel("Nama");
		lblNama.setHorizontalAlignment(SwingConstants.LEFT);
		lblNama.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblNama.setBounds(10, 69, 91, 16);
		contentPane.add(lblNama);
		
		tfNama = new JTextField();
		tfNama.setFont(new Font("SansSerif", Font.PLAIN, 14));
		tfNama.setBounds(111, 66, 315, 19);
		contentPane.add(tfNama);
		tfNama.setColumns(10);
		
		JLabel lblTinggi = new JLabel("Tinggi");
		lblTinggi.setHorizontalAlignment(SwingConstants.LEFT);
		lblTinggi.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblTinggi.setBounds(10, 95, 91, 16);
		contentPane.add(lblTinggi);
		
		tfTinggi = new JTextField();
		tfTinggi.setFont(new Font("SansSerif", Font.PLAIN, 14));
		tfTinggi.setColumns(10);
		tfTinggi.setBounds(111, 95, 258, 19);
		contentPane.add(tfTinggi);
		
		JLabel lblCm = new JLabel("cm");
		lblCm.setHorizontalAlignment(SwingConstants.LEFT);
		lblCm.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblCm.setBounds(376, 95, 50, 16);
		contentPane.add(lblCm);
		
		JLabel lblJurusan = new JLabel("Jurusan");
		lblJurusan.setHorizontalAlignment(SwingConstants.LEFT);
		lblJurusan.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblJurusan.setBounds(10, 123, 91, 16);
		contentPane.add(lblJurusan);
		
		JComboBox cbJurusan = new JComboBox();
		cbJurusan.setModel(new DefaultComboBoxModel(new String[] {"Teknik Komputer", "Sistem Informasi", "Informatika"}));
		cbJurusan.setFont(new Font("SansSerif", Font.PLAIN, 14));
		cbJurusan.setBounds(111, 121, 206, 21);
		contentPane.add(cbJurusan);
		
		JTextArea taInfo = new JTextArea();
		taInfo.setEditable(false);
		taInfo.setFont(new Font("SansSerif", Font.PLAIN, 14));
		taInfo.setBounds(10, 149, 416, 76);
		contentPane.add(taInfo);
		
		JButton btnTambah = new JButton("Tambah");
		btnTambah.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (num < 99) {
					String nm = tfNama.getText();
					nama[num] = nm;
					int tgg = Integer.parseInt(tfTinggi.getText());
					tinggi[num] = tgg;
					String jrsn = cbJurusan.getSelectedItem().toString();
					jurusan[num] = jrsn;
					num++;count++;
					
					tfNama.setText("");
					tfTinggi.setText("");
					cbJurusan.setSelectedIndex(0);
					
					taInfo.setText("Data "+nm +" dari jurusan "+jrsn + " berhasil disimpan.");
				}else {
					JOptionPane.showMessageDialog(null, "Data yang dimasukkan telah mencapai maksimal.");
				}
			}
		});
		btnTambah.setFont(new Font("SansSerif", Font.BOLD, 14));
		btnTambah.setBounds(31, 235, 132, 18);
		contentPane.add(btnTambah);
		
		JButton btnHasil = new JButton("Hasil");
		btnHasil.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (count > 1) {
					int jumlah = 0;
					for (num = 0;num <= count;num++) {
						jumlah += tinggi[num];
					}
					double rata2 = jumlah/count;
					taInfo.setText("Tinggi rata-rata Mahasiswa adalah :"+rata2 +" cm.");
					
					int atasrata = 0;
					for (num = 0;num <= count; num++) {
						if (tinggi[num] > rata2) {
							atasrata++;
						}
					}
					taInfo.setText(taInfo.getText()+"\nMahasiswa yang tingginya di atas rata-rata ada :"
					+atasrata +" orang. \n yaitu : ");
					
					for (num = 0;num <= count;num++ ) {
						int temp = 0;
						if (tinggi[num] > rata2) {
							taInfo.setText(taInfo.getText()+nama[num]+" (" +jurusan[num]+
									") dengan tinggi " +tinggi[num]+ " cm");
							temp++;
							if (temp< atasrata) {
								taInfo.setText(taInfo.getText()+", \n");
							}else {
								taInfo.setText(taInfo.getText()+". ");
							}
							
						}
					}
				}else {
					JOptionPane.showMessageDialog(null, "Mohon masukkan data terlebih dahulu.");
				}
			}
		});
		btnHasil.setFont(new Font("SansSerif", Font.BOLD, 14));
		btnHasil.setBounds(273, 235, 132, 18);
		contentPane.add(btnHasil);
	}
}
