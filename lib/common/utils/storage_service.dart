import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  Future<List<String>> uploadServiceImages(List<XFile> images) async {
    final List<String> imageUrls = [];
    
    for (final image in images) {
      final file = File(image.path);
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('services/$fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      imageUrls.add(downloadUrl);
    }
    
    return imageUrls;
  }

  Future<String?> uploadProfileImage(XFile image) async {
    try {
      final file = File(image.path);
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('profiles/$fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<List<XFile>> pickImages({int maxImages = 5}) async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (images.length > maxImages) {
      return images.take(maxImages).toList();
    }
    
    return images;
  }

  Future<XFile?> pickSingleImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
  }
}
