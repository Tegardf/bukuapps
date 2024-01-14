class PenggunasModel {
  final int? id;
  final String idPengguna;
  final String nama;
  final String alamat;
  final String tglDaftar;
  final String noTelepon;
  final String foto;

  PenggunasModel({
    this.id,
    required this.idPengguna,
    required this.nama,
    required this.alamat,
    required this.tglDaftar,
    required this.noTelepon,
    required this.foto,
  });

  factory PenggunasModel.fromMap(Map<String, dynamic> json) => PenggunasModel(
        id: json["id"],
        idPengguna: json["id_pengguna"],
        nama: json["nama"],
        alamat: json["alamat"],
        tglDaftar: json["tgl_daftar"],
        noTelepon: json["no_telepon"],
        foto: json["foto"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "id_pengguna": idPengguna,
        "nama": nama,
        "alamat": alamat,
        "tgl_daftar": tglDaftar,
        "no_telepon": noTelepon,
        "foto": foto,
      };
}
