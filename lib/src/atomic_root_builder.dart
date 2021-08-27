import 'package:atom_state/src/atomic_state.dart';
import 'package:flutter/material.dart';

/// @param `members` with tag that's not in `tags` will be ignored
// ignore: non_constant_identifier_names
TransitionBuilder AutoAtomicRootBuilder(
    {List<String>? tags, List<AtomicTrinity>? members}) {
  return (BuildContext context, Widget? child) {
    Builder func = Builder(builder: (context) {
      return _AtomicRoot(
          initialTags: tags ?? [],
          initialMembers: members ?? [],
          child: child ?? Container());
    });
    return func.build(context);
  };
}

// helper wrapper class for atomic state values.
class AtomicTrinity<T> {
  late String tag;
  late String name;
  late T value;
}

class _AtomicRoot extends StatefulWidget {
  final Widget child;
  final List<String> initialTags;
  late final List<AtomicTrinity>? initialMembers;

  _AtomicRoot(
      {required this.child, initialMembers, required this.initialTags}) {
    this.initialMembers = initialMembers ?? [];
  }
  @override
  AtomicState<StatefulWidget> createState() => _AtomicRootState();
}

class _AtomicRootState extends AtomicState<_AtomicRoot> {
  @override
  void register(List<String> availableStates) {
    widget.initialTags.forEach((tag) {
      bindTag(tag);
    });
    if (widget.initialMembers != null)
      widget.initialMembers?.forEach((trinity) {
        if (bindedTags.contains(trinity.tag))
          value(trinity.tag, trinity.name, trinity.value);
      });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
