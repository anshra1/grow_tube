import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  Widget get center => Center(child: this);

  Widget paddingAll(double padding) => Padding(
    padding: EdgeInsets.all(padding),
    child: this,
  );

  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  Widget paddingOnly({
    double top = 0.0,
    double bottom = 0.0,
    double left = 0.0,
    double right = 0.0,
  }) => Padding(
    padding: EdgeInsets.only(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    ),
    child: this,
  );

  Widget get sliver => SliverToBoxAdapter(child: this);
}
