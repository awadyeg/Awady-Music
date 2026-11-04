abstract final class FormatUtils {
  static String formatDuration(int seconds) {
    if (seconds <= 0) return '0:00';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final sStr = s.toString().padLeft(2, '0');
    if (m >= 60) {
      final h = m ~/ 60;
      final mRem = (m % 60).toString().padLeft(2, '0');
      return '$h:$mRem:$sStr';
    }
    return '$m:$sStr';
  }

  static String formatCompactNumber(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) {
      final val = (count / 1000).toStringAsFixed(count % 1000 < 100 ? 0 : 1);
      return '${val}K';
    }
    final val = (count / 1000000).toStringAsFixed(
      count % 1000000 < 100000 ? 0 : 1,
    );
    return '${val}M';
  }
}
