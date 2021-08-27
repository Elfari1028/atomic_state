import 'atomic_state_manager.dart';
import 'atomic_state.dart';

abstract class AtomicIOMixin {
  /// ----------------------------- ---------------- -----------------------------  ///////
  ///
  /// ----------------------------- ---------------- -----------------------------  ///////
  /// ----------------------------- HELPER FUNCTIONS -----------------------------  ///////
  /// ----------------------------- ---------------- -----------------------------  ///////
  ///
  /// ----------------------------- ---------------- -----------------------------  ///////

  /// helper function, returns the value of a `string` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead
  String? string(String stateName, String dataName, [String? newVal]) {
    putIfNotNull(stateName, dataName, newVal);
    return value<String>(stateName, dataName, newVal);
  }

  /// helper function, returns the value of a `int` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead
  int? integer(String stateName, String dataName, [int? newVal]) {
    return value<int>(stateName, dataName, newVal);
  }

  /// helper function, returns the value of a `int` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead
  bool? boolean(String stateName, String dataName, [bool? newVal]) {
    return value<bool>(stateName, dataName, newVal);
  }

  /// helper function, returns the value of a `num` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead
  num? number(String stateName, String dataName, [num? newVal]) {
    return value<num>(stateName, dataName, newVal);
  }

  /// helper function, returns the value of a `dynamic` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead
  dynamic obtain(String stateName, String dataName, [dynamic newVal]) {
    return value<dynamic>(stateName, dataName, newVal);
  }

  /// helper function, returns the value of a `Map<M,N>` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead
  Map<M, N>? map<M, N>(String stateName, String dataName, [dynamic newVal]) {
    return value<Map<M, N>>(stateName, dataName, newVal);
  }

  /// helper function, returns the value of a `List<M>` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead
  List<M>? list<M>(String stateName, String dataName, [dynamic newVal]) {
    return value<List<M>>(stateName, dataName, newVal);
  }

  /// helper function, returns the value of a `double` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead
  double? doubleNum(String stateName, String dataName, [dynamic newVal]) {
    return value<double>(stateName, dataName, newVal);
  }

  DateTime? datetime(String stateName, String dataName, [dynamic newVal]) {
    return value<DateTime>(stateName, dataName, newVal);
  }

  // universal retriever and setter
  T? value<T>(String stateName, String dataName, [T? newVal]) {
    this.stateAccessInterceptor(stateName, dataName: dataName, data: newVal);
    putIfNotNull(stateName, dataName, newVal);
    return AtomicState.getState(stateName)?.value<T>(dataName);
  }

  //shortened version
  T? v<T>(String stateName, String dataName, [T? newVal]) {
    return value<T>(stateName, dataName, newVal);
  }

  /// sets the `dataName` member of state `stateName` to `null`
  dynamic setNull(String stateName, String dataName, {bool setState = true}) {
    this.stateAccessInterceptor(stateName, dataName: dataName);
    AtomicState.getState(stateName)?.put(dataName, null, setState: setState);
  }

  ///
  ///   when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  void putIfNotNull<T>(String stateName, String dataName, T newVal,
      {bool setState = true}) {
    this.stateAccessInterceptor(stateName, dataName: dataName);
    if (newVal != null) {
      AtomicState.getState(stateName)
          ?.put(dataName, newVal, setState: setState);
    }
  }

  /// ---------- will be called before `value<T>(), setNull() and putIfNotNull()`
  /// ---------- throw error if you wanna abort
  void stateAccessInterceptor<T>(String stateName, {String? dataName, T? data});
}
