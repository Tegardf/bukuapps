import 'package:bukuapps/JsonModels/buku_model.dart';
import 'package:bukuapps/sqflite/sqlite.dart';
import 'package:flutter/material.dart';

class BukuList extends StatefulWidget {
  const BukuList({super.key});

  @override
  State<BukuList> createState() => _BukuListState();
}

class _BukuListState extends State<BukuList> {
  late DatabaseHelper handler;
  late Future<List<BooksModel>> books;

  final db = DatabaseHelper();

  static const List<String> list = <String>[
    'Teknik',
    'Seni',
    'Ekonomi',
    'Humaniora'
  ];

  final isbnController = TextEditingController();
  final pengarangController = TextEditingController();
  final tglCetakController = TextEditingController();
  final hargaController = TextEditingController();
  final hargaProduksiController = TextEditingController();
  final keyword = TextEditingController();
  int kondisiValue = 0;
  String jenisValue = list.first;

  @override
  void initState() {
    handler = DatabaseHelper();
    books = handler.getBooks();

    handler.initDB().whenComplete(() {
      books = getAllBooks();
    });
    super.initState();
  }

  Future<List<BooksModel>> getAllBooks() {
    return handler.getBooks();
  }

  Future<List<BooksModel>> searchBook() {
    return handler.searchBook(keyword.text);
  }

  Future<void> _refresh() async {
    setState(() {
      books = getAllBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: keyword,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      books = searchBook();
                    });
                  } else {
                    setState(() {
                      books = getAllBooks();
                    });
                  }
                },
                decoration: const InputDecoration(
                  hintText: "Cari Pengarang",
                ),
              ),
            ),
            Expanded(
                child: FutureBuilder<List<BooksModel>>(
              future: books,
              builder: (BuildContext context,
                  AsyncSnapshot<List<BooksModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Data"));
                } else if (snapshot.hasError) {
                  print('error');
                  return Text(snapshot.error.toString());
                } else {
                  final items = snapshot.data ?? <BooksModel>[];
                  print(books);
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text("Pengarang: ${items[index].namaPengarang}"),
                        subtitle: Text(items[index].tglCetak),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            print(items[index].id);
                            if (items[index].id != null) {
                              db.deleteBook(items[index].id!).whenComplete(() {
                                _refresh();
                              });
                            }
                          },
                        ),
                        onTap: () {
                          _showdialogupdate(items, index, context);
                        },
                      );
                    },
                  );
                }
              },
            ))
          ],
        ));
  }

  void _showdialogupdate(
      List<BooksModel> items, int index, BuildContext context) {
    setState(() {
      isbnController.text = items[index].noIsbn;
      pengarangController.text = items[index].namaPengarang;
      tglCetakController.text = items[index].tglCetak;
      hargaController.text = items[index].harga.toString();
      hargaProduksiController.text = items[index].hargaProduksi.toString();
      kondisiValue = items[index].kondisi;
      jenisValue = items[index].jenis;
    });
    showDialog(
        context: context,
        builder: <Future>(context) {
          return AlertDialog(
              actions: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        db
                            .updateBook(
                                BooksModel(
                                  noIsbn: isbnController.text,
                                  namaPengarang: pengarangController.text,
                                  tglCetak: tglCetakController.text,
                                  kondisi: kondisiValue,
                                  harga: int.parse(hargaController.text),
                                  jenis: jenisValue,
                                  hargaProduksi:
                                      int.parse(hargaProduksiController.text),
                                ),
                                items[index].id)
                            .whenComplete(() {
                          _refresh();
                          Navigator.pop(context);
                        });
                      },
                      child: const Text("update"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("close"),
                    ),
                  ],
                ),
              ],
              title: const Text("Update Buku"),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: isbnController,
                        decoration: const InputDecoration(labelText: 'ISBN'),
                      ),
                      TextField(
                        controller: pengarangController,
                        decoration:
                            const InputDecoration(labelText: 'Pengarang'),
                      ),
                      TextField(
                        controller: tglCetakController,
                        decoration:
                            const InputDecoration(labelText: 'Tanggal Cetak'),
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
                            String formatedData =
                                "${date.day.toString().padLeft(2, '0')}-"
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
                                print('Kondisi Value: $kondisiValue');
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
                                print('Kondisi Value: $kondisiValue');
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
                        decoration:
                            const InputDecoration(labelText: 'Harga Produksi'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ));
        });
  }
}
