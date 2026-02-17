import 'package:chatify/controller/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Text controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Reactive variables
  final isLoading = false.obs;
  final error = "".obs;
  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() =>
      obscureCurrentPassword.value = !obscureCurrentPassword.value;

  void toggleNewPasswordVisibility() =>
      obscureNewPassword.value = !obscureNewPassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  // Validators
  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your current password";
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your new password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    if (value == currentPasswordController.text) {
      return "New password must be different from current password";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your confirm password";
    }
    if (value != newPasswordController.text) {
      return "Password does not match";
    }
    return null;
  }

  void clearError() => error.value = "";

  // Change password function
  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      error.value = "";

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in");
      }

      // Reauthenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPasswordController.text);

      Get.snackbar(
        "Success",
        "Password changed successfully",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      // Clear fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      // Sign out user
      await _authController.signOut();

    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case "wrong-password":
          errorMessage = "Current password is incorrect";
          break;
        case "weak-password":
          errorMessage = "New password is too weak";
          break;
        case "requires-recent-login":
          errorMessage =
          "Please login again and then try to change password";
          break;
        default:
          errorMessage = e.message ?? "Failed to change password";
      }

      error.value = errorMessage;
      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      error.value = "Failed to change password";
      print(e.toString());
      Get.snackbar(
        "Error",
        error.value,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
