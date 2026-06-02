package Model;

public class CustomerBuilder {
	private String id, nama, alamat, noHp;
	
	public CustomerBuilder() {
		// TODO Auto-generated constructor stub
	}

	public CustomerBuilder setId(String id) {
		this.id = id;
		return this;
	}

	public CustomerBuilder setNama(String nama) {
		this.nama = nama;
		return this;
	}

	public CustomerBuilder setAlamat(String alamat) {
		this.alamat = alamat;
		return this;
	}

	public CustomerBuilder setNoHp(String noHp) {
		this.noHp = noHp;
		return this;
	}
	
	 public Customer build() {
	        return new Customer(id, nama, alamat, noHp);
	    }
	
}
