import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/audio_utils.dart';
import 'package:back_packers/utils/file_utils.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentMessageBubble extends StatelessWidget {
  final Map<String, dynamic> documentData;
  final MsgType msgType;
  final Timestamp time;

  const DocumentMessageBubble({
    Key? key,
    required this.documentData,
    required this.msgType,
    required this.time,
  }) : super(key: key);

  Future<void> _downloadAndOpenFile() async {
    try {
      final fileUrl = documentData['url'] as String? ?? '';
      final fileName = documentData['fileName'] as String? ?? 'document';
      
      if (fileUrl.isEmpty) {
        throw Exception('File URL is empty');
      }
      
      EasyLoading.show(status: 'Downloading file...');
      log('📥 Starting download: $fileName');
      log('📍 URL: $fileUrl');

      // Download file with timeout
      final response = await http.get(
        Uri.parse(fileUrl),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Download timeout - file too large or slow connection');
        },
      );
      
      log('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download: HTTP ${response.statusCode}');
      }
      
      if (response.bodyBytes.isEmpty) {
        throw Exception('Downloaded file is empty');
      }
      
      log('✅ Downloaded ${response.bodyBytes.length} bytes');
      
      // Save to Downloads or temp directory
      Directory? directory;
      String dirPath;
      
      try {
        // Try to use Downloads directory (better for user access)
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            // Fallback to external storage
            directory = await getExternalStorageDirectory();
          }
        } else {
          // For iOS, use documents directory
          directory = await getApplicationDocumentsDirectory();
        }
        dirPath = directory!.path;
      } catch (e) {
        log('⚠️ Could not access downloads directory, using temp: $e');
        // Fallback to temp directory
        final tempDir = await getTemporaryDirectory();
        dirPath = tempDir.path;
      }
      
      // Clean filename (remove special characters)
      final cleanFileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final filePath = '$dirPath/$cleanFileName';
      
      log('💾 Saving to: $filePath');
      
      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      
      log('✅ File saved successfully');
      
      EasyLoading.dismiss();
      EasyLoading.showSuccess('File downloaded successfully!');
      
      // Try to open the file after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final uri = Uri.parse('file://$filePath');
        final canLaunch = await canLaunchUrl(uri);
        
        log('🔍 Can launch file: $canLaunch');
        
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          log('✅ File opened successfully');
        } else {
          // Show file location instead
          EasyLoading.showToast(
            'File saved to: $filePath',
            duration: const Duration(seconds: 4),
          );
          log('ℹ️ File saved but cannot auto-open this file type');
        }
      } catch (openError) {
        log('⚠️ Could not open file automatically: $openError');
        EasyLoading.showToast(
          'File saved to: $filePath',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e, stackTrace) {
      log('❌ Error downloading file: $e');
      log('Stack trace: $stackTrace');
      EasyLoading.dismiss();
      
      String errorMsg = 'Failed to download file. Please try again.';
      
      // Provide more specific error messages
      if (e.toString().contains('timeout')) {
        errorMsg = 'Download timeout. Check your internet connection.';
      } else if (e.toString().contains('SocketException')) {
        errorMsg = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('HTTP')) {
        errorMsg = 'File not accessible. It may have been deleted.';
      } else if (e.toString().contains('empty')) {
        errorMsg = 'File is corrupted or empty.';
      }
      
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Download Failed",
        strMsg: errorMsg,
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSender = msgType == MsgType.right;
    final fileName = documentData['fileName'] as String? ?? 'Document';
    final fileSize = documentData['fileSize'] as int? ?? 0;
    final fileExtension = documentData['fileExtension'] as String? ?? '';

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: _downloadAndOpenFile,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          margin: EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: isSender ? 60 : 10,
            right: isSender ? 10 : 60,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSender 
                ? AppColors.primaryColor.withOpacity(0.3) 
                : const Color(0xff383838),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: Radius.circular(isSender ? 15 : 0),
              bottomRight: Radius.circular(isSender ? 0 : 15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // File icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: FileUtils.getFileColor(fileExtension).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      FileUtils.getFileIcon(fileExtension),
                      color: FileUtils.getFileColor(fileExtension),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName.length > 25 
                              ? fileName.substring(0, 22) + '...' 
                              : fileName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSender ? Colors.white : Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              FileUtils.getFileTypeName(fileExtension),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSender ? Colors.white70 : Colors.grey[400],
                              ),
                            ),
                            const Text(' • ', style: TextStyle(color: Colors.grey)),
                            Text(
                              AudioUtils.formatFileSize(fileSize),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSender ? Colors.white70 : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Download icon
                  Icon(
                    Icons.download,
                    color: isSender ? Colors.white70 : Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Timestamp
              Text(
                _formatTime(time),
                style: TextStyle(
                  fontSize: 10,
                  color: isSender ? Colors.white60 : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

