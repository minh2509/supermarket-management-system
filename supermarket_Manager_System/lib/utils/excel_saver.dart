import 'excel_saver_io.dart'
    if (dart.library.html) 'excel_saver_web.dart'
    as impl;

/// Saves an .xlsx file. On desktop/mobile it writes to the Downloads folder
/// and returns the file path; on web it triggers a download and returns null.
Future<String?> saveExcelFile(List<int> bytes, String fileName) =>
    impl.saveExcelFile(bytes, fileName);
