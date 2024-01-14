import 'dart:io';

import 'package:bukuapps/JsonModels/pengguna_model.dart';
import 'package:bukuapps/sqflite/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PenggunaList extends StatefulWidget {
  const PenggunaList({super.key});

  @override
  State<PenggunaList> createState() => _PenggunaListState();
}

class _PenggunaListState extends State<PenggunaList> {
  late DatabaseHelper handler;
  late Future<List<PenggunasModel>> penggunas;

  final db = DatabaseHelper();

  final idPenggunaController = TextEditingController();
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final tglDaftarController = TextEditingController();
  final noTeleponController = TextEditingController();
  final fotoController = TextEditingController();

  XFile? image;
  final ImagePicker picker = ImagePicker();
  final keyword = TextEditingController();

  @override
  void initState() {
    handler = DatabaseHelper();
    penggunas = handler.getPenggunas();

    handler.initDB().whenComplete(() {
      penggunas = getAllPenggunas();
    });
    super.initState();
  }

  Future<List<PenggunasModel>> getAllPenggunas() {
    return handler.getPenggunas();
  }

  Future<List<PenggunasModel>> searchPengguna() {
    return handler.searchPenguna(keyword.text);
  }

  Future<void> _refresh() async {
    setState(() {
      penggunas = getAllPenggunas();
    });
  }

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    setState(() {
      image = img;
      fotoController.text = img!.path;
    });
  }

  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Please choose media to select'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
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
                  penggunas = searchPengguna();
                });
              } else {
                setState(() {
                  penggunas = getAllPenggunas();
                });
              }
            },
            decoration: const InputDecoration(
              hintText: "Cari Pengguna",
            ),
          ),
        ),
        Expanded(
            child: FutureBuilder<List<PenggunasModel>>(
          future: penggunas,
          builder: (BuildContext context,
              AsyncSnapshot<List<PenggunasModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Center(child: Text("No Data"));
            } else if (snapshot.hasError) {
              print('error');
              return Text(snapshot.error.toString());
            } else {
              final items = snapshot.data ?? <PenggunasModel>[];
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("${items[index].nama}"),
                    subtitle: Text(items[index].tglDaftar),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        print(items[index].id);
                        if (items[index].id != null) {
                          db.deletePengguna(items[index].id!).whenComplete(() {
                            _refresh();
                          });
                        }
                      },
                    ),
                    onTap: () {
                      _showdialogupdatepengguna(items, index, context);
                    },
                  );
                },
              );
            }
          },
        ))
      ]),
    );
  }

  void _showdialogupdatepengguna(
      List<PenggunasModel> items, int index, BuildContext context) {
    setState(() {
      idPenggunaController.text = items[index].idPengguna;
      namaController.text = items[index].nama;
      alamatController.text = items[index].alamat;
      tglDaftarController.text = items[index].tglDaftar;
      noTeleponController.text = items[index].noTelepon;
      fotoController.text = items[index].foto;
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
                            .updatePenggunas(
                                PenggunasModel(
                                  idPengguna: idPenggunaController.text,
                                  nama: namaController.text,
                                  alamat: alamatController.text,
                                  tglDaftar: tglDaftarController.text,
                                  noTelepon: noTeleponController.text,
                                  foto: fotoController.text,
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
              title: const Text("Update Pengguna"),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: idPenggunaController,
                        decoration:
                            const InputDecoration(labelText: 'Id Pengguna'),
                      ),
                      TextField(
                        controller: namaController,
                        decoration: const InputDecoration(labelText: 'Nama'),
                      ),
                      TextField(
                        controller: alamatController,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                      ),
                      TextField(
                        controller: tglDaftarController,
                        decoration:
                            const InputDecoration(labelText: 'Tanggal Daftar'),
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
                            tglDaftarController.text = formatedData;
                          }
                        },
                      ),
                      TextField(
                        controller: noTeleponController,
                        decoration:
                            const InputDecoration(labelText: 'Nomor Telepon'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          myAlert();
                        },
                        child: const Text('Upload Photo'),
                      ),
                      const SizedBox(height: 16),
                      image != null
                          ? (Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  //to show image, you type like this.
                                  File(image!.path),
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                ),
                              ),
                            ))
                          : Image.file(
                              File(fotoController.text),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ));
        });
  }
}
