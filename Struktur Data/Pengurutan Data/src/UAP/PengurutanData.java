package UAP;

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
import javax.swing.JTextArea;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.util.Stack;
import java.awt.event.ActionEvent;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JScrollPane;

public class PengurutanData extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTextField tfData;
	private JTextArea taProses;
	private JTextArea taHasil;
	
	private int data;
	Stack<Integer> s = new Stack<Integer>();
	
	private int[]array;
	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					PengurutanData frame = new PengurutanData();
					frame.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the frame.
	 */
	public PengurutanData() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 450, 350);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JLabel lblJudul = new JLabel("Pengurutan Data Menggunakan Selection Sort");
		lblJudul.setHorizontalAlignment(SwingConstants.CENTER);
		lblJudul.setFont(new Font("SansSerif", Font.BOLD, 18));
		lblJudul.setBounds(10, 10, 416, 45);
		contentPane.add(lblJudul);
		
		JLabel lblData = new JLabel("Data");
		lblData.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblData.setBounds(10, 65, 111, 32);
		contentPane.add(lblData);
		
		tfData = new JTextField();
		tfData.setFont(new Font("SansSerif", Font.BOLD, 14));
		tfData.setBounds(120, 74, 306, 19);
		contentPane.add(tfData);
		tfData.setColumns(10);
		
		JLabel lblJenis = new JLabel("Jenis");
		lblJenis.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblJenis.setBounds(10, 101, 111, 32);
		contentPane.add(lblJenis);
		
		JComboBox cbJenis = new JComboBox();
		cbJenis.setModel(new DefaultComboBoxModel(new String[] {"Berurutan", "Berurutan Terbalik"}));
		cbJenis.setFont(new Font("SansSerif", Font.BOLD, 14));
		cbJenis.setBounds(120, 109, 163, 21);
		contentPane.add(cbJenis);
		
		taHasil = new JTextArea();
		taHasil.setEditable(false);
		taHasil.setFont(new Font("SansSerif", Font.BOLD, 14));
		taHasil.setBounds(10, 143, 416, 22);
		contentPane.add(taHasil);
		
		taProses = new JTextArea();
		taProses.setFont(new Font("SansSerif", Font.BOLD, 14));
		taProses.setEditable(false);
		taProses.setBounds(10, 175, 416, 97);
		contentPane.add(taProses);
		
		JButton btnPop = new JButton("Pop");
		btnPop.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if(!s.isEmpty()) {
					taProses.setText("Data "+data+" telah berhasil dihapus.");
					s.pop();
					
					arrUpdate();
					taHasil.setText("");
					

					Stack<Integer> s2 = new Stack<Integer>();
					int arr[] = new int[s.size()];
					while(!s.isEmpty()) {
						s2.push(s.pop());
					}
					int c = 0;
					while(!s2.isEmpty()) {
						int nilai = s2.pop();
						s.push(nilai);
						taHasil.append(nilai+" ");
						arr[c++] = nilai;
					}
				}else {
					JOptionPane.showMessageDialog(null, "Stack saat ini sedang kosong.", "ERROR", JOptionPane.ERROR_MESSAGE);
				}
			}
		});
		btnPop.setBounds(293, 109, 66, 21);
		contentPane.add(btnPop);
		
		JButton btnPush = new JButton("Push");
		btnPush.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					data = Integer.parseInt(tfData.getText());
					s.push(data);
					
					taHasil.append(data+" ");
					taProses.setText("Data "+data+" berhasil dimasukkan.");
					tfData.setText("");
					arrUpdate();
				}catch(NumberFormatException ex) {
					JOptionPane.showMessageDialog(null, "Silahkan Masukkan Data Terlebih Dahulu.", "ERROR", JOptionPane.ERROR_MESSAGE);
				}
			}
		});
		btnPush.setBounds(356, 109, 66, 21);
		contentPane.add(btnPush);
		
		JButton btnUrutkan = new JButton("Urutkan");
		btnUrutkan.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				String jenis = cbJenis.getSelectedItem().toString();
				int array[] = arrUpdate();
				if(array != null && array.length > 0) {
					btnPush.setEnabled(false);
					btnPop.setEnabled(false);
					btnUrutkan.setEnabled(false);
					
					taProses.setText("Proses pengurutan data : \n");
					taHasil.append(" menjadi ");
					if(jenis == "Berurutan") {
						selectionSort(array);
					}else {
						revselectionSort(array);
					}
					for (int k = 0; k < array.length;k++) {
						taHasil.append(array[k]+" ");
					}
				}else {
					JOptionPane.showMessageDialog(null, "Tak ada data yang dapat diurutkan.", "ERROR", JOptionPane.ERROR_MESSAGE);
				}
			}
		});
		btnUrutkan.setBounds(299, 282, 111, 31);
		contentPane.add(btnUrutkan);
		
		JScrollPane scrollPane = new JScrollPane(taProses);
		scrollPane.setBounds(10, 175, 416, 97);
		contentPane.add(scrollPane);
	}
	private void selectionSort(int[]array) {
		for (int i = 0; i< array.length; i++) {
			int min = i;
			for(int j = i+1;j < array.length; j++) {
				if(array[j] < array[min]) {
					min = j;
				}
			}
			int temp = array[i];
			array[i] = array[min];
			array[min] = temp;
			
			for(int k = 0;k < array.length; k++) {
				taProses.append(array[k]+" ");
			}taProses.append("\n");
		}
	}
	private void revselectionSort(int[]array) {
		for (int i = 0; i< array.length; i++) {
			int min = i;
			for(int j = i+1;j < array.length; j++) {
				if(array[j] > array[min]) {
					min = j;
				}
			}
			int temp = array[i];
			array[i] = array[min];
			array[min] = temp;
			
			for(int k = 0;k < array.length; k++) {
				taProses.append(array[k]+" ");
			}taProses.append("\n");
		}
	}
	private int[] arrUpdate(){
		Stack<Integer> temp = new Stack<Integer>();
		int[]array = new int[s.size()];
		while(!s.isEmpty()) {
			temp.push(s.pop());
		}
		int index = 0;
		while(!temp.isEmpty()) {
			int val = temp.pop();
			s.push(val);
			array[index++] = val;
		}
		return array;
	}
}
