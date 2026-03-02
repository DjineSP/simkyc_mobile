import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mrz_scanner/flutter_mrz_scanner.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';
class IdScanData {
  final String lastName;
  final String firstName;
  final String dob;
  final String pob;
  final String geo;
  final String post;
  final String email;
  final String job;
  final String clientPhone;
  final bool isMale;
  final String idNature;
  final String idNumber;
  final String idValidity;
  final File? frontImg;
  final File? backImg;

  IdScanData({
    required this.lastName,
    required this.firstName,
    required this.dob,
    required this.pob,
    required this.geo,
    required this.post,
    required this.email,
    required this.job,
    required this.clientPhone,
    required this.isMale,
    required this.idNature,
    required this.idNumber,
    required this.idValidity,
    this.frontImg,
    this.backImg,
  });
}

class IdScannerHelper {
  static Future<IdScanData?> scanId(BuildContext context) async {
    return Navigator.push<IdScanData>(
      context,
      MaterialPageRoute(builder: (_) => const MrzScannerPage()),
    );
  }
}

class MrzScannerPage extends StatefulWidget {
  const MrzScannerPage({super.key});

  @override
  State<MrzScannerPage> createState() => _MrzScannerPageState();
}

class _MrzScannerPageState extends State<MrzScannerPage> {
  MRZController? controller;
  bool isParsed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mrz_scanner_title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<PermissionStatus>(
        future: Permission.camera.request(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data == PermissionStatus.granted) {
            return Stack(
              children: [
                MRZScanner(
                  onControllerCreated: (c) {
                    controller = c;
                    c.onParsed = (result) {
                      if (isParsed) return;
                      isParsed = true;
                      c.stopPreview();

                      bool isMale = true;
                      try {
                        isMale = result.sex.name.toLowerCase() == 'male' || result.sex.toString() == 'Sex.male';
                      } catch (_) {}

                      final data = IdScanData(
                        lastName: result.surnames,
                        firstName: result.givenNames,
                        dob: DateFormat('dd/MM/yyyy').format(result.birthDate),
                        pob: '',
                        geo: '',
                        post: '',
                        email: '',
                        job: '',
                        clientPhone: '',
                        isMale: isMale,
                        idNature: '1', // Par défaut
                        idNumber: result.documentNumber,
                        idValidity: DateFormat('dd/MM/yyyy').format(result.expiryDate),
                        frontImg: null,
                        backImg: null,
                      );
                      if (mounted) {
                        Navigator.pop(context, data);
                      }
                    };
                    c.onError = (error) {
                      debugPrint('MRZ Scan Error: $error');
                    };
                    c.startPreview();
                  },
                ),
                _buildOverlay(context, l10n),
              ],
            );
          }
          if (snapshot.data == PermissionStatus.permanentlyDenied) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(l10n.mrz_camera_permission_denied, textAlign: TextAlign.center),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () => openAppSettings(),
                     child: Text(l10n.mrz_open_settings),
                   )
                ],
              )
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.mrz_camera_permission_required, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text(l10n.mrz_retry),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        
        // Exactement comme dans le code natif Kotlin (FotoapparatCamera.kt) :
        // Le ratio du document est de 1.42
        // Sur un écran en mode portrait (height > width)
        final double docWidth = width * 0.9;
        final double docHeight = docWidth / 1.42;
        
        // Le document entier est centré
        final double docTop = (height - docHeight) / 2;
        final double docLeft = (width - docWidth) / 2;
        
        // La zone MRZ est les 40% inférieurs de ce document
        final double mrzHeight = docHeight * 0.4;
        final double mrzTop = docTop + (docHeight * 0.6);
        
        return Stack(
          children: [
            // Couche semi-transparente avec double découpe (Document entier léger, MRZ complètement transparent)
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.white, backgroundBlendMode: BlendMode.dstOut),
                  ),
                  // Découpe de la zone MRZ uniquement (complètement transparente)
                  Positioned(
                    top: mrzTop,
                    left: docLeft,
                    width: docWidth,
                    height: mrzHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black, // sera transparent
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Ligne de guidage pour le document entier
            Positioned(
              top: docTop,
              left: docLeft,
              width: docWidth,
              height: docHeight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white38, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            // Cadre visible pour la zone MRZ
            Positioned(
              top: mrzTop,
              left: docLeft,
              width: docWidth,
              height: mrzHeight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            // Texte d'instruction
            Positioned(
              top: docTop - 40,
              left: 20,
              right: 20,
              child: Text(
                l10n.mrz_scanner_help,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
