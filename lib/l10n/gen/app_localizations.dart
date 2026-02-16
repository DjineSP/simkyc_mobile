import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @splash_subtitle.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER MANAGEMENT AND\nSIM-KYC CARDS\nBACK-OFFICE'**
  String get splash_subtitle;

  /// No description provided for @auth_login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login_title;

  /// No description provided for @auth_login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get auth_login_subtitle;

  /// No description provided for @auth_field_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_field_login;

  /// No description provided for @auth_field_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get auth_field_phone;

  /// No description provided for @auth_field_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_field_password;

  /// No description provided for @auth_remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get auth_remember_me;

  /// No description provided for @auth_button_submit.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get auth_button_submit;

  /// No description provided for @auth_error_invalid_phone.
  ///
  /// In en, this message translates to:
  /// **'Invalid format (ex: 6XX XX XX XX)'**
  String get auth_error_invalid_phone;

  /// No description provided for @auth_error_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get auth_error_password_required;

  /// No description provided for @auth_error_auth_failed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed.'**
  String get auth_error_auth_failed;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_forgot_password_dialog_body.
  ///
  /// In en, this message translates to:
  /// **'Please contact the admin.'**
  String get auth_forgot_password_dialog_body;

  /// No description provided for @auth_no_account.
  ///
  /// In en, this message translates to:
  /// **'No account?'**
  String get auth_no_account;

  /// No description provided for @auth_contact_admin.
  ///
  /// In en, this message translates to:
  /// **'Contact admin'**
  String get auth_contact_admin;

  /// No description provided for @auth_contact_admin_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get auth_contact_admin_dialog_title;

  /// No description provided for @auth_contact_admin_dialog_body.
  ///
  /// In en, this message translates to:
  /// **'Email: admin@cellcom.cm'**
  String get auth_contact_admin_dialog_body;

  /// No description provided for @auth_footer.
  ///
  /// In en, this message translates to:
  /// **'2026 Cellcom'**
  String get auth_footer;

  /// No description provided for @common_error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error_title;

  /// No description provided for @common_info_title.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get common_info_title;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @op_validate_title.
  ///
  /// In en, this message translates to:
  /// **'Validation required'**
  String get op_validate_title;

  /// No description provided for @op_validate_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a method to continue.'**
  String get op_validate_subtitle;

  /// No description provided for @op_validate_use_biometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get op_validate_use_biometric;

  /// No description provided for @op_validate_use_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get op_validate_use_password;

  /// No description provided for @op_validate_user_not_identified.
  ///
  /// In en, this message translates to:
  /// **'User not identified.'**
  String get op_validate_user_not_identified;

  /// No description provided for @op_validate_biometric_failed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed or was cancelled.'**
  String get op_validate_biometric_failed;

  /// No description provided for @home_nav_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get home_nav_dashboard;

  /// No description provided for @home_nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_nav_home;

  /// No description provided for @home_nav_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get home_nav_history;

  /// No description provided for @home_nav_reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get home_nav_reports;

  /// No description provided for @home_nav_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get home_nav_profile;

  /// No description provided for @home_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get home_greeting;

  /// No description provided for @home_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search MSISDN...'**
  String get home_search_hint;

  /// No description provided for @home_action_activation.
  ///
  /// In en, this message translates to:
  /// **'SIM Activation'**
  String get home_action_activation;

  /// No description provided for @home_desc_activation.
  ///
  /// In en, this message translates to:
  /// **'Activate a new customer SIM'**
  String get home_desc_activation;

  /// No description provided for @home_action_reactivation.
  ///
  /// In en, this message translates to:
  /// **'SIM Reactivation'**
  String get home_action_reactivation;

  /// No description provided for @home_desc_reactivation.
  ///
  /// In en, this message translates to:
  /// **'Reactivate dormant numbers'**
  String get home_desc_reactivation;

  /// No description provided for @home_action_update.
  ///
  /// In en, this message translates to:
  /// **'SIM Update'**
  String get home_action_update;

  /// No description provided for @home_desc_update.
  ///
  /// In en, this message translates to:
  /// **'Update SIM information'**
  String get home_desc_update;

  /// No description provided for @home_section_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get home_section_actions;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_theme_dark;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @history_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, MSISDN or ID...'**
  String get history_search_hint;

  /// No description provided for @history_date_all.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get history_date_all;

  /// No description provided for @history_date_range.
  ///
  /// In en, this message translates to:
  /// **'From {start} to {end}'**
  String history_date_range(Object end, Object start);

  /// No description provided for @history_empty.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get history_empty;

  /// No description provided for @history_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get history_status_active;

  /// No description provided for @history_status_suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get history_status_suspended;

  /// No description provided for @history_status_inactive.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get history_status_inactive;

  /// No description provided for @history_btn_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get history_btn_details;

  /// No description provided for @history_btn_reactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get history_btn_reactivate;

  /// No description provided for @history_btn_update.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get history_btn_update;

  /// No description provided for @history_dialog_kyc_title.
  ///
  /// In en, this message translates to:
  /// **'KYC Details'**
  String get history_dialog_kyc_title;

  /// No description provided for @history_dialog_kyc_msg.
  ///
  /// In en, this message translates to:
  /// **'Showing data for {name}'**
  String history_dialog_kyc_msg(Object name);

  /// No description provided for @history_dialog_reactivate_msg.
  ///
  /// In en, this message translates to:
  /// **'Launching for {msisdn}'**
  String history_dialog_reactivate_msg(Object msisdn);

  /// No description provided for @reports_title.
  ///
  /// In en, this message translates to:
  /// **'Activity Overview'**
  String get reports_title;

  /// No description provided for @reports_period_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reports_period_today;

  /// No description provided for @reports_period_7d.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get reports_period_7d;

  /// No description provided for @reports_period_30d.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get reports_period_30d;

  /// No description provided for @reports_kpi_activations.
  ///
  /// In en, this message translates to:
  /// **'Activations'**
  String get reports_kpi_activations;

  /// No description provided for @reports_kpi_reactivations.
  ///
  /// In en, this message translates to:
  /// **'Reactivations'**
  String get reports_kpi_reactivations;

  /// No description provided for @reports_kpi_updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get reports_kpi_updates;

  /// No description provided for @reports_section_reason.
  ///
  /// In en, this message translates to:
  /// **'Reactivation by reason'**
  String get reports_section_reason;

  /// No description provided for @reports_reason_customer.
  ///
  /// In en, this message translates to:
  /// **'Customer request'**
  String get reports_reason_customer;

  /// No description provided for @reports_reason_sim_change.
  ///
  /// In en, this message translates to:
  /// **'SIM swap'**
  String get reports_reason_sim_change;

  /// No description provided for @reports_reason_tech.
  ///
  /// In en, this message translates to:
  /// **'Technical issue'**
  String get reports_reason_tech;

  /// No description provided for @reports_reason_fraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud investigation'**
  String get reports_reason_fraud;

  /// No description provided for @reports_reason_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reports_reason_other;

  /// No description provided for @profile_agent_id.
  ///
  /// In en, this message translates to:
  /// **'Agent ID: {id}'**
  String profile_agent_id(Object id);

  /// No description provided for @profile_role.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String profile_role(Object role);

  /// No description provided for @profile_section_app.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get profile_section_app;

  /// No description provided for @profile_section_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profile_section_security;

  /// No description provided for @profile_section_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profile_section_about;

  /// No description provided for @profile_option_lang.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_option_lang;

  /// No description provided for @profile_option_lang_desc.
  ///
  /// In en, this message translates to:
  /// **'French / English'**
  String get profile_option_lang_desc;

  /// No description provided for @profile_option_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profile_option_theme;

  /// No description provided for @profile_option_theme_desc.
  ///
  /// In en, this message translates to:
  /// **'Light / Dark'**
  String get profile_option_theme_desc;

  /// No description provided for @profile_option_notif.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profile_option_notif;

  /// No description provided for @profile_option_notif_desc.
  ///
  /// In en, this message translates to:
  /// **'Manage push alerts'**
  String get profile_option_notif_desc;

  /// No description provided for @profile_option_security_pass.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profile_option_security_pass;

  /// No description provided for @profile_option_security_pass_desc.
  ///
  /// In en, this message translates to:
  /// **'Update your access'**
  String get profile_option_security_pass_desc;

  /// No description provided for @profile_option_last_login.
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get profile_option_last_login;

  /// No description provided for @profile_option_last_login_desc.
  ///
  /// In en, this message translates to:
  /// **'Today, 09:24 · Android'**
  String get profile_option_last_login_desc;

  /// No description provided for @profile_option_about_title.
  ///
  /// In en, this message translates to:
  /// **'SIM KYC App'**
  String get profile_option_about_title;

  /// No description provided for @profile_option_about_desc.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 · Contact support.'**
  String get profile_option_about_desc;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profile_logout_confirm;

  /// No description provided for @profile_logout_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profile_logout_cancel;

  /// No description provided for @profile_logout_dialog_body.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profile_logout_dialog_body;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notifications_empty_title;

  /// No description provided for @notifications_empty_body.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any notifications at the moment.'**
  String get notifications_empty_body;

  /// No description provided for @scanner_title.
  ///
  /// In en, this message translates to:
  /// **'Scan SIM Code'**
  String get scanner_title;

  /// No description provided for @scanner_hint.
  ///
  /// In en, this message translates to:
  /// **'Place the barcode inside the frame'**
  String get scanner_hint;

  /// No description provided for @scanner_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to access camera'**
  String get scanner_error;

  /// No description provided for @sim_act_title.
  ///
  /// In en, this message translates to:
  /// **'SIM Activation'**
  String get sim_act_title;

  /// No description provided for @sim_step_1.
  ///
  /// In en, this message translates to:
  /// **'SIM'**
  String get sim_step_1;

  /// No description provided for @sim_step_2.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get sim_step_2;

  /// No description provided for @sim_step_3.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get sim_step_3;

  /// No description provided for @sim_step_4.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get sim_step_4;

  /// No description provided for @sim_step_5.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get sim_step_5;

  /// No description provided for @sim_error_serial.
  ///
  /// In en, this message translates to:
  /// **'Serial number is required'**
  String get sim_error_serial;

  /// No description provided for @sim_error_lastname.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get sim_error_lastname;

  /// No description provided for @sim_error_firstname.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get sim_error_firstname;

  /// No description provided for @sim_error_dob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get sim_error_dob;

  /// No description provided for @sim_error_pob.
  ///
  /// In en, this message translates to:
  /// **'Place of birth is required'**
  String get sim_error_pob;

  /// No description provided for @sim_error_id_nature.
  ///
  /// In en, this message translates to:
  /// **'ID type is required'**
  String get sim_error_id_nature;

  /// No description provided for @sim_error_id_number.
  ///
  /// In en, this message translates to:
  /// **'ID number is required'**
  String get sim_error_id_number;

  /// No description provided for @sim_error_id_validity.
  ///
  /// In en, this message translates to:
  /// **'Expiry date is required'**
  String get sim_error_id_validity;

  /// No description provided for @sim_error_photo_front.
  ///
  /// In en, this message translates to:
  /// **'Front photo is required'**
  String get sim_error_photo_front;

  /// No description provided for @sim_error_photo_back.
  ///
  /// In en, this message translates to:
  /// **'Back photo is required'**
  String get sim_error_photo_back;

  /// No description provided for @sim_btn_next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get sim_btn_next;

  /// No description provided for @sim_btn_prev.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get sim_btn_prev;

  /// No description provided for @sim_btn_submit.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get sim_btn_submit;

  /// No description provided for @sim_msg_success_title.
  ///
  /// In en, this message translates to:
  /// **'Activation successful'**
  String get sim_msg_success_title;

  /// No description provided for @sim_msg_success_body.
  ///
  /// In en, this message translates to:
  /// **'The file has been submitted successfully.'**
  String get sim_msg_success_body;

  /// No description provided for @sim_react_title.
  ///
  /// In en, this message translates to:
  /// **'SIM Reactivation'**
  String get sim_react_title;

  /// No description provided for @sim_react_step_1.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get sim_react_step_1;

  /// No description provided for @sim_react_step_2.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get sim_react_step_2;

  /// No description provided for @sim_react_step_3.
  ///
  /// In en, this message translates to:
  /// **'Reactivation'**
  String get sim_react_step_3;

  /// No description provided for @sim_react_error_title.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get sim_react_error_title;

  /// No description provided for @sim_react_error_phone_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get sim_react_error_phone_required;

  /// No description provided for @sim_react_error_reason_required.
  ///
  /// In en, this message translates to:
  /// **'Please provide the reason'**
  String get sim_react_error_reason_required;

  /// No description provided for @sim_react_error_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'No user linked to this phone number was found.'**
  String get sim_react_error_user_not_found;

  /// No description provided for @sim_react_error_new_iccid_required.
  ///
  /// In en, this message translates to:
  /// **'New ICCID is required'**
  String get sim_react_error_new_iccid_required;

  /// No description provided for @sim_react_error_frequent1_required.
  ///
  /// In en, this message translates to:
  /// **'Number 1 is required'**
  String get sim_react_error_frequent1_required;

  /// No description provided for @sim_react_success_title.
  ///
  /// In en, this message translates to:
  /// **'Operation successful'**
  String get sim_react_success_title;

  /// No description provided for @sim_react_success_body.
  ///
  /// In en, this message translates to:
  /// **'The line has been reactivated successfully.'**
  String get sim_react_success_body;

  /// No description provided for @sim_update_step_1.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get sim_update_step_1;

  /// No description provided for @sim_update_step_2.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get sim_update_step_2;

  /// No description provided for @sim_update_step_3.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get sim_update_step_3;

  /// No description provided for @sim_update_btn_search.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get sim_update_btn_search;

  /// No description provided for @sim_update_btn_confirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get sim_update_btn_confirm;

  /// No description provided for @sim_update_error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get sim_update_error_title;

  /// No description provided for @sim_update_error_phone_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get sim_update_error_phone_required;

  /// No description provided for @sim_update_error_geo_required.
  ///
  /// In en, this message translates to:
  /// **'Residential address is required'**
  String get sim_update_error_geo_required;

  /// No description provided for @sim_update_error_subscriber_not_found.
  ///
  /// In en, this message translates to:
  /// **'Subscriber not found'**
  String get sim_update_error_subscriber_not_found;

  /// No description provided for @sim_update_success_title.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get sim_update_success_title;

  /// No description provided for @sim_update_success_body.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get sim_update_success_body;

  /// No description provided for @sim_update_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Update summary'**
  String get sim_update_summary_title;

  /// No description provided for @sim_update_summary_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the changes before the final confirmation.'**
  String get sim_update_summary_subtitle;

  /// No description provided for @check_title.
  ///
  /// In en, this message translates to:
  /// **'Holder Verification'**
  String get check_title;

  /// No description provided for @check_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm this information with the customer present.'**
  String get check_subtitle;

  /// No description provided for @check_section_line.
  ///
  /// In en, this message translates to:
  /// **'Line to reactivate'**
  String get check_section_line;

  /// No description provided for @check_section_identity.
  ///
  /// In en, this message translates to:
  /// **'Subscriber identity'**
  String get check_section_identity;

  /// No description provided for @check_section_coords.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get check_section_coords;

  /// No description provided for @check_section_id.
  ///
  /// In en, this message translates to:
  /// **'Identification document'**
  String get check_section_id;

  /// No description provided for @check_label_msisdn.
  ///
  /// In en, this message translates to:
  /// **'Number (MSISDN)'**
  String get check_label_msisdn;

  /// No description provided for @check_label_serial.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get check_label_serial;

  /// No description provided for @check_label_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get check_label_status;

  /// No description provided for @check_label_name.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get check_label_name;

  /// No description provided for @check_label_dob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get check_label_dob;

  /// No description provided for @check_label_pob.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get check_label_pob;

  /// No description provided for @check_label_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get check_label_gender;

  /// No description provided for @check_label_job.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get check_label_job;

  /// No description provided for @check_label_address.
  ///
  /// In en, this message translates to:
  /// **'Residential address'**
  String get check_label_address;

  /// No description provided for @check_label_post.
  ///
  /// In en, this message translates to:
  /// **'Postal address'**
  String get check_label_post;

  /// No description provided for @check_label_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get check_label_email;

  /// No description provided for @check_label_id_nature.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get check_label_id_nature;

  /// No description provided for @check_label_id_number.
  ///
  /// In en, this message translates to:
  /// **'ID number'**
  String get check_label_id_number;

  /// No description provided for @check_label_id_validity.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get check_label_id_validity;

  /// No description provided for @check_warning.
  ///
  /// In en, this message translates to:
  /// **'The operation must be refused if the above information does not match the presented ID.'**
  String get check_warning;

  /// No description provided for @check_status_unknown.
  ///
  /// In en, this message translates to:
  /// **'Suspended / Lost'**
  String get check_status_unknown;

  /// No description provided for @step_cust_lastname.
  ///
  /// In en, this message translates to:
  /// **'Last name *'**
  String get step_cust_lastname;

  /// No description provided for @step_cust_firstname.
  ///
  /// In en, this message translates to:
  /// **'First name(s) *'**
  String get step_cust_firstname;

  /// No description provided for @step_cust_dob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth *'**
  String get step_cust_dob;

  /// No description provided for @step_cust_pob.
  ///
  /// In en, this message translates to:
  /// **'Place of birth *'**
  String get step_cust_pob;

  /// No description provided for @step_cust_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender *'**
  String get step_cust_gender;

  /// No description provided for @step_cust_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get step_cust_male;

  /// No description provided for @step_cust_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get step_cust_female;

  /// No description provided for @step_cust_geo.
  ///
  /// In en, this message translates to:
  /// **'Residential address'**
  String get step_cust_geo;

  /// No description provided for @step_cust_post.
  ///
  /// In en, this message translates to:
  /// **'Postal address'**
  String get step_cust_post;

  /// No description provided for @step_cust_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get step_cust_email;

  /// No description provided for @step_cust_job.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get step_cust_job;

  /// No description provided for @step_cust_hint_name.
  ///
  /// In en, this message translates to:
  /// **'e.g.: DJINE'**
  String get step_cust_hint_name;

  /// No description provided for @step_cust_hint_firstname.
  ///
  /// In en, this message translates to:
  /// **'e.g.: John Silas'**
  String get step_cust_hint_firstname;

  /// No description provided for @step_cust_hint_date.
  ///
  /// In en, this message translates to:
  /// **'dd/mm/yyyy'**
  String get step_cust_hint_date;

  /// No description provided for @step_cust_hint_pob.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Conakry'**
  String get step_cust_hint_pob;

  /// No description provided for @step_cust_hint_geo.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood, Street, Door number'**
  String get step_cust_hint_geo;

  /// No description provided for @step_cust_hint_post.
  ///
  /// In en, this message translates to:
  /// **'P.O. Box, City, Country'**
  String get step_cust_hint_post;

  /// No description provided for @step_cust_hint_email.
  ///
  /// In en, this message translates to:
  /// **'example@domain.com'**
  String get step_cust_hint_email;

  /// No description provided for @step_cust_hint_job.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Trader, Student...'**
  String get step_cust_hint_job;

  /// No description provided for @step_edit_identity_label.
  ///
  /// In en, this message translates to:
  /// **'Identity information *'**
  String get step_edit_identity_label;

  /// No description provided for @step_edit_complementary_label.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get step_edit_complementary_label;

  /// No description provided for @step_edit_id_doc_label.
  ///
  /// In en, this message translates to:
  /// **'Identification document *'**
  String get step_edit_id_doc_label;

  /// No description provided for @step_edit_nature_label.
  ///
  /// In en, this message translates to:
  /// **'Type *'**
  String get step_edit_nature_label;

  /// No description provided for @step_edit_id_hint.
  ///
  /// In en, this message translates to:
  /// **'Select an ID document'**
  String get step_edit_id_hint;

  /// No description provided for @step_edit_id_number_label.
  ///
  /// In en, this message translates to:
  /// **'ID number *'**
  String get step_edit_id_number_label;

  /// No description provided for @step_edit_id_number_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the document number'**
  String get step_edit_id_number_hint;

  /// No description provided for @step_edit_photos_label.
  ///
  /// In en, this message translates to:
  /// **'Photos *'**
  String get step_edit_photos_label;

  /// No description provided for @step_edit_photo_recto.
  ///
  /// In en, this message translates to:
  /// **'Front (Front side) *'**
  String get step_edit_photo_recto;

  /// No description provided for @step_edit_photo_verso.
  ///
  /// In en, this message translates to:
  /// **'Back (Back side) *'**
  String get step_edit_photo_verso;

  /// No description provided for @step_edit_photo_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap to capture'**
  String get step_edit_photo_hint;

  /// No description provided for @step_edit_date_hint.
  ///
  /// In en, this message translates to:
  /// **'dd/mm/yyyy'**
  String get step_edit_date_hint;

  /// No description provided for @step_id_validity.
  ///
  /// In en, this message translates to:
  /// **'Expiry date *'**
  String get step_id_validity;

  /// No description provided for @step_id_nature.
  ///
  /// In en, this message translates to:
  /// **'ID document type *'**
  String get step_id_nature;

  /// No description provided for @step_id_number.
  ///
  /// In en, this message translates to:
  /// **'ID number *'**
  String get step_id_number;

  /// No description provided for @step_id_nature_label.
  ///
  /// In en, this message translates to:
  /// **'ID document type *'**
  String get step_id_nature_label;

  /// No description provided for @step_id_nature_hint.
  ///
  /// In en, this message translates to:
  /// **'Select an ID document'**
  String get step_id_nature_hint;

  /// No description provided for @step_id_number_label.
  ///
  /// In en, this message translates to:
  /// **'ID document number *'**
  String get step_id_number_label;

  /// No description provided for @step_id_number_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the document number'**
  String get step_id_number_hint;

  /// No description provided for @step_id_date_hint.
  ///
  /// In en, this message translates to:
  /// **'dd/mm/yyyy'**
  String get step_id_date_hint;

  /// No description provided for @step_sim_serial_label.
  ///
  /// In en, this message translates to:
  /// **'SIM serial number *'**
  String get step_sim_serial_label;

  /// No description provided for @step_sim_serial_hint.
  ///
  /// In en, this message translates to:
  /// **'Scan or enter the number'**
  String get step_sim_serial_hint;

  /// No description provided for @step_sim_success.
  ///
  /// In en, this message translates to:
  /// **'MSISDN linked successfully'**
  String get step_sim_success;

  /// No description provided for @step_sim_info.
  ///
  /// In en, this message translates to:
  /// **'The MSISDN will be linked after scanning.'**
  String get step_sim_info;

  /// No description provided for @step_search_sim_msisdn_label.
  ///
  /// In en, this message translates to:
  /// **'Phone number to reactivate *'**
  String get step_search_sim_msisdn_label;

  /// No description provided for @step_search_sim_msisdn_hint.
  ///
  /// In en, this message translates to:
  /// **'6XX XX XX XX'**
  String get step_search_sim_msisdn_hint;

  /// No description provided for @step_search_sim_reason_label.
  ///
  /// In en, this message translates to:
  /// **'Reactivation reason *'**
  String get step_search_sim_reason_label;

  /// No description provided for @step_search_sim_reason_hint.
  ///
  /// In en, this message translates to:
  /// **'Explain why the customer is reactivating the line'**
  String get step_search_sim_reason_hint;

  /// No description provided for @step_search_sim_info.
  ///
  /// In en, this message translates to:
  /// **'Enter the number to identify the subscriber.'**
  String get step_search_sim_info;

  /// No description provided for @step_search_sim_user_identified.
  ///
  /// In en, this message translates to:
  /// **'USER IDENTIFIED'**
  String get step_search_sim_user_identified;

  /// No description provided for @step_search_update_msisdn_label.
  ///
  /// In en, this message translates to:
  /// **'Subscriber phone number *'**
  String get step_search_update_msisdn_label;

  /// No description provided for @step_search_update_msisdn_hint.
  ///
  /// In en, this message translates to:
  /// **'6XX XX XX XX'**
  String get step_search_update_msisdn_hint;

  /// No description provided for @step_search_update_info.
  ///
  /// In en, this message translates to:
  /// **'Enter the full number to load the profile information to edit.'**
  String get step_search_update_info;

  /// No description provided for @step_new_sim_section_title.
  ///
  /// In en, this message translates to:
  /// **'New SIM Card'**
  String get step_new_sim_section_title;

  /// No description provided for @step_new_sim_serial_label.
  ///
  /// In en, this message translates to:
  /// **'New serial number (ICCID) *'**
  String get step_new_sim_serial_label;

  /// No description provided for @step_new_sim_serial_hint.
  ///
  /// In en, this message translates to:
  /// **'Scan or enter the ICCID'**
  String get step_new_sim_serial_hint;

  /// No description provided for @step_new_sim_associated.
  ///
  /// In en, this message translates to:
  /// **'ASSOCIATED NUMBER'**
  String get step_new_sim_associated;

  /// No description provided for @step_new_sim_frequent_section.
  ///
  /// In en, this message translates to:
  /// **'Check: 3 frequent numbers'**
  String get step_new_sim_frequent_section;

  /// No description provided for @step_new_sim_frequent_1.
  ///
  /// In en, this message translates to:
  /// **'Number 1 (Required) *'**
  String get step_new_sim_frequent_1;

  /// No description provided for @step_new_sim_frequent_2.
  ///
  /// In en, this message translates to:
  /// **'Number 2 (Optional)'**
  String get step_new_sim_frequent_2;

  /// No description provided for @step_new_sim_frequent_3.
  ///
  /// In en, this message translates to:
  /// **'Number 3 (Optional)'**
  String get step_new_sim_frequent_3;

  /// No description provided for @step_photo_docs_label.
  ///
  /// In en, this message translates to:
  /// **'Identity documents (Originals) *'**
  String get step_photo_docs_label;

  /// No description provided for @step_photo_source_title.
  ///
  /// In en, this message translates to:
  /// **'Select Source'**
  String get step_photo_source_title;

  /// No description provided for @step_photo_source_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get step_photo_source_camera;

  /// No description provided for @step_photo_source_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get step_photo_source_gallery;

  /// No description provided for @step_photo_crop_title.
  ///
  /// In en, this message translates to:
  /// **'Adjust Photo'**
  String get step_photo_crop_title;

  /// No description provided for @step_photo_front_title.
  ///
  /// In en, this message translates to:
  /// **'Front photo (Front side)'**
  String get step_photo_front_title;

  /// No description provided for @step_photo_back_title.
  ///
  /// In en, this message translates to:
  /// **'Back photo (Back side)'**
  String get step_photo_back_title;

  /// No description provided for @step_photo_subtitle_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get step_photo_subtitle_edit;

  /// No description provided for @step_photo_subtitle_capture.
  ///
  /// In en, this message translates to:
  /// **'Tap to capture'**
  String get step_photo_subtitle_capture;

  /// No description provided for @step_photo_info_note.
  ///
  /// In en, this message translates to:
  /// **'Make sure the document is well-lit and readable.'**
  String get step_photo_info_note;

  /// No description provided for @history_detail_title_client.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER INFO'**
  String get history_detail_title_client;

  /// No description provided for @history_detail_title_coords.
  ///
  /// In en, this message translates to:
  /// **'CONTACT DETAILS'**
  String get history_detail_title_coords;

  /// No description provided for @history_detail_title_id.
  ///
  /// In en, this message translates to:
  /// **'IDENTITY DOCUMENT'**
  String get history_detail_title_id;

  /// No description provided for @history_detail_title_op.
  ///
  /// In en, this message translates to:
  /// **'OPERATION DETAILS'**
  String get history_detail_title_op;

  /// No description provided for @history_detail_label_fullname.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get history_detail_label_fullname;

  /// No description provided for @history_detail_label_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get history_detail_label_gender;

  /// No description provided for @history_detail_value_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get history_detail_value_male;

  /// No description provided for @history_detail_value_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get history_detail_value_female;

  /// No description provided for @history_detail_label_dob.
  ///
  /// In en, this message translates to:
  /// **'Born on'**
  String get history_detail_label_dob;

  /// No description provided for @history_detail_label_pob.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get history_detail_label_pob;

  /// No description provided for @history_detail_label_job.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get history_detail_label_job;

  /// No description provided for @history_detail_label_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get history_detail_label_phone;

  /// No description provided for @history_detail_label_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get history_detail_label_email;

  /// No description provided for @history_detail_label_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get history_detail_label_address;

  /// No description provided for @history_detail_label_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get history_detail_label_location;

  /// No description provided for @history_detail_label_id_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get history_detail_label_id_type;

  /// No description provided for @history_detail_label_id_number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get history_detail_label_id_number;

  /// No description provided for @history_detail_label_id_expire.
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get history_detail_label_id_expire;

  /// No description provided for @history_detail_label_op_id.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get history_detail_label_op_id;

  /// No description provided for @history_detail_label_op_target.
  ///
  /// In en, this message translates to:
  /// **'Target MSISDN'**
  String get history_detail_label_op_target;

  /// No description provided for @history_detail_label_op_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get history_detail_label_op_date;

  /// No description provided for @history_detail_label_op_agent.
  ///
  /// In en, this message translates to:
  /// **'Operator (ID)'**
  String get history_detail_label_op_agent;

  /// No description provided for @history_detail_value_unspecified.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get history_detail_value_unspecified;

  /// No description provided for @history_detail_error_load.
  ///
  /// In en, this message translates to:
  /// **'Unable to load details.'**
  String get history_detail_error_load;

  /// No description provided for @history_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get history_filter_all;

  /// No description provided for @history_filter_activation.
  ///
  /// In en, this message translates to:
  /// **'Activation'**
  String get history_filter_activation;

  /// No description provided for @history_filter_reactivation.
  ///
  /// In en, this message translates to:
  /// **'Reactivation'**
  String get history_filter_reactivation;

  /// No description provided for @history_filter_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get history_filter_update;

  /// No description provided for @history_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get history_status_pending;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
