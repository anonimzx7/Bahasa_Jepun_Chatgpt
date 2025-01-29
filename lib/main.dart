import 'package:flutter/material.dart';
import 'database.dart';

void main() {
  runApp(AplikasiHuruf());
}

class AplikasiHuruf extends StatelessWidget {
  const AplikasiHuruf({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belajar Huruf Jepang',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PilihanHalaman(),
    );
  }
}

class PilihanHalaman extends StatefulWidget {
  const PilihanHalaman({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PilihanHalamanState createState() => _PilihanHalamanState();
}

class _PilihanHalamanState extends State<PilihanHalaman> {
  String pilihanHuruf = "Tabel_Hiragana"; // Default pilihan Hiragana
  bool acak = false;
  List<Map<String, dynamic>> daftarHuruf = [];

  /// Mengambil data dari database berdasarkan pilihan
  void ambilData() async {
    List<Map<String, dynamic>> data = await DatabaseHelper.getData(
      tabel: pilihanHuruf,
      acak: acak,
    );
    setState(() {
      daftarHuruf = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Belajar Huruf Jepang")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Pilih Jenis Huruf:"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: "Tabel_Hiragana",
                      groupValue: pilihanHuruf,
                      onChanged: (value) {
                        setState(() {
                          pilihanHuruf = value.toString();
                        });
                      },
                    ),
                    Text("Hiragana"),
                    Radio(
                      value: "Tabel_Katakana",
                      groupValue: pilihanHuruf,
                      onChanged: (value) {
                        setState(() {
                          pilihanHuruf = value.toString();
                        });
                      },
                    ),
                    Text("Katakana"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: acak,
                      onChanged: (value) {
                        setState(() {
                          acak = value!;
                        });
                      },
                    ),
                    Text("Acak"),
                  ],
                ),
                ElevatedButton(
                  onPressed: ambilData,
                  child: Text("Tampilkan"),
                ),
              ],
            ),
          ),
          Expanded(
            child: daftarHuruf.isEmpty
                ? Center(child: Text("Belum ada data"))
                : ListView.builder(
                    itemCount: daftarHuruf.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          daftarHuruf[index]['karakter'],
                          style: TextStyle(fontSize: 30),
                        ),
                        subtitle: Text(
                          daftarHuruf[index]['romaji'],
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
