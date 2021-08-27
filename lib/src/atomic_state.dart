import 'dart:math';
import 'atomic_io_mixin.dart';

import 'atomic_map.dart';
import 'atomic_state_manager.dart';
import 'package:flutter/widgets.dart';

abstract class AtomicState<T extends StatefulWidget> extends State<T>
    with AtomicIOMixin {
  /// all the states are in here
  static Map<String, AtomicMap> _children = <String, AtomicMap>{};

  //
  static AtomicMap? getState(String tag) =>
      _children.containsKey(tag) ? _children[tag] : null;

  static AtomicMap registerState(
    String tag, {
    bool deleteOldState = false,
    void Function()? setStateCallback,
    String? stateId,
  }) {
    assert((stateId == null) == (setStateCallback == null));
    if (!_children.containsKey(tag) || deleteOldState) {
      _children[tag] = AtomicMap(tag);
    } else
      _children.putIfAbsent(tag, () => AtomicMap(tag));
    if (stateId != null && setStateCallback != null)
      _children[tag]?.addStateSetter(stateId, setStateCallback);
    return _children[tag]!;
  }

  static void deleteState(String tag) {
    _children.remove(tag);
  }

  static List<String> get registeredTags => _children.keys.toList();

  late String _id;
  List<String> _subscribedStateNames = [];

  String get id => _id;
  Set<String> get bindedTags => _subscribedStateNames.toSet();

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    _id = _getRandomString(64);
    register(registeredTags);
  }

  /// `register()` is called right after `super.initState()` finishes
  ///  you can leave it blank though.
  ///  `registeredTags` provides a list of names of states that has already been registered / initialized.
  ///  you can call `bindTag` or `bindTags` here.
  ///  the variables you bind to the state are automatically disposed when `dispose` is called.
  void register(List<String> availableStates);

  @mustCallSuper
  @override
  void dispose() {
    bindedTags.forEach((state) {
      getState(state)?.removeStateSetter(id);
    });
    super.dispose();
  }

  /// a safer way to call setState.
  void setStateIfMounted(void Function() fn) {
    if (mounted) {
      this.setState(fn);
    }
  }

  /// subscribe AtomStates in batch, will call `bindTag` one by one
  void bindTags(List<String> stateNames,
      {bool deleteOldState = false, void Function()? setStateCallback}) {
    stateNames.forEach((name) {
      bindTag(name,
          deleteOldState: deleteOldState, setStateCallback: setStateCallback);
    });
  }

  /// subscribe to an AtomicState, if the `stateName` AtomicState does not exist, it will automatically create one.
  /// will add the state name to `bindedTags`
  /// will pass your `setStateCallback` (if there is any) to the  `setState(fn)` function's parameter
  /// any changes from `stateName`'s state will automatically result in a `setStateIfMounted(setStateCallback)` call.
  void bindTag(String stateName,
      {bool deleteOldState = false, void Function()? setStateCallback}) {
    if (!_subscribedStateNames.contains(stateName))
      _subscribedStateNames.add(stateName);

    void Function() callback = () {
      void Function() caller = setStateCallback ?? () {};
      if (setStateCallback == null) {
        this.setStateIfMounted(caller);
      }
    };

    registerState(stateName,
        deleteOldState: deleteOldState,
        setStateCallback: callback,
        stateId: _id);
  }

  ///
  /// unsubcribe a state.
  /// the changes made to a state's member will no longer call setState for your widget.
  /// but you will still be able to access members with helper functions such as `value<T>(.. , .. , [..])`
  ///
  /// will be automatically called with every subscribed state when `dispose` is called;
  void unbindTag(String stateName) {
    getState(stateName)?.removeStateSetter(_id);
  }

  /// delete the `stateName` state globally, this process is irreversiable
  /// this will likely lead to undesired errors if more than one widget is still rendering data based on the particular state
  /// please use
  void deleteTag(String stateName) {
    unbindTag(stateName);
    deleteState(stateName);
  }

  void onBeforeMemberUpdate(String stateName, String key,
      Function(dynamic, dynamic)? onBeforeUpdate) {
    getState(stateName)?.onBeforeMemberUpdate(key, onBeforeUpdate);
  }

  void onAfterMemberUpdate(
      String stateName, String key, Function(dynamic, dynamic)? onAfterUpdate) {
    getState(stateName)?.onAfterMemberUpdate(key, onAfterUpdate);
  }

  /// returns the subscribers of a `stateName` state
  /// if `stateName` state does not exists, then returns an empty `List`.
  Iterable<String> querySubscribers(String stateName) {
    return getState(stateName)?.subscribers ?? [];
  }

  /// AtomicIOMixin implementations

  @override
  void stateAccessInterceptor<T>(String stateName,
      {String? dataName, T? data}) {
    if (!bindedTags.contains(stateName))
      throw FlutterError(__unbinded_access_error_msg +
          '''
---- Direct access usage: ----
> `AtomicMap.getState("$stateName")?.value<T>("$dataName")
> `AtomicMap.getState("$stateName")?.put("$dataName",null)
> `AtomicMap.getState("$stateName")?.put("$dataName",newVal);  
---- -------------------- ----''');
  }

  /// helper function, returns the value of a `T` state memember;
  /// when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  /// if you want to set `dataName` of `stateName` to `null`, please use `setNull(stateName,dataName)` instead

  @override
  T? value<T>(String stateName, String dataName, [T? newVal]) {
    if (!bindedTags.contains(stateName))
      throw FlutterError(__unbinded_access_error_msg +
          '''
---- Direct access usage: ----
Example: `AtomicMap.getState("$stateName")?.value<${newVal.runtimeType.toString()}>("$dataName") 
---- -------------------- ----''');
    putIfNotNull(stateName, dataName, newVal);
    return getState(stateName)?.value<T>(dataName);
  }

  /// sets the `dataName` member of state `stateName` to `null`
  @override
  void setNull(String stateName, String dataName, {bool setState = true}) {
    if (!bindedTags.contains(stateName))
      throw FlutterError(__unbinded_access_error_msg +
          '''
---- Direct access usage: ----
Example: `AtomicMap.getState("$stateName")?.put("$dataName",null) 
---- -------------------- ----''');
    getState(stateName)?.put(dataName, null, setState: setState);
  }

  ///
  ///   when `newVal` is not null, `dataName` of `stateName` will be set to `newVal`
  @override
  void putIfNotNull<T>(String stateName, String dataName, T newVal,
      {bool setState = true}) {
    if (!bindedTags.contains(stateName))
      throw FlutterError(__unbinded_access_error_msg +
          '''
---- Direct access usage: ----
Example: `AtomicMap.getState("$stateName")?.put("$dataName",newVal); 
---- -------------------- ---- ''');
    if (newVal != null) {
      // if (AtomicMap.getState(stateName) == null) {
      //   debugPrint("null state $stateName");
      // }
      getState(stateName)?.put(dataName, newVal, setState: setState);
    }
  }

  static const String __unbinded_access_error_msg = '''
Tried to access an AtomicState's member data withour subscribing to it first.
You can subscribe to it in `register()` function in AtomicState.
If you are sure you want to access this member, please access it directly through `AtomicMap`
[WARNING] Direct access will not notify your `AtomicState` to setState when accessed data changes. 
Other widgets could have removed the state or the member at the time your accessing it, causing unintended actions.
''';

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static String _getRandomString(int length) {
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}
