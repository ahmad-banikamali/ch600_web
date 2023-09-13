import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ch600/data/models/alarm.dart';
import 'package:ch600/data/models/device.dart';
import 'package:ch600/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DeviceAdapter());
  Hive.registerAdapter(AlarmAdapter());
  await Hive.openBox<Device>(DbConstants.deviceDB);
  await Hive.openBox<Alarm>(DbConstants.alarmDB);
  await Hive.openBox(DbConstants.etcDB);
}

void closeKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

bool isPhoneNumberValid(String value) {
  return true;
}

var remainedTime = 10;
var isTimerActive = false;
late Timer timer;

extension ExtendedState on State {
  Future pushScreen(Widget route) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (c) => route));
  }

  void popScreen() {
    Navigator.pop(context);
  }

  void replaceScreen(Widget route) {
    popScreen();
    pushScreen(route);
  }

  void handleSendMessage(String codeToSend, Device? device, isClicked,
      void Function(bool) onClick) {
    if (device == null) {
      showSnackBar('ابتدا یک دستگاه تعریف کنید');
      return;
    }
    if (isClicked) {
      showSnackBar("$remainedTime ثانیه دیگر دستور را ارسال نمائید");
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("آیا از ارسال دستور مطمئن هستید ؟",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.black)),
            actions: [
              TextButton(
                onPressed: () {
                  popScreen();
                },
                // function used to perform after pressing the button
                child: Text('بی خیال',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  sendMessage(codeToSend, device, () {
                    showSnackBar('پیام با موفقیت ارسال شد');
                  });
                  calculateRemainedTime();
                  Future.delayed(const Duration(milliseconds: 10000), () {
                    onClick(false);
                  });
                  popScreen();
                  onClick(true);
                },
                child: Text('تایید',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.green)),
              ),
            ],
          );
        });
  }


  exitApp() {
    var exitDialog = showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
                "لطفا از دکمه خروج گوشی (back) برای خروج از برنامه استفاده کنید.",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.black)),
          );
        });
    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (ModalRoute.of(context)?.isCurrent==true) {
        popScreen();
      }
    });
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    var snackBar = SnackBar(
        content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // showDialog(context: context, builder: (context){
    //   return AlertDialog(content: Text(text),actions: [TextButton(onPressed: (){
    //     popScreen();
    //   }, child: const Text("باشه"))],);
    // });
  }
}

void calculateRemainedTime() {
  if (!isTimerActive) {
    isTimerActive = true;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      remainedTime--;
      if (remainedTime == 0) {
        timer.cancel();
        isTimerActive = false;
        remainedTime = 10;
      }
    });
  }
}

extension ExtendedInt on int {
  String addZeroToString() {
    if (this < 10) {
      return "0$this";
    }
    return "$this";
  }


}

extension ExtendedString on String {

  bool isNumeric() {
    return double.tryParse(this) != null;
  }

  String replaceFarsiNumber() {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var x = this;
    for (int i = 0; i < english.length; i++) {
      x = x.replaceAll(farsi[i], english[i]);
    }
    return x;
  }

  String addZeroToString() {
    if (int.parse(this) < 10) {
      return "0$this";
    }
    return this;
  }

  String toDayOfWeek() {
    var dayOfWeek = "";
    switch (this) {
      case "0":
        dayOfWeek = WeekDay.saturday;
      case "1":
        dayOfWeek = WeekDay.sunday;
      case "2":
        dayOfWeek = WeekDay.monday;
      case "3":
        dayOfWeek = WeekDay.tuesday;
      case "4":
        dayOfWeek = WeekDay.wednesday;
      case "5":
        dayOfWeek = WeekDay.thursday;
      case "6":
        dayOfWeek = WeekDay.friday;
      case "-1":
        dayOfWeek = WeekDay.everyday;
      default:
        dayOfWeek = WeekDay.error;
    }
    return dayOfWeek;
  }
}

void sendMessage(String code, Device device, callback) async {
  var appendSign = defaultTargetPlatform == TargetPlatform.iOS?"&":"?";
  String uri = 'sms:${device.phone}${appendSign}body=${Uri.encodeComponent("${device.password}#${code.replaceFarsiNumber()}")}';
  await launchUrl(Uri.parse(uri),mode: LaunchMode.externalNonBrowserApplication);
}

const platform = MethodChannel('ch600.com/channel');
bool clickData = false;

var codeMap = {
  "نوع دستور": "-1",
  "دستگاه فعال": "11",
  "دستگاه غیر فعال": "00",
  "فعال با صدا": "12",
  "تغییر فعال با صدا": "10",
  "نیمه فعال": "15",
  "رله 1 فعال": "20",
  "رله 1 غیر فعال": "21",
  "رله 2 فعال": "25",
  "رله 2 غیر فعال": "26",
  "رله 3 فعال": "30",
  "رله 3 غیر فعال": "31",
  "رله 4 فعال": "35",
  "رله 4 غیر فعال": "36",
  "همه رله ها فعال": "37",
  "همه رله ها غیر فعال": "38",
  "گزارش دستگاه": "99",
  "گزارش رله ها": "98",
  "آژیر اضظراری": "70",
};

Future<void> setAlarm(Device device, Alarm alarm) async {
  try {
    var arguments = {
      'phone': device.phone,
      'password': device.password,
      'defaultSimCard': device.defaultSimCard,
      'dayOfWeek': alarm.dayOfWeek,
      'hour': alarm.hour,
      'minute': alarm.minute,
      'codeToSend': alarm.codeToSend,
      'alarmId': alarm.key,
      'codeName': codeMap.entries
          .firstWhere((element) => element.value == alarm.codeToSend)
          .key,
      'deviceName': device.name
    };
    await platform.invokeMethod('setAlarm', arguments);
  } on PlatformException catch (e) {}
}

Future<void> removeAlarm(int alarmId) async {
  try {
    var arguments = {
      'alarmId': alarmId,
    };
    await platform.invokeMethod('removeAlarm', arguments);
  } on PlatformException catch (e) {}
}
