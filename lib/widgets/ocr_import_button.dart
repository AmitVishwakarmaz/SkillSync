/// Reusable OCR Import Button widget
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ocr_result_model.dart';
import '../providers/ocr_provider.dart';

/// A drop-in button widget for OCR import functionality
///
/// Usage:
/// ```dart
/// OcrImportButton(
///   onResult: (result) {
///     // Handle extracted skills
///     for (final skill in result.extractedSkills) {
///       print('Found: ${skill.name}');
///     }
///   },
/// )
/// ```
class OcrImportButton extends StatelessWidget {
  /// Callback when OCR successfully extracts skills
  final void Function(OcrResult result)? onResult;

  /// Custom button text (default: "Import from Document")
  final String? buttonText;

  /// Custom icon (default: document scanner icon)
  final IconData? icon;

  /// Whether to show as an icon-only button
  final bool iconOnly;

  const OcrImportButton({
    super.key,
    this.onResult,
    this.buttonText,
    this.icon,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OcrProvider(),
      child: _OcrImportButtonContent(
        onResult: onResult,
        buttonText: buttonText,
        icon: icon,
        iconOnly: iconOnly,
      ),
    );
  }
}

class _OcrImportButtonContent extends StatelessWidget {
  final void Function(OcrResult result)? onResult;
  final String? buttonText;
  final IconData? icon;
  final bool iconOnly;

  const _OcrImportButtonContent({
    this.onResult,
    this.buttonText,
    this.icon,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OcrProvider>();

    if (iconOnly) {
      return IconButton(
        onPressed: provider.isProcessing
            ? null
            : () => _showSourcePicker(context),
        icon: provider.isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon ?? Icons.document_scanner_outlined),
        tooltip: buttonText ?? 'Import from Document',
      );
    }

    return ElevatedButton.icon(
      onPressed: provider.isProcessing
          ? null
          : () => _showSourcePicker(context),
      icon: provider.isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.document_scanner_outlined),
      label: Text(buttonText ?? 'Import from Document'),
    );
  }

  void _showSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _SourcePickerSheet(
        onSourceSelected: (source) async {
          Navigator.pop(sheetContext);
          await _processImage(context, source);
        },
      ),
    );
  }

  Future<void> _processImage(
    BuildContext context,
    OcrImageSource source,
  ) async {
    final provider = context.read<OcrProvider>();
    final result = await provider.pickAndProcessImage(source);

    if (!context.mounted) return;

    if (provider.error != null) {
      _showError(context, provider.error!);
      return;
    }

    if (result != null) {
      if (result.hasSkills) {
        _showSuccess(context, result.extractedSkills.length);
        onResult?.call(result);
      } else if (result.hasText) {
        _showNoSkillsFound(context);
        onResult?.call(result);
      } else {
        _showNoTextFound(context);
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _showSourcePicker(context),
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, int skillCount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Found $skillCount skill${skillCount == 1 ? '' : 's'}!'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _showNoSkillsFound(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text found, but no matching skills detected.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showNoTextFound(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No text found in image. Try a clearer image.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

/// Bottom sheet for selecting image source
class _SourcePickerSheet extends StatelessWidget {
  final void Function(OcrImageSource source) onSourceSelected;

  const _SourcePickerSheet({required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Import Skills From',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
              title: const Text('Camera'),
              subtitle: const Text('Take a photo of a document'),
              onTap: () => onSourceSelected(OcrImageSource.camera),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.photo_library)),
              title: const Text('Gallery'),
              subtitle: const Text('Choose an existing image'),
              onTap: () => onSourceSelected(OcrImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
