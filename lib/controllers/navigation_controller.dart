import 'package:get/get.dart';

class NavigationController extends GetxController {
  /// Navigates to a named route.
  void navigateTo(String routeName) {
    Get.toNamed(routeName);
  }

  /// Example: Replace the current screen with a new one.
  void navigateAndReplace(String routeName) {
    Get.offNamed(routeName);
  }

  /// Navigates back (pop).
  void goBack() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    } else {
      Get.back();
    }
  }
}