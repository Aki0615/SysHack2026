import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 円形のプロフィール写真と、画像アップロード用のカメラボタンを含むWidget
class ProfileIconWidget extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String> onImageSelected;

  const ProfileIconWidget({
    super.key,
    this.imagePath,
    required this.onImageSelected,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // ギャラリーから画像を選択
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImageSelected(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // 写真部分
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0x263AAA3A), // #3AAA3Aの15%透明度
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: imagePath != null
                ? Image.file(
                    File(imagePath!),
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.person, color: Color(0xFF3AAA3A), size: 48),
          ),
          // 編集ボタン（右下）
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF3AAA3A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
