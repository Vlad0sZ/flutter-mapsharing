import 'package:flutter/material.dart';

class CirclePoint extends StatelessWidget {
  final Color color;

  const CirclePoint({super.key, this.color = Colors.red});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image(
        image: const AssetImage('assets/white_circle.png'),
        color: color,
      ),
    );
  }
}

class CircleMaterialPoint extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final Function()? onTap;
  final Function()? onLongTap;

  const CircleMaterialPoint(
      {super.key, this.color, this.child, this.onTap, this.onLongTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        onTap: onTap,
        onLongPress: onLongTap,
        child: child,
      ),
    );
  }
}

class DraggablePinPoint extends StatefulWidget {
  final Color color;
  final GlobalKey? draggableKey;
  final Widget draggableChild;
  final Function(Offset position, bool wasAccepted)? onDragCompleted;
  final Function()? onTap;
  final Function()? onLongTap;

  const DraggablePinPoint({
    super.key,
    required this.draggableChild,
    this.draggableKey,
    this.color = Colors.white,
    this.onTap,
    this.onDragCompleted,
    this.onLongTap,
  });

  @override
  State<DraggablePinPoint> createState() => _DraggablePinPointState();
}

class _DraggablePinPointState extends State<DraggablePinPoint> {
  Offset? _tapOffset;

  @override
  Widget build(BuildContext context) {
    return Draggable(
        data: 1,
        onDragEnd: _onDragEnd,
        dragAnchorStrategy: childDragAnchorStrategy,
        feedback: Center(child: widget.draggableChild),
        child: CircleMaterialPoint(
          color: widget.color,
          onTap: _onDraggableTap,
          onLongTap: _onDraggableLongTap,
        ));
  }

  void _onDragEnd(DraggableDetails details) {
    Offset offset = details.offset;
    if (widget.draggableKey != null) {
      offset = _convertToParentLocalPosition(widget.draggableKey!, offset);
    }

    widget.onDragCompleted?.call(offset, details.wasAccepted);
  }

  void _onDraggableTap() => widget.onTap?.call();

  void _onDraggableLongTap() => widget.onLongTap?.call();

  Offset _convertToParentLocalPosition(
      GlobalKey parentKey, Offset childPosition) {
    final parentBox =
        parentKey.currentContext?.findRenderObject() as RenderBox?;

    if (parentBox == null) {
      throw Exception();
    }

    final childBox = context.findRenderObject() as RenderBox?;
    if (childBox == null) {
      throw Exception();
    }

    final parentPosition = parentBox.localToGlobal(Offset.zero);
    final childSize = childBox.size;
    final tapOffset = Offset(childSize.width / 2.0, childSize.height / 2.0);

    final x = childPosition.dx + tapOffset.dx - parentPosition.dx;
    final y = childPosition.dy + tapOffset.dy - parentPosition.dy;

    return Offset(x, y);

    final childPos = childBox.localToGlobal(Offset.zero);
    final childHeight = childBox.size.height;

    print('child position = $childPos');
    //final x = childPosition.dx - parentPosition.dx;
    //final y = (childPosition.dy + parentPosition.dy + childHeight).abs();

    return Offset(x, y);
  }
}
