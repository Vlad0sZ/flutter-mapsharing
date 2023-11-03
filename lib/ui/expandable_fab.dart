
import 'package:flutter/material.dart';
import 'dart:math';

class ExpandableFloatingActionButton extends StatefulWidget {
  const ExpandableFloatingActionButton({
    super.key,
    this.initialOpen,
    required this.children
  });

  final bool? initialOpen;
  final List<Widget> children;

  @override
  State<ExpandableFloatingActionButton> createState() => _ExpandableFloatingActionButtonState();
}

class _ExpandableFloatingActionButtonState extends State<ExpandableFloatingActionButton>
  with SingleTickerProviderStateMixin
{

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isOpen = false;


  @override
  void initState() {
    super.initState();
    _isOpen = widget.initialOpen ?? false;
    _controller = AnimationController(
        value: _isOpen ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        vsync: this
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          //_buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return FloatingActionButton(
      onPressed: _toggleFab,
      child: Icon(_isOpen ? Icons.close : Icons.add_circle_outline),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
    i < count;
    i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: 100.0,
          progress: _expandAnimation,
          child: IgnorePointer(
              ignoring: !_isOpen,
              child: widget.children[i]
          ),
        ),
      );
    }

    return children;
  }

  void _toggleFab() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {

  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child
  });


  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
            directionInDegrees * (pi / 180.0),
            progress.value * maxDistance
        );

        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),);
  }
}
