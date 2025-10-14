import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_image_v2/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import '../../globals/chat_database.dart';
import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../models/chat_model.dart';
import '../../models/local_chat_model.dart';
import '../../utils/login_details.dart';
import '../../utils/audio_utils.dart';
import '../../services/audio_service.dart';
import 'voice_recording_controller.dart';
import 'audio_player_controller.dart';
import '../../screens/main_screens/chat_view/location_picker_screen.dart';

class ChatDetailController extends GetxController {
  bool mShowData = false;
  bool isShowLoader = false;
  bool isShowEmojis = false;

  // late io.Socket socket;
  List<LocalChatModel> alChat = [];
  int initialCount = 0;
  TextEditingController controllerMessage = TextEditingController();

  bool showSendButton = false;

  String imgProfilePic = '';
  String id = '';
  String userId = '';

  // Voice recording
  late VoiceRecordingController voiceRecordingController;
  late AudioPlayerController audioPlayerController;
  bool isUploadingVoice = false;
  double uploadProgress = 0.0;

  @override
  void onInit() {
    super.onInit();
    voiceRecordingController = VoiceRecordingController();
    audioPlayerController = Get.put(AudioPlayerController(), permanent: false);
  }

  @override
  void onClose() {
    voiceRecordingController.dispose();
    // Don't dispose here - GetX will handle it
    try {
      Get.delete<AudioPlayerController>();
    } catch (e) {
      log('Error deleting AudioPlayerController: $e');
    }
    super.onClose();
  }

  changeText(String strvalue) {
    if (Global.checkNull(strvalue) && strvalue.trim().isNotEmpty) {
      showSendButton = true;
    } else {
      showSendButton = false;
    }
    update();
  }

  Future<void> sendMessage({List<String> files = const []}) async {
    if (controllerMessage.text.trim().isNotEmpty || files.isNotEmpty) {
      // Determine message type
      MessageType msgType = MessageType.text;
      if (files.isNotEmpty) {
        msgType = MessageType.image;
      }

      await FireDatabase.addMessage(
          id,
          ChatModel(
            from: Get.find<UserDetail>().userId,
            to: userId,
            message: controllerMessage.text.trim(),
            files: files,
            timeStamp: Timestamp.now(),
            messageType: msgType,
          ));
    }

    controllerMessage.clear();
    showSendButton = false;
    update();
  }

  addEmojis(String strvalue) {
    controllerMessage.text = controllerMessage.text + strvalue;
    showSendButton = true;
    update();
  }

  showEmoji() {
    isShowEmojis = isShowEmojis ? false : true;
    update();
  }

  disableEmoji() {
    isShowEmojis = false;

    update();
  }

  List<String> emojis = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😅',
    '😂',
    '🤣',
    '🥲',
    '😊',
    '😇',
    '🙂',
    '🙃',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚'
  ];

  /// Show attachment picker for documents (WhatsApp style)
  void showAttachmentPicker(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Attach',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.insert_drive_file, color: Colors.orange),
                    ),
                    title: const Text('Document'),
                    subtitle: const Text('PDF, DOC, XLS, etc.', style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await pickDocument();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_library, color: Colors.green),
                    ),
                    title: const Text('Gallery'),
                    subtitle: const Text('Photos and videos', style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      _showGalleryOptions(context);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, color: Colors.red),
                    ),
                    title: const Text('Location'),
                    subtitle: const Text('Share your location', style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await pickLocation();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  /// Show camera options (photo or video)
  void showCameraOptions(context) {
    _showCameraOptions(context);
  }

  void _showCameraOptions(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Use Camera',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_camera, color: Colors.blue),
                    ),
                    title: const Text('Take Photo'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await imgFromCamera2();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.videocam, color: Colors.red),
                    ),
                    title: const Text('Record Video'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await pickVideo(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  void _showGalleryOptions(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_library, color: Colors.green),
                    ),
                    title: const Text('Photos'),
                    subtitle: const Text('Choose from gallery', style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await imgFromGallery2();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.video_library, color: Colors.purple),
                    ),
                    title: const Text('Video'),
                    subtitle: const Text('Choose from gallery', style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await pickVideo(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  /// Pick and send document/file
  Future<void> pickDocument() async {
    try {
      log('Opening file picker for documents...');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip', 'rar'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        log('User cancelled file selection');
        return;
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileExtension = result.files.single.extension ?? '';
      
      log('File selected: $fileName, size: ${result.files.single.size} bytes');
      
      await uploadDocument(file, fileName, fileExtension);
    } catch (e) {
      log('Error picking document: $e');
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "Failed to pick file. Please try again.",
          toastType: TOAST_TYPE.toastError);
    }
  }

  /// Upload document to Firebase Storage
  Future<void> uploadDocument(File documentFile, String fileName, String extension) async {
    try {
      loading = true;
      update();
      
      log('Starting document upload: $fileName');

      // Check file size (25 MB limit for documents)
      final fileSize = await documentFile.length();
      log('Document file size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');
      
      if (fileSize > 25 * 1024 * 1024) {
        loading = false;
        update();
        EasyLoading.dismiss();
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Error",
            strMsg: "File is too large. Maximum size is 25MB.",
            toastType: TOAST_TYPE.toastError);
        return;
      }

      EasyLoading.show(status: 'Uploading document...');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'doc_${timestamp}_$fileName';
      final filePath = 'chats/$id/documents/$uniqueFileName';

      log('Uploading to: $filePath');

      // Upload to Firebase Storage
      final Reference ref = FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask = ref.putFile(documentFile);

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        EasyLoading.showProgress(
          progress, 
          status: 'Uploading ${(progress * 100).toStringAsFixed(0)}%'
        );
        log('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final TaskSnapshot taskSnapshot = await uploadTask
          .timeout(const Duration(minutes: 3), onTimeout: () {
        throw Exception('Upload timeout - please check your internet connection');
      });
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      log('Document uploaded successfully');

      // Send message with document
      await FireDatabase.addMessage(
        id,
        ChatModel(
          from: Get.find<UserDetail>().userId,
          to: userId,
          message: fileName,
          files: [],
          timeStamp: Timestamp.now(),
          messageType: MessageType.document,
          voiceData: {
            'url': downloadUrl,
            'fileName': fileName,
            'fileSize': fileSize,
            'fileExtension': extension,
          },
        ),
      );

      loading = false;
      update();
      
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Document sent!');
      
      log('Document upload complete: $downloadUrl');
    } catch (e) {
      log('Error uploading document: $e');
      loading = false;
      update();
      
      EasyLoading.dismiss();
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "Failed to upload document. Please try again.\n${e.toString()}",
          toastType: TOAST_TYPE.toastError);
    }
  }

  imgFromCamera2() async {
    try {
      log('Opening camera for photo...');
      ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        log('User cancelled photo capture');
        return;
      }
      
      log('Photo captured: ${pickedFile.path}');
      await imageCompressor([pickedFile]);
    } catch (e) {
      log('Error picking image from camera: $e');
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "Failed to capture photo. Please try again.",
          toastType: TOAST_TYPE.toastError);
    }
  }

  imgFromGallery2() async {
    try {
      log('Opening gallery for photos...');
      ImagePicker picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 85,
      );
      
      if (pickedFiles.isEmpty) {
        log('User cancelled photo selection');
        return;
      }
      
      log('Selected ${pickedFiles.length} photos');
      await imageCompressor(pickedFiles);
    } catch (e) {
      log('Error picking images from gallery: $e');
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "Failed to select photos. Please try again.",
          toastType: TOAST_TYPE.toastError);
    }
  }

  var loading = false;

  imageCompressor(List<XFile> selectedImage) async {
    if (selectedImage.isEmpty) {
      log('No images selected');
      return;
    }

    try {
      log('Starting compression for ${selectedImage.length} images');
      loading = true;
      update();
      EasyLoading.show(status: 'Processing ${selectedImage.length} photo(s)...');

      List<File> files = [];
      for (int i = 0; i < selectedImage.length; i++) {
        log('Processing image ${i + 1}/${selectedImage.length}: ${selectedImage[i].path}');
        
        // Check if file exists
        final File originalFile = File(selectedImage[i].path);
        if (!await originalFile.exists()) {
          log('ERROR: Image file does not exist: ${selectedImage[i].path}');
          throw Exception('Image file not found');
        }

        // Try to compress image, fallback to original if fails
        try {
          log('Attempting to compress image ${i + 1}...');
          File compressedFile = await FlutterNativeImage.compressImage(
              selectedImage[i].path,
              quality: 30,
              percentage: 50).timeout(
                const Duration(seconds: 30),
                onTimeout: () {
                  log('Compression timeout, using original');
                  return originalFile;
                },
              );

          files.add(compressedFile);
          log('Image ${i + 1} compressed successfully: ${compressedFile.path}');
        } catch (compressError) {
          log('⚠️ Compression failed for image $i, using original file: $compressError');
          // If compression fails, use original file
          files.add(originalFile);
          log('Using original file instead: ${originalFile.path}');
        }
      }

      log('All images processed (${files.length} files), starting upload');
      EasyLoading.dismiss();
      await uploadImage(files);
    } catch (e, stackTrace) {
      log('Error processing images: $e');
      log('Stack trace: $stackTrace');
      loading = false;
      update();
      EasyLoading.dismiss();
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "Failed to process images: ${e.toString()}",
          toastType: TOAST_TYPE.toastError);
    }
  }

  Future<void> uploadImage(List<File> files) async {
    log('Uploading ${files.length} images');
    if (files.isEmpty) {
      loading = false;
      update();
      return;
    }

    try {
      loading = true;
      update();
      EasyLoading.show(status: 'Uploading ${files.length} photo(s)...');

      List<String> uploadedUrls = [];

      for (int i = 0; i < files.length; i++) {
        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'image_${timestamp}_$i.jpg';
        final filePath = 'chats/$id/images/$fileName';

        log('Uploading image $i: $filePath');

        // Upload to Firebase Storage
        final Reference ref = FirebaseStorage.instance.ref().child(filePath);
        final UploadTask uploadTask = ref.putFile(files[i]);
        
        // Track progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          EasyLoading.showProgress(
            progress, 
            status: 'Uploading image ${i + 1}/${files.length} - ${(progress * 100).toStringAsFixed(0)}%'
          );
        });

        final TaskSnapshot taskSnapshot = await uploadTask
            .timeout(const Duration(minutes: 2), onTimeout: () {
          throw Exception('Upload timeout - please check your internet connection');
        });
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        
        uploadedUrls.add(downloadUrl);
        log('Image uploaded: $downloadUrl');
      }

      log('Sending message to Firestore with ${uploadedUrls.length} images');

      // Send message with uploaded images
      await sendMessage(files: uploadedUrls);
      
      loading = false;
      update();
      
      EasyLoading.dismiss();
      EasyLoading.showSuccess('${files.length} photo(s) sent!');
      
      log('All images uploaded successfully');
    } catch (e) {
      log('Error uploading images: $e');
      loading = false;
      update();
      
      EasyLoading.dismiss();
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "Failed to upload photos. Please try again.\n${e.toString()}",
          toastType: TOAST_TYPE.toastError);
    }
  }

  /// Pick and send video
  Future<void> pickVideo(ImageSource source) async {
    try {
      ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickVideo(source: source);
      
      if (pickedFile != null) {
        await uploadVideo(File(pickedFile.path));
      }
    } catch (e) {
      log('Error picking video: $e');
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "Failed to pick video.",
          toastType: TOAST_TYPE.toastError);
    }
  }

  /// Upload video to Firebase Storage
  Future<void> uploadVideo(File videoFile) async {
    try {
      loading = true;
      update();
      
      log('Starting video upload...');

      // Check file size (100 MB limit)
      final fileSize = await videoFile.length();
      log('Video file size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');
      
      if (fileSize > 100 * 1024 * 1024) {
        loading = false;
        update();
        EasyLoading.dismiss();
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Error",
            strMsg: "Video is too large. Maximum size is 100MB.",
            toastType: TOAST_TYPE.toastError);
        return;
      }

      EasyLoading.show(status: 'Uploading video...');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'video_$timestamp.mp4';
      final filePath = 'chats/$id/videos/$fileName';

      log('Uploading to: $filePath');

      // Upload to Firebase Storage
      final Reference ref = FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask = ref.putFile(videoFile);

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        EasyLoading.showProgress(
          progress, 
          status: 'Uploading video ${(progress * 100).toStringAsFixed(0)}%'
        );
        log('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final TaskSnapshot taskSnapshot = await uploadTask
          .timeout(const Duration(minutes: 3), onTimeout: () {
        throw Exception('Upload timeout - please check your internet connection');
      });
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      log('Video uploaded successfully, getting duration...');

      // Get video duration
      int duration = await _getVideoDuration(videoFile);

      log('Sending video message to Firestore...');

      // Send message with video
      await FireDatabase.addMessage(
        id,
        ChatModel(
          from: Get.find<UserDetail>().userId,
          to: userId,
          message: 'Video',
          files: [],
          timeStamp: Timestamp.now(),
          messageType: MessageType.video,
          voiceData: {
            'url': downloadUrl,
            'duration': duration,
            'fileSize': fileSize,
          },
        ),
      );

      loading = false;
      update();
      
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Video sent!');
      
      log('Video upload complete: $downloadUrl');
    } catch (e) {
      log('Error uploading video: $e');
      loading = false;
      update();
      
      EasyLoading.dismiss();
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "Failed to upload video. Please try again.\n${e.toString()}",
          toastType: TOAST_TYPE.toastError);
    }
  }

  /// Get video duration in seconds
  Future<int> _getVideoDuration(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      final duration = controller.value.duration.inSeconds;
      await controller.dispose();
      return duration;
    } catch (e) {
      log('Error getting video duration: $e');
      return 0;
    }
  }

  /// Send voice message
  Future<void> sendVoiceMessage() async {
    try {
      // Get recorded file
      final File? audioFile = voiceRecordingController.getRecordingFile();
      if (audioFile == null) {
        log('No audio file to send');
        return;
      }

      // Show loading
      isUploadingVoice = true;
      uploadProgress = 0.0;
      update();
      EasyLoading.show(status: 'Uploading voice message...');

      // Get file size and duration
      final fileSize = await AudioUtils.getFileSize(audioFile.path);
      final duration =
          AudioUtils.durationToSeconds(voiceRecordingController.recordingDuration);

      // Upload to Firebase Storage
      final uploadResult = await AudioService.uploadAudioWithRetry(
        audioFile: audioFile,
        chatRoomId: id,
        onProgress: (progress) {
          uploadProgress = progress;
          update();
        },
      );

      if (uploadResult['success'] != true) {
        throw Exception('Upload failed: ${uploadResult['error']}');
      }

      final audioUrl = uploadResult['url'] as String;

      // Create voice message
      final voiceData = {
        'url': audioUrl,
        'duration': duration,
        'fileSize': fileSize,
      };

      // Send message to Firestore
      await FireDatabase.addMessage(
        id,
        ChatModel(
          from: Get.find<UserDetail>().userId,
          to: userId,
          message: 'Voice message',
          files: [],
          timeStamp: Timestamp.now(),
          messageType: MessageType.voice,
          voiceData: voiceData,
        ),
      );

      // Clean up
      await voiceRecordingController.reset();
      isUploadingVoice = false;
      uploadProgress = 0.0;
      update();

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Voice message sent!');

      log('Voice message sent successfully');
    } catch (e) {
      log('Error sending voice message: $e');
      isUploadingVoice = false;
      uploadProgress = 0.0;
      update();

      EasyLoading.dismiss();
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to send voice message. Please try again.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  /// Cancel voice recording
  Future<void> cancelVoiceRecording() async {
    await voiceRecordingController.cancelRecording();
    isUploadingVoice = false;
    uploadProgress = 0.0;
    update();
  }

  /// Handle voice send from locked recording
  Future<void> handleLockedVoiceSend() async {
    final path = await voiceRecordingController.stopRecording();
    if (path != null) {
      await sendVoiceMessage();
    }
  }

  /// Pick and send location
  Future<void> pickLocation() async {
    try {
      log('Opening location picker...');
      
      // Import the location picker screen dynamically
      final result = await Get.to(() => 
        const LocationPickerScreen()
      );

      if (result != null && result is Map<String, dynamic>) {
        log('Location selected: ${result['latitude']}, ${result['longitude']}');
        await sendLocationMessage(result);
      } else {
        log('Location picker cancelled');
      }
    } catch (e) {
      log('Error picking location: $e');
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to pick location. Please try again.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  /// Send location message
  Future<void> sendLocationMessage(Map<String, dynamic> locationData) async {
    try {
      log('Sending location message...');
      
      loading = true;
      update();
      EasyLoading.show(status: 'Sending location...');

      // Send message to Firestore
      await FireDatabase.addMessage(
        id,
        ChatModel(
          from: Get.find<UserDetail>().userId,
          to: userId,
          message: 'Location',
          files: [],
          timeStamp: Timestamp.now(),
          messageType: MessageType.location,
          voiceData: locationData,
        ),
      );

      loading = false;
      update();
      
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Location sent!');
      
      log('Location message sent successfully');
    } catch (e) {
      log('Error sending location message: $e');
      loading = false;
      update();
      
      EasyLoading.dismiss();
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to send location. Please try again.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }
}
