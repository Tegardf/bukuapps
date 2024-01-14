import 'dart:io';

import 'package:bukuapps/JsonModels/pengguna_model.dart';
import 'package:bukuapps/sqflite/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormulirUser extends StatefulWidget {
  const FormulirUser({super.key});

  @override
  State<FormulirUser> createState() => _FormulirUserState();
}

class _FormulirUserState extends State<FormulirUser> {
  final idPenggunaController = TextEditingController();
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final tglDaftarController = TextEditingController();
  final noTeleponController = TextEditingController();
  final fotoController = TextEditingController();

  XFile? image;
  final ImagePicker picker = ImagePicker();

  final db = DatabaseHelper();

  void _onAddButtonPressedPengguna() async {
    try {
      await db.createPengguna(PenggunasModel(
          idPengguna: idPenggunaController.text,
          nama: namaController.text,
          alamat: alamatController.text,
          tglDaftar: tglDaftarController.text,
          noTelepon: noTeleponController.text,
          foto: fotoController.text));
      _showPopupPengguna(true);
    } catch (e) {
      _showPopupPengguna(false);
    }
  }

  void _showPopupPengguna(bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: isSuccess ? const Text('Success') : const Text('Error'),
          content: isSuccess
              ? const Text('Data Penggunas Berhasil dimasukkan')
              : const Text('Error, data Penggunas gagal dimasukkan'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  _resetFormPenggunas();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resetFormPenggunas() {
    idPenggunaController.clear();
    namaController.clear();
    alamatController.clear();
    tglDaftarController.clear();
    noTeleponController.clear();
    fotoController.clear();
    image = null;
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
      child: Column(
        children: [
          TextField(
            controller: idPenggunaController,
            decoration: const InputDecoration(labelText: 'Id Pengguna'),
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
            decoration: const InputDecoration(labelText: 'Tanggal Daftar'),
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
                tglDaftarController.text = formatedData;
              }
            },
          ),
          TextField(
            controller: noTeleponController,
            decoration: const InputDecoration(labelText: 'Nomor Telepon'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
              : const Text(
                  "No Image",
                  style: TextStyle(fontSize: 20),
                ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onAddButtonPressedPengguna,
            child: const Text('Tambah Pengguna'),
          ),
        ],
      ),
    );
  }
}
