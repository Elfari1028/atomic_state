///
///    AtomicMap is a modular state management solution.
///    Using `AtomicMap` global class to manage all (important) state with auto `setState((){})` call!
///    This is merely a helpful wrapper to automate and organize your states and global states more effciently.
///    The concenpt is that:
///       - use a `tag` to create/access/destroy an AtomicMap instance to manage the variables (states) you use in a widget.
///       - use getter and setter to access variables in your state instead of direct access (luckily with dart syntax you won't feel the difference!)
///
///    for example, if you have a gridview with custom cards that takes user to detail pages, you can
///       1. manage comman card style config with one singular instance of AtomicMap
///       2. each card and its detail page can use an instance of AtomicMap to access/manipulate data
///
///    Advantages:
///      - more organized data access
///      - allow organized preload / cache schemes
///
///

class AtomicMap {
  // ignore: unused_field
  late String _tag;
  Map<String, dynamic> _data = {};

  // widget state id  <-> setState Callbacks for this particular state
  Map<String, void Function()> _stateSetters = <String, void Function()>{};

  /// key <-> callback when set value.
  Map<String, Function(dynamic, dynamic)> _onBeforeMemberUpdateCallbacks =
      <String, Function(dynamic, dynamic)>{};
  Map<String, Function(dynamic, dynamic)> _onAfterMemberUpdateCallbacks =
      <String, Function(dynamic, dynamic)>{};

  Iterable<String> get subscribers => _stateSetters.keys;

  AtomicMap(String tag) {
    _data = {};
    this._tag = tag;
  }

  void addStateSetter(String id, void Function() func) {
    _stateSetters[id] = func;
  }

  void removeStateSetter(String id) {
    _stateSetters.remove(id);
  }

  dynamic obtain(String key) {
    if (!_data.containsKey(key)) return null;
    return _data[key];
  }

  T? value<T>(String key) {
    if (obtain(key) is T) {
      return obtain(key) as T;
    } else {
      return null;
    }
  }

  /// TODO:  Use a task queue to optimize the number of times that `setState` will be called.
  void put(String key, dynamic data, {bool setState = true}) {
    // onBeforeMemberUpdate hook

    dynamic oldVal = _data[key];
    dynamic Function(dynamic, dynamic)? onBeforeUpdate;
    if (_onBeforeMemberUpdateCallbacks.containsKey(key))
      onBeforeUpdate = _onBeforeMemberUpdateCallbacks[key]!;
    if (onBeforeUpdate != null) onBeforeUpdate(oldVal, data);

    _data[key] = data;

    // onAfterMemberUpdate hook
    dynamic Function(dynamic, dynamic)? onAfterUpdate;
    if (_onAfterMemberUpdateCallbacks.containsKey(key))
      onAfterUpdate = _onAfterMemberUpdateCallbacks[key]!;
    if (onAfterUpdate != null) onAfterUpdate(oldVal, data);

    // setState.
    if (setState)
      _stateSetters.values.forEach((stateSetter) {
        stateSetter();
      });
  }

  void onBeforeMemberUpdate(
      String key, void Function(dynamic, dynamic)? onBeforeUpdate) {
    if (onBeforeUpdate == null)
      _onBeforeMemberUpdateCallbacks.remove(key);
    else
      _onBeforeMemberUpdateCallbacks[key] = onBeforeUpdate;
  }

  void onAfterMemberUpdate(
      String key, void Function(dynamic, dynamic)? onAfterUpdate) {
    if (onAfterUpdate == null)
      _onAfterMemberUpdateCallbacks.remove(key);
    else
      _onAfterMemberUpdateCallbacks[key] = onAfterUpdate;
  }
}
