class Matiere {
  final int codMatiere;
  final String nomMat;
  final String duree; // Assuming you are storing LocalDateTime as a string for simplicity

  Matiere({
    required this.codMatiere,
    required this.nomMat,
    required this.duree,
  });

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      codMatiere: json['codMatiere'],
      nomMat: json['nomMat'],
      duree: json['duree'],
    );
  }
}
