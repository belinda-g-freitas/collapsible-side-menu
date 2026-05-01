import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data != null) {
      // Write timeline summaries to build/ directory.
      // Each key corresponds to a reportKey passed to watchPerformance().
      for (final entry in data.entries) {
        print('[PERF] ${entry.key}: ${entry.value}');
      }
    }
  },
);
