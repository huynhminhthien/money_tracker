import 'package:logger/logger.dart';

final logger = Logger(
  level: Level.debug,
  printer: PrettyPrinter(
    methodCount: 1,
    lineLength: 80,
    errorMethodCount: 3,
    colors: true,
    printEmojis: true,
  ),
);
