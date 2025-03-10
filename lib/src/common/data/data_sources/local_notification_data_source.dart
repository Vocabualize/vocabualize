import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:log/log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vocabualize/constants/common_constants.dart';
import 'package:vocabualize/constants/global.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/language_extensions.dart';

final localNotificationDataSourceProvider = Provider((ref) {
  return LocalNotificationDataSource();
});

class LocalNotificationDataSource {
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _practiceNotificationId = 1;
  final _gatherNotificationId = 2;

  Future<void> init() async {
    const androidInitializationSettings = AndroidInitializationSettings("ic_notification");
    const darwinInitializationSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );
    await _requestPermissions();
    await _initTimeZone();
    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> _requestPermissions() async {
    try {
      if (await Permission.notification.isDenied) {
        final hasGranted = await Permission.notification.request().isGranted;
        Log.hint(
          "Notification permission has been ${hasGranted ? "granted" : "denied"}.",
        );
      }
      if (!(await Permission.scheduleExactAlarm.isGranted)) {
        final hasGranted = await Permission.scheduleExactAlarm.request().isGranted;
        Log.hint(
          "Schedule exact alarm permission has been ${hasGranted ? "granted" : "denied"}.",
        );
      }
    } on PlatformException catch (e) {
      Log.error("Failed to request permissions", exception: e);
    }
  }

  Future<void> _initTimeZone() async {
    tz.initializeTimeZones();
    final locationName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(locationName));
  }

  void schedulePracticeNotification({
    required TimeOfDay time,
    int? numberOfVocabularies,
  }) async {
    await _localNotifications.cancel(_practiceNotificationId);
    // * Notification will always be shown, currently, since we can't check due vocabularies rn
    // if (numberOfVocabularies == null || numberOfVocabularies <= 1) {
    //   Log.warning(
    //     "Not scheduling practice notification because there are no vocabularies to practice.",
    //   );
    //   return;
    // }
    if (!Global.context.mounted) return;
    await _scheduleLocalNotification(
      id: _practiceNotificationId,
      channelId: "practice_notification",
      channelName: Global.context.s.notification_channel_name_practice,
      channelDescription: Global.context.s.notification_channel_description_practice,
      title: Global.context.s.notification_practice_title,
      body: Global.context.s.notification_practice_body,
      time: time,
    );
    Log.hint(
      "Schedule practice notification at $time with $numberOfVocabularies vocabularies.",
    );
  }

  void scheduleGatherNotification({
    required TimeOfDay time,
    required Language targetLanguage,
  }) async {
    await _localNotifications.cancel(_gatherNotificationId);
    if (!Global.context.mounted) return;
    await _scheduleLocalNotification(
      id: _gatherNotificationId,
      time: time,
      channelId: "gather_notification",
      channelName: Global.context.s.notification_channel_name_gather,
      channelDescription: Global.context.s.notification_channel_description_gather,
      title: Global.context.s.notification_gather_title,
      body: Global.context.s.notification_gather_body(targetLanguage.localName(Global.context)),
    );
    Log.hint("Schedule gather notification at $time for ${targetLanguage.name}.");
  }

  Future<void> _scheduleLocalNotification({
    required int id,
    required TimeOfDay time,
    required String channelId,
    required String channelName,
    String? channelDescription,
    String? title = CommonConstants.appName,
    String? body,
    String? payload,
  }) async {
    final now = DateTime.now();
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    try {
      return await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate.isBefore(now) ? scheduledDate.add(const Duration(days: 1)) : scheduledDate,
        _getLocalNotificationDetails(channelId, channelName, channelDescription),
        payload: payload,
        androidScheduleMode:
            kDebugMode ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      Log.error("Failed to schedule local notification", exception: e);
    }
  }

  // TODO: Is this in use?
  Future<void> showLocalNotification({
    int id = 0,
    String? title = CommonConstants.appName,
    String? body,
    String? payload,
  }) async {
    return await _localNotifications.show(
      id,
      title,
      body,
      _getLocalNotificationDetails(
        "general_notification",
        "General",
        null,
      ),
      payload: payload,
    );
  }

  NotificationDetails _getLocalNotificationDetails(
    String channelId,
    String channelName,
    String? channelDescription,
  ) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }
}
