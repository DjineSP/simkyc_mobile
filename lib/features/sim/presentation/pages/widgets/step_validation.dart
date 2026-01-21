import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../../core/constants/app_colors.dart';
import '../components/activation_helpers.dart';

class StepValidation extends StatelessWidget {
  final Map<String, TextEditingController> ctrls;
  final bool isMale;
  final File? frontImg;
  final File? backImg;

  const StepValidation({
    super.key,
    required this.ctrls,
    required this.isMale,
    this.frontImg,
    this.backImg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Aligne la colonne au centre
          children: [
            const SizedBox(width: double.infinity), // Force la colonne à prendre toute la largeur pour le centrage
            const Text(
              'Vérification finale',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.slate,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vérifiez scrupuleusement les données avant la soumission.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic, // Mise en italique
                color: AppColors.slate.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 1. SECTION SIM
        _buildHeaderSection("Détails de la SIM"),
        CardContainer(
          child: Column(
            children: [
              _infoRow('Numéro (MSISDN)', ctrls['msisdn']?.text),
              _infoRow('Numéro de série', ctrls['serial']?.text),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. SECTION CLIENT
        _buildHeaderSection("Identité du Client"),
        CardContainer(
          child: Column(
            children: [
              _infoRow('Nom complet', '${ctrls['firstName']?.text} ${ctrls['lastName']?.text}'),
              _infoRow('Date de naissance', ctrls['dob']?.text),
              _infoRow('Lieu de naissance', ctrls['pob']?.text),
              _infoRow('Genre', isMale ? 'Masculin' : 'Féminin'),
              _infoRow('Profession', ctrls['job']?.text),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. SECTION COORDONNÉES
        _buildHeaderSection("Coordonnées"),
        CardContainer(
          child: Column(
            children: [
              _infoRow('Adresse Géographique', ctrls['geo']?.text),
              _infoRow('Adresse Postale', ctrls['post']?.text),
              _infoRow('Email', ctrls['email']?.text),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. SECTION PIÈCE D'IDENTITÉ
        _buildHeaderSection("Document d'identification"),
        CardContainer(
          child: Column(
            children: [
              _infoRow('Nature', ctrls['idNature']?.text),
              _infoRow('N° de pièce', ctrls['idNumber']?.text),
              _infoRow('Date de validité', ctrls['idValidity']?.text),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 5. SECTION PHOTOS
        _buildHeaderSection("Preuves visuelles"),
        Row(
          children: [
            _imagePreview('Recto de la pièce', frontImg),
            const SizedBox(width: 12),
            _imagePreview('Verso de la pièce', backImg),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Petit titre de section rouge et stylisé
  Widget _buildHeaderSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.red,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // Ligne d'information clé/valeur
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? 'Non renseigné' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de prévisualisation d'image
  Widget _imagePreview(String label, File? image) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(image, fit: BoxFit.cover),
            )
                : const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}