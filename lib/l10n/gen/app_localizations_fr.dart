// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get splash_subtitle =>
      'GESTION DES CLIENTS ET DES\nCARTE SIM-KYC\nBACK-OFFICE';

  @override
  String get auth_login_title => 'Connexion';

  @override
  String get auth_login_subtitle => 'Bon retour !';

  @override
  String get auth_field_login => 'Login';

  @override
  String get auth_field_phone => 'Numéro de téléphone';

  @override
  String get auth_field_password => 'Mot de passe';

  @override
  String get auth_remember_me => 'Se souvenir de moi';

  @override
  String get auth_button_submit => 'Se connecter';

  @override
  String get auth_error_invalid_phone => 'Format invalide (ex: 6XX XX XX XX)';

  @override
  String get auth_error_password_required => 'Mot de passe requis';

  @override
  String get auth_error_auth_failed => 'Authentification échouée.';

  @override
  String get auth_forgot_password => 'Mot de passe oublié ?';

  @override
  String get auth_forgot_password_dialog_body => 'Contactez l\'admin.';

  @override
  String get auth_no_account => 'Pas de compte ?';

  @override
  String get auth_contact_admin => 'Contacter l\'admin';

  @override
  String get auth_contact_admin_dialog_title => 'Admin';

  @override
  String get auth_contact_admin_dialog_body => 'Email : admin@cellcom.cm';

  @override
  String get auth_footer => '2026 Cellcom';

  @override
  String get common_error_title => 'Erreur';

  @override
  String get common_info_title => 'Info';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get op_validate_title => 'Validation requise';

  @override
  String get op_validate_subtitle => 'Choisissez une méthode pour continuer.';

  @override
  String get op_validate_use_biometric => 'Empreinte digitale';

  @override
  String get op_validate_use_password => 'Mot de passe';

  @override
  String get op_validate_user_not_identified => 'Utilisateur non identifié.';

  @override
  String get op_validate_biometric_failed =>
      'Authentification biométrique échouée ou annulée.';

  @override
  String get home_nav_dashboard => 'Tableau de bord';

  @override
  String get home_nav_home => 'Accueil';

  @override
  String get home_nav_history => 'Historique';

  @override
  String get home_nav_reports => 'Rapports';

  @override
  String get home_nav_profile => 'Mon Profil';

  @override
  String get home_greeting => 'Bonjour,';

  @override
  String get home_search_hint => 'Rechercher MSISDN...';

  @override
  String get home_action_activation => 'Activation SIM';

  @override
  String get home_desc_activation => 'Activer une nouvelle SIM client';

  @override
  String get home_action_reactivation => 'Réactivation SIM';

  @override
  String get home_desc_reactivation => 'Réactiver des numéros dormants';

  @override
  String get home_action_update => 'Mise à jour SIM';

  @override
  String get home_desc_update => 'Mettre à jour les infos de la SIM';

  @override
  String get home_section_actions => 'Actions Rapides';

  @override
  String get settings_title => 'Paramètres';

  @override
  String get settings_theme_dark => 'Mode Sombre';

  @override
  String get settings_language => 'Langue';

  @override
  String get history_search_hint => 'Rechercher par nom, MSISDN ou ID...';

  @override
  String get history_date_all => 'Toutes les dates';

  @override
  String history_date_range(Object end, Object start) {
    return 'Du $start au $end';
  }

  @override
  String get history_empty => 'Aucun historique trouvé';

  @override
  String get history_status_active => 'Actif';

  @override
  String get history_status_suspended => 'Suspendu';

  @override
  String get history_status_inactive => 'Désactivé';

  @override
  String get history_btn_details => 'Détails';

  @override
  String get history_btn_reactivate => 'Réactiver';

  @override
  String get history_btn_update => 'Modifier';

  @override
  String get history_dialog_kyc_title => 'Détails KYC';

  @override
  String history_dialog_kyc_msg(Object name) {
    return 'Affichage des données de $name';
  }

  @override
  String history_dialog_reactivate_msg(Object msisdn) {
    return 'Lancement pour $msisdn';
  }

  @override
  String get reports_title => 'Aperçu de l\'activité';

  @override
  String get reports_period_today => 'Aujourd\'hui';

  @override
  String get reports_period_7d => '7 derniers jours';

  @override
  String get reports_period_30d => '30 derniers jours';

  @override
  String get reports_kpi_activations => 'Activations';

  @override
  String get reports_kpi_reactivations => 'Réactivations';

  @override
  String get reports_kpi_new_customers => 'Nouveaux Clients';

  @override
  String get reports_section_reason => 'Réactivation par motif';

  @override
  String get reports_reason_customer => 'Demande client';

  @override
  String get reports_reason_sim_change => 'Changement de SIM';

  @override
  String get reports_reason_tech => 'Problème technique';

  @override
  String get reports_reason_fraud => 'Enquête de fraude';

  @override
  String get reports_reason_other => 'Autre';

  @override
  String profile_agent_id(Object id) {
    return 'ID Agent: $id';
  }

  @override
  String profile_role(Object role) {
    return 'Rôle: $role';
  }

  @override
  String get profile_section_app => 'Paramètres de l\'application';

  @override
  String get profile_section_security => 'Sécurité';

  @override
  String get profile_section_about => 'À propos';

  @override
  String get profile_option_lang => 'Langue';

  @override
  String get profile_option_lang_desc => 'Français / Anglais';

  @override
  String get profile_option_theme => 'Thème';

  @override
  String get profile_option_theme_desc => 'Clair / Sombre';

  @override
  String get profile_option_notif => 'Notifications';

  @override
  String get profile_option_notif_desc => 'Gérer vos alertes push';

  @override
  String get profile_option_security_pass => 'Changer le mot de passe / PIN';

  @override
  String get profile_option_security_pass_desc => 'Mettre à jour vos accès';

  @override
  String get profile_option_last_login => 'Dernière connexion';

  @override
  String get profile_option_last_login_desc => 'Aujourd\'hui, 09:24 · Android';

  @override
  String get profile_option_about_title => 'Application SIM KYC';

  @override
  String get profile_option_about_desc =>
      'Version 1.0.0 · Contactez le support.';

  @override
  String get profile_logout => 'Déconnexion';

  @override
  String get profile_logout_confirm => 'Se déconnecter';

  @override
  String get profile_logout_cancel => 'Annuler';

  @override
  String get profile_logout_dialog_body =>
      'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_empty_title => 'Aucune notification';

  @override
  String get notifications_empty_body =>
      'Vous n\'avez aucune notification pour le moment.';

  @override
  String get scanner_title => 'Scanner le code SIM';

  @override
  String get scanner_hint => 'Placez le code-barres dans le cadre';

  @override
  String get scanner_error => 'Impossible d\'accéder à la caméra';

  @override
  String get sim_act_title => 'Activation SIM';

  @override
  String get sim_step_1 => 'SIM';

  @override
  String get sim_step_2 => 'Client';

  @override
  String get sim_step_3 => 'ID';

  @override
  String get sim_step_4 => 'Photos';

  @override
  String get sim_step_5 => 'Check';

  @override
  String get sim_error_serial => 'Série requise';

  @override
  String get sim_error_lastname => 'Nom obligatoire';

  @override
  String get sim_error_firstname => 'Prénom obligatoire';

  @override
  String get sim_error_dob => 'Date obligatoire';

  @override
  String get sim_error_pob => 'Lieu obligatoire';

  @override
  String get sim_error_id_nature => 'Nature requise';

  @override
  String get sim_error_id_number => 'Numéro requis';

  @override
  String get sim_error_id_validity => 'Date de validité requise';

  @override
  String get sim_error_photo_front => 'La photo recto est obligatoire';

  @override
  String get sim_error_photo_back => 'La photo verso est obligatoire';

  @override
  String get sim_btn_next => 'SUIVANT';

  @override
  String get sim_btn_prev => 'RETOUR';

  @override
  String get sim_btn_submit => 'SOUMETTRE';

  @override
  String get sim_msg_success_title => 'Activation réussie';

  @override
  String get sim_msg_success_body => 'Le dossier a été envoyé avec succès.';

  @override
  String get sim_react_title => 'Réactivation SIM';

  @override
  String get sim_react_step_1 => 'Recherche';

  @override
  String get sim_react_step_2 => 'Vérification';

  @override
  String get sim_react_step_3 => 'Réactivation';

  @override
  String get sim_react_error_title => 'Attention';

  @override
  String get sim_react_error_phone_required => 'Le numéro est requis';

  @override
  String get sim_react_error_reason_required => 'Veuillez indiquer le motif';

  @override
  String get sim_react_error_user_not_found =>
      'Aucun utilisateur associé à ce numéro n\'a été trouvé.';

  @override
  String get sim_react_error_new_iccid_required => 'Nouveau ICCID requis';

  @override
  String get sim_react_error_frequent1_required => 'Numéro 1 requis';

  @override
  String get sim_react_success_title => 'Opération réussie';

  @override
  String get sim_react_success_body => 'La ligne a été réactivée avec succès.';

  @override
  String get sim_update_step_1 => 'Recherche';

  @override
  String get sim_update_step_2 => 'Modification';

  @override
  String get sim_update_step_3 => 'Mise à jour';

  @override
  String get sim_update_btn_search => 'RECHERCHER';

  @override
  String get sim_update_btn_confirm => 'CONFIRMER';

  @override
  String get sim_update_error_title => 'Erreur';

  @override
  String get sim_update_error_phone_required =>
      'Le numéro de téléphone est requis';

  @override
  String get sim_update_error_geo_required =>
      'L\'adresse géographique est requise';

  @override
  String get sim_update_error_subscriber_not_found => 'Abonné introuvable';

  @override
  String get sim_update_success_title => 'Succès';

  @override
  String get sim_update_success_body => 'Profil mis à jour !';

  @override
  String get sim_update_summary_title => 'Résumé de la mise à jour';

  @override
  String get sim_update_summary_subtitle =>
      'Vérifiez les modifications avant la confirmation finale.';

  @override
  String get check_title => 'Vérification du titulaire';

  @override
  String get check_subtitle =>
      'Confirmez ces informations avec le client présent.';

  @override
  String get check_section_line => 'Ligne à réactiver';

  @override
  String get check_section_identity => 'Identité de l\'abonné';

  @override
  String get check_section_coords => 'Coordonnées';

  @override
  String get check_section_id => 'Document d\'identification';

  @override
  String get check_label_msisdn => 'Numéro (MSISDN)';

  @override
  String get check_label_serial => 'Numéro de série';

  @override
  String get check_label_status => 'Statut';

  @override
  String get check_label_name => 'Nom complet';

  @override
  String get check_label_dob => 'Date de naissance';

  @override
  String get check_label_pob => 'Lieu de naissance';

  @override
  String get check_label_gender => 'Genre';

  @override
  String get check_label_job => 'Profession';

  @override
  String get check_label_address => 'Adresse Géographique';

  @override
  String get check_label_post => 'Adresse Postale';

  @override
  String get check_label_email => 'Email';

  @override
  String get check_label_id_nature => 'Nature';

  @override
  String get check_label_id_number => 'N° de pièce';

  @override
  String get check_label_id_validity => 'Date de validité';

  @override
  String get check_warning =>
      'L\'opération doit être refusée si les informations ci-dessus ne sont pas conformes à la pièce présentée.';

  @override
  String get check_status_unknown => 'Suspendue / Perdue';

  @override
  String get step_cust_lastname => 'Nom *';

  @override
  String get step_cust_firstname => 'Prénoms *';

  @override
  String get step_cust_dob => 'Date de naissance *';

  @override
  String get step_cust_pob => 'Lieu de naissance *';

  @override
  String get step_cust_gender => 'Sexe *';

  @override
  String get step_cust_male => 'Homme';

  @override
  String get step_cust_female => 'Femme';

  @override
  String get step_cust_geo => 'Adresse géographique';

  @override
  String get step_cust_post => 'Adresse postale';

  @override
  String get step_cust_email => 'Email';

  @override
  String get step_cust_job => 'Profession';

  @override
  String get step_cust_hint_name => 'Ex: DJINE';

  @override
  String get step_cust_hint_firstname => 'Ex: John Silas';

  @override
  String get step_cust_hint_date => 'jj/mm/aaaa';

  @override
  String get step_cust_hint_pob => 'Ex: Conakry';

  @override
  String get step_cust_hint_geo => 'Quartier, Rue, N° de porte';

  @override
  String get step_cust_hint_post => 'BP, Ville, Pays';

  @override
  String get step_cust_hint_email => 'exemple@domaine.com';

  @override
  String get step_cust_hint_job => 'Ex: Commerçant, Étudiant...';

  @override
  String get step_edit_identity_label => 'Information identitaire *';

  @override
  String get step_edit_complementary_label => 'Information complémentaires';

  @override
  String get step_edit_id_doc_label => 'Document d\'identification *';

  @override
  String get step_edit_nature_label => 'Nature *';

  @override
  String get step_edit_id_hint => 'Sélectionner une pièce';

  @override
  String get step_edit_id_number_label => 'N° de pièce *';

  @override
  String get step_edit_id_number_hint => 'Entrer le numéro du document';

  @override
  String get step_edit_photos_label => 'Photos *';

  @override
  String get step_edit_photo_recto => 'Recto (Face) *';

  @override
  String get step_edit_photo_verso => 'Verso (Dos) *';

  @override
  String get step_edit_photo_hint => 'Cliquer pour capturer';

  @override
  String get step_edit_date_hint => 'jj/mm/aaaa';

  @override
  String get step_id_validity => 'Date de validité *';

  @override
  String get step_id_nature => 'Nature de la pièce *';

  @override
  String get step_id_number => 'N° de la pièce *';

  @override
  String get step_id_nature_label => 'Nature de la pièce *';

  @override
  String get step_id_nature_hint => 'Sélectionner une pièce';

  @override
  String get step_id_number_label => 'Numéro de la pièce *';

  @override
  String get step_id_number_hint => 'Entrer le numéro du document';

  @override
  String get step_id_date_hint => 'jj/mm/aaaa';

  @override
  String get step_sim_serial_label => 'Numéro de série de la SIM *';

  @override
  String get step_sim_serial_hint => 'Scanner ou entrer le numéro';

  @override
  String get step_sim_success => 'MSISDN lié avec succès';

  @override
  String get step_sim_info => 'Le MSISDN sera lié après le scan.';

  @override
  String get step_search_sim_msisdn_label =>
      'Numéro de téléphone à réactiver *';

  @override
  String get step_search_sim_msisdn_hint => '6XX XX XX XX';

  @override
  String get step_search_sim_reason_label => 'Motif de réactivation *';

  @override
  String get step_search_sim_reason_hint =>
      'Expliquez pourquoi le client réactive sa ligne';

  @override
  String get step_search_sim_info =>
      'Saisissez le numéro pour identifier l\'abonné.';

  @override
  String get step_search_sim_user_identified => 'UTILISATEUR IDENTIFIÉ';

  @override
  String get step_search_update_msisdn_label =>
      'Numéro de téléphone de l\'abonné *';

  @override
  String get step_search_update_msisdn_hint => '6XX XX XX XX';

  @override
  String get step_search_update_info =>
      'Saisissez le numéro complet pour charger les informations du profil à modifier.';

  @override
  String get step_new_sim_section_title => 'Nouvelle Carte SIM';

  @override
  String get step_new_sim_serial_label => 'Nouveau numéro de série (ICCID) *';

  @override
  String get step_new_sim_serial_hint => 'Scanner ou saisir l\'ICCID';

  @override
  String get step_new_sim_associated => 'NUMÉRO ASSOCIÉ';

  @override
  String get step_new_sim_frequent_section =>
      'Vérification : 3 numéros fréquents';

  @override
  String get step_new_sim_frequent_1 => 'Numéro 1 (Obligatoire) *';

  @override
  String get step_new_sim_frequent_2 => 'Numéro 2 (Optionnel)';

  @override
  String get step_new_sim_frequent_3 => 'Numéro 3 (Optionnel)';

  @override
  String get step_photo_docs_label => 'Documents d\'identité (Originaux) *';

  @override
  String get step_photo_source_title => 'Sélectionner la Source';

  @override
  String get step_photo_source_camera => 'Caméra';

  @override
  String get step_photo_source_gallery => 'Galerie';

  @override
  String get step_photo_crop_title => 'Ajuster la Photo';

  @override
  String get step_photo_front_title => 'Photo Recto (Face)';

  @override
  String get step_photo_back_title => 'Photo Verso (Dos)';

  @override
  String get step_photo_subtitle_edit => 'Modifier la photo';

  @override
  String get step_photo_subtitle_capture => 'Appuyer pour capturer';

  @override
  String get step_photo_info_note =>
      'Veillez à ce que le document soit bien éclairé et lisible.';
}
