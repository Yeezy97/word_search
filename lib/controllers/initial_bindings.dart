import 'package:get/get.dart';
import 'package:word_search/controllers/navigation_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies(){
    Get.put(NavigationController());
  }
}