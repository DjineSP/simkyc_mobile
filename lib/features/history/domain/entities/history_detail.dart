import 'package:flutter/material.dart';

class HistoryDetail {
  final String id;
  final String msisdn;
  final DateTime? dateActivation;
  final int etat;
  final bool? saveByPos;
  final DateTime? createDate;
  final DateTime? editDate;
  final int? createCodeUser;
  final int? editCodeUser;
  final int? idNaturePiece;
  final String? libelleNaturePiece;
  final String? idFrontImage;
  final String? idBackImage;
  final String? noms;
  final String? prenoms;
  final bool? sexe; // true = M, false = F ? Ou l'inverse. On verra.
  final DateTime? dateNaissance;
  final String? lieuNaissance;
  final String? profession;
  final DateTime? dateValiditePiece;
  final String? numeroPiece;
  final String? adressePostale;
  final String? numeroTelephoneClient;
  final String? mail;
  final String? adresseGeographique;

  HistoryDetail({
    required this.id,
    required this.msisdn,
    this.dateActivation,
    required this.etat,
    this.saveByPos,
    this.createDate,
    this.editDate,
    this.createCodeUser,
    this.editCodeUser,
    this.idNaturePiece,
    this.libelleNaturePiece,
    this.idFrontImage,
    this.idBackImage,
    this.noms,
    this.prenoms,
    this.sexe,
    this.dateNaissance,
    this.lieuNaissance,
    this.profession,
    this.dateValiditePiece,
    this.numeroPiece,
    this.adressePostale,
    this.numeroTelephoneClient,
    this.mail,
    this.adresseGeographique,
  });

  factory HistoryDetail.fromJson(Map<String, dynamic> json) {
    return HistoryDetail(
      id: (json['iD_Activation_Sim'] ?? json['iD_Reactivation_Sim'] ?? json['iD_Mise_A_Jour_Client'] ?? json['id'] ?? '').toString(),
      msisdn: json['msisdn']?.toString() ?? '',
      dateActivation: json['dateActivation'] != null ? DateTime.tryParse(json['dateActivation']) : null,
      etat: json['etat'] is int ? json['etat'] : 0,
      saveByPos: json['saveByPos'],
      createDate: json['createDate'] != null ? DateTime.tryParse(json['createDate']) : null,
      editDate: json['editDate'] != null ? DateTime.tryParse(json['editDate']) : null,
      createCodeUser: json['createCodeUser'],
      editCodeUser: json['editCodeUser'],
      idNaturePiece: json['idNaturePiece'] ?? json['iD_Nature_Piece'],
      libelleNaturePiece: json['nature_Piece'],
      idFrontImage: json['idFrontImage'],
      idBackImage: json['idBackImage'],
      noms: json['noms'],
      prenoms: json['prenoms'],
      sexe: json['sexe'],
      dateNaissance: json['dateNaissance'] != null ? DateTime.tryParse(json['dateNaissance']) : null,
      lieuNaissance: json['lieuNaissance'],
      profession: json['profession'],
      dateValiditePiece: json['dateValiditePiece'] != null ? DateTime.tryParse(json['dateValiditePiece']) : null,
      numeroPiece: json['numeroPiece'],
      adressePostale: json['adressePostale'],
      numeroTelephoneClient: json['numeroTelephoneClient'],
      mail: json['mail'],
      adresseGeographique: json['adresseGeographique'],
    );
  }
}
