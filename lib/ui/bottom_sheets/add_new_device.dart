import 'package:ch600/data/models/device.dart';
import 'package:ch600/utils/constants.dart';
import 'package:ch600/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddNewDevice extends StatefulWidget {
  final void Function(MapEntry<dynamic, Device>) onSaveClick;
  final MapEntry<dynamic, Device>? deviceMapEntry;

  const AddNewDevice({
    this.deviceMapEntry,
    required this.onSaveClick,
    super.key,
  });

  @override
  State<AddNewDevice> createState() => _AddNewDeviceState();
}

class _AddNewDeviceState extends State<AddNewDevice> {
  final _formKey = GlobalKey<FormState>();
  final _dropdownButtonKey = GlobalKey();

  var defaultSimCard = "1";
  var password = "";
  var phone = "";
  var name = "";

  void openDropdown() {
    _dropdownButtonKey.currentContext?.visitChildElements((element) {
      if (element.widget is Semantics) {
        element.visitChildElements((element) {
          if (element.widget is Actions) {
            element.visitChildElements((element) {
              Actions.invoke(element, const ActivateIntent());
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    var device = widget.deviceMapEntry?.value;
    defaultSimCard = device?.defaultSimCard ?? "1";
    password = device?.password ?? "";
    phone = device?.phone ?? "";
    name = device?.name ?? "";
    getSimCardCount();

    super.initState();
  }

  final _textController = TextEditingController();

  Future<int?> getSimCardCount() async {
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getSimCardCount(),
      initialData: null,
      builder: (w, s) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: null,
                title: TextFormField(
                  initialValue: name,
                  autofocus: true,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    label: Text(
                      deviceName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'لطفا نام دستگاه را وارد کنید';
                    }
                    return null;
                  },
                  onSaved: (s) {
                    name = s!;
                  },
                ),
              ),
              ListTile(
                onTap: null,
                title: TextFormField(
                  initialValue: phone,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                      label: Text(
                    devicePhone,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.black),
                  )),
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'لطفا شماره تلفن دستگاه را وارد کنید';
                    }
                    return null;
                  },
                  onSaved: (s) {
                    phone = s!;
                  },
                ),
              ),
              ListTile(
                onTap: null,
                title: TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      var replaceFarsiNumber = newValue.text.replaceFarsiNumber();
                      return newValue.copyWith(text: replaceFarsiNumber);
                    })
                  ],
                  keyboardType: TextInputType.number,
                  initialValue: password,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                      label: Text(
                    changePassword,
                    style: TextStyle(color: Colors.black),
                  )),
                  validator: (s) {
                    if (s == null || s.isEmpty) {
                      return "رمز را وارد نمایید";
                    }
                    if (s.isNotEmpty && s.length != 5) {
                      return " طول رمز باید 5 کارکتر باشد";
                    }
                    if (s.contains("-") ||
                        s.contains(" ") ||
                        s.contains(",") ||
                        s.contains(".")) {
                      return "فقط کارکتر عددی وارد نمایید";
                    }
                    if(!s.isNumeric()){
                      return "فقط کارکتر عددی وارد نمایید";
                    }
                  },
                  onSaved: (s) {
                    password = s!.replaceFarsiNumber();
                  },
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: TextButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == false) return;
                    _formKey.currentState?.save();
                    widget.onSaveClick(MapEntry(
                        widget.deviceMapEntry?.key,
                        Device(
                            name: name,
                            phone: phone,
                            defaultSimCard: defaultSimCard,
                            password: password)));
                  },
                  child: Text(accept,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
