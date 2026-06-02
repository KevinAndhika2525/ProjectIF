package Model;

public class User {
	String id, nama, username, password;
	
	public User(String uname, String pass) {
		this.username = uname;
		this.password = pass;
	}
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}

	public String getNama() {
		return nama;
	}
	public void setNama(String nama) {
		this.nama = nama;
	}

	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	
	public void sayHai (String message) {
		System.out.println(message);
	}
	
	public static boolean login(String username,String password) {
		boolean isLogin = false;
//		User user = new User();
//		user.setId("1");
//		user.setNama("Flan");
//		user.setUsername("Flan");
//		user.setPassword("12345");
//		String noSpace = username.trim();
//		
//		if((user.getUsername().equalsIgnoreCase(noSpace))&&(user.getPassword().equalsIgnoreCase(password))) {
//			isLogin = true;
//		}else {
//			isLogin = false;
//		}
		return isLogin;
	}
}
