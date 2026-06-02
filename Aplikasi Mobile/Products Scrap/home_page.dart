import 'package:flutter/material.dart';
import 'package:hai2/kabataku.dart';
import 'product_detail_page.dart';

// Data dari login
class HomePage extends StatefulWidget {
  final String username;
  final String password;

  const HomePage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

// Bottom Navbar ----------------------------------------------------------------------------------------------------------------------------------->>>
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List halaman untuk Bottom Navigation Bar
  static final List<Widget> _widgetOptions = <Widget>[];

  @override
  void initState() {
    super.initState();
    // Inisialisasi halaman
    _widgetOptions.addAll([
      HomeTab(username: widget.username),
      ProductTab(),
      ProfileTab(),
    ]);
  }

  // action navbar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Bottom navigation bar
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        // Bottom Nav Bar
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Product',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 30, 192, 59),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// Halaman Home Tab --------------------------------------------------------------------------------------------------------------------------------------->>>
class HomeTab extends StatelessWidget {
  final String username;
  // list fitur
  final List<Feature> features = [
    Feature (
      id: 1,
      title: 'Products',
      subtitle: 'Lihat produk terbaru',
    ),
    Feature (
      id: 2,
      title: 'Profile', 
      subtitle: 'Kelola profil Anda',
    ),
    Feature (
      id: 3,
      title: 'Kabataku',
      subtitle: 'Perhitungan Sederhana',
    ),
  ];
  HomeTab({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              //  Text Dashboard
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Card pesan welcome
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 30),

                          // icon tangan 
                          const Icon(
                            Icons.waving_hand,
                            color: Colors.amber,
                            size: 30,
                          ),
                          const SizedBox(width: 20),

                          // text selamat datang
                          Text(
                            'Selamat Datang, $username!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // text deskripsi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 30),

                          const Text(
                            'Selamat datang di dashboard aplikasi mobile',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Text Fitur Aplikasi
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Fitur Aplikasi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Widget Grid dengan Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 30,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    return _buildFeatureCard(context, features[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, Feature features) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // kabataku page
          if (features.id == 3) {
            Navigator.push(
              context,  
              MaterialPageRoute(
                builder: (context) => KabatakuPage()),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // icon fitur case 
            _buildFeatureIcon(features.id),
            const SizedBox(height: 8),

            // text fitur
            Text(
              features.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),

            // text deskripsi fitur
            Text(
              features.subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureIcon(int featureId) {
    switch (featureId) {
      case 1:
        return Icon(Icons.shopping_basket, size: 40, color: Colors.grey);
      case 2:
        return Icon(Icons.person, size: 40, color: Colors.grey);
      case 3:
        return Icon(Icons.calculate, size: 40, color: Colors.grey);
      default:
        return Icon(Icons.help, size: 40, color: Colors.grey);
    }
  }
}

// Halaman Product Tab ------------------------------------------------------------------------------------------------------------------------------------>>>
class ProductTab extends StatelessWidget {
  // list produk
  final List<Product> products = [
    Product(
      id: 1,
      name: 'Pocket Bear',
      price: '\$10.99',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1737145126i/220908889.jpg',
      rating: '4.39',
      description: 'Terlahir dari ujung kepala hingga ujung kaki, Pocket Bear mengingat setiap momen "penjelmaannya": jarum yang berkilauan, benang sutra, tangan-tangan lembut yang setiap jahitannya mendekatkan dirinya. Lahir di tengah pergolakan Perang Dunia I, ia dirancang agar muat di saku jaket tentara, dengan mata dijahit sedikit lebih tinggi dari biasanya agar ia selalu menatap ke atas. Dengan begitu, seorang tentara akan melihat tanda cinta yang menawan dari seseorang di rumah, dan, semoga, sebuah jimat keberuntungan.',
      author: 'Katherine Applegate',
    ),
    Product(
      id: 2,
      name: 'Honeyeater',
      price: '\$14.99',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1742313027i/222376616.jpg',
      rating: '3.46',
      description: 'Bellworth yang subtropis dibangun di atas dataran banjir dan rahasia yang terpendam. Dan Charlie, yang hanya dikenal karena teman-teman yang telah hilang dan seorang saudari yang sukses, berencana untuk pergi selamanya, tepat setelah ia mengurus rumah bibinya yang telah meninggal. Kemudian Grace datang, putus asa, dengan mawar-mawar yang menyembul di kulitnya, dan menyeret Charlie ke dalam misteri Bellworth yang dipenuhi hantu, mengungkap konsekuensi mustahil dari kehilangan dan hasrat — dan sebuah pilihan yang dibuat Charlie saat ia masih kecil.',
      author: 'Kathleen Jennings',
    ),
    Product(
      id: 3,
      name: 'A Composer\'s Life',
      price: '\$8.53',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1751462503i/226461368.jpg',
      rating: '4.57',
      description: 'Biografi pertama seorang komposer besar Amerika di era sinema. John Williams adalah salah satu komposer film terpenting sepanjang masa, yang hampir sendirian menghidupkan kembali tradisi skor simfoni Hollywood dan membantu memulihkan mata pencaharian orkestra Amerika melalui popularitas program musik film. Musik filmnya, dalam kata-kata sutradara Oliver Stone',
      author: 'Tim Greiving',
    ),
    Product(
      id: 4,
      name: 'Escape #1',
      price: '\$5.00',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1754235395i/239188913.jpg',
      rating: '4.32',
      description: 'Milton Shaw adalah pilot pembom yang tangguh dalam pertempuran, menerbangkan misi di atas dunia yang dilanda perang yang diperintah oleh kekaisaran yang kejam. Tetapi ketika pesawatnya ditembak jatuh dari langit, Milton terbangun di belakang garis musuh—di reruntuhan kota yang membara yang ia bantu bakar. Dan dalam waktu kurang dari 24 jam, pihaknya sendiri menjatuhkan yang besar untuk menyelesaikan pekerjaan.',
      author: 'Rick Remender',
    ),
    Product(
      id: 5,
      name: 'The Lion Narnia',
      price: '\$6.79',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1697079942i/132080146.jpg',
      rating: '4.24',
      description: 'Mereka membuka pintu dan memasuki dunia NARNIA... negeri di balik lemari pakaian, negeri rahasia yang hanya diketahui Peter, Susan, Edmund, dan Lucy... tempat petualangan dimulai. Lucy adalah orang pertama yang menemukan rahasia lemari pakaian di rumah tua misterius milik sang profesor. Awalnya, tak seorang pun percaya ketika ia menceritakan petualangannya di negeri Narnia.',
      author: 'CS Lewis',
    ),
    Product(
      id: 6,
      name: 'Fahrenreit 451',
      price: '\$12.99',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1383718290i/13079982.jpg',
      rating: '3.97',
      description: 'Guy Montag adalah seorang pemadam kebakaran. Tugasnya adalah menghancurkan komoditas yang paling ilegal, buku cetak, bersama dengan rumah-rumah tempat mereka disembunyikan. Montag tidak pernah mempertanyakan kehancuran dan kehancuran yang dihasilkan oleh tindakannya, kembali setiap hari ke kehidupan yang hambar dan istrinya, Mildred, yang menghabiskan sepanjang hari dengan "keluarga" televisinya. ',
      author: 'Ray Bradbury',
    ),
    Product(
      id: 7,
      name: 'Tuck Me In',
      price: '\$6.99',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1739004612i/220284304.jpg',
      rating: '4.20',
      description: 'Pada suatu malam berbintang, bulan dengan ramah menarik air laut ke atas pasir, untuk menyelimuti pantai. Namun tiba-tiba, ia mendengar pantai lain di kejauhan berteriak, "HEI, KEMANA SELIMUTKU PERGI?" Uh oh! Saat bulan mendorong arus bolak-balik mencoba menyelimuti kedua pantai, salah satu selalu terekspos dan tidak bahagia, dan pertengkaran pun dimulai...',
      author: 'Nathan W. Pyle',
    ),
    Product(
      id: 8,
      name: 'Unseen',
      price: '\$12.99',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1747720584i/227786591.jpg',
      rating: '4.43',
      description: 'Ketika Molly Burke berusia empat tahun, ia didiagnosis menderita retinitis pigmentosa, penyakit mata degeneratif langka yang menyebabkan kebutaan bertahap dan total, memaksa Burke untuk mengonseptualisasikan dunia secara berbeda. Tumbuh sebagai penyandang disabilitas tidak menghentikannya dari bermain olahraga, berbicara di depan umum, atau menjadi instruktur panjat tebing, tetapi persepsi sempit orang lain tentang dirinya yang menahannya. ',
      author: 'Molly Burke',
    ),
    Product(
      id: 9,
      name: 'Batman v1',
      price: '\$18.10',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1743742857i/229187490.jpg',
      rating: '4.35',
      description: 'Seorang pembunuh berantai baru meneror Kota Gotham, dan modus operandinya tampaknya menyiksa korbannya hingga tewas dengan presisi bedah. Namun, Batman segera menyadari bahwa ada lebih dari sekadar sadisme yang sedang dimainkan, dan "Wound Man" yang baru dijuluki ini memiliki lebih dari sekadar hasrat brutal akan kekerasan.',
      author: 'Dan Watters',
    ),
    Product(
      id: 10,
      name: 'De Camino',
      price: '\$9.99',
      imageUrl: 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1614636064i/57280590.jpg',
      rating: '3.96',
      description: 'ini adalah harga yang sangat berharga bagi Lottes man onverwacht zelfmoord pleegde tijdens het Wandelen van de Camino. Emil juga pernah mengunjungi Bosnië dan Herzegovina dalam beberapa tahun terakhir, tapi masih belum ada zelfmoord plegen. Emil adalah seorang geweldige vader, sangat baik dalam pekerjaannya. Banyak yang harus memilih rute yang tepat untuk membuka, dalam lingkaran itu akan menjadi apa yang akan membuat mereka sangat mengantuk. ',
      author: 'Anya Niewierra',
    ),
  ];
  ProductTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),

              //  Text Judul
              const Text(
                'Daftar Produk',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Container Produk
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductItem(context, products[index]);
                  },
                ),
              ),
              const SizedBox(height: 40),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gambar Produk
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
            
            // Detail Teks
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Nama Produk
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Harga Produk
                  Text(
                    product.price,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Profile Tab ------------------------------------------------------------------------------------------------------------------------------------->>>
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Logo Unand
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    Image.network(
                      "https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Logo_Unand_PTN-BH.png/150px-Logo_Unand_PTN-BH.png",
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 10),
                    const Text('Universitas Andalas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(width: 20),

                // Foto Avatar
                CircleAvatar(
                  radius: 80,
                  child: Image.network(
                    'https://raw.githubusercontent.com/KevinAndT25/Pemograman_Web/refs/heads/main/assets/images/Kevin2.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 10),
                // Text Avatar
                const Text(
                  'Kevin Andhika',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                // Container Nim
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge, color: Color.fromARGB(255, 10, 88, 9)),
                      const SizedBox(width: 10),
                      const Text(
                        'NIM:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '2311532005',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                // Container Alamat
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color.fromARGB(255, 10, 88, 9)),
                      const SizedBox(width: 10),
                      const Text(
                        'Alamat:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Kuranji, Kota Padang, Sumatera Barat',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                // Container no HP
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Color.fromARGB(255, 10, 88, 9)),
                      const SizedBox(width: 10),
                      const Text(
                        'HP:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '+62 812-3456-7890',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                // Container Jurusan
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school, color: Color.fromARGB(255, 10, 88, 9)),
                      const SizedBox(width: 10),
                      const Text(
                        'Jurusan:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Informatika',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                
                // Row icon social media 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [   
                    // Instagram
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[200],
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 222, 53, 120)),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // GitHub
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[200],
                      child: IconButton(
                        icon: const Icon(Icons.code, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // YouTube
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[200],
                      child: IconButton(
                        icon: const Icon(Icons.play_circle_filled, color: Color(0xFFFF0000)),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================================================================================================================================>>>>>
// Model Data Feature
class Feature {
  final int id;
  final String title;
  final String subtitle;

  Feature({
    required this.id,
    required this.title,
    required this.subtitle,
  });
}

// Model Data Product
class Product {
  final int id;
  final String name;
  final String price;
  final String imageUrl;
  final String rating; 
  final String description;
  final String author;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating, 
    required this.description,
    required this.author,
  });
}