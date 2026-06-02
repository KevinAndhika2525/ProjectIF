package Tugas;

import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;

import Error.ValidationException;
import Model.User;
import UI.MainFrame;
import service.LoginService;
import util.ValidationUtil;

import javax.swing.JLabel;
import javax.swing.JOptionPane;

import java.awt.Font;
import javax.swing.JTextField;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.awt.event.ActionEvent;

public class ArrayIndex extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTextField tfMasukkan;
	private JTextField tfCek;
	private JTextField tfArray;
    private ArrayList<Integer> dataList;
	private JTextField tfHasil;
	
	private void updateDataArea() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dataList.size(); i++) {
            sb.append(dataList.get(i));
            if (i < dataList.size() - 1) {
                sb.append(", ");
            }
        }
        tfArray.setText(sb.toString());
    }
	
	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					ArrayIndex frame = new ArrayIndex();
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
	public ArrayIndex() {
        dataList = new ArrayList<>();
        
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 450, 336);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JLabel lblMasukkan = new JLabel("Masukkan Data:");
		lblMasukkan.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblMasukkan.setBounds(10, 37, 151, 25);
		contentPane.add(lblMasukkan);
		
		tfMasukkan = new JTextField();
		tfMasukkan.setFont(new Font("SansSerif", Font.BOLD, 12));
		tfMasukkan.setColumns(10);
		tfMasukkan.setBounds(10, 61, 314, 33);
		contentPane.add(tfMasukkan);
		
		JButton btnLogin = new JButton("Simpan");
		btnLogin.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
                    String inputText = tfMasukkan.getText();
                    String[] numbers = inputText.split(",");
                    dataList.clear();
                    for (String num : numbers) {
                        dataList.add(Integer.parseInt(num.trim()));
                    }
                    updateDataArea();
                    tfMasukkan.setText("");
                } catch (NumberFormatException ex) {
                    JOptionPane.showMessageDialog(null, "Harap masukkan data berupa angka dan dipisahkan dengan koma.");
                }
			}
		});
		btnLogin.setFont(new Font("SansSerif", Font.BOLD, 14));
		btnLogin.setBounds(334, 61, 92, 33);
		contentPane.add(btnLogin);
		
		JLabel lblData = new JLabel("Data:");
		lblData.setFont(new Font("SansSerif", Font.PLAIN, 14));
		lblData.setBounds(10, 104, 77, 25);
		contentPane.add(lblData);
		
		JLabel lblCekArrayKe = new JLabel("Cek Array ke-");
		lblCekArrayKe.setFont(new Font("SansSerif", Font.BOLD, 14));
		lblCekArrayKe.setBounds(10, 139, 114, 25);
		contentPane.add(lblCekArrayKe);
		
		tfCek = new JTextField();
		tfCek.setFont(new Font("SansSerif", Font.BOLD, 12));
		tfCek.setColumns(10);
		tfCek.setBounds(129, 136, 195, 33);
		contentPane.add(tfCek);
		
		JButton btnCek = new JButton("Cek");
		btnCek.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
                    int index = Integer.parseInt(tfCek.getText()) - 1;
                    if (index >= 0 && index < dataList.size()) {
                        int value = dataList.get(index);
                        tfHasil.setText("Index ke-" + (index + 1) + " adalah " + value);
                        tfCek.setText("");
                    } else {
                        tfHasil.setText("Index ke-" + (index + 1) + " berada di luar batas array.");
                    }
                } catch (NumberFormatException ex) {
                    tfHasil.setText("Masukkan nilai index berupa angka");
                }
			}
		});
		btnCek.setFont(new Font("SansSerif", Font.BOLD, 14));
		btnCek.setBounds(334, 136, 92, 33);
		contentPane.add(btnCek);
		
		tfArray = new JTextField();
		tfArray.setEditable(false);
		tfArray.setFont(new Font("SansSerif", Font.BOLD, 12));
		tfArray.setColumns(10);
		tfArray.setBounds(70, 104, 254, 25);
		contentPane.add(tfArray);
		
		tfHasil = new JTextField();
		tfHasil.setFont(new Font("SansSerif", Font.BOLD, 12));
		tfHasil.setEditable(false);
		tfHasil.setColumns(10);
		tfHasil.setBounds(10, 178, 416, 75);
		contentPane.add(tfHasil);
		
		JButton btnKembali = new JButton("Kembali");
		btnKembali.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				MainFrame mf = new MainFrame();
				mf.setVisible(true);
				dispose();
			}
		});
		btnKembali.setFont(new Font("SansSerif", Font.BOLD, 14));
		btnKembali.setBounds(173, 263, 92, 33);
		contentPane.add(btnKembali);
	}
}
