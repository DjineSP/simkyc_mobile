import 'dart:async';

import '../models/notification_item.dart';

class NotificationRepository {
  Future<List<NotificationItem>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 250));

    final now = DateTime.now();

    final items = <NotificationItem>[
      NotificationItem(
        id: 'notif_1',
        title: 'Activation SIM réussie',
        body: 'La SIM a été activée avec succès et le dossier KYC a été enregistré.',
        createdAt: now.subtract(const Duration(minutes: 6)),
        type: NotificationType.success,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_2',
        title: 'KYC en attente de validation',
        body: 'Un dossier KYC nécessite une validation Back Office.',
        createdAt: now.subtract(const Duration(minutes: 18)),
        type: NotificationType.warning,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_3',
        title: 'Authentification biométrique activée',
        body: 'La connexion nécessitera désormais une empreinte/FaceID sur cet appareil.',
        createdAt: now.subtract(const Duration(minutes: 44)),
        type: NotificationType.info,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_4',
        title: 'Réactivation SIM',
        body: 'La demande de réactivation a été soumise et sera traitée sous peu.',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 5)),
        type: NotificationType.info,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_5',
        title: 'Échec de synchronisation',
        body: 'Impossible de synchroniser certaines données. Vérifiez votre connexion internet.',
        createdAt: now.subtract(const Duration(hours: 3, minutes: 20)),
        type: NotificationType.error,
        isRead: true,
      ),
      NotificationItem(
        id: 'notif_6',
        title: 'Mise à jour SIM effectuée',
        body: 'Les informations de la SIM ont été mises à jour avec succès.',
        createdAt: now.subtract(const Duration(hours: 6)),
        type: NotificationType.success,
        isRead: true,
      ),
      NotificationItem(
        id: 'notif_7',
        title: 'Connexion détectée',
        body: 'Une connexion à votre session a été enregistrée.',
        createdAt: now.subtract(const Duration(hours: 8, minutes: 30)),
        type: NotificationType.info,
        isRead: true,
      ),
      NotificationItem(
        id: 'notif_8',
        title: 'Rapports disponibles',
        body: 'Les statistiques de la journée sont disponibles dans la section Rapports.',
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
        type: NotificationType.info,
        isRead: true,
      ),
      NotificationItem(
        id: 'notif_9',
        title: 'Suspicion de fraude',
        body: 'Une tentative de validation a été signalée. Veuillez vérifier le dossier.',
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
        type: NotificationType.warning,
        isRead: true,
      ),
      NotificationItem(
        id: 'notif_10',
        title: 'Session expirée',
        body: 'Votre session a expiré. Veuillez vous reconnecter.',
        createdAt: now.subtract(const Duration(days: 2)),
        type: NotificationType.error,
        isRead: true,
      ),
      NotificationItem(
        id: 'notif_11',
        title: 'SIM suspendue',
        body: 'Une SIM a été suspendue suite à une règle de conformité.',
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
        type: NotificationType.warning,
        isRead: true,
      ),
      NotificationItem(
        id: 'notif_12',
        title: 'Sauvegarde locale',
        body: 'Les préférences (langue/thème) ont été enregistrées sur l’appareil.',
        createdAt: now.subtract(const Duration(days: 5)),
        type: NotificationType.info,
        isRead: true,
      ),
    ];

    return items;
  }
}
