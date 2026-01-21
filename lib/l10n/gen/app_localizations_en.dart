// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splash_subtitle =>
      'CUSTOMER MANAGEMENT AND\nSIM-KYC CARDS\nBACK-OFFICE';

  @override
  String get auth_login_title => 'Login';

  @override
  String get auth_login_subtitle => 'Welcome back!';

  @override
  String get auth_field_phone => 'Phone Number';

  @override
  String get auth_field_password => 'Password';

  @override
  String get auth_button_submit => 'Sign In';

  @override
  String get auth_error_invalid_phone => 'Invalid format (ex: 6XX XX XX XX)';

  @override
  String get auth_forgot_password => 'Forgot password?';

  @override
  String get auth_no_account => 'No account?';

  @override
  String get auth_contact_admin => 'Contact admin';

  @override
  String get home_nav_dashboard => 'Dashboard';

  @override
  String get home_nav_home => 'Home';

  @override
  String get home_nav_history => 'History';

  @override
  String get home_nav_reports => 'Reports';

  @override
  String get home_nav_profile => 'My Profile';

  @override
  String get home_greeting => 'Hello,';

  @override
  String get home_search_hint => 'Search MSISDN...';

  @override
  String get home_action_activation => 'SIM Activation';

  @override
  String get home_desc_activation => 'Activate a new customer SIM';

  @override
  String get home_action_reactivation => 'SIM Reactivation';

  @override
  String get home_desc_reactivation => 'Reactivate dormant numbers';

  @override
  String get home_action_update => 'SIM Update';

  @override
  String get home_desc_update => 'Update SIM information';

  @override
  String get home_section_actions => 'Quick Actions';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_theme_dark => 'Dark Mode';

  @override
  String get settings_language => 'Language';

  @override
  String get history_search_hint => 'Search by name, MSISDN or ID...';

  @override
  String get history_date_all => 'All dates';

  @override
  String history_date_range(Object end, Object start) {
    return 'From $start to $end';
  }

  @override
  String get history_empty => 'No history found';

  @override
  String get history_status_active => 'Active';

  @override
  String get history_status_suspended => 'Suspended';

  @override
  String get history_status_inactive => 'Deactivated';

  @override
  String get history_btn_details => 'Details';

  @override
  String get history_btn_reactivate => 'Reactivate';

  @override
  String get history_btn_update => 'Edit';

  @override
  String get history_dialog_kyc_title => 'KYC Details';

  @override
  String history_dialog_kyc_msg(Object name) {
    return 'Showing data for $name';
  }

  @override
  String history_dialog_reactivate_msg(Object msisdn) {
    return 'Launching for $msisdn';
  }

  @override
  String get reports_title => 'Activity Overview';

  @override
  String get reports_period_today => 'Today';

  @override
  String get reports_period_7d => 'Last 7 days';

  @override
  String get reports_period_30d => 'Last 30 days';

  @override
  String get reports_kpi_activations => 'Activations';

  @override
  String get reports_kpi_reactivations => 'Reactivations';

  @override
  String get reports_kpi_new_customers => 'New Customers';

  @override
  String get reports_section_reason => 'Reactivation by reason';

  @override
  String get reports_reason_customer => 'Customer request';

  @override
  String get reports_reason_sim_change => 'SIM swap';

  @override
  String get reports_reason_tech => 'Technical issue';

  @override
  String get reports_reason_fraud => 'Fraud investigation';

  @override
  String get reports_reason_other => 'Other';

  @override
  String profile_agent_id(Object id) {
    return 'Agent ID: $id';
  }

  @override
  String profile_role(Object role) {
    return 'Role: $role';
  }

  @override
  String get profile_section_app => 'App Settings';

  @override
  String get profile_section_security => 'Security';

  @override
  String get profile_section_about => 'About';

  @override
  String get profile_option_lang => 'Language';

  @override
  String get profile_option_lang_desc => 'French / English';

  @override
  String get profile_option_theme => 'Theme';

  @override
  String get profile_option_theme_desc => 'Light / Dark';

  @override
  String get profile_option_notif => 'Notifications';

  @override
  String get profile_option_notif_desc => 'Manage push alerts';

  @override
  String get profile_option_security_pass => 'Change password / PIN';

  @override
  String get profile_option_security_pass_desc => 'Update your access';

  @override
  String get profile_option_last_login => 'Last Login';

  @override
  String get profile_option_last_login_desc => 'Today, 09:24 · Android';

  @override
  String get profile_option_about_title => 'SIM KYC App';

  @override
  String get profile_option_about_desc => 'Version 1.0.0 · Contact support.';

  @override
  String get profile_logout => 'Logout';

  @override
  String get profile_logout_confirm => 'Log out';

  @override
  String get profile_logout_cancel => 'Cancel';

  @override
  String get profile_logout_dialog_body => 'Are you sure you want to log out?';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_empty_title => 'No notifications';

  @override
  String get notifications_empty_body =>
      'You don\'t have any notifications at the moment.';

  @override
  String get scanner_title => 'Scan SIM Code';

  @override
  String get scanner_hint => 'Place the barcode inside the frame';

  @override
  String get scanner_error => 'Unable to access camera';

  @override
  String get sim_act_title => 'SIM Activation';

  @override
  String get sim_step_1 => 'SIM';

  @override
  String get sim_step_2 => 'Customer';

  @override
  String get sim_step_3 => 'ID';

  @override
  String get sim_step_4 => 'Photos';

  @override
  String get sim_step_5 => 'Check';

  @override
  String get sim_error_serial => 'Serial number is required';

  @override
  String get sim_error_lastname => 'Last name is required';

  @override
  String get sim_error_firstname => 'First name is required';

  @override
  String get sim_error_dob => 'Date of birth is required';

  @override
  String get sim_error_pob => 'Place of birth is required';

  @override
  String get sim_error_id_nature => 'ID type is required';

  @override
  String get sim_error_id_number => 'ID number is required';

  @override
  String get sim_error_id_validity => 'Expiry date is required';

  @override
  String get sim_error_photo_front => 'Front photo is required';

  @override
  String get sim_error_photo_back => 'Back photo is required';

  @override
  String get sim_btn_next => 'NEXT';

  @override
  String get sim_btn_prev => 'BACK';

  @override
  String get sim_btn_submit => 'SUBMIT';

  @override
  String get sim_msg_success_title => 'Activation successful';

  @override
  String get sim_msg_success_body =>
      'The file has been submitted successfully.';

  @override
  String get sim_react_title => 'SIM Reactivation';

  @override
  String get sim_react_step_1 => 'Search';

  @override
  String get sim_react_step_2 => 'Verification';

  @override
  String get sim_react_step_3 => 'Reactivation';

  @override
  String get sim_react_error_title => 'Warning';

  @override
  String get sim_react_error_phone_required => 'Phone number is required';

  @override
  String get sim_react_error_reason_required => 'Please provide the reason';

  @override
  String get sim_react_error_user_not_found =>
      'No user linked to this phone number was found.';

  @override
  String get sim_react_error_new_iccid_required => 'New ICCID is required';

  @override
  String get sim_react_error_frequent1_required => 'Number 1 is required';

  @override
  String get sim_react_success_title => 'Operation successful';

  @override
  String get sim_react_success_body =>
      'The line has been reactivated successfully.';

  @override
  String get sim_update_step_1 => 'Search';

  @override
  String get sim_update_step_2 => 'Edit';

  @override
  String get sim_update_step_3 => 'Update';

  @override
  String get sim_update_btn_search => 'SEARCH';

  @override
  String get sim_update_btn_confirm => 'CONFIRM';

  @override
  String get sim_update_error_title => 'Error';

  @override
  String get sim_update_error_phone_required => 'Phone number is required';

  @override
  String get sim_update_error_geo_required => 'Residential address is required';

  @override
  String get sim_update_error_subscriber_not_found => 'Subscriber not found';

  @override
  String get sim_update_success_title => 'Success';

  @override
  String get sim_update_success_body => 'Profile updated!';

  @override
  String get sim_update_summary_title => 'Update summary';

  @override
  String get sim_update_summary_subtitle =>
      'Review the changes before the final confirmation.';

  @override
  String get check_title => 'Holder Verification';

  @override
  String get check_subtitle =>
      'Confirm this information with the customer present.';

  @override
  String get check_section_line => 'Line to reactivate';

  @override
  String get check_section_identity => 'Subscriber identity';

  @override
  String get check_section_coords => 'Contact details';

  @override
  String get check_section_id => 'Identification document';

  @override
  String get check_label_msisdn => 'Number (MSISDN)';

  @override
  String get check_label_serial => 'Serial number';

  @override
  String get check_label_status => 'Status';

  @override
  String get check_label_name => 'Full name';

  @override
  String get check_label_dob => 'Date of birth';

  @override
  String get check_label_pob => 'Place of birth';

  @override
  String get check_label_gender => 'Gender';

  @override
  String get check_label_job => 'Occupation';

  @override
  String get check_label_address => 'Residential address';

  @override
  String get check_label_post => 'Postal address';

  @override
  String get check_label_email => 'Email';

  @override
  String get check_label_id_nature => 'Type';

  @override
  String get check_label_id_number => 'ID number';

  @override
  String get check_label_id_validity => 'Expiry date';

  @override
  String get check_warning =>
      'The operation must be refused if the above information does not match the presented ID.';

  @override
  String get check_status_unknown => 'Suspended / Lost';

  @override
  String get step_cust_lastname => 'Last name *';

  @override
  String get step_cust_firstname => 'First name(s) *';

  @override
  String get step_cust_dob => 'Date of birth *';

  @override
  String get step_cust_pob => 'Place of birth *';

  @override
  String get step_cust_gender => 'Gender *';

  @override
  String get step_cust_male => 'Male';

  @override
  String get step_cust_female => 'Female';

  @override
  String get step_cust_geo => 'Residential address';

  @override
  String get step_cust_post => 'Postal address';

  @override
  String get step_cust_email => 'Email';

  @override
  String get step_cust_job => 'Occupation';

  @override
  String get step_cust_hint_name => 'e.g.: DJINE';

  @override
  String get step_cust_hint_firstname => 'e.g.: John Silas';

  @override
  String get step_cust_hint_date => 'dd/mm/yyyy';

  @override
  String get step_cust_hint_pob => 'e.g.: Conakry';

  @override
  String get step_cust_hint_geo => 'Neighborhood, Street, Door number';

  @override
  String get step_cust_hint_post => 'P.O. Box, City, Country';

  @override
  String get step_cust_hint_email => 'example@domain.com';

  @override
  String get step_cust_hint_job => 'e.g.: Trader, Student...';

  @override
  String get step_edit_identity_label => 'Identity information *';

  @override
  String get step_edit_complementary_label => 'Additional information';

  @override
  String get step_edit_id_doc_label => 'Identification document *';

  @override
  String get step_edit_nature_label => 'Type *';

  @override
  String get step_edit_id_hint => 'Select an ID document';

  @override
  String get step_edit_id_number_label => 'ID number *';

  @override
  String get step_edit_id_number_hint => 'Enter the document number';

  @override
  String get step_edit_photos_label => 'Photos *';

  @override
  String get step_edit_photo_recto => 'Front (Front side) *';

  @override
  String get step_edit_photo_verso => 'Back (Back side) *';

  @override
  String get step_edit_photo_hint => 'Tap to capture';

  @override
  String get step_edit_date_hint => 'dd/mm/yyyy';

  @override
  String get step_id_validity => 'Expiry date *';

  @override
  String get step_id_nature => 'ID document type *';

  @override
  String get step_id_number => 'ID number *';

  @override
  String get step_id_nature_label => 'ID document type *';

  @override
  String get step_id_nature_hint => 'Select an ID document';

  @override
  String get step_id_number_label => 'ID document number *';

  @override
  String get step_id_number_hint => 'Enter the document number';

  @override
  String get step_id_date_hint => 'dd/mm/yyyy';

  @override
  String get step_sim_serial_label => 'SIM serial number *';

  @override
  String get step_sim_serial_hint => 'Scan or enter the number';

  @override
  String get step_sim_success => 'MSISDN linked successfully';

  @override
  String get step_sim_info => 'The MSISDN will be linked after scanning.';

  @override
  String get step_search_sim_msisdn_label => 'Phone number to reactivate *';

  @override
  String get step_search_sim_msisdn_hint => '6XX XX XX XX';

  @override
  String get step_search_sim_reason_label => 'Reactivation reason *';

  @override
  String get step_search_sim_reason_hint =>
      'Explain why the customer is reactivating the line';

  @override
  String get step_search_sim_info =>
      'Enter the number to identify the subscriber.';

  @override
  String get step_search_sim_user_identified => 'USER IDENTIFIED';

  @override
  String get step_search_update_msisdn_label => 'Subscriber phone number *';

  @override
  String get step_search_update_msisdn_hint => '6XX XX XX XX';

  @override
  String get step_search_update_info =>
      'Enter the full number to load the profile information to edit.';

  @override
  String get step_new_sim_section_title => 'New SIM Card';

  @override
  String get step_new_sim_serial_label => 'New serial number (ICCID) *';

  @override
  String get step_new_sim_serial_hint => 'Scan or enter the ICCID';

  @override
  String get step_new_sim_associated => 'ASSOCIATED NUMBER';

  @override
  String get step_new_sim_frequent_section => 'Check: 3 frequent numbers';

  @override
  String get step_new_sim_frequent_1 => 'Number 1 (Required) *';

  @override
  String get step_new_sim_frequent_2 => 'Number 2 (Optional)';

  @override
  String get step_new_sim_frequent_3 => 'Number 3 (Optional)';

  @override
  String get step_photo_docs_label => 'Identity documents (Originals) *';

  @override
  String get step_photo_source_title => 'Select Source';

  @override
  String get step_photo_source_camera => 'Camera';

  @override
  String get step_photo_source_gallery => 'Gallery';

  @override
  String get step_photo_crop_title => 'Adjust Photo';

  @override
  String get step_photo_front_title => 'Front photo (Front side)';

  @override
  String get step_photo_back_title => 'Back photo (Back side)';

  @override
  String get step_photo_subtitle_edit => 'Edit photo';

  @override
  String get step_photo_subtitle_capture => 'Tap to capture';

  @override
  String get step_photo_info_note =>
      'Make sure the document is well-lit and readable.';
}
