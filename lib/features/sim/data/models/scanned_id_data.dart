import 'dart:io';

/// Données simulées extraites d'un scan de pièce d'identité.
class ScannedIdData {
  final String lastName;
  final String firstName;
  final String dob; // format dd/MM/yyyy
  final String pob;
  final bool isMale;
  final String geo;
  final String post;
  final String email;
  final String job;
  final String clientPhone;

  // Champs pièce d'identité (étape 3)
  final String idNature; // id de la nature (ex: "1")
  final String idNumber;
  final String idValidity; // format dd/MM/yyyy

  // Images des deux faces de la pièce
  final File frontImage;
  final File backImage;

  const ScannedIdData({
    required this.lastName,
    required this.firstName,
    required this.dob,
    required this.pob,
    required this.isMale,
    required this.geo,
    required this.post,
    required this.email,
    required this.job,
    required this.clientPhone,
    required this.idNature,
    required this.idNumber,
    required this.idValidity,
    required this.frontImage,
    required this.backImage,
  });
}
