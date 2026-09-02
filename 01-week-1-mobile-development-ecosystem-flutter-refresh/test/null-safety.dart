void main() {
  print(hitungLuasPersegiPanjang(10, 5));
  final profile = Profile(
    name: 'nama',
    nim: 'nim',
    email: 'email',
  );
  print(profile.status());
}

//fungsi untuk menghitung luas persegi panjang
double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

//class untuk menampung data profile
class Profile {
  Profile({
    required this.name,
    required this.nim,
    required this.email,
  });
  final String? name;
  final String? nim;
  final String? email;
  String status() => email ?? 'Belum ada email';
}
