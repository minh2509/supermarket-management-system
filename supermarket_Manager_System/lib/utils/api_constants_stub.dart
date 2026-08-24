/// Base URL for API (web / non-Android). Uses localhost.
String getBaseUrl() {
  const customBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  if (customBaseUrl.isNotEmpty) {
    return customBaseUrl;
  }
  return 'http://localhost:8080';
}
