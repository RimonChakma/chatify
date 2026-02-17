import 'package:chatify/controller/auth/auth_controller.dart';
import 'package:chatify/model/user_model.dart';
import 'package:chatify/service/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxBool _isLoading = false.obs;
  final RxBool _isEditing = false.obs;
  final RxString _error = "".obs;
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  bool get isLoading => _isLoading.value;

  bool get isEditing => _isEditing.value;

  String get error => _error.value;

  UserModel? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    displayNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void _loadUserData() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      print("UID: $currentUserId");
      _currentUser.bindStream(_firestoreService.getUserStream(currentUserId));

      ever(_currentUser, (UserModel? user) {
        if (user != null) {
          displayNameController.text = user.displayName;
          emailController.text = user.email;
        }
      });
    }
  }

  void toggleEditing() {
    _isEditing.value = !_isEditing.value;
    if (_isEditing.value) {
      final user = _currentUser.value;
      if (user != null) {
        displayNameController.text = user.displayName;
        emailController.text = user.email;
      }
    }
  }

  Future<void> updateProfile() async {
    try {
      _isLoading.value = true;
      _error.value = "";

      final user = _currentUser.value;
      if (user == null) return;

      final updateUser = user.copyWith(displayName: displayNameController.text);
      await _firestoreService.updateUser(updateUser);
      _isEditing.value = false;
      Get.snackbar("success", "Profile update successfully");
    } catch (e) {
      _error.value = e.toString();
      print(e.toString());
      Get.snackbar("Error", "Failed to update profile");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authController.signOut();
    } catch (e) {
      Get.snackbar("Error", "Failed to sign out");
    }
  }

  Future<void> deleteUser() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text("Delete Account"),
          content: Text(
            "Are you sure you want to delete your account? This action can not be undone",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (result == true) {
        _isLoading.value = true;
        await _authController.deleteAccount();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete profile");
    }
  }

  String getJoinedData() {
    final user = _currentUser.value;
    if (user == null) return "";{
      final date = user.createdAt;
      final months = [
        "jan",
        "feb",
        "mar",
        "apr",
        "may",
        "jun",
        "jul",
        "aug",
        "sep",
        "aug",
        "nov",
        "dec",
      ];
      return "joined ${months[date.month - 1]}${date.year}";
    }
  }

  void clearError () {
    _error.value = "";
  }
}
