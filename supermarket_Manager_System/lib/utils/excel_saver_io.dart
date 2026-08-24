import 'dart:io';

/// Saves [bytes] into the user's Downloads folder (falls back to the home
/// directory), then reveals the file in the platform file manager.
/// Returns the full path of the written file.
Future<String?> saveExcelFile(List<int> bytes, String fileName) async {
  final dir = await _downloadsDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes, flush: true);
  await _revealInFileManager(file.path);
  return file.path;
}

Future<Directory> _downloadsDirectory() async {
  final home =
      Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      Directory.current.path;
  if (Platform.isWindows) {
    // The Downloads folder can be relocated (e.g. OneDrive), so ask the
    // registry for its real location instead of assuming %USERPROFILE%.
    final fromRegistry = await _windowsDownloadsFromRegistry();
    if (fromRegistry != null && Directory(fromRegistry).existsSync()) {
      return Directory(fromRegistry);
    }
  }
  final fallback = Directory('$home${Platform.pathSeparator}Downloads');
  return fallback.existsSync() ? fallback : Directory(home);
}

Future<String?> _windowsDownloadsFromRegistry() async {
  try {
    final result = await Process.run('reg', [
      'query',
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',
      '/v',
      '{374DE290-123F-4565-9164-39C4925E467B}',
    ]);
    if (result.exitCode != 0) {
      return null;
    }
    for (final line in (result.stdout as String).split('\n')) {
      final idx = line.indexOf('REG_SZ');
      if (idx >= 0) {
        final value = line.substring(idx + 'REG_SZ'.length).trim();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
  } catch (_) {
    // Fall through to the %USERPROFILE%\Downloads fallback.
  }
  return null;
}

Future<void> _revealInFileManager(String path) async {
  try {
    if (Platform.isWindows) {
      await Process.run('explorer.exe', ['/select,$path']);
    } else if (Platform.isMacOS) {
      await Process.run('open', ['-R', path]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [File(path).parent.path]);
    }
  } catch (_) {
    // Revealing is best-effort; the file is already saved.
  }
}
