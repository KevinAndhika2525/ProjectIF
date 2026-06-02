import 'package:flutter/material.dart';

class KabatakuPage extends StatelessWidget {
  const KabatakuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const CalculatorApp(),
    );
  }
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  final _formKey = GlobalKey<FormState>();
  final _number1Controller = TextEditingController();
  final _number2Controller = TextEditingController();
  String _result = 'Hasil akan muncul di sini';
  String _errorMessage = '';

  @override
  void dispose() {
    _number1Controller.dispose();
    _number2Controller.dispose();
    super.dispose();
  }

// perhitungan
  void _calculate(String operation) {
    if (_formKey.currentState!.validate()) {
      try {
        double num1 = double.parse(_number1Controller.text);
        double num2 = double.parse(_number2Controller.text);
        double result = 0;

        setState(() {
          _errorMessage = '';
          switch (operation) {
            case 'tambah':
              result = num1 + num2;
              _result = '$num1 + $num2 = $result';
              break;
            case 'kurang':
              result = num1 - num2;
              _result = '$num1 - $num2 = $result';
              break;
            case 'kali':
              result = num1 * num2;
              _result = '$num1 × $num2 = $result';
              break;
            case 'bagi':
              if (num2 == 0) {
                _errorMessage = 'Error: Pembagian dengan nol tidak diperbolehkan';
                _result = 'Error';
                return;
              }
              result = num1 / num2;
              _result = '$num1 ÷ $num2 = ${result.toStringAsFixed(2)}';
              break;
          }
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: Terjadi kesalahan dalam perhitungan';
          _result = 'Error';
        });
      }
    }
  }

// kabataku page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Sederhana'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card textfield angka
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        // textfield pertama
                        child: TextFormField(
                          controller: _number1Controller,
                          decoration: InputDecoration(
                            labelText: 'Angka Pertama',
                            hintText: 'Masukkan angka pertama',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers, color: Colors.grey[700]),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                          // validasi kedua
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Angka masih kosong';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Angka tidak valid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        // textfield kedua
                        child: TextFormField(
                          controller: _number2Controller,
                          decoration: InputDecoration(
                            labelText: 'Angka Kedua',
                            hintText: 'Masukkan angka kedua',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers, color: Colors.grey[700]),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                          // validasi kedua
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Angka masih kosong';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Angka tidak valid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                ),
              ),
              const SizedBox(height: 20),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Card(
                  elevation: 2,
                  color: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.red[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[700], size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_errorMessage.isNotEmpty) const SizedBox(height: 15),

              // Card Tombol Operasi
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Title operasi aritmatika
                      Text(
                        'Pilih Operasi Aritmatika',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Tombol Tambah
                          ElevatedButton(
                            onPressed: () => _calculate('tambah'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              '+',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),

                          // Tombol Kurang
                          ElevatedButton(
                            onPressed: () => _calculate('kurang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              '-',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),

                          // Tombol Kali
                          ElevatedButton(
                            onPressed: () => _calculate('kali'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              '×',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),

                          // Tombol Bagi
                          ElevatedButton(
                            onPressed: () => _calculate('bagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              '÷',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Card Hasil Perhitungan
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15),
                        Text(
                          'Hasil Perhitungan:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _result,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}