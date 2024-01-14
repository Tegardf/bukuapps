import 'package:bukuapps/JsonModels/pengguna_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bukuapps/JsonModels/buku_model.dart';

class DatabaseHelper {
  final databaseName = "bukuku.db";
  String bukuTable =
      "CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, No_ISBN CHAR(10), Nama_Pengarang VARCHAR(20), Tgl_Cetak DATE, Kondisi BOOLEAN, Harga INTEGER, Jenis CHAR(10), Harga_Produksi INTEGER);";
  String penggunaTable =
      "CREATE TABLE penggunas (id INTEGER PRIMARY KEY AUTOINCREMENT, Id_Pengguna CHAR(10), Nama VARCHAR(20), Alamat VARCHAR(50), Tgl_Daftar DATE, No_Telepon VARCHAR(15), Foto VARCHAR(50));";

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(bukuTable);
      await db.execute(penggunaTable);
    });
  }

  //Search method
  Future<List<BooksModel>> searchBook(String keyword) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> result = await db.rawQuery(
        "select * from books where Nama_Pengarang LIKE ?", ["%$keyword"]);
    return List.generate(result.length, (i) {
      return BooksModel(
        id: result[i]['id'],
        noIsbn: result[i]['No_ISBN'],
        namaPengarang: result[i]['Nama_Pengarang'],
        tglCetak: result[i]['Tgl_Cetak'],
        kondisi: result[i]['Kondisi'],
        harga: result[i]['Harga'],
        jenis: result[i]['Jenis'],
        hargaProduksi: result[i]['Harga_Produksi'],
      );
    });
  }

  Future<List<PenggunasModel>> searchPenguna(String keyword) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> result = await db
        .rawQuery("select * from penggunas where Nama LIKE ?", ["%$keyword"]);
    return List.generate(result.length, (i) {
      return PenggunasModel(
        id: result[i]["id"],
        idPengguna: result[i]["Id_Pengguna"],
        nama: result[i]["Nama"],
        alamat: result[i]["Alamat"],
        tglDaftar: result[i]["Tgl_Daftar"],
        noTelepon: result[i]["No_Telepon"],
        foto: result[i]["Foto"],
      );
    });
  }

  //create
  Future<int> createBuku(BooksModel buku) async {
    final Database db = await initDB();
    return db.insert('books', buku.toMap());
  }

  Future<int> createPengguna(PenggunasModel pengguna) async {
    final Database db = await initDB();
    return db.insert('penggunas', pengguna.toMap());
  }

  //Read
  Future<List<BooksModel>> getBooks() async {
    final Database db = await initDB();
    List<Map<String, dynamic>> result = await db.query('books');
    return List.generate(result.length, (i) {
      return BooksModel(
        id: result[i]['id'],
        noIsbn: result[i]['No_ISBN'],
        namaPengarang: result[i]['Nama_Pengarang'],
        tglCetak: result[i]['Tgl_Cetak'],
        kondisi: result[i]['Kondisi'],
        harga: result[i]['Harga'],
        jenis: result[i]['Jenis'],
        hargaProduksi: result[i]['Harga_Produksi'],
      );
    });
  }

  Future<List<PenggunasModel>> getPenggunas() async {
    final Database db = await initDB();
    List<Map<String, dynamic>> result = await db.query('penggunas');
    return List.generate(result.length, (i) {
      return PenggunasModel(
        id: result[i]["id"],
        idPengguna: result[i]["Id_Pengguna"],
        nama: result[i]["Nama"],
        alamat: result[i]["Alamat"],
        tglDaftar: result[i]["Tgl_Daftar"],
        noTelepon: result[i]["No_Telepon"],
        foto: result[i]["Foto"],
      );
    });
  }

  //Delete
  Future<int> deleteBook(int id) async {
    final Database db = await initDB();
    return db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePengguna(int id) async {
    final Database db = await initDB();
    return db.delete('penggunas', where: 'id = ?', whereArgs: [id]);
  }

  //update
  Future<int> updateBook(BooksModel buku, idbuku) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update books set No_ISBN = ?,Nama_Pengarang = ?,Tgl_Cetak = ?,Kondisi = ?,Harga = ?,Jenis = ?,Harga_Produksi = ? where id = ?',
        [
          buku.noIsbn,
          buku.namaPengarang,
          buku.tglCetak,
          buku.kondisi,
          buku.harga,
          buku.jenis,
          buku.hargaProduksi,
          idbuku
        ]);
  }

  Future<int> updatePenggunas(PenggunasModel pengguna, idpenggunas) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update penggunas set Id_Pengguna = ?, Nama = ?, Alamat = ?, Tgl_Daftar = ?, No_Telepon = ?, Foto = ? where id = ?',
        [
          pengguna.idPengguna,
          pengguna.nama,
          pengguna.alamat,
          pengguna.tglDaftar,
          pengguna.noTelepon,
          pengguna.foto,
          idpenggunas
        ]);
  }
}
