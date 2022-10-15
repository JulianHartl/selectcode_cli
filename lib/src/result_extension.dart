import 'package:universal_io/io.dart';

extension ResultExtension on ProcessResult {
  bool get isSuccess => exitCode == 0 ;
}
