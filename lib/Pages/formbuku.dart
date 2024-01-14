import 'package:bukuapps/JsonModels/buku_model.dart';
import 'package:bukuapps/sqflite/sqlite.dart';
import 'package:flutter/material.dart';

class FormulirBuku extends StatefulWidget {
  const FormulirBuku({super.key});

  @override
  State<FormulirBuku> createState() => _FormulirBukuState();
}

class _FormulirBukuState extends State<FormulirBuku> {
  static const List<String> list = <String>[
    'Teknik',
    'Seni',
    'Ekonomi',
    'Humaniora'
  ];

  final TextEditingController isbnController = TextEditingController();
  final TextEditingController pengarangController = TextEditingController();
  final TextEditingController tglCetakController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController hargaProduksiController = TextEditingController();
  int kondisiValue = 0;
  String jenisValue = list.first;

  final db = DatabaseHelper();

  void _onAddButtonPressed() async {
    // ... Your existing code ...

    try {
      await db.createBuku(BooksModel(
        noIsbn: isbnController.text,
        namaPengarang: pengarangController.text,
        tglCetak: tglCetakController.text,
        kondisi: kondisiValue,
        harga: int.parse(hargaController.text),
        jenis: jenisValue,
        hargaProduksi: int.parse(hargaProduksiController.text),
      ));

      _showPopup(true);
    } catch (e) {
      _showPopup(false);
    }
  }

  void _showPopup(bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: isSuccess ? const Text('Success') : const Text('Error'),
          content: isSuccess
              ? const Text('Data Buku Berhasil dimasukkan')
              : const Text('Error, data buku gagal dimasukkan'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the pop-up
                // If successful, reset the form
                if (isSuccess) {
                  _resetForm();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    isbnController.clear();
    pengarangController.clear();
    tglCetakController.clear();
    hargaController.clear();
    hargaProduksiController.clear();
    kondisiValue = 0;
    jenisValue = list.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: isbnController,
            decoration: const InputDecoration(labelText: 'ISBN'),
          ),
          TextField(
            controller: pengarangController,
            decoration: const InputDecoration(labelText: 'Pengarang'),
          ),
          TextField(
            controller: tglCetakController,
            decoration: const InputDecoration(labelText: 'Tanggal Cetak'),
            onTap: () async {
              DateTime? date = DateTime(1900);
              FocusScope.of(context).requestFocus(FocusNode());

              date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2101),
              );

              if (date != null) {
                String formatedData = "${date.day.toString().padLeft(2, '0')}-"
                    "${date.month.toString().padLeft(2, '0')}-"
                    "${date.year.toString()}";
                tglCetakController.text = formatedData;
              }
            },
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: double.infinity,
            child: Text(
              'Kondisi',
              textAlign: TextAlign.start,
            ),
          ),
          Row(
            children: [
              Radio(
                value: 1,
                groupValue: kondisiValue,
                onChanged: (value) {
                  setState(() {
                    kondisiValue = 1;
                  });
                },
                activeColor: Colors.black,
              ),
              const Text('Baik'),
              Radio(
                value: 0,
                groupValue: kondisiValue,
                onChanged: (value) {
                  setState(() {
                    kondisiValue = 0;
                  });
                },
                activeColor: Colors.black,
              ),
              const Text('Rusak'),
            ],
          ),
          TextField(
            controller: hargaController,
            decoration: const InputDecoration(labelText: 'Harga'),
          ),
          SizedBox(
            width: double.infinity,
            height: 65.0,
            child: DropdownButton<String>(
              value: jenisValue.toString(),
              onChanged: (String? newValue) {
                setState(() {
                  jenisValue = newValue!;
                });
              },
              items: list.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: const Text('Jenis'),
              isExpanded: true,
            ),
          ),
          TextField(
            controller: hargaProduksiController,
            decoration: const InputDecoration(labelText: 'Harga Produksi'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onAddButtonPressed,
            child: const Text('Tambah buku'),
          ),
        ],
      ),
    );
  }
}
