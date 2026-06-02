package UI;

import java.awt.BorderLayout;
import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;

import Error.ValidationException;
import Model.User;
import service.LoginService;
import util.ValidationUtil;

import javax.swing.JLabel;
import javax.swing.JOptionPane;

import java.awt.Font;
import javax.swing.SwingConstants;
import javax.swing.JTextField;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

public class LoginFrame extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTextField tfUsername;
	private JTextField tfPassword;

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					LoginFrame frame = new LoginFrame();
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
	public LoginFrame() {
		setTitle("Laundry KevAsh");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 450, 300);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JLabel lblTitle = new JLabel("Laundry Account Login");
		lblTitle.setHorizontalAlignment(SwingConstants.CENTER);
		lblTitle.setFont(new Font("Serif", Font.BOLD, 18));
		lblTitle.setBounds(10, 10, 416, 38);
		contentPane.add(lblTitle);
		
		JLabel lblUsername = new JLabel("Username");
		lblUsername.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblUsername.setBounds(10, 97, 92, 25);
		contentPane.add(lblUsername);
		
		JLabel lblPassword = new JLabel("Password");
		lblPassword.setFont(new Font("SansSerif", Font.BOLD, 12));
		lblPassword.setBounds(10, 132, 92, 25);
		contentPane.add(lblPassword);
		
		tfUsername = new JTextField();
		tfUsername.setFont(new Font("SansSerif", Font.BOLD, 12));
		tfUsername.setBounds(112, 97, 314, 25);
		contentPane.add(tfUsername);
		tfUsername.setColumns(10);
		
		tfPassword = new JTextField();
		tfPassword.setFont(new Font("SansSerif", Font.BOLD, 12));
		tfPassword.setColumns(10);
		tfPassword.setBounds(112, 136, 314, 25);
		contentPane.add(tfPassword);
		
		JButton btnLogin = new JButton("Login");
		btnLogin.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				String userValue = tfUsername.getText();
				String passValue = tfPassword.getText();
				
				User user = new User(userValue, passValue);
				try {
					ValidationUtil.validate(user);
					LoginService loginSer = new LoginService();
					if(loginSer.authenticate(user)) {
						System.out.println("Login Successfull!!");
						JOptionPane.showMessageDialog(null, "Login Successfull!!");
						new MainFrame().setVisible(true);
						dispose();
					}else {
						System.out.println("Invalid Username or Password");
						JOptionPane.showMessageDialog(null, "Login Gagal, Invalid Username or Password.");
					}
				}catch (ValidationException | NullPointerException exception) {
					System.out.println("Data Tidak Valid : " + exception.getMessage());
					JOptionPane.showMessageDialog(null, "Login Gagal: "+ exception.getMessage());
				}finally {
					System.out.println("Selalu Dieksekusi");
				}
				
//				if (User.login(tfUsername.getText(), tfPassword.getText())) {
//					JOptionPane.showMessageDialog(null,"Selamat Anda Berhasil Login");
//					MainFrame mf = new MainFrame();
//					mf.setVisible(true);
//					dispose();
//				}else {
//					JOptionPane.showMessageDialog(null,"Maaf Data Yang Anda Masukkan Salah");
//				}
			}
		});
		btnLogin.setFont(new Font("SansSerif", Font.BOLD, 14));
		btnLogin.setBounds(153, 208, 121, 33);
		contentPane.add(btnLogin);
		
		JLabel lblDesc = new JLabel("Silahkan masukkan akun yang anda miliki");
		lblDesc.setHorizontalAlignment(SwingConstants.CENTER);
		lblDesc.setFont(new Font("SansSerif", Font.PLAIN, 12));
		lblDesc.setBounds(10, 44, 416, 25);
		contentPane.add(lblDesc);
	}
}
