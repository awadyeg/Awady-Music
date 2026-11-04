import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error }

abstract final class Log {
  static Directory? _logDirectory;
  static File? _currentLogFile;
  static int _maxSizeBytes = 1024 * 1024; // 1 MB
  static int _maxBackupFiles = 3;
  static bool _initialized = false;

  static Future<void> init({
    Directory? directory,
    int maxSizeBytes = 1024 * 1024,
    int maxBackupFiles = 3,
  }) async {
    _maxSizeBytes = maxSizeBytes;
    _maxBackupFiles = maxBackupFiles;

    if (directory != null) {
      _logDirectory = directory;
    } else {
      try {
        _logDirectory = await getApplicationSupportDirectory();
      } on Object {
        _logDirectory = Directory.systemTemp;
      }
    }

    if (!_logDirectory!.existsSync()) {
      _logDirectory!.createSync(recursive: true);
    }

    _currentLogFile = File(p.join(_logDirectory!.path, 'main.log'));
    _initialized = true;
  }

  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    _write(LogLevel.debug, message, error, stackTrace);
  }

  static void i(String message, [Object? error, StackTrace? stackTrace]) {
    _write(LogLevel.info, message, error, stackTrace);
  }

  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    _write(LogLevel.warning, message, error, stackTrace);
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _write(LogLevel.error, message, error, stackTrace);
  }

  static String _levelTag(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO ';
      case LogLevel.warning:
        return 'WARN ';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  static void _write(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    final levelTag = _levelTag(level);
    final errorPart = error != null ? ' | Error: $error' : '';
    final stackPart = stackTrace != null ? '\n$stackTrace' : '';
    final line = '[$timestamp] [$levelTag] $message$errorPart$stackPart\n';

    if (kDebugMode) {
      debugPrint('[$levelTag] $message$errorPart');
    }

    _writeToFile(line);
  }

  static void _writeToFile(String line) {
    if (!_initialized || _currentLogFile == null) {
      _ensureInitializedSync();
    }

    try {
      final file = _currentLogFile;
      if (file == null) return;

      if (!file.existsSync()) {
        file.createSync(recursive: true);
      } else if (file.lengthSync() >= _maxSizeBytes) {
        _rotateFiles();
      }

      file.writeAsStringSync(line, mode: FileMode.append, flush: true);
    } on Object catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to write to log file: $e');
      }
    }
  }

  static void _ensureInitializedSync() {
    if (_initialized) return;
    _logDirectory ??= Directory.systemTemp;
    _currentLogFile = File(p.join(_logDirectory!.path, 'main.log'));
    _initialized = true;
  }

  static void _rotateFiles() {
    final dir = _logDirectory;
    if (dir == null) return;

    for (var i = _maxBackupFiles - 1; i >= 1; i--) {
      final olderFile = File(p.join(dir.path, 'main.$i.log'));
      final targetFile = File(p.join(dir.path, 'main.${i + 1}.log'));

      if (olderFile.existsSync()) {
        if (i == _maxBackupFiles - 1) {
          olderFile.deleteSync();
        } else {
          olderFile.renameSync(targetFile.path);
        }
      }
    }

    final current = _currentLogFile;
    if (current != null && current.existsSync()) {
      final firstBackup = File(p.join(dir.path, 'main.1.log'));
      current.renameSync(firstBackup.path);
      _currentLogFile = File(p.join(dir.path, 'main.log'));
    }
  }

  static List<File> getLogFiles() {
    final dir = _logDirectory;
    if (dir == null || !dir.existsSync()) return [];

    final files = <File>[];
    final current = File(p.join(dir.path, 'main.log'));
    if (current.existsSync()) files.add(current);

    for (var i = 1; i <= _maxBackupFiles; i++) {
      final backup = File(p.join(dir.path, 'main.$i.log'));
      if (backup.existsSync()) files.add(backup);
    }
    return files;
  }

  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
    _logDirectory = null;
    _currentLogFile = null;
  }
}
