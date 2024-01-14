class BooksModel {
  final int? id;
  final String noIsbn;
  final String namaPengarang;
  final String tglCetak;
  final int kondisi;
  final int harga;
  final String jenis;
  final int hargaProduksi;

  BooksModel({
    this.id,
    required this.noIsbn,
    required this.namaPengarang,
    required this.tglCetak,
    required this.kondisi,
    required this.harga,
    required this.jenis,
    required this.hargaProduksi,
  });

  factory BooksModel.fromMap(Map<String, dynamic> json) => BooksModel(
        id: json["id"],
        noIsbn: json["No_ISBN"],
        namaPengarang: json["Nama_Pengarang"],
        tglCetak: json["Tgl_Cetak "],
        kondisi: json["Kondisi"],
        harga: json["Harga"],
        jenis: json["Jenis"],
        hargaProduksi: json["Harga_Produksi"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "No_ISBN": noIsbn,
        "Nama_Pengarang": namaPengarang,
        "Tgl_Cetak ": tglCetak,
        "Kondisi": kondisi,
        "Harga": harga,
        "Jenis": jenis,
        "Harga_Produksi": hargaProduksi,
      };
}
