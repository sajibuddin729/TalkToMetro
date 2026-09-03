import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/modules/settings/controller/settings_controller.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late String _selectedStation;
  String? _pickedImagePath;

  final SettingsController c = Get.find<SettingsController>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: c.userName.value);
    _phoneController = TextEditingController(text: c.userPhone.value);
    _emailController = TextEditingController(text: c.userEmail.value);
    _selectedStation = c.preferredStation.value;
    // Load the currently saved profile image path
    _pickedImagePath = c.profileImagePath.value.isNotEmpty
        ? c.profileImagePath.value
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Open gallery and pick an image, then store path
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() => _pickedImagePath = image.path);
      }
    } catch (e) {
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open gallery: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: ubuntuBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            // ── Tappable Profile Avatar ──────────────────────────────
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48.r,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: _pickedImagePath != null
                        ? FileImage(File(_pickedImagePath!))
                        : null,
                    child: _pickedImagePath == null
                        ? Icon(Icons.person, size: 52.r, color: Colors.green.shade700)
                        : null,
                  ),
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.camera_alt, size: 14.r, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap photo to change',
              style: ubuntuRegular.copyWith(
                  fontSize: 11.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 20.h),

            // ── Profile Fields ────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                  initialValue: _selectedStation,
                    decoration: InputDecoration(
                      labelText: 'Preferred Metro Station',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                      prefixIcon: const Icon(Icons.subway_outlined),
                    ),
                    items: metroStationNames
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStation = val);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () async {
                await c.updateProfile(
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim(),
                  email: _emailController.text.trim(),
                  station: _selectedStation,
                  imagePath: _pickedImagePath,
                );
                Get.back();
              },
              icon: const Icon(Icons.save_alt_outlined, color: Colors.white),
              label: Text(
                'Save Changes',
                style: ubuntuBold.copyWith(fontSize: 15.sp, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: Size(double.infinity, 46.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
