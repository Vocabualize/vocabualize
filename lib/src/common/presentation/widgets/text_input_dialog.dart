import 'package:flutter/material.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';

class TextInputDialog extends StatefulWidget {
  final void Function(String) onSave;
  final VoidCallback? onCancel;
  final String? labelText;
  final String? hintText;
  const TextInputDialog({
    required this.onSave,
    this.onCancel,
    this.labelText,
    this.hintText,
    super.key,
  });

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  String _text = "";

  void _updateText(String text) {
    setState(() => _text = text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Dimensions.largeSpacing,
      ),
      contentPadding: const EdgeInsets.all(Dimensions.semiSmallSpacing),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                focusNode: FocusNode()..requestFocus(),
                onChanged: _updateText,
                textInputAction: TextInputAction.go,
                onSubmitted: widget.onSave,
                minLines: 1,
                maxLines: 2,
                decoration: InputDecoration(
                  label: widget.labelText?.let((t) => Text(t)),
                  hintText: widget.hintText,
                ),
              ),
            ),
            const SizedBox(width: Dimensions.smallSpacing),
            IconButton(
              onPressed: _text.isEmpty ? widget.onCancel : () => widget.onSave(_text),
              icon: switch (_text.isEmpty) {
                true => const Icon(Icons.close_rounded),
                false => const Icon(Icons.arrow_forward_rounded),
              },
            ),
          ],
        ),
      ),
    );
  }
}
