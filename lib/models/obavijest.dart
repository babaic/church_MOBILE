class Obavijest {
  final int id;
  String naslov;
  String text;
  final String datum;
  final String glavnaSlika;
  final List<dynamic> slike;
  final String kategorija;
  final int kategorijaId;

  Obavijest({this.id, this.naslov, this.text, this.datum, this.glavnaSlika, this.slike, this.kategorija, this.kategorijaId});
}