import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/core/constants/enums.dart';
import 'package:money_tracker/data/models/item.dart';

extension ParseToString on int {
  String asMoneyDisplay({String unit = 'đ', bool showSign = false}) {
    String raw = abs().toString();
    String sign = this < 0 && showSign ? "-" : "";
    return formatString(raw, sign: sign, unit: unit);
  }
}

String formatString(String raw,
    {String sign = "", String separate = ',', String unit = 'đ'}) {
  List<String> each3Number = [];
  String output = "";
  int size = raw.length;
  if (size == 0) return "$sign$unit";

  while (size >= 0) {
    int start = size > 3 ? size - 3 : 0;
    each3Number.add(raw.substring(start, size));
    size -= 3;
  }
  for (var element in each3Number.reversed) {
    if (element.isNotEmpty) output += element + separate;
  }

  return "$sign$unit ${output.substring(0, output.length - separate.length)}";
}

extension DateTimeEx on DateTime {
  String parseAsString() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  String parseAsDisplay() {
    return DateFormat.yMMMMd('en_US').format(this);
  }

  String get dayOfWeek => DateFormat('EEEE').format(this);

  bool isCurrentDate() {
    DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension TimeOfDateExt on TimeOfDay {
  String toShortString() {
    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10) return '0$value';
      return value.toString();
    }

    final String hourLabel = _addLeadingZeroIfNeeded(hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(minute);

    return '$hourLabel:$minuteLabel';
  }
}

extension EnumEx on String {
  TransactionType toEnumType() => TransactionType.values
      .firstWhere((d) => describeEnum(d) == toLowerCase());

  EVisibility toEnumVisibility() =>
      EVisibility.values.firstWhere((d) => describeEnum(d) == toLowerCase());

  DateType toEnumDateType() =>
      DateType.values.firstWhere((d) => describeEnum(d) == toLowerCase());

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  // ============= parse to datetime
  DateTime parseToDateTime() => DateFormat('dd/MM/yyyy').parse(this);

  DateTime parseToDateTimeWithoutDay() => DateFormat('MM/yyyy').parse(this);

  DateTime parseToDateOnlyYear() => DateFormat('yyyy').parse(this);

  String refomartDataTime() {
    final today = DateTime.now().parseAsString();
    final yesterday =
        DateTime.now().subtract(const Duration(days: 1)).parseAsString();
    if (this == today) {
      return "$this - Today";
    } else if (this == yesterday) {
      return "$this - Yesterday";
    }
    return this;
  }
}

extension TransactionTypeEx on TransactionType {
  String toShortString() {
    return toString().split('.').last.capitalize();
  }
}

extension VisibilityToString on EVisibility {
  String toShortString() {
    return toString().split('.').last.capitalize();
  }
}

extension DateTypeEx on DateType {
  String toShortString() {
    return toString().split('.').last.capitalize();
  }
}

String image2Base64String(String pathImage) {
  final bytes = File(pathImage).readAsBytesSync();
  return const Base64Encoder().convert(bytes);
}

Image base64String2Image(String base64String) {
  return Image.memory(const Base64Decoder().convert(base64String));
}
