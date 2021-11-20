import 'dart:io';
import 'dart:isolate';

import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:hive/hive.dart';
import 'package:money_tracker/core/helpers/hive_helper.dart';
import 'package:money_tracker/data/models/isolate_model.dart';
import 'package:money_tracker/logic/restore_backup_isolate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:money_tracker/core/themes/colors_utility.dart';
import 'package:money_tracker/core/themes/my_flutter_app_icons.dart';
import 'package:money_tracker/logic/cubit/account_cubit.dart';
import 'package:money_tracker/logic/cubit/catalog_cubit.dart';
import 'package:money_tracker/logic/cubit/setting_cubit.dart';
import 'package:money_tracker/logic/debug/logger.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:money_tracker/presentation/widget/notify.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Isolate? _isolate;
  ReceivePort? _receivePort;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(
            height: 10,
          ),
          Text("Profile", style: Theme.of(context).textTheme.headline5),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFAA76FF),
                      Color(0xFF4400D5),
                    ],
                    tileMode: TileMode.repeated,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  MyFlutterApp.userOutline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Thien Thien",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(
                    "thien@gmail.com",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "General",
            style: Theme.of(context).textTheme.headline6,
          ),
          BlocBuilder<CatalogCubit, CatalogState>(
            builder: (context, state) {
              return ShowMoreCard(
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.catalogView),
                icon: LineariconsFree.tag_1,
                firstText: "Categorise",
                sencondText: state.catalogInfo,
              );
            },
          ),
          BlocBuilder<SettingCubit, SettingState>(
            buildWhen: (previous, current) =>
                previous.notification != current.notification,
            builder: (context, state) {
              return CustomConfigCard(
                icon: const Icon(
                  LineariconsFree.alarm,
                  size: 45,
                  color: Colors.white,
                ),
                fisrtText: "Notification",
                secondText: state.notification.isNotEmpty
                    ? "at ${state.notification}"
                    : "Off",
                initValue: state.notification.isNotEmpty,
                onChange: (value) async {
                  if (value) {
                    final newTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    BlocProvider.of<SettingCubit>(context)
                        .notificationChange(newTime);
                  } else {
                    BlocProvider.of<SettingCubit>(context).notificationChange();
                  }
                },
              );
            },
          ),
          BlocBuilder<SettingCubit, SettingState>(
            buildWhen: (previous, current) =>
                previous.fingerprint != current.fingerprint,
            builder: (context, state) {
              return CustomConfigCard(
                icon: const Icon(
                  Icons.fingerprint_outlined,
                  size: 45,
                  color: Colors.white,
                ),
                fisrtText: "Fingerprint",
                secondText: state.fingerprint ? "On" : "Off",
                initValue: state.fingerprint,
                onChange: (value) => BlocProvider.of<SettingCubit>(context)
                    .fingerprintChange(value),
              );
            },
          ),
          BlocConsumer<SettingCubit, SettingState>(
            listenWhen: (previous, current) =>
                previous.showAllAccount != current.showAllAccount,
            listener: (context, state) {
              BlocProvider.of<AccountCubit>(context).reFilterAccount();
            },
            buildWhen: (previous, current) =>
                previous.showAllAccount != current.showAllAccount,
            builder: (context, state) {
              return CustomConfigCard(
                activeIcon: const Icon(
                  Icons.visibility_outlined,
                  size: 35,
                  color: Colors.white,
                ),
                icon: const Icon(
                  Icons.visibility_off_outlined,
                  size: 35,
                  color: Colors.white,
                ),
                fisrtText: "Show hidden account",
                secondText: state.showAllAccount ? "On" : "Off",
                initValue: state.showAllAccount,
                onChange: (value) => BlocProvider.of<SettingCubit>(context)
                    .showAllAccount(value),
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Data",
            style: Theme.of(context).textTheme.headline6,
          ),
          ShowMoreCard(
            onTap: () async {
              bool allowRetore = false;
              await showWarningMessage(
                context: context,
                message: 'This will overwrite current your data!',
                onAccept: () {
                  allowRetore = true;
                },
              );
              if (allowRetore) {
                Directory? newDirectory = await FolderPicker.pick(
                  allowFolderCreation: true,
                  context: context,
                  rootDirectory: Directory("/storage/emulated/0/"),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                );
                if (newDirectory != null) {
                  // _startIsolate(false, newDirectory.path);
                  BlocProvider.of<SettingCubit>(context)
                      .restoreData(newDirectory.path);
                }
              }
            },
            icon: MyFlutterApp.restore,
            firstText: "Restore data",
          ),
          BlocListener<SettingCubit, SettingState>(
            listenWhen: (previous, current) => current.message.isNotEmpty,
            listener: (context, state) {
              showNotify(context, state.message);
              BlocProvider.of<SettingCubit>(context).clearMessage();
            },
            child: ShowMoreCard(
              onTap: () async {
                Directory? newDirectory = await FolderPicker.pick(
                  allowFolderCreation: true,
                  context: context,
                  rootDirectory: Directory("/storage/emulated/0/"),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                );

                if (newDirectory != null) {
                  // _startIsolate(true, newDirectory.path);
                  BlocProvider.of<SettingCubit>(context)
                      .backupData(newDirectory.path);
                }
              },
              icon: MyFlutterApp.backup,
              firstText: "Backup data",
            ),
          ),
          ShowMoreCard(
            onTap: () async {
              await showWarningMessage(
                context: context,
                message:
                    'This will reset your device to default factory settings.',
                onAccept: () {
                  BlocProvider.of<SettingCubit>(context).clearAllDatabase();
                },
              );
            },
            icon: MyFlutterApp.deleteDatabase,
            firstText: "Delete data",
          ),
        ],
      ),
    );
  }

  void _startIsolate(bool isBackup, String backupPath) async {
    if (_isolate != null) return;
    _receivePort = ReceivePort();
    logger.d("_startIsolate");
    final appDocDir = await getApplicationDocumentsDirectory();
    _isolate = await Isolate.spawn(
      isolateHandler,
      IsolateBackupParam(
          isBackup, backupPath, appDocDir.path, _receivePort!.sendPort),
    );

    _receivePort!.listen(_onData);
  }

  void _onData(dynamic msg) {
    if (msg is String) {
      logger.d(msg);
    }
    if (_isolate != null) {
      _receivePort!.close();
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }
}

class CustomConfigCard extends StatefulWidget {
  const CustomConfigCard({
    Key? key,
    required this.onChange,
    required this.icon,
    required this.fisrtText,
    required this.secondText,
    required this.initValue,
    this.activeIcon,
  }) : super(key: key);

  final Function(bool value) onChange;
  final Widget icon;
  final Widget? activeIcon;
  final String fisrtText;
  final String secondText;
  final bool initValue;

  @override
  CustomConfigCardState createState() => CustomConfigCardState();
}

class CustomConfigCardState extends State<CustomConfigCard> {
  @override
  Widget build(BuildContext context) {
    bool isSwitched = widget.initValue;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 80,
      width: MediaQuery.of(context).size.width * 0.87,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: RadiantGradientMask(
              child: widget.activeIcon != null && isSwitched
                  ? widget.activeIcon!
                  : widget.icon,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fisrtText,
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.secondText,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: Switch(
              value: isSwitched,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
                widget.onChange(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShowMoreCard extends StatelessWidget {
  const ShowMoreCard({
    Key? key,
    required this.onTap,
    required this.icon,
    required this.firstText,
    this.sencondText = "",
  }) : super(key: key);

  final Function() onTap;
  final IconData icon;
  final String firstText;
  final String sencondText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 80,
        width: MediaQuery.of(context).size.width * 0.87,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(25, 0, 0, 0),
              blurRadius: 4.0,
              spreadRadius: 0.0,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: RadiantGradientMask(
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstText,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  if (sencondText.isNotEmpty)
                    const SizedBox(
                      height: 5,
                    ),
                  if (sencondText.isNotEmpty)
                    Text(
                      sencondText,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
      ),
    );
  }
}
