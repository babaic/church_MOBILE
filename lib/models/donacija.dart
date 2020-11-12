class Donacija {
  int iznos;
  String desc;
  String mjesec;
  String godina;
  String brKartice;
  String cvv;
}

class DonacijaToDisplay {
  final int userId;
  final String datum;
  final double iznos;
  final String imePrezime;
  final String poruka;
  final int id;

  DonacijaToDisplay({this.userId, this.datum, this.iznos, this.imePrezime, this.poruka, this.id});
}