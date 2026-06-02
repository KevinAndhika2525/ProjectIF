package Model;

public class Customer {
	private String id, nama, alamat, noHp;
	
	public Customer (String id, String nama, 
			String alamat, String noHp) {
		this.id = id;
		this.nama = nama;
		this.alamat = alamat;
		this.noHp = noHp;
	}

	public String getId() {
		return id;
	}

	public String getNama() {
		return nama;
	}

	public String getAlamat() {
		return alamat;
	}

	public String getNoHp() {
		return noHp;
	}
	
}
