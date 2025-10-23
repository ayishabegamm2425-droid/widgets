import 'dart:io';
import 'dart:math';

import 'package:edzi/Widgets/appColors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';


class FileSelectorField extends StatefulWidget {
  final String label;
  final String helperText;
  final List<String> allowedExtensions;
  final bool isRequired;
  final Color fillColor;
  final Color hintColor;
  final Color textColor;
  final Color labelColor;
  final Color errorColor;
  final double hintFontSize;
  final double? labelFontSize;
  final FontWeight? labelFontWeight;
  final double borderRadius;
  final Color borderColor;
  final Color focusedBorderColor;
  final String? errorText;
  final bool enabled;
  final int? index;
  final ValueChanged<File> onFileSelected;
  final VoidCallback onFileRemoved;
  final String? existingFileUrl;

  const FileSelectorField({
    Key? key,
    required this.label,
    required this.helperText,
    required this.onFileSelected,
    required this.onFileRemoved,
    this.allowedExtensions = const ['pdf', 'jpg', 'jpeg', 'png'],
    this.isRequired = true,
    this.fillColor = const Color(0xFFF8F9FA),
    this.hintColor = const Color.fromARGB(255, 79, 85, 95),
    this.textColor = const Color(0xFF111827),
    this.labelColor = const Color(0xFF374151),
    this.errorColor = Colors.red,
    this.hintFontSize = 11,
    this.labelFontSize,
    this.labelFontWeight,
    this.borderRadius = 6.0,
    this.borderColor = const Color(0xFFE5E7EB),
    this.focusedBorderColor = Colors.transparent,
    this.errorText,
    this.enabled = true,
    this.index,
    this.existingFileUrl,
  }) : super(key: key);

  @override
  _FileSelectorFieldState createState() => _FileSelectorFieldState();
}

class _FileSelectorFieldState extends State<FileSelectorField> {
  File? _selectedFile;
  bool _isUploading = false;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _processExistingFileUrl();
  }

  @override
  void didUpdateWidget(FileSelectorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingFileUrl != oldWidget.existingFileUrl) {
      _processExistingFileUrl();
    }
  }

  void _processExistingFileUrl() {
    if (widget.existingFileUrl != null && widget.existingFileUrl!.isNotEmpty) {
      try {
        // Extract the file name from the URL
        final uri = Uri.parse(widget.existingFileUrl!);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          // Get the last segment which should be the file name
          String encodedFileName = pathSegments.last;
          // Decode URI components (handles %20 for spaces, etc.)
          _fileName = Uri.decodeComponent(encodedFileName);
        } else {
          _fileName = 'Download file'; // Fallback if no path segments
        }
      } catch (e) {
        debugPrint('Error parsing file URL: $e');
        _fileName = 'Download file'; // Fallback if URL parsing fails
      }
    } else {
      _fileName = null;
    }
  }
Future<void> _pickFile() async {
  if (!widget.enabled) return;

  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      final file = File(result.files.first.path!);
      final fileSize = await file.length();
      
      // Check file size (3MB limit)
      if (fileSize > 3 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size must be less than 3MB')),
        );
        return;
      }

      setState(() {
        _selectedFile = file;
        _isUploading = true;
        _fileName = _selectedFile?.path.split('/').last;
      });
      widget.onFileSelected(_selectedFile!);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error picking file: ${e.toString()}')),
    );
  } finally {
    setState(() => _isUploading = false);
  }
}

 Future<void> _removeFile() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MyColors.redColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: MyColors.redColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Confirm File Deletion',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MyColors.darkBlue,
            ),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete this file?',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(70, 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: MyColors.lightThemeIconGrey,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.redColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(
            'Delete',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
    widget.onFileRemoved();
  }
}

  void _viewFile() {
    if (widget.existingFileUrl != null) {
      launchUrl(Uri.parse(widget.existingFileUrl!));
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

 @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileSize = _selectedFile != null 
        ? _formatFileSize(_selectedFile!.lengthSync()) 
        : '';
    final hasExistingFile = widget.existingFileUrl != null && _selectedFile == null;
    final hasFile = _selectedFile != null || hasExistingFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.labelFontSize ?? 12,
                fontWeight: widget.labelFontWeight ?? FontWeight.w500,
                color: widget.labelColor,
              ),
            ),
          ),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: !widget.enabled ? widget.fillColor.withOpacity(0.5) : widget.fillColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.errorText != null ? widget.errorColor : widget.borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (!hasFile)
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !widget.enabled ? Colors.grey.shade300 : MyColors.leaveColor,
                      foregroundColor: !widget.enabled ? Colors.grey.shade500 : Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(widget.borderRadius - 2),
                      ),
                    ),
                    onPressed: !widget.enabled ? null : _pickFile,
                    child: Text(
                      'Choose File',
                      style: TextStyle(
                        fontSize: widget.hintFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              if (!hasFile) const SizedBox(width: 12),
               Expanded(
    child: InkWell(
      onTap: hasExistingFile ? _viewFile : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasFile) Text(
              _fileName ?? 'File',
              style: TextStyle(
                fontSize: widget.hintFontSize,
                color: !widget.enabled 
                    ? theme.disabledColor 
                    : hasExistingFile 
                        ? Colors.blue 
                        : widget.textColor,
                fontWeight: FontWeight.w400,
                decoration: hasExistingFile 
                    ? TextDecoration.underline 
                    : TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (!hasFile) Text(
              'No file chosen',
              style: TextStyle(
                fontSize: widget.hintFontSize,
                color: widget.hintColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (fileSize.isNotEmpty)
              Text(
                fileSize,
                style: TextStyle(
                  fontSize: widget.hintFontSize - 2,
                  color: !widget.enabled ? theme.disabledColor : widget.hintColor,
                ),
              ),
          ],
        ),
      ),
    ),
  ),
              if (hasFile && widget.enabled)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.grey,
                  onPressed: _removeFile,
                ),
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: widget.errorColor,
                fontSize: widget.hintFontSize - 2,
              ),
            ),
          ),
        if (widget.helperText.isNotEmpty && widget.errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              widget.helperText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.hintColor,
                fontSize: widget.hintFontSize - 2,
              ),
            ),
          ),
      ],
    );
  }
}