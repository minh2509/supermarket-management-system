// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'picked_excel_file.dart';

/// Opens the browser file picker for .xlsx files.
Future<PickedExcelFile?> pickExcelFile() async {
  final input = html.FileUploadInputElement()..accept = '.xlsx';
  input.click();
  await input.onChange.first;
  final files = input.files;
  if (files == null || files.isEmpty) {
    return null;
  }
  final file = files.first;
  final reader = html.FileReader();
  reader.readAsArrayBuffer(file);
  await reader.onLoad.first;
  final result = reader.result;
  if (result is! List<int>) {
    return null;
  }
  return PickedExcelFile(name: file.name, bytes: result);
}
