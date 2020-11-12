import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class Notifikacije {
  static void sendNotificationForOneUser({String content, String userId}) async {
    List<String> devicesId = [];
    Firestore.instance
        .collection('/notifications/$userId/device')
        .getDocuments()
        .then((value) async {
      value.documents.forEach((element) {
        devicesId.add(element.data['deviceId']);
      });
      if (devicesId.length != 0) {
        var notification = OSCreateNotification(
          playerIds: devicesId,
          content: content,
          heading: "Imate novu poruku",
        );

        var response = await OneSignal.shared.postNotification(notification);
        print("Sent notification with response: $response");
      }
    });
  }

  static void sendNotificationForManyUsers({String content, List<String> userId}) async {
    userId.forEach((uid) {
      List<String> devicesId = [];
      Firestore.instance
        .collection('/notifications/$uid/device')
        .getDocuments()
        .then((value) async {
          value.documents.forEach((element) {
            devicesId.add(element.data['deviceId']);
          });
      if (devicesId.length != 0) {
        var notification = OSCreateNotification(
          playerIds: devicesId,
          content: content,
          heading: "Imate novu poruku za obred",
        );

        var response = await OneSignal.shared.postNotification(notification);
        print("Sent notification with response: $response");
      }
    });
    });
  }
}