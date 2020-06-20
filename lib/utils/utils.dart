import 'package:flutter/widgets.dart';

Map<Object, GlobalKey> _globalKeys = {};

/// creates and hashes global key for an object (such as stream)
GlobalKey keyForObject(Object object) {
  if (!_globalKeys.containsKey(object)) {
    _globalKeys[object] = GlobalKey();
  }
  return _globalKeys[object];
}
