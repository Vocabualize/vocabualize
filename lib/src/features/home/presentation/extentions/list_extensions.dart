import 'package:flutter/material.dart';

extension ListExtensions<T> on List<T> {
  (List<T>, List<T>) splitListInHalf({required int threshold}) {
    if (length >= threshold) {
      int breakpoint = (length / 2).ceil();
      return (sublist(0, breakpoint), sublist(breakpoint));
    } else {
      return (this, []);
    }
  }
}

extension WidgetListExtensions on Iterable<Widget> {
  Iterable<Widget> padding(EdgeInsetsGeometry padding) {
    return map((e) => Padding(padding: padding, child: e));
  }
}
