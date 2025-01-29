import 'package:flutter/material.dart';
import 'database.dart';

void main() {
  runApp(AplikasiHuruf());
}

class AplikasiHuruf extends StatelessWidget {
  const AplikasiHuruf({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          darkModeNotifier, // Mendengarkan perubahan status dark mode
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'Belajar Huruf Jepang',
          theme:
              isDarkMode
                  ? ThemeData.dark()
                  : ThemeData.light(), // Menggunakan tema tergantung dark mode
          home: PilihanHalaman(),
        );
      },
    );
  }
}

class PilihanHalaman extends StatefulWidget {
  const PilihanHalaman({super.key});

  @override
  PilihanHalamanState createState() => PilihanHalamanState();
}

class PilihanHalamanState extends State<PilihanHalaman> {
  String pilihanHuruf = "hiragana"; // Pilihan huruf awal
  bool acak = false;
  String? kategori = 'a'; // Kategori default
  bool showKategoriDropdown =
      false; // Menentukan apakah dropdown kategori ditampilkan
  List<Map<String, dynamic>> daftarHuruf = [];
  List<String> kategoriList = [];
  List<String> hurufList = ['hiragana', 'katakana'];

  // Fungsi untuk mengambil data kategori dari database berdasarkan tabel hiragana/katakana
  Future<void> ambilKategori() async {
    try {
      final db = await DatabaseHelper.database;
      String query =
          "SELECT DISTINCT group_name FROM $pilihanHuruf WHERE group_name IS NOT NULL";
      List<Map<String, dynamic>> kategoriData = await db.rawQuery(query);

      // Menyaring kategori menjadi hanya satu data per kategori
      List<String> kategoriTemp =
          kategoriData.map((e) => e['group_name'] as String).toSet().toList();

      setState(() {
        kategoriList = kategoriTemp;
      });
    } catch (e) {
      print("Gagal mengambil kategori: $e");
    }
  }

  // Fungsi untuk mengambil data berdasarkan pilihan huruf, acak, dan kategori
  void ambilData() async {
    if (kategori == null) return;

    List<Map<String, dynamic>> data;

    final db = await DatabaseHelper.database;

    // Jika kategori dipilih, ambil berdasarkan kategori, jika tidak, ambil semua data
    String query = "SELECT * FROM $pilihanHuruf";
    if (kategori != null && kategori!.isNotEmpty) {
      query += " WHERE group_name = '$kategori'";
    }

    if (acak) {
      query += " ORDER BY RANDOM()";
    }

    data = await db.rawQuery(query);

    setState(() {
      daftarHuruf = data; // Menyimpan data yang diambil
    });

    // Jika ada data, navigasi ke TampilanHurufHalaman
    if (daftarHuruf.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TampilanHurufHalaman(daftarHuruf: daftarHuruf),
        ),
      );
    } else {
      print("Tidak ada data yang ditemukan untuk kategori: $kategori");
    }
  }

  @override
  void initState() {
    super.initState();
    ambilKategori(); // Mengambil kategori ketika aplikasi pertama kali dimuat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Belajar Huruf Jepang"),
        actions: [
          Switch(
            value: darkModeNotifier.value,
            onChanged: (bool value) {
              darkModeNotifier.value = value; // Mengubah nilai dark mode
            },
          ),
        ],
      ),
      body: Center(
        // Membungkus seluruh konten dalam Center untuk menempatkannya di tengah
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Menjaga pilihan tetap di tengah
            children: [
              Text("Pilih Jenis Huruf:"),
              // Dropdown untuk memilih jenis huruf
              DropdownButton<String>(
                value: pilihanHuruf,
                items:
                    hurufList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase()),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    pilihanHuruf = newValue!;
                    ambilKategori(); // Ambil kategori berdasarkan tabel yang dipilih
                  });
                },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: showKategoriDropdown,
                    onChanged: (value) {
                      setState(() {
                        showKategoriDropdown = value!;
                      });
                    },
                  ),
                  Text("Pilih berdasarkan kategori"),
                ],
              ),
              // Menampilkan dropdown kategori jika checkbox dicentang
              if (showKategoriDropdown)
                DropdownButton<String>(
                  value: kategori,
                  items:
                      kategoriList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      kategori = newValue;
                    });
                  },
                ),
              ElevatedButton(
                onPressed: ambilData,
                child: Text("Tampilkan Huruf"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TampilanHurufHalaman extends StatefulWidget {
  final List<Map<String, dynamic>> daftarHuruf;

  const TampilanHurufHalaman({super.key, required this.daftarHuruf});

  @override
  TampilanHurufHalamanState createState() => TampilanHurufHalamanState();
}

class TampilanHurufHalamanState extends State<TampilanHurufHalaman> {
  int currentIndex = 0; // Indeks huruf yang ditampilkan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Belajar Huruf Jepang")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            widget.daftarHuruf.isEmpty
                ? Center(child: Text("Belum ada data"))
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.daftarHuruf[currentIndex]['character'] ??
                          'Tidak ada karakter',
                      style: TextStyle(fontSize: 30),
                    ),
                    Text(
                      widget.daftarHuruf[currentIndex]['romaji'] ??
                          'Tidak ada romaji',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed:
                              currentIndex > 0
                                  ? () {
                                    setState(() {
                                      currentIndex--;
                                    });
                                  }
                                  : null,
                          child: Text("Back"),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed:
                              currentIndex < widget.daftarHuruf.length - 1
                                  ? () {
                                    setState(() {
                                      currentIndex++;
                                    });
                                  }
                                  : null,
                          child: Text("Next"),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}

// Menambahkan ValueNotifier untuk dark mode
ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);
