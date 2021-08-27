import 'package:flutter/widgets.dart';
import 'atomic_io_mixin.dart';
import 'atom.dart';

abstract class AtomicWidget extends StatelessWidget with AtomicIOMixin {
  /// helper function, returns the value of a `T` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead

  @override
  bool stateAccessInterceptor<T>(String stateName,
      {Function? onError, String? dataName, T? data}) {
    return true;
  }
}
