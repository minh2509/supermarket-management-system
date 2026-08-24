import 'dart:io';

import 'picked_excel_file.dart';

/// Opens the native Windows file dialog (via PowerShell, so no Flutter plugin
/// is required) and returns the selected .xlsx file, or null if cancelled.
Future<PickedExcelFile?> pickExcelFile() async {
  if (!Platform.isWindows) {
    throw Exception('File picking is only supported on Windows.');
  }
  final result = await Process.run('powershell', [
    '-NoProfile',
    '-STA',
    '-Command',
    "Add-Type -AssemblyName System.Windows.Forms | Out-Null; "
        r"$f = New-Object System.Windows.Forms.OpenFileDialog; "
        r"$f.Filter = 'Excel Workbook (*.xlsx)|*.xlsx'; "
        r"$f.Title = 'Select product import file'; "
        r"if ($f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output $f.FileName }",
  ]);
  final path = (result.stdout as String).trim();
  if (path.isEmpty) {
    return null;
  }
  final file = File(path);
  if (!file.existsSync()) {
    return null;
  }
  return PickedExcelFile(
    name: path.split(Platform.pathSeparator).last,
    bytes: await file.readAsBytes(),
  );
}
