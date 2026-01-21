import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/gen/app_localizations.dart';

class SimCodeScanner extends StatefulWidget {
  final Function(String) onCodeScanned;

  const SimCodeScanner({super.key, required this.onCodeScanned});

  static Future<void> show(BuildContext context, {required Function(String) onCodeScanned}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SimCodeScanner(onCodeScanned: onCodeScanned),
    );
  }

  @override
  State<SimCodeScanner> createState() => _SimCodeScannerState();
}

class _SimCodeScannerState extends State<SimCodeScanner> {
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String code = barcodes.first.rawValue ?? "";
                  if (code.isNotEmpty) {
                    Navigator.pop(context);
                    widget.onCodeScanned(code);
                  }
                }
              },
            ),
            // Overlay sombre avec trou central
            _ScannerOverlay(),
            // En-tête avec titre et contrôles
            _ScannerHeader(
              controller: controller,
              title: l10n.scanner_title,
              hint: l10n.scanner_hint,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerHeader extends StatelessWidget {
  final MobileScannerController controller;
  final String title;
  final String hint;

  const _ScannerHeader({
    required this.controller,
    required this.title,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15, left: 0, right: 0,
      child: Column(
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 25),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          Text(hint, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton Flash
              _CircleActionButton(
                icon: Icons.flashlight_on_rounded,
                onPressed: () => controller.toggleTorch(),
              ),
              const SizedBox(width: 20),
              // Bouton Fermer
              _CircleActionButton(
                icon: Icons.close_rounded,
                color: AppColors.primary,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 20),
              // Bouton Switch Camera
              _CircleActionButton(
                icon: Icons.flip_camera_ios_rounded,
                onPressed: () => controller.switchCamera(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _CircleActionButton({required this.icon, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
      ),
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: color ?? Colors.white12,
          padding: const EdgeInsets.all(12),
        ),
        icon: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.srcOut),
          child: Stack(
            children: [
              Container(decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut)),
              Center(
                child: Container(
                  width: 280, height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white, // Définit la zone transparente
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bordure rouge du viseur
        Center(
          child: Container(
            width: 280, height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}