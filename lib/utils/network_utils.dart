import 'dart:io';
import 'dart:async';

/// 网络工具类
class NetworkUtils {
  /// 检查网络连接
  static Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('www.google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  /// 检查是否可以访问指定URL
  static Future<bool> canReachUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final result = await InternetAddress.lookup(uri.host)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// 获取网络状态描述
  static Future<String> getNetworkStatus() async {
    final hasNetwork = await checkConnectivity();
    if (hasNetwork) {
      return '网络连接正常';
    } else {
      return '网络连接失败';
    }
  }
}
