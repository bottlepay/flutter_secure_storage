import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/src/ios_accessibility.dart';
import 'package:flutter_secure_storage/src/options/options.dart';

class IOSOptions extends Options {
  IOSOptions({
    String? groupId,
    IOSAccessibility accessibility = IOSAccessibility.unlocked,
  })  : _groupId = groupId,
        _accessibility = accessibility;

  final String? _groupId;
  final IOSAccessibility _accessibility;

  @override
  Map<String, String> toMap() {
    final m = <String, String>{};
    if (_groupId != null) {
      m['groupId'] = _groupId!;
    }
    m['accessibility'] = describeEnum(_accessibility);
    return m;
  }
}
