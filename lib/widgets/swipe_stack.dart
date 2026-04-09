import 'package:flutter/material.dart';
import '../models/comment.dart';
import 'comment_card.dart';

class SwipeStack extends StatefulWidget {
  final Comment? comment;
  final void Function(bool approve) onSwiped;
  final bool detectorActive;

  const SwipeStack({
    super.key,
    required this.comment,
    required this.onSwiped,
    this.detectorActive = false,
  });

  @override
  State<SwipeStack> createState() => _SwipeStackState();
}

class _SwipeStackState extends State<SwipeStack>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  late AnimationController _animController;
  late Animation<Offset> _animOffset;
  static const _swipeThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comment != oldWidget.comment) {
      _dragX = 0;
      _animController.reset();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _dragX += details.delta.dx);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragX.abs() >= _swipeThreshold) {
      final approve = _dragX > 0;
      final screenWidth = MediaQuery.of(context).size.width;
      _animOffset = Tween<Offset>(
        begin: Offset(_dragX, 0),
        end: Offset(approve ? screenWidth : -screenWidth, 0),
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ));
      _animController.forward(from: 0).then((_) {
        widget.onSwiped(approve);
        setState(() => _dragX = 0);
        _animController.reset();
      });
    } else {
      _animOffset = Tween<Offset>(
        begin: Offset(_dragX, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ));
      _animController.forward(from: 0).then((_) {
        setState(() => _dragX = 0);
        _animController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comment == null) {
      return const Center(
        child: Text('댓글 준비 중...', style: TextStyle(color: Colors.grey)),
      );
    }

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final offset =
              _animController.isAnimating ? _animOffset.value.dx : _dragX;
          return CommentCard(
            comment: widget.comment!,
            dragOffset: offset,
            showIndicator: true,
            detectorActive: widget.detectorActive,
          );
        },
      ),
    );
  }
}
