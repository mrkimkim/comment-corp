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
    with TickerProviderStateMixin {
  double _dragX = 0;
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  // Card entry animation controller (slide-up + slight bounce)
  late AnimationController _entryController;
  late Animation<double> _entrySlide;
  late Animation<double> _entryOpacity;

  double get _swipeThreshold {
    final mq = MediaQuery.maybeOf(context);
    if (mq != null) {
      return mq.size.width * 0.25;
    }
    return 80.0; // fallback
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _animOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    // Entry animation: 250ms slide-up with slight bounce
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _entrySlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutBack, // slight bounce overshoot
      ),
    );
    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOut,
      ),
    );

    // Play entry animation for the first card
    if (widget.comment != null) {
      _entryController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comment != oldWidget.comment) {
      _dragX = 0;
      _animController.reset();
      // Trigger entry animation for the new card
      _entryController.forward(from: 0);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_animController.isAnimating) return;
    setState(() => _dragX += details.delta.dx);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_animController.isAnimating) return;
    final threshold = _swipeThreshold;
    if (_dragX.abs() >= threshold) {
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
        child: CircularProgressIndicator.adaptive(),
      );
    }

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animController, _entryController]),
        builder: (context, child) {
          final swipeOffset =
              _animController.isAnimating ? _animOffset.value.dx : _dragX;
          return Opacity(
            opacity: _entryOpacity.value,
            child: Transform.translate(
              offset: Offset(0, _entrySlide.value),
              child: CommentCard(
                comment: widget.comment!,
                dragOffset: swipeOffset,
                showIndicator: true,
                detectorActive: widget.detectorActive,
              ),
            ),
          );
        },
      ),
    );
  }
}
