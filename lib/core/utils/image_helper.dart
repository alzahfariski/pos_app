import 'dart:io';

class ImageHelper {
  /// Replaces '127.0.0.1' or 'localhost' with '10.0.2.2'.
  static String sanitizeUrl(String url) {
    if (Platform.isAndroid) {
      if (url.contains('127.0.0.1')) {
        return url.replaceAll('127.0.0.1', '10.0.2.2');
      } else if (url.contains('localhost')) {
        return url.replaceAll('localhost', '10.0.2.2');
      }
    }
    return url;
  }
}
