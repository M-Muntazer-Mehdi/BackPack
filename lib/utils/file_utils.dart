import 'package:flutter/material.dart';

class FileUtils {
  /// Get icon for file extension
  static IconData getFileIcon(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    
    switch (ext) {
      // PDF
      case 'pdf':
        return Icons.picture_as_pdf;
      
      // Word
      case 'doc':
      case 'docx':
        return Icons.description;
      
      // Excel
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      
      // PowerPoint
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      
      // Text
      case 'txt':
        return Icons.text_snippet;
      
      // Archives
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      
      // Images
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      
      // Videos
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam;
      
      // Audio
      case 'mp3':
      case 'wav':
      case 'm4a':
        return Icons.audio_file;
      
      // Default
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Get color for file extension
  static Color getFileColor(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    
    switch (ext) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'txt':
        return Colors.grey;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  /// Get file type name
  static String getFileTypeName(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    
    switch (ext) {
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'xls':
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'csv':
        return 'CSV File';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint';
      case 'txt':
        return 'Text File';
      case 'zip':
      case 'rar':
      case '7z':
        return 'Archive';
      default:
        return ext.toUpperCase() + ' File';
    }
  }

  /// Check if file can be previewed
  static bool canPreview(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    return ['pdf', 'txt', 'jpg', 'jpeg', 'png', 'gif'].contains(ext);
  }
}

