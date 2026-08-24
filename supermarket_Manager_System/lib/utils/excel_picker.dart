import 'excel_picker_io.dart'
    if (dart.library.html) 'excel_picker_web.dart'
    as impl;
import 'picked_excel_file.dart';

export 'picked_excel_file.dart';

/// Lets the user pick an .xlsx file. Returns null if the dialog was cancelled.
Future<PickedExcelFile?> pickExcelFile() => impl.pickExcelFile();
