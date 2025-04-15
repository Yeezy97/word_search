import 'package:get/get.dart';

class MyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'rank': 'Rank',
      'score': 'Score',
      'leaderboards': 'Leaderboards',
      'continue': 'Continue',
      'new game': 'New Game',
      'settings': 'Settings',
      'sound': 'Sound',
      'language': 'Language',
      'arabic': 'Arabic',
      'english': 'English',
      'confirm': 'Confirm',
      'back_confirmation': 'Are you sure you want to go back to menu screen?\nCurrent level progress will not be saved.',
      'yes': 'Yes',
      'no': 'No',
      // Add additional keys used in your UI
    },
    'ar_AE': {
      'rank': 'الرتبة',
      'score': 'النقاط',
      'leaderboards': 'قائمة الرتب',
      'continue': 'اكمل',
      'new game': 'بداية جديدة',
      'settings': 'الإعدادات',
      'sound': 'الصوت',
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'الإنجليزية',
      'confirm': 'تأكيد',
      'back_confirmation': 'هل أنت متأكد أنك تريد العودة إلى الشاشة الرئيسية؟\nلن يتم حفظ تقدم المستوى الحالي.',
      'yes': 'نعم',
      'no': 'لا',
      // And more keys for your UI...
    },
  };
}
