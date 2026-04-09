import 'package:flutter/material.dart';

class RotatedAwareTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const RotatedAwareTextField({
    required this.controller,
    required this.onChanged,
  });

  @override
  State<RotatedAwareTextField> createState() => _RotatedAwareTextFieldState();
}

class _RotatedAwareTextFieldState extends State<RotatedAwareTextField>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  void _showKeyboard() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            elevation: 8,
            child: _CustomKeyboardWidget(
              onKeyTap: (key) {
                final text = widget.controller.text + key;
                widget.controller.text = text;
                widget.controller.selection = TextSelection.collapsed(
                  offset: text.length,
                );
                widget.onChanged(text);
              },
              onBackspace: () {
                final text = widget.controller.text;
                if (text.isNotEmpty) {
                  final newText = text.substring(0, text.length - 1);
                  widget.controller.text = newText;
                  widget.controller.selection = TextSelection.collapsed(
                    offset: newText.length,
                  );
                  widget.onChanged(newText);
                }
              },
              onDone: _removeKeyboard,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward();
  }

  Future<void> _removeKeyboard() async {
    await _animController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: true,
      onTap: _showKeyboard,
      decoration: InputDecoration(
        suffixIcon: _overlayEntry != null
            ? IconButton(
                icon: const Icon(Icons.keyboard_hide),
                onPressed: _removeKeyboard,
              )
            : null,
      ),
    );
  }
}

class _CustomKeyboardWidget extends StatelessWidget {
  final Function(String) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onDone;

  const _CustomKeyboardWidget({
    required this.onKeyTap,
    required this.onBackspace,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
    ];

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...rows.map(
            (row) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row
                  .map(
                    (key) => _KeyButton(label: key, onTap: () => onKeyTap(key)),
                  )
                  .toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onBackspace,
                child: const Icon(Icons.backspace),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => onKeyTap(' '),
                  child: const Text('Space'),
                ),
              ),
              TextButton(onPressed: onDone, child: const Text('Done')),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
