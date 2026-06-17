import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Shows the Post-Session Note modal and returns the user's title and note.
///
/// Returns `null` if the user taps "Skip" or dismisses the dialog.
Future<(String title, String? note)?> showPostSessionModal(
  BuildContext context, {
  String? initialTitle,
  String? initialNote,
}) {
  return showGeneralDialog<(String, String?)?>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss note dialog',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
    pageBuilder: (context, _, _) => _PostSessionModal(
      initialTitle: initialTitle,
      initialNote: initialNote,
    ),
  );
}

class _PostSessionModal extends StatefulWidget {
  const _PostSessionModal({this.initialTitle, this.initialNote});

  final String? initialTitle;
  final String? initialNote;

  @override
  State<_PostSessionModal> createState() => _PostSessionModalState();
}

class _PostSessionModalState extends State<_PostSessionModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  int _noteCharCount = 0;

  static const int _maxNoteChars = 250;
  static const int _maxTitleChars = 50;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _noteController = TextEditingController(text: widget.initialNote);
    _noteCharCount = _noteController.text.length;
    _noteController.addListener(
      () => setState(() => _noteCharCount = _noteController.text.length),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Session',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                
                // Title Field
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  maxLength: _maxTitleChars,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Session Title (e.g. Study Math)',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    counterText: '', // Hide counter for title
                  ),
                ),
                const SizedBox(height: 16),
                
                // Note Field
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  maxLength: _maxNoteChars,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppStrings.notePlaceholder,
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    counterText: '$_noteCharCount / $_maxNoteChars',
                    counterStyle: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: Text(
                          AppStrings.skipNote,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {
                          final title = _titleController.text.trim().isEmpty 
                              ? 'Untitled Session' 
                              : _titleController.text.trim();
                          Navigator.of(context).pop((title, _noteController.text));
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(AppStrings.saveSession),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
