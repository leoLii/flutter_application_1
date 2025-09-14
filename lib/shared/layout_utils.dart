import 'package:flutter/widgets.dart';

Widget box(Rect r, Widget child) =>
    Positioned(left: r.left, top: r.top, width: r.width, height: r.height, child: child);

Widget baselineText(Offset base, String text, TextStyle style) =>
    Positioned(left: base.dx, top: base.dy - 14, child: Text(text, style: style));

Widget px(Offset p, Widget child) =>
    Positioned(left: p.dx, top: p.dy, child: child);