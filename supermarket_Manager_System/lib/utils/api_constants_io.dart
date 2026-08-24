import 'dart:io';

/// Base URL for API. On Android emulator, localhost = emulator itself,
/// so use 10.0.2.2 to reach host machine.
String getBaseUrl() {
  const customBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  if (customBaseUrl.isNotEmpty) {
    return customBaseUrl;
  }
  return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
}
