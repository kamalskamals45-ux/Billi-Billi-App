import 'dart:io';
import 'dart:ui' as ui;
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/online_social_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class AppSettings {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  final ValueNotifier<String> language = ValueNotifier<String>('hi');

  static const languages = <Map<String, String>>[
    {'code': 'hi', 'name': 'हिन्दी', 'native': 'हिन्दी'},
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    {'code': 'pa', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    {'code': 'ur', 'name': 'Urdu', 'native': 'اردو'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
    {'code': 'pt', 'name': 'Portuguese', 'native': 'Português'},
    {'code': 'fr', 'name': 'French', 'native': 'Français'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
    {'code': 'it', 'name': 'Italian', 'native': 'Italiano'},
    {'code': 'id', 'name': 'Indonesian', 'native': 'Bahasa Indonesia'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
    {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'native': '한국어'},
    {'code': 'ru', 'name': 'Russian', 'native': 'Русский'},
    {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
  ];

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ValueNotifier<bool> notifications = ValueNotifier<bool>(true);
  final ValueNotifier<bool> privateAccount = ValueNotifier<bool>(false);
  final ValueNotifier<bool> biometricLock = ValueNotifier<bool>(false);
  final ValueNotifier<bool> dataSaver = ValueNotifier<bool>(false);
  final ValueNotifier<bool> autoplay = ValueNotifier<bool>(true);
  final ValueNotifier<String> country = ValueNotifier<String>('IN');
  final ValueNotifier<bool> secureStorageReady = ValueNotifier<bool>(false);
  final ValueNotifier<bool> biometricAvailable = ValueNotifier<bool>(false);

  static const countries = <Map<String, String>>[
    {'code':'IN','name':'India','native':'भारत'}, {'code':'US','name':'United States','native':'United States'},
    {'code':'GB','name':'United Kingdom','native':'United Kingdom'}, {'code':'CA','name':'Canada','native':'Canada'},
    {'code':'AU','name':'Australia','native':'Australia'}, {'code':'AE','name':'United Arab Emirates','native':'الإمارات العربية المتحدة'},
    {'code':'SA','name':'Saudi Arabia','native':'السعودية'}, {'code':'SG','name':'Singapore','native':'Singapore'},
    {'code':'MY','name':'Malaysia','native':'Malaysia'}, {'code':'ID','name':'Indonesia','native':'Indonesia'},
    {'code':'JP','name':'Japan','native':'日本'}, {'code':'KR','name':'South Korea','native':'대한민국'},
    {'code':'CN','name':'China','native':'中国'}, {'code':'DE','name':'Germany','native':'Deutschland'},
    {'code':'FR','name':'France','native':'France'}, {'code':'IT','name':'Italy','native':'Italia'},
    {'code':'ES','name':'Spain','native':'España'}, {'code':'BR','name':'Brazil','native':'Brasil'},
    {'code':'MX','name':'Mexico','native':'México'}, {'code':'ZA','name':'South Africa','native':'South Africa'},
  ];

  // ISO-style locale/currency metadata used by the international UI.
  // The backend should remain the source of truth for prices and payments.
  static const countryMeta = <String, Map<String, String>>{
    'IN': {'locale': 'hi-IN', 'currency': 'INR', 'symbol': '₹'},
    'US': {'locale': 'en-US', 'currency': 'USD', 'symbol': r'$'},
    'GB': {'locale': 'en-GB', 'currency': 'GBP', 'symbol': '£'},
    'CA': {'locale': 'en-CA', 'currency': 'CAD', 'symbol': r'$'},
    'AU': {'locale': 'en-AU', 'currency': 'AUD', 'symbol': r'$'},
    'AE': {'locale': 'ar-AE', 'currency': 'AED', 'symbol': 'د.إ'},
    'SA': {'locale': 'ar-SA', 'currency': 'SAR', 'symbol': '﷼'},
    'SG': {'locale': 'en-SG', 'currency': 'SGD', 'symbol': r'$'},
    'MY': {'locale': 'ms-MY', 'currency': 'MYR', 'symbol': 'RM'},
    'ID': {'locale': 'id-ID', 'currency': 'IDR', 'symbol': 'Rp'},
    'JP': {'locale': 'ja-JP', 'currency': 'JPY', 'symbol': '¥'},
    'KR': {'locale': 'ko-KR', 'currency': 'KRW', 'symbol': '₩'},
    'CN': {'locale': 'zh-CN', 'currency': 'CNY', 'symbol': '¥'},
    'DE': {'locale': 'de-DE', 'currency': 'EUR', 'symbol': '€'},
    'FR': {'locale': 'fr-FR', 'currency': 'EUR', 'symbol': '€'},
    'IT': {'locale': 'it-IT', 'currency': 'EUR', 'symbol': '€'},
    'ES': {'locale': 'es-ES', 'currency': 'EUR', 'symbol': '€'},
    'BR': {'locale': 'pt-BR', 'currency': 'BRL', 'symbol': r'R$'},
    'MX': {'locale': 'es-MX', 'currency': 'MXN', 'symbol': r'$'},
    'ZA': {'locale': 'en-ZA', 'currency': 'ZAR', 'symbol': 'R'},
  };

  String get currentLocale {
    final meta = countryMeta[country.value];
    return meta?['locale'] ?? (isRtl ? '${language.value}-${country.value}' : '${language.value}-${country.value}');
  }

  String get currencyCode => countryMeta[country.value]?['currency'] ?? 'USD';
  String get currencySymbol => countryMeta[country.value]?['symbol'] ?? r'$';

  static List<ui.Locale> get supportedLocales => languages
      .map((item) => ui.Locale(item['code']!))
      .toList(growable: false);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    language.value = _prefs?.getString('billi_language') ?? 'hi';
    notifications.value = _prefs?.getBool('billi_notifications') ?? true;
    privateAccount.value = _prefs?.getBool('billi_private_account') ?? false;
    biometricLock.value = _prefs?.getBool('billi_biometric_lock') ?? false;
    dataSaver.value = _prefs?.getBool('billi_data_saver') ?? false;
    autoplay.value = _prefs?.getBool('billi_autoplay') ?? true;
    country.value = _prefs?.getString('billi_country') ?? 'IN';
    try {
      final auth = LocalAuthentication();
      biometricAvailable.value = await auth.isDeviceSupported() && await auth.canCheckBiometrics;
    } catch (_) {
      biometricAvailable.value = false;
    }
    try {
      await _secureStorage.write(key: 'billi_security_initialized', value: '1');
      secureStorageReady.value = (await _secureStorage.read(key: 'billi_security_initialized')) == '1';
    } catch (_) {
      secureStorageReady.value = false;
    }
  }

  Future<void> setLanguage(String code) async {
    language.value = code;
    await _prefs?.setString('billi_language', code);
  }

  Future<void> setBool(String key, ValueNotifier<bool> target, bool value) async {
    target.value = value;
    await _prefs?.setBool(key, value);
  }

  Future<bool> checkBiometricAvailability() async {
    try {
      final auth = LocalAuthentication();
      biometricAvailable.value = await auth.isDeviceSupported() && await auth.canCheckBiometrics;
    } catch (_) {
      biometricAvailable.value = false;
    }
    return biometricAvailable.value;
  }

  Future<void> clearSecureData() async {
    try {
      await _secureStorage.deleteAll();
      secureStorageReady.value = false;
    } catch (_) {}
  }

  Future<void> setCountry(String code) async {
    country.value = code;
    await _prefs?.setString('billi_country', code);
  }

  Future<bool> authenticateForAppLock() async {
    if (!biometricLock.value) return true;
    final auth = LocalAuthentication();
    try {
      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      if (!supported || !canCheck) return false;
      return await auth.authenticate(
        localizedReason: 'Unlock Billi Billi',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    } 
  }

  bool get isRtl => language.value == 'ar' || language.value == 'ur';

  static String text(String code, String key) {
    const en = {
      'settings': 'Settings', 'account': 'Account', 'notifications': 'Notifications',
      'privacy': 'Privacy & Security', 'language': 'Language', 'about': 'About Billi Billi',
      'home': 'Home', 'search': 'Search', 'create': 'Create', 'reels': 'Reels',
      'profile': 'Profile', 'save': 'Saved', 'logout': 'Logout',
      'choose_language': 'Choose app language', 'global': 'Global', 'security': 'Security', 'private_account': 'Private account', 'biometric_lock': 'Biometric app lock', 'data_saver': 'Data saver', 'autoplay': 'Autoplay videos', 'privacy_desc': 'Control who can see your activity', 'security_desc': 'Protect your app and personal data', 'data_saver_desc': 'Reduce mobile data usage', 'autoplay_desc': 'Automatically play videos when possible', 'private_desc': 'Only approved followers can see your content', 'biometric_desc': 'Require device biometric authentication', 'delete_data': 'Delete my local data', 'delete_data_desc': 'Remove locally stored Billi Billi data from this device', 'cancel': 'Cancel', 'delete': 'Delete', 'delete_confirm': 'Delete all locally stored app data?', 'security_status': 'Security status', 'secure_storage': 'Secure device storage', 'secure_storage_desc': 'Sensitive security data uses encrypted device-backed storage when available.', 'security_ready': 'Protected', 'security_unavailable': 'Not available',
    };
    const hi = {
      'settings': 'सेटिंग्स', 'account': 'खाता', 'notifications': 'सूचनाएँ',
      'privacy': 'गोपनीयता और सुरक्षा', 'language': 'भाषा', 'about': 'Billi Billi के बारे में',
      'home': 'होम', 'search': 'खोजें', 'create': 'बनाएँ', 'reels': 'रील्स',
      'profile': 'प्रोफ़ाइल', 'save': 'सेव किए गए', 'logout': 'लॉग आउट',
      'choose_language': 'ऐप की भाषा चुनें', 'global': 'वैश्विक', 'security': 'सुरक्षा', 'private_account': 'निजी खाता', 'biometric_lock': 'बायोमेट्रिक ऐप लॉक', 'data_saver': 'डेटा सेवर', 'autoplay': 'वीडियो ऑटोप्ले', 'privacy_desc': 'कौन आपकी गतिविधि देख सकता है नियंत्रित करें', 'security_desc': 'ऐप और निजी डेटा की सुरक्षा करें', 'data_saver_desc': 'मोबाइल डेटा की खपत कम करें', 'autoplay_desc': 'जहाँ संभव हो वीडियो अपने आप चलाएँ', 'private_desc': 'केवल स्वीकृत followers आपका content देख सकेंगे', 'biometric_desc': 'डिवाइस का बायोमेट्रिक प्रमाणीकरण आवश्यक करें', 'delete_data': 'मेरा स्थानीय डेटा हटाएँ', 'delete_data_desc': 'इस डिवाइस से स्थानीय Billi Billi डेटा हटाएँ', 'cancel': 'रद्द करें', 'delete': 'हटाएँ', 'delete_confirm': 'क्या इस डिवाइस पर रखा पूरा स्थानीय ऐप डेटा हटाना है?', 'security_status': 'सुरक्षा स्थिति', 'secure_storage': 'सुरक्षित डिवाइस स्टोरेज', 'secure_storage_desc': 'संवेदनशील सुरक्षा डेटा उपलब्ध होने पर encrypted device-backed storage में रखा जाता है।', 'security_ready': 'सुरक्षित', 'security_unavailable': 'उपलब्ध नहीं',
    };
    const other = {
      'bn': {'settings':'সেটিংস','account':'অ্যাকাউন্ট','notifications':'বিজ্ঞপ্তি','privacy':'গোপনীয়তা ও নিরাপত্তা','language':'ভাষা','about':'Billi Billi সম্পর্কে','home':'হোম','search':'খুঁজুন','create':'তৈরি করুন','reels':'রিলস','profile':'প্রোফাইল','save':'সংরক্ষিত','logout':'লগ আউট','choose_language':'অ্যাপের ভাষা নির্বাচন করুন','global':'বিশ্বব্যাপী'},
      'ta': {'settings':'அமைப்புகள்','account':'கணக்கு','notifications':'அறிவிப்புகள்','privacy':'தனியுரிமை மற்றும் பாதுகாப்பு','language':'மொழி','about':'Billi Billi பற்றி','home':'முகப்பு','search':'தேடல்','create':'உருவாக்கு','reels':'ரீல்ஸ்','profile':'சுயவிவரம்','save':'சேமித்தவை','logout':'வெளியேறு','choose_language':'பயன்பாட்டு மொழியைத் தேர்ந்தெடுக்கவும்','global':'உலகளாவிய'},
      'te': {'settings':'సెట్టింగ్‌లు','account':'ఖాతా','notifications':'నోటిఫికేషన్‌లు','privacy':'గోప్యత మరియు భద్రత','language':'భాష','about':'Billi Billi గురించి','home':'హోమ్','search':'శోధన','create':'సృష్టించండి','reels':'రీల్స్','profile':'ప్రొఫైల్','save':'సేవ్ చేసినవి','logout':'లాగ్ అవుట్','choose_language':'యాప్ భాషను ఎంచుకోండి','global':'ప్రపంచవ్యాప్త'},
      'mr': {'settings':'सेटिंग्ज','account':'खाते','notifications':'सूचना','privacy':'गोपनीयता आणि सुरक्षा','language':'भाषा','about':'Billi Billi बद्दल','home':'होम','search':'शोधा','create':'तयार करा','reels':'रील्स','profile':'प्रोफाइल','save':'जतन केलेले','logout':'लॉग आउट','choose_language':'अॅपची भाषा निवडा','global':'जागतिक'},
      'gu': {'settings':'સેટિંગ્સ','account':'ખાતું','notifications':'સૂચનાઓ','privacy':'ગોપનીયતા અને સુરક્ષા','language':'ભાષા','about':'Billi Billi વિશે','home':'હોમ','search':'શોધ','create':'બનાવો','reels':'રીલ્સ','profile':'પ્રોફાઇલ','save':'સાચવેલ','logout':'લૉગ આઉટ','choose_language':'એપની ભાષા પસંદ કરો','global':'વૈશ્વિક'},
      'pa': {'settings':'ਸੈਟਿੰਗਾਂ','account':'ਖਾਤਾ','notifications':'ਸੂਚਨਾਵਾਂ','privacy':'ਪਰਦੇਦਾਰੀ ਅਤੇ ਸੁਰੱਖਿਆ','language':'ਭਾਸ਼ਾ','about':'Billi Billi ਬਾਰੇ','home':'ਹੋਮ','search':'ਖੋਜ','create':'ਬਣਾਓ','reels':'ਰੀਲਜ਼','profile':'ਪ੍ਰੋਫਾਈਲ','save':'ਸੇਵ ਕੀਤੇ','logout':'ਲੌਗ ਆਊਟ','choose_language':'ਐਪ ਦੀ ਭਾਸ਼ਾ ਚੁਣੋ','global':'ਵਿਸ਼ਵਵਿਆਪੀ'},
      'kn': {'settings':'ಸೆಟ್ಟಿಂಗ್‌ಗಳು','account':'ಖಾತೆ','notifications':'ಅಧಿಸೂಚನೆಗಳು','privacy':'ಗೌಪ್ಯತೆ ಮತ್ತು ಭದ್ರತೆ','language':'ಭಾಷೆ','about':'Billi Billi ಕುರಿತು','home':'ಮುಖಪುಟ','search':'ಹುಡುಕಿ','create':'ರಚಿಸಿ','reels':'ರೀಲ್ಸ್','profile':'ಪ್ರೊಫೈಲ್','save':'ಉಳಿಸಿದವು','logout':'ಲಾಗ್ ಔಟ್','choose_language':'ಆ್ಯಪ್ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ','global':'ಜಾಗತಿಕ'},
      'ml': {'settings':'ക്രമീകരണങ്ങൾ','account':'അക്കൗണ്ട്','notifications':'അറിയിപ്പുകൾ','privacy':'സ്വകാര്യതയും സുരക്ഷയും','language':'ഭാഷ','about':'Billi Billiയെ കുറിച്ച്','home':'ഹോം','search':'തിരയുക','create':'സൃഷ്ടിക്കുക','reels':'റീൽസ്','profile':'പ്രൊഫൈൽ','save':'സംരക്ഷിച്ചത്','logout':'ലോഗ് ഔട്ട്','choose_language':'ആപ്പ് ഭാഷ തിരഞ്ഞെടുക്കുക','global':'ആഗോള'},
      'ur': {'settings':'ترتیبات','account':'اکاؤنٹ','notifications':'اطلاعات','privacy':'رازداری اور سیکیورٹی','language':'زبان','about':'Billi Billi کے بارے میں','home':'ہوم','search':'تلاش','create':'بنائیں','reels':'ریلز','profile':'پروفائل','save':'محفوظ شدہ','logout':'لاگ آؤٹ','choose_language':'ایپ کی زبان منتخب کریں','global':'عالمی'},
      'es': {'settings':'Configuración','account':'Cuenta','notifications':'Notificaciones','privacy':'Privacidad y seguridad','language':'Idioma','about':'Acerca de Billi Billi','home':'Inicio','search':'Buscar','create':'Crear','reels':'Reels','profile':'Perfil','save':'Guardados','logout':'Cerrar sesión','choose_language':'Elegir idioma de la app','global':'Global'},
      'fr': {'settings':'Paramètres','account':'Compte','notifications':'Notifications','privacy':'Confidentialité et sécurité','language':'Langue','about':'À propos de Billi Billi','home':'Accueil','search':'Rechercher','create':'Créer','reels':'Reels','profile':'Profil','save':'Enregistrés','logout':'Déconnexion','choose_language':'Choisir la langue de l’application','global':'Mondial'},
      'de': {'settings':'Einstellungen','account':'Konto','notifications':'Benachrichtigungen','privacy':'Datenschutz und Sicherheit','language':'Sprache','about':'Über Billi Billi','home':'Startseite','search':'Suchen','create':'Erstellen','reels':'Reels','profile':'Profil','save':'Gespeichert','logout':'Abmelden','choose_language':'App-Sprache wählen','global':'Global'},
      'it': {'settings':'Impostazioni','account':'Account','notifications':'Notifiche','privacy':'Privacy e sicurezza','language':'Lingua','about':'Informazioni su Billi Billi','home':'Home','search':'Cerca','create':'Crea','reels':'Reels','profile':'Profilo','save':'Salvati','logout':'Esci','choose_language':'Scegli la lingua dell’app','global':'Globale'},
      'pt': {'settings':'Configurações','account':'Conta','notifications':'Notificações','privacy':'Privacidade e segurança','language':'Idioma','about':'Sobre o Billi Billi','home':'Início','search':'Pesquisar','create':'Criar','reels':'Reels','profile':'Perfil','save':'Salvos','logout':'Sair','choose_language':'Escolher idioma do app','global':'Global'},
      'id': {'settings':'Pengaturan','account':'Akun','notifications':'Notifikasi','privacy':'Privasi & Keamanan','language':'Bahasa','about':'Tentang Billi Billi','home':'Beranda','search':'Cari','create':'Buat','reels':'Reels','profile':'Profil','save':'Tersimpan','logout':'Keluar','choose_language':'Pilih bahasa aplikasi','global':'Global'},
      'ar': {'settings':'الإعدادات','account':'الحساب','notifications':'الإشعارات','privacy':'الخصوصية والأمان','language':'اللغة','about':'حول Billi Billi','home':'الرئيسية','search':'بحث','create':'إنشاء','reels':'ريلز','profile':'الملف الشخصي','save':'المحفوظات','logout':'تسجيل الخروج','choose_language':'اختر لغة التطبيق','global':'عالمي'},
      'ja': {'settings':'設定','account':'アカウント','notifications':'通知','privacy':'プライバシーとセキュリティ','language':'言語','about':'Billi Billiについて','home':'ホーム','search':'検索','create':'作成','reels':'リール','profile':'プロフィール','save':'保存済み','logout':'ログアウト','choose_language':'アプリの言語を選択','global':'グローバル'},
      'ko': {'settings':'설정','account':'계정','notifications':'알림','privacy':'개인정보 및 보안','language':'언어','about':'Billi Billi 정보','home':'홈','search':'검색','create':'만들기','reels':'릴스','profile':'프로필','save':'저장됨','logout':'로그아웃','choose_language':'앱 언어 선택','global':'글로벌'},
      'ru': {'settings':'Настройки','account':'Аккаунт','notifications':'Уведомления','privacy':'Конфиденциальность и безопасность','language':'Язык','about':'О Billi Billi','home':'Главная','search':'Поиск','create':'Создать','reels':'Рилс','profile':'Профиль','save':'Сохранённое','logout':'Выйти','choose_language':'Выберите язык приложения','global':'Глобальный'},
      'zh': {'settings':'设置','account':'账户','notifications':'通知','privacy':'隐私与安全','language':'语言','about':'关于 Billi Billi','home':'首页','search':'搜索','create':'创建','reels':'短视频','profile':'个人资料','save':'已保存','logout':'退出登录','choose_language':'选择应用语言','global':'全球'},
    };
    if (code == 'hi') return hi[key] ?? en[key] ?? key;
    return other[code]?[key] ?? en[key] ?? key;
  }
}

// Online backend foundation lives in lib/services/; UI integration is staged after Firebase project configuration.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAppCheck.instance.activate(
  providerAndroid: const AndroidPlayIntegrityProvider(),
);
  } catch (_) {
    // Keep the existing local Billi Billi experience available if Firebase
    // is temporarily unavailable or a service has not been enabled yet.
  }
  runApp(const BilliBilliApp());
}

class BilliBilliApp extends StatefulWidget {
  const BilliBilliApp({super.key});

  @override
  State<BilliBilliApp> createState() => _BilliBilliAppState();
}

class _BilliBilliAppState extends State<BilliBilliApp> with WidgetsBindingObserver {
  bool ready = false;
  bool unlocked = false;
  bool authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSettings();
  }

  Future<void> _initSettings() async {
    await AppSettings.instance.init();
    await AppData.instance.init();
    await AppData.instance.initOnlineIdentity();
    if (!mounted) return;
    setState(() {
      ready = true;
      unlocked = !AppSettings.instance.biometricLock.value;
    });
    if (AppSettings.instance.biometricLock.value) {
      await _unlock();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (AppSettings.instance.biometricLock.value && mounted) {
        setState(() => unlocked = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (AppSettings.instance.biometricLock.value && mounted) {
        _unlock();
      }
    }
  }

  Future<void> _unlock() async {
    if (authenticating || unlocked) return;
    setState(() => authenticating = true);
    final ok = await AppSettings.instance.authenticateForAppLock();
    if (!mounted) return;
    setState(() {
      authenticating = false;
      unlocked = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (!unlocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorSchemeSeed: Colors.pink,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64),
                const SizedBox(height: 16),
                const Text('Billi Billi is locked', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: authenticating ? null : _unlock,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(authenticating ? 'Authenticating…' : 'Unlock'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder<String>(
      valueListenable: AppSettings.instance.language,
      builder: (context, language, _) {
        final rtl = AppSettings.instance.isRtl;
        return MaterialApp(
          title: 'Billi Billi',
          debugShowCheckedModeBanner: false,
          locale: ui.Locale(language),
          supportedLocales: AppSettings.supportedLocales,
          builder: (context, child) => Directionality(
            textDirection: rtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
          theme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorSchemeSeed: Colors.pink,
            scaffoldBackgroundColor: Colors.black,
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}

enum MediaType { photo, video }

class MediaPost {
  MediaPost({
    required this.path,
    required this.type,
    this.caption = '',
    this.liked = false,
    this.saved = false,
    this.likes = 0,
    this.comments = 0,
    this.postId,
    this.ownerUid,
    this.remoteUrl,
    this.storagePath,
  });

  final String path;
  final MediaType type;
  final String caption;
  bool liked;
  bool saved;
  int likes;
  int comments;
  final String? postId;
  final String? ownerUid;
  final String? remoteUrl;
  final String? storagePath;
}

class BilliUser {
  const BilliUser({required this.id, required this.name, required this.bio});
  final String id;
  final String name;
  final String bio;
}

const demoUsers = <BilliUser>[
  BilliUser(id: 'creator_1', name: 'Billi Creator', bio: 'Video creator'),
  BilliUser(id: 'creator_2', name: 'Billi Shorts', bio: 'Shorts & reels'),
  BilliUser(id: 'creator_3', name: 'Travel Billi', bio: 'Travel videos'),
  BilliUser(id: 'creator_4', name: 'Food Billi', bio: 'Food & cooking'),
  BilliUser(id: 'creator_5', name: 'Music Billi', bio: 'Music creator'),
];

class ChatMessage {
  ChatMessage({required this.text, required this.sentByMe, DateTime? time})
      : time = time ?? DateTime.now();
  final String text;
  final bool sentByMe;
  final DateTime time;
}

class AppData {
  AppData._();

  static final AppData instance = AppData._();

  final ValueNotifier<List<MediaPost>> posts =
      ValueNotifier<List<MediaPost>>(<MediaPost>[]);

  final ValueNotifier<List<MediaPost>> savedPosts =
      ValueNotifier<List<MediaPost>>(<MediaPost>[]);

  final ValueNotifier<String> searchText = ValueNotifier<String>('');
  final ValueNotifier<String> profileName = ValueNotifier<String>('Billi Billi User');
  final ValueNotifier<String> profileBio = ValueNotifier<String>('Billi Billi पर आपका स्वागत है ❤️');
  final ValueNotifier<String> profilePhotoPath = ValueNotifier<String>('');

  final ValueNotifier<Set<String>> following = ValueNotifier<Set<String>>(<String>{});
  final ValueNotifier<Map<String, List<ChatMessage>>> chats =
      ValueNotifier<Map<String, List<ChatMessage>>>({});

  SharedPreferences? _prefs;
  
  final OnlineSocialService online = OnlineSocialService();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPosts();
    profileName.value = _prefs?.getString('billi_profile_name') ?? 'Billi Billi User';
    profileBio.value = _prefs?.getString('billi_profile_bio') ?? 'Billi Billi पर आपका स्वागत है ❤️';
    profilePhotoPath.value = _prefs?.getString('billi_profile_photo') ?? '';
    following.value = (_prefs?.getStringList('billi_following') ?? <String>[]).toSet();
  }

  Future<void> saveProfile({required String name, required String bio, String? photoPath}) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError('नाम खाली नहीं हो सकता।');
    profileName.value = cleanName;
    profileBio.value = bio.trim();
    if (photoPath != null && photoPath.isNotEmpty) {
      profilePhotoPath.value = photoPath;
    }
    await _prefs?.setString('billi_profile_name', profileName.value);
    await _prefs?.setString('billi_profile_bio', profileBio.value);
    if (profilePhotoPath.value.isNotEmpty) {
      await _prefs?.setString('billi_profile_photo', profilePhotoPath.value);
    }
    try {
      if (online.currentUser != null) {
        await online.upsertProfile(
          uid: online.currentUser!.uid,
          displayName: profileName.value,
          country: AppSettings.instance.country.value,
          language: AppSettings.instance.language.value,
        );
      }
    } catch (_) {
      // Local profile remains saved even when Firebase Storage/backend is unavailable.
    }
  }

  Future<String?> pickAndSaveProfilePhoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 88, maxWidth: 1200);
      if (picked == null) return null;
      final savedPath = await copyMediaToAppFolder(picked.path);
      if (savedPath == null) return null;
      profilePhotoPath.value = savedPath;
      await _prefs?.setString('billi_profile_photo', savedPath);
      return savedPath;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearExplicitLogout() async {
    await _prefs?.setBool('billi_explicit_logout', false);
  }

  Future<void> setExplicitLogout() async {
    await _prefs?.setBool('billi_explicit_logout', true);
  }

  Future<void> initOnlineIdentity() async {
    try {
      final explicitlySignedOut = _prefs?.getBool('billi_explicit_logout') ?? false;
      if (online.currentUser == null && explicitlySignedOut) return;
      if (online.currentUser == null) {
        await online.signInAnonymously();
      }
      final user = online.currentUser;
      if (user != null) {
        await _prefs?.setBool('billi_explicit_logout', false);
        await online.upsertProfile(
          uid: user.uid,
          displayName: 'Billi User',
          country: AppSettings.instance.country.value,
          language: AppSettings.instance.language.value,
        );
      }
      final snapshot = await online.followingStream().first;
      final ids = snapshot.docs.map((doc) => doc.id).toSet();
      following.value = ids;
      await _prefs?.setStringList('billi_following', ids.toList());
    } catch (_) {}
  }

  Future<Directory> _mediaDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/billi_billi_media');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _loadPosts() async {
    final values = _prefs?.getStringList('billi_posts') ?? <String>[];
    final loaded = <MediaPost>[];

    for (final value in values) {
      final parts = value.split('|');
      if (parts.length < 7) continue;

      final file = File(parts[0]);
      if (!await file.exists()) continue;

      loaded.add(
        MediaPost(
          path: parts[0],
          type: parts[1] == 'video' ? MediaType.video : MediaType.photo,
          caption: parts[2].replaceAll(r'\n', '\n'),
          liked: parts[3] == '1',
          saved: parts[4] == '1',
          likes: int.tryParse(parts[5]) ?? 0,
          comments: int.tryParse(parts[6]) ?? 0,
        ),
      );
    }

    posts.value = loaded;
    _refreshSaved();
  }

  Future<void> _savePosts() async {
    final values = posts.value.map((post) {
      final safeCaption = post.caption.replaceAll('|', ' ').replaceAll('\n', r'\n');
      return [
        post.path,
        post.type == MediaType.video ? 'video' : 'photo',
        safeCaption,
        post.liked ? '1' : '0',
        post.saved ? '1' : '0',
        '${post.likes}',
        '${post.comments}',
      ].join('|');
    }).toList();

    await _prefs?.setStringList('billi_posts', values);
    _refreshSaved();
  }

  void _refreshSaved() {
    savedPosts.value =
        posts.value.where((post) => post.saved).toList(growable: false);
  }

  Future<String?> copyMediaToAppFolder(String sourcePath) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) return null;

      final dir = await _mediaDirectory();
      final extension = sourcePath.contains('.')
          ? sourcePath.split('.').last.toLowerCase()
          : 'mp4';

      final name =
          'billi_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final saved = await source.copy('${dir.path}/$name');
      return saved.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> initPushNotifications() async {
    try {
      if (!online.isSignedIn) return;
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await online.registerPushToken(messaging: messaging);
      messaging.onTokenRefresh.listen((token) async {
        try {
          await online.registerPushToken(messaging: messaging);
        } catch (_) {}
      });
    } catch (_) {
      // Push notifications are optional; the app continues without them.
    }
  }

  Future<void> addPost({
    required String path,
    required MediaType type,
    String caption = '',
  }) async {
    posts.value = <MediaPost>[
      MediaPost(path: path, type: type, caption: caption),
      ...posts.value,
    ];
    await _savePosts();
  }

  Future<String?> uploadPostOnline({
    required String path,
    required MediaType type,
    String caption = '',
  }) async {
    try {
      return await online.uploadPost(
        localPath: path,
        mediaType: type == MediaType.video ? 'video' : 'photo',
        caption: caption,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleLike(MediaPost post) async {
    final wasLiked = post.liked;
    post.liked = !wasLiked;
    if (post.liked) {
      post.likes++;
    } else if (post.likes > 0) {
      post.likes--;
    }
    posts.value = List<MediaPost>.from(posts.value);
    await _savePosts();
    if (post.postId != null) {
      try {
        if (post.liked) {
          await online.likePost(post.postId!);
        } else {
          await online.unlikePost(post.postId!);
        }
      } catch (_) {
        // Keep the existing local experience if online engagement is unavailable.
      }
    }
  }

  Future<void> toggleSave(MediaPost post) async {
    post.saved = !post.saved;
    posts.value = List<MediaPost>.from(posts.value);
    await _savePosts();
  }

  Future<void> addComment(MediaPost post, {String text = ''}) async {
    post.comments++;
    posts.value = List<MediaPost>.from(posts.value);
    await _savePosts();
    if (post.postId != null && text.trim().isNotEmpty) {
      try {
        await online.addOnlineComment(post.postId!, text);
      } catch (_) {
        // Local count remains available if the network is unavailable.
      }
    }
  }

  Future<void> deletePost(MediaPost post) async {
    posts.value = posts.value.where((item) => item != post).toList();
    await _savePosts();

    try {
      final file = File(post.path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> toggleFollow(BilliUser user) async {
    final next = Set<String>.from(following.value);
    try {
      if (next.contains(user.id)) {
        await online.unfollow(user.id);
        next.remove(user.id);
      } else {
        await online.follow(user.id);
        next.add(user.id);
      }
    } catch (_) {
      if (next.contains(user.id)) {
        next.remove(user.id);
      } else {
        next.add(user.id);
      }
    }
    following.value = next;
    await _prefs?.setStringList('billi_following', next.toList());
  }

  Future<void> sendMessage(String userId, String text) async {
    final value = text.trim();
    if (value.isEmpty) return;
    try {
      await online.sendMessage(otherUid: userId, text: value);
    } catch (_) {
      final next = Map<String, List<ChatMessage>>.from(chats.value);
      final list = List<ChatMessage>.from(next[userId] ?? <ChatMessage>[]);
      list.add(ChatMessage(text: value, sentByMe: true));
      next[userId] = list;
      chats.value = next;
    }
  }

  List<MediaPost> filteredPosts() {
    final query = searchText.value.trim().toLowerCase();
    if (query.isEmpty) return posts.value;

    return posts.value.where((post) {
      return post.caption.toLowerCase().contains(query) ||
          (post.type == MediaType.video ? 'video' : 'photo')
              .contains(query) ||
          'billi billi'.contains(query);
    }).toList();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // AppData and Firebase identity are initialized once by the root app state.
    await AppData.instance.init();
    if (mounted) {
      setState(() => ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets, size: 64),
              SizedBox(height: 14),
              Text(
                'Billi Billi',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 18),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    final pages = <Widget>[
      const HomePage(),
      const SearchPage(),
      CreatePage(
        onPostComplete: () {
          if (mounted) setState(() => currentIndex = 0);
        },
      ),
      const ReelsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.black,
        child: NavigationBar(
          height: 80,
          backgroundColor: Colors.black,
          indicatorColor: Colors.white12,
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() => currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Create',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline),
              selectedIcon: Icon(Icons.play_circle),
              label: 'Reels',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<MediaPost>>(
        valueListenable: AppData.instance.posts,
        builder: (context, posts, _) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black,
                floating: true,
                title: const Text(
                  'Billi Billi',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Chat',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatListPage()),
                    ),
                    icon: const Icon(Icons.chat_outlined),
                  ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: AppData.instance.online.notificationsStream(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ??
                          const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                      final unread = docs.where((d) => d.data()['read'] != true).length;
                      return IconButton(
                        tooltip: 'Notifications',
                        onPressed: () => _openNotifications(context),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none),
                            if (unread > 0)
                              Positioned(
                                right: -4,
                                top: -5,
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    unread > 99 ? '99+' : '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Online Posts',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OnlineFeedPage()),
                    ),
                    icon: const Icon(Icons.cloud_outlined),
                  ),
                  IconButton(
                    tooltip: 'Saved',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark_border),
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: StoriesSection()),
              if (posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyHome(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => MediaPostCard(post: posts[index]),
                    childCount: posts.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class OnlineFeedPage extends StatelessWidget {
  const OnlineFeedPage({super.key});

  MediaPost _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return MediaPost(
      path: '',
      type: data['mediaType'] == 'video' ? MediaType.video : MediaType.photo,
      caption: (data['caption'] ?? '').toString(),
      postId: doc.id,
      ownerUid: (data['ownerUid'] ?? '').toString(),
      remoteUrl: (data['mediaUrl'] ?? '').toString(),
      storagePath: (data['storagePath'] ?? '').toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Posts')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: AppData.instance.online.postsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Online posts लोड नहीं हो पाए।'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('अभी कोई Online post नहीं है।\nCreate से पोस्ट करें।', textAlign: TextAlign.center),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) => MediaPostCard(post: _fromDoc(docs[index])),
          );
        },
      ),
    );
  }
}

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: index == 0
                      ? Colors.pink.withValues(alpha: .25)
                      : Colors.white24,
                  child: index == 0
                      ? const Icon(Icons.add, size: 30)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
                const SizedBox(height: 5),
                Text(
                  index == 0 ? 'Your story' : 'User ${index + 1}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_collection_outlined, size: 80, color: Colors.white38),
            SizedBox(height: 20),
            Text(
              'अभी कोई पोस्ट नहीं है',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Create में जाकर अपना पहला फोटो या वीडियो पोस्ट करें।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaPostCard extends StatefulWidget {
  const MediaPostCard({super.key, required this.post});

  final MediaPost post;

  @override
  State<MediaPostCard> createState() => _MediaPostCardState();
}

class _MediaPostCardState extends State<MediaPostCard> {
  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PostHeader(post: post),
        if (post.type == MediaType.photo)
          AspectRatio(
            aspectRatio: 1,
            child: post.remoteUrl != null && post.remoteUrl!.isNotEmpty
                ? Image.network(post.remoteUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _MediaError())
                : Image.file(File(post.path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _MediaError()),
          )
        else
          VideoPost(path: post.path, remoteUrl: post.remoteUrl),
        Row(
          children: [
            IconButton(
              tooltip: 'Like',
              onPressed: () async {
                await AppData.instance.toggleLike(post);
                if (mounted) setState(() {});
              },
              icon: Icon(
                post.liked ? Icons.favorite : Icons.favorite_border,
                color: post.liked ? Colors.red : Colors.white,
              ),
            ),
            if (post.likes > 0) Text('${post.likes}'),
            IconButton(
              tooltip: 'Comment',
              onPressed: () => _showCommentDialog(context),
              icon: const Icon(Icons.chat_bubble_outline),
            ),
            if (post.comments > 0) Text('${post.comments}'),
            IconButton(
              tooltip: 'Share',
              onPressed: () => _sharePost(context, post),
              icon: const Icon(Icons.send_outlined),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Save',
              onPressed: () async {
                await AppData.instance.toggleSave(post);
                if (mounted) setState(() {});
              },
              icon: Icon(
                post.saved ? Icons.bookmark : Icons.bookmark_border,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Text(
            post.caption.isEmpty
                ? post.type == MediaType.video
                    ? 'Billi Billi वीडियो पोस्ट'
                    : 'Billi Billi फोटो पोस्ट'
                : post.caption,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        if (post.postId != null)
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: AppData.instance.online.commentsStream(post.postId!),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
              if (docs.isEmpty) return const SizedBox.shrink();
              final visible = docs.length > 3 ? docs.sublist(docs.length - 3) : docs;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: visible.map((doc) {
                    final data = doc.data();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• ${(data['text'] ?? '').toString()}'),
                    );
                  }).toList(),
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _showCommentDialog(BuildContext context) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Comment'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'अपना कमेंट लिखें...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await AppData.instance.addComment(widget.post, text: controller.text);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (mounted) setState(() {});
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _sharePost(BuildContext context, MediaPost post) async {
    await Clipboard.setData(ClipboardData(text: post.path));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('वीडियो/फोटो का path clipboard में कॉपी हो गया।')),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});

  final MediaPost post;

  @override
  Widget build(BuildContext context) {
    if (post.postId == null || post.ownerUid == null || post.ownerUid!.isEmpty) {
      return const ListTile(
        leading: CircleAvatar(child: Icon(Icons.person)),
        title: Text(
          'Billi Billi User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Billi Billi'),
      );
    }

    final ownerUid = post.ownerUid!;
    final myUid = AppData.instance.online.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AppData.instance.online.userProfileStream(ownerUid),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = (data?['displayName'] ?? 'Billi Billi User').toString();
        final bio = (data?['bio'] ?? 'Billi Billi').toString();

        return ValueListenableBuilder<Set<String>>(
          valueListenable: AppData.instance.following,
          builder: (context, following, _) {
            final isFollowing = following.contains(ownerUid);
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(bio),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (myUid != ownerUid)
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          if (isFollowing) {
                            await AppData.instance.toggleFollow(BilliUser(id: ownerUid, name: name, bio: bio));
                          } else {
                            await AppData.instance.toggleFollow(BilliUser(id: ownerUid, name: name, bio: bio));
                          }
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Follow अभी उपलब्ध नहीं है।')),
                            );
                          }
                        }
                      },
                      child: Text(isFollowing ? 'Following' : 'Follow'),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        if (post.postId != null) {
                          await AppData.instance.online.deletePost(
                            post.postId!,
                            post.storagePath,
                          );
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete post'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MediaError extends StatelessWidget {
  const _MediaError();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 350,
      child: Center(child: Text('मीडिया उपलब्ध नहीं है')),
    );
  }
}

class VideoPost extends StatefulWidget {
  const VideoPost({super.key, required this.path, this.remoteUrl});

  final String path;
  final String? remoteUrl;

  @override
  State<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends State<VideoPost> {
  VideoPlayerController? _controller;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = widget.remoteUrl != null && widget.remoteUrl!.isNotEmpty
          ? VideoPlayerController.networkUrl(Uri.parse(widget.remoteUrl!))
          : VideoPlayerController.file(File(widget.path));
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => error = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error) return const _MediaError();

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 9 / 16,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final ratio =
        controller.value.aspectRatio == 0 ? 9 / 16 : controller.value.aspectRatio;

    return GestureDetector(
      onTap: () {
        setState(() {
          controller.value.isPlaying ? controller.pause() : controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(aspectRatio: ratio, child: VideoPlayer(controller)),
          if (!controller.value.isPlaying)
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.play_arrow, size: 38),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    controller.addListener(_search);
  }

  void _search() {
    AppData.instance.searchText.value = controller.text;
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = AppData.instance.filteredPosts();
    final query = controller.text.trim().toLowerCase();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 8),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search people, videos, hashtags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: controller.clear,
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'Posts'),
              Tab(text: 'Online'),
              Tab(text: 'People'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                results.isEmpty
                    ? const Center(child: Text('कोई पोस्ट नहीं मिली'))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (_, index) =>
                            MediaPostCard(post: results[index]),
                      ),
                _OnlineSearchResults(query: query),
                _PeopleSearchResults(query: query),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineSearchResults extends StatelessWidget {
  const _OnlineSearchResults({required this.query});
  final String query;

  MediaPost _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return MediaPost(
      path: '',
      type: data['mediaType'] == 'video' ? MediaType.video : MediaType.photo,
      caption: (data['caption'] ?? '').toString(),
      postId: doc.id,
      ownerUid: (data['ownerUid'] ?? '').toString(),
      remoteUrl: (data['mediaUrl'] ?? '').toString(),
      storagePath: (data['storagePath'] ?? '').toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: AppData.instance.online.postsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Online search अभी उपलब्ध नहीं है।'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs.where((doc) {
          if (query.isEmpty) return true;
          final data = doc.data();
          final caption = (data['caption'] ?? '').toString().toLowerCase();
          final type = (data['mediaType'] ?? '').toString().toLowerCase();
          return caption.contains(query) || type.contains(query) ||
              'billi billi'.contains(query);
        }).toList();
        if (docs.isEmpty) {
          return const Center(child: Text('कोई Online पोस्ट नहीं मिली'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, index) =>
              MediaPostCard(post: _fromDoc(docs[index])),
        );
      },
    );
  }
}

class _PeopleSearchResults extends StatelessWidget {
  const _PeopleSearchResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: AppData.instance.online.usersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Online people अभी उपलब्ध नहीं हैं।'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final myUid = AppData.instance.online.currentUser?.uid;
        final users = snapshot.data!.docs.where((doc) {
          if (doc.id == myUid) return false;
          if (query.isEmpty) return true;
          final data = doc.data();
          final name = (data['displayName'] ?? '').toString().toLowerCase();
          final bio = (data['bio'] ?? '').toString().toLowerCase();
          return name.contains(query) || bio.contains(query);
        }).map((doc) {
          final data = doc.data();
          final name = (data['displayName'] as String?)?.trim();
          return BilliUser(
            id: doc.id,
            name: name == null || name.isEmpty ? 'Billi User' : name,
            bio: (data['bio'] as String?) ?? 'Billi Billi creator',
          );
        }).toList();
        if (users.isEmpty) {
          return const Center(child: Text('कोई व्यक्ति नहीं मिला'));
        }
        return ValueListenableBuilder<Set<String>>(
          valueListenable: AppData.instance.following,
          builder: (context, following, _) {
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                final isFollowing = following.contains(user.id);
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.name),
                  subtitle: Text(user.bio),
                  trailing: FilledButton(
                    onPressed: () => AppData.instance.toggleFollow(user),
                    child: Text(isFollowing ? 'Following' : 'Follow'),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatPage(user: user)),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key, required this.onPostComplete});

  final VoidCallback onPostComplete;

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final ImagePicker picker = ImagePicker();
  VideoPlayerController? videoController;
  XFile? selectedVideo;
  String? selectedImagePath;
  bool loading = false;
  bool posting = false;

  Future<void> pickVideo(ImageSource source) async {
    if (loading || posting) return;

    setState(() => loading = true);

    try {
      final video = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (video == null) {
        if (mounted) setState(() => loading = false);
        return;
      }

      final newController = VideoPlayerController.file(File(video.path));
      await newController.initialize();
      await videoController?.dispose();

      if (!mounted) {
        await newController.dispose();
        return;
      }

      setState(() {
        selectedVideo = video;
        selectedImagePath = null;
        videoController = newController;
        loading = false;
      });
      await newController.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showError('वीडियो open नहीं हुआ: $e');
    }
  }

  Future<void> pickPhoto(ImageSource source) async {
    if (loading || posting) return;

    setState(() => loading = true);

    try {
      final photo = await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1800,
      );

      if (photo == null) {
        if (mounted) setState(() => loading = false);
        return;
      }

      await videoController?.dispose();
      if (!mounted) return;

      setState(() {
        selectedImagePath = photo.path;
        selectedVideo = null;
        videoController = null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showError('फोटो open नहीं हुई: $e');
    }
  }

  Future<void> postMedia() async {
    if (posting) return;

    final video = selectedVideo;
    final image = selectedImagePath;

    if (video == null && image == null) {
      _showError('पहले फोटो या वीडियो चुनें।');
      return;
    }

    setState(() => posting = true);

    final sourcePath = video?.path ?? image!;
    final savedPath =
        await AppData.instance.copyMediaToAppFolder(sourcePath);

    if (savedPath == null) {
      if (mounted) {
        setState(() => posting = false);
        _showError('मीडिया सेव नहीं हो पाया।');
      }
      return;
    }

    final mediaType = video != null ? MediaType.video : MediaType.photo;
    await AppData.instance.addPost(
      path: savedPath,
      type: mediaType,
    );

    final onlinePostId = await AppData.instance.uploadPostOnline(
      path: savedPath,
      type: mediaType,
    );

    await videoController?.dispose();

    if (!mounted) return;

    setState(() {
      videoController = null;
      selectedVideo = null;
      selectedImagePath = null;
      posting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(onlinePostId != null
            ? 'पोस्ट फोन और Online दोनों जगह सेव हो गई ✅'
            : 'पोस्ट फोन में सेव हो गई। Online upload के लिए Firebase Storage चालू होना जरूरी है।'),
      ),
    );
    widget.onPostComplete();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = videoController;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Create',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Billi Billi पर फोटो और वीडियो बनाएं',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            if (loading) const CircularProgressIndicator(),
            if (selectedImagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(selectedImagePath!),
                  height: 330,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            if (controller != null && controller.value.isInitialized)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                  IconButton(
                    iconSize: 55,
                    onPressed: () {
                      setState(() {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 18),
            _CreateButton(
              icon: Icons.video_library_outlined,
              text: 'Gallery से वीडियो चुनें',
              onPressed: loading || posting
                  ? null
                  : () => pickVideo(ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            _CreateButton(
              icon: Icons.videocam_outlined,
              text: 'Camera से वीडियो रिकॉर्ड करें',
              onPressed: loading || posting
                  ? null
                  : () => pickVideo(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            _CreateButton(
              icon: Icons.photo_library_outlined,
              text: 'Gallery से फोटो चुनें',
              onPressed: loading || posting
                  ? null
                  : () => pickPhoto(ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            _CreateButton(
              icon: Icons.camera_alt_outlined,
              text: 'Camera से फोटो लें',
              onPressed: loading || posting
                  ? null
                  : () => pickPhoto(ImageSource.camera),
            ),
            if (selectedVideo != null || selectedImagePath != null) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton.icon(
                  onPressed: loading || posting ? null : postMedia,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(posting ? 'Posting...' : 'Post करें'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }
}

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final videos = AppData.instance.posts.value
        .where((post) => post.type == MediaType.video)
        .toList();

    if (videos.isEmpty) {
      return const SafeArea(
        child: Center(
          child: Text(
            'अभी कोई Shorts नहीं है।\nCreate से वीडियो पोस्ट करें।',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    return ShortsPage(videos: videos);
  }
}

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key, required this.videos});

  final List<MediaPost> videos;

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  late final PageController pageController;
  int current = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Billi Billi Shorts'),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: pageController,
        itemCount: widget.videos.length,
        onPageChanged: (index) => setState(() => current = index),
        itemBuilder: (_, index) => ShortVideoItem(
          post: widget.videos[index],
          active: index == current,
        ),
      ),
    );
  }
}

class ShortVideoItem extends StatefulWidget {
  const ShortVideoItem({
    super.key,
    required this.post,
    required this.active,
  });

  final MediaPost post;
  final bool active;

  @override
  State<ShortVideoItem> createState() => _ShortVideoItemState();
}

class _ShortVideoItemState extends State<ShortVideoItem> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final newController =
        VideoPlayerController.file(File(widget.post.path));
    try {
      await newController.setLooping(true);
      await newController.initialize();

      if (!mounted) {
        await newController.dispose();
        return;
      }

      setState(() => controller = newController);

      if (widget.active) await newController.play();
    } catch (_) {
      await newController.dispose();
    }
  }

  @override
  void didUpdateWidget(covariant ShortVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentController = controller;
    if (currentController == null ||
        !currentController.value.isInitialized) {
      return;
    }

    if (widget.active) {
      currentController.play();
    } else {
      currentController.pause();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentController = controller;

    if (currentController == null ||
        !currentController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          currentController.value.isPlaying
              ? currentController.pause()
              : currentController.play();
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: currentController.value.size.width,
              height: currentController.value.size.height,
              child: VideoPlayer(currentController),
            ),
          ),
          Positioned(
            left: 16,
            right: 12,
            bottom: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    widget.post.caption.isEmpty
                        ? 'Billi Billi User\n#BilliBilli #Shorts'
                        : '${widget.post.caption}\n#BilliBilli #Shorts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await AppData.instance.toggleLike(widget.post);
                        if (mounted) setState(() {});
                      },
                      color: widget.post.liked ? Colors.red : Colors.white,
                      icon: Icon(
                        widget.post.liked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 32,
                      ),
                    ),
                    Text(
                      '${widget.post.likes}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () async {
                        await AppData.instance.addComment(widget.post);
                        if (mounted) setState(() {});
                      },
                      color: Colors.white,
                      icon: const Icon(Icons.comment, size: 30),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.post.path),
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Short का path कॉपी हो गया।'),
                          ),
                        );
                      },
                      color: Colors.white,
                      icon: const Icon(Icons.share, size: 30),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              currentController,
              allowScrubbing: false,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: AppData.instance.profileName.value);
    final bioController = TextEditingController(text: AppData.instance.profileBio.value);
    String? selectedPhoto = AppData.instance.profilePhotoPath.value.isNotEmpty
        ? AppData.instance.profilePhotoPath.value
        : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget avatar() {
              if (selectedPhoto != null && File(selectedPhoto!).existsSync()) {
                return CircleAvatar(radius: 48, backgroundImage: FileImage(File(selectedPhoto!)));
              }
              return const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 52));
            }

            return AlertDialog(
              title: const Text('प्रोफ़ाइल एडिट करें'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final path = await AppData.instance.pickAndSaveProfilePhoto(ImageSource.gallery);
                        if (path != null) setDialogState(() => selectedPhoto = path);
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          avatar(),
                          const CircleAvatar(radius: 18, child: Icon(Icons.camera_alt, size: 19)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('फोटो बदलने के लिए फोटो पर दबाएँ', style: TextStyle(color: Colors.white60)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'नाम'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Bio'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('रद्द करें')),
                FilledButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    await AppData.instance.saveProfile(
                      name: nameController.text,
                      bio: bioController.text,
                      photoPath: selectedPhoto,
                    );
                    if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                  },
                  child: const Text('सेव'),
                ),
              ],
            );
          },
        );
      },
    );
    nameController.dispose();
    bioController.dispose();
    if (result == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<MediaPost>>(
        valueListenable: AppData.instance.posts,
        builder: (context, posts, _) {
          final photos = posts.where((p) => p.type == MediaType.photo).length;
          return ValueListenableBuilder<String>(
            valueListenable: AppData.instance.profileName,
            builder: (context, name, __) {
              return ValueListenableBuilder<String>(
                valueListenable: AppData.instance.profileBio,
                builder: (context, bio, ___) {
                  return ValueListenableBuilder<String>(
                    valueListenable: AppData.instance.profilePhotoPath,
                    builder: (context, photoPath, ____) {
                      final hasPhoto = photoPath.isNotEmpty && File(photoPath).existsSync();
                      return CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            pinned: true,
                            title: const Text('Profile'),
                            actions: [
                              IconButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
                                icon: const Icon(Icons.menu),
                              ),
                            ],
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 48,
                                    backgroundImage: hasPhoto ? FileImage(File(photoPath)) : null,
                                    child: hasPhoto ? null : const Icon(Icons.person, size: 52),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text(bio, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _Stat(value: '$photos', label: 'Photos'),
                                      _OnlineCountStat(label: 'Followers', stream: AppData.instance.online.followersStream(AppData.instance.online.currentUser?.uid ?? ''), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowersPage()))),
                                      _OnlineCountStat(label: 'Following', stream: AppData.instance.online.followingStream(), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowingPage()))),
                                      _Stat(value: '${posts.length}', label: 'Posts'),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  OutlinedButton.icon(
                                    onPressed: _editProfile,
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Edit Profile'),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedPage())), icon: const Icon(Icons.bookmark_border), label: const Text('Saved'))),
                                      const SizedBox(width: 10),
                                      Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())), icon: const Icon(Icons.settings_outlined), label: const Text('Settings'))),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PeoplePage())), icon: const Icon(Icons.person_add_alt_1), label: const Text('Find people'))),
                                      const SizedBox(width: 10),
                                      Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListPage())), icon: const Icon(Icons.chat_outlined), label: const Text('Chat'))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (posts.isEmpty)
                            const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('आपकी पोस्ट यहां दिखाई देंगी।')))
                          else
                            SliverGrid(
                              delegate: SliverChildBuilderDelegate((context, index) => _ProfileTile(post: posts[index]), childCount: posts.length),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                            ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _OnlineCountStat extends StatelessWidget {
  const _OnlineCountStat({
    required this.label,
    required this.stream,
    required this.onTap,
  });

  final String label;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(label, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.white60)),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.post});

  final MediaPost post;

  @override
  Widget build(BuildContext context) {
    if (post.type == MediaType.photo) {
      return Image.file(
        File(post.path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const ColoredBox(color: Colors.transparent, child: Icon(Icons.broken_image)),
      );
    }

    return Container(
      color: Colors.white12,
      child: const Center(
        child: Icon(Icons.play_circle, size: 42),
      ),
    );
  }
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: ValueListenableBuilder<List<MediaPost>>(
        valueListenable: AppData.instance.savedPosts,
        builder: (context, posts, _) {
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'अभी कोई saved post नहीं है।',
                style: TextStyle(fontSize: 19),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, index) => MediaPostCard(post: posts[index]),
          );
        },
      ),
    );
  }
}

class FollowersPage extends StatelessWidget {
  const FollowersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AppData.instance.online.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Followers')),
      body: uid == null
          ? const Center(child: Text('पहले अपने Billi Billi account में login करें।'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: AppData.instance.online.followersStream(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Followers लोड नहीं हो सके।'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('अभी कोई follower नहीं है।'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) => _OnlineUserTile(uid: docs[index].id),
                );
              },
            ),
    );
  }
}

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AppData.instance.online.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: uid == null
          ? const Center(child: Text('पहले अपने Billi Billi account में login करें।'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: AppData.instance.online.followingStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Following लोड नहीं हो सके।'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('आप अभी किसी को follow नहीं कर रहे हैं।'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) => _OnlineUserTile(uid: docs[index].id),
                );
              },
            ),
    );
  }
}

class _OnlineUserTile extends StatelessWidget {
  const _OnlineUserTile({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AppData.instance.online.userProfileStream(uid),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = (data?['displayName'] as String?)?.trim();
        final country = (data?['country'] as String?)?.trim();
        return ListTile(
          leading: CircleAvatar(
            child: Text((name?.isNotEmpty == true ? name! : 'B').substring(0, 1).toUpperCase()),
          ),
          title: Text(name?.isNotEmpty == true ? name! : 'Billi Billi User'),
          subtitle: Text(country?.isNotEmpty == true ? country! : 'Billi Billi'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PeoplePage()),
          ),
        );
      },
    );
  }
}

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find people')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: AppData.instance.online.usersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Online people are temporarily unavailable.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final myUid = AppData.instance.online.currentUser?.uid;
          final users = snapshot.data!.docs
              .where((doc) => doc.id != myUid)
              .map((doc) {
                final data = doc.data();
                final name = (data['displayName'] as String?)?.trim();
                return BilliUser(
                  id: doc.id,
                  name: name == null || name.isEmpty ? 'Billi User' : name,
                  bio: (data['bio'] as String?) ?? 'Billi Billi creator',
                );
              })
              .toList();
          if (users.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No other Billi Billi users yet. Invite someone to join.'),
              ),
            );
          }
          return ValueListenableBuilder<Set<String>>(
            valueListenable: AppData.instance.following,
            builder: (context, following, _) {
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isFollowing = following.contains(user.id);
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user.name),
                    subtitle: Text(user.bio),
                    trailing: FilledButton(
                      onPressed: () => AppData.instance.toggleFollow(user),
                      child: Text(isFollowing ? 'Following' : 'Follow'),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatPage(user: user)),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: AppData.instance.online.usersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Online chat users are temporarily unavailable.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final myUid = AppData.instance.online.currentUser?.uid;
          final allUsers = snapshot.data!.docs
              .where((doc) => doc.id != myUid)
              .map((doc) {
                final data = doc.data();
                final name = (data['displayName'] as String?)?.trim();
                return BilliUser(
                  id: doc.id,
                  name: name == null || name.isEmpty ? 'Billi User' : name,
                  bio: (data['bio'] as String?) ?? 'Billi Billi creator',
                );
              })
              .toList();

          return ValueListenableBuilder<Set<String>>(
            valueListenable: AppData.instance.following,
            builder: (context, following, _) {
              final users = allUsers.where((u) => following.contains(u.id)).toList();
              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 64),
                      const SizedBox(height: 14),
                      const Text('पहले किसी creator को Follow करें।'),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PeoplePage()),
                        ),
                        child: const Text('Find people'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, index) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(users[index].name),
                  subtitle: const Text('Message'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatPage(user: users[index])),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.user});
  final BilliUser user;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();
    await AppData.instance.sendMessage(widget.user.id, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: AppData.instance.online.messagesStream(widget.user.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Chat is temporarily unavailable.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final myUid = AppData.instance.online.currentUser?.uid;
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('कोई संदेश नहीं है।'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final data = docs[index].data();
                    final text = (data['text'] as String?) ?? '';
                    final sentByMe = data['senderId'] == myUid;
                    return Align(
                      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: sentByMe ? Colors.pink.withValues(alpha: .35) : Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'संदेश लिखें…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _text(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: AppData.instance.online.notificationsStream(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
              final unread = docs.where((d) => d.data()['read'] != true).toList();
              if (unread.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () async {
                  try {
                    await AppData.instance.online.markAllNotificationsRead(unread.map((d) => d.id));
                  } catch (_) {}
                },
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: AppData.instance.online.notificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Notifications लोड नहीं हो पाईं।'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('अभी कोई नई notification नहीं है।'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final doc = docs[index];
              final data = doc.data();
              final read = data['read'] == true;
              final actor = _text(data['actorName'], 'Billi Billi User');
              final title = _text(data['title'], 'Billi Billi activity');
              final body = _text(data['body'], '');
              return ListTile(
                tileColor: read ? null : Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                leading: CircleAvatar(child: Icon(read ? Icons.notifications_none : Icons.notifications)),
                title: Text(title, style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(body.isEmpty ? actor : '$actor · $body'),
                onTap: read
                    ? null
                    : () async {
                        try {
                          await AppData.instance.online.markNotificationRead(doc.id);
                        } catch (_) {}
                      },
              );
            },
          );
        },
      ),
    );
  }
}

class AccountAuthPage extends StatefulWidget {
  const AccountAuthPage({super.key});

  @override
  State<AccountAuthPage> createState() => _AccountAuthPageState();
}

class _AccountAuthPageState extends State<AccountAuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool createAccount = true;
  bool busy = false;
  bool obscure = true;
  bool verified = false;

  void _syncVerificationState() {
    final user = AppData.instance.online.currentUser;
    verified = user?.emailVerified ?? false;
  }

  Future<void> _refreshVerification() async {
    setState(() => busy = true);
    try {
      await AppData.instance.online.reloadCurrentUser();
      _syncVerificationState();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(verified ? 'Email verified है।' : 'अभी email verify नहीं हुआ है।')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _resendVerification() async {
    setState(() => busy = true);
    try {
      await AppData.instance.online.sendEmailVerification();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email फिर से भेज दिया गया है।')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: AppData.instance.online.currentUser?.displayName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('नाम बदलें'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    setState(() => busy = true);
    try {
      await AppData.instance.online.updateDisplayName(name);
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  String _friendlyError(Object error) {
    final message = error is FirebaseAuthException
        ? (error.message ?? error.code)
        : error.toString();
    switch (error is FirebaseAuthException ? error.code : '') {
      case 'email-already-in-use':
        return 'यह ईमेल पहले से इस्तेमाल हो रहा है। Login चुनें।';
      case 'invalid-email':
        return 'ईमेल पता सही नहीं है।';
      case 'weak-password':
        return 'पासवर्ड कमजोर है। कम से कम 6 अक्षर रखें।';
      case 'wrong-password':
      case 'invalid-credential':
        return 'ईमेल या पासवर्ड सही नहीं है।';
      case 'user-not-found':
        return 'इस ईमेल से कोई अकाउंट नहीं मिला।';
      case 'credential-already-in-use':
        return 'यह ईमेल किसी दूसरे अकाउंट से जुड़ा है। पहले Login करें।';
      case 'too-many-requests':
        return 'बहुत अधिक प्रयास हुए हैं। थोड़ी देर बाद फिर कोशिश करें।';
      default:
        return message.replaceFirst('Exception: ', '');
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('पहले अपना ईमेल डालें।')),
      );
      return;
    }
    setState(() => busy = true);
    try {
      await AppData.instance.online.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link ईमेल पर भेज दिया गया है।')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final name = _name.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सही ईमेल डालें।')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('पासवर्ड कम से कम 6 अक्षरों का रखें।')),
      );
      return;
    }
    if (createAccount && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया अपना नाम डालें।')),
      );
      return;
    }

    setState(() => busy = true);
    try {
      if (createAccount) {
        await AppData.instance.online.registerOrLinkEmailPassword(
          email: email,
          password: password,
          displayName: name,
        );
        await AppData.instance.online.sendEmailVerification();
      } else {
        await AppData.instance.online.signInEmailPassword(
          email: email,
          password: password,
        );
        final user = AppData.instance.online.currentUser;
        if (user != null) {
          await AppData.instance.online.upsertProfile(
            uid: user.uid,
            displayName: user.displayName?.trim().isNotEmpty == true
                ? user.displayName!.trim()
                : 'Billi User',
            country: AppSettings.instance.country.value,
            language: AppSettings.instance.language.value,
          );
        }
      }
      await AppData.instance.clearExplicitLogout();
      await AppData.instance.initOnlineIdentity();
      await AppData.instance.initPushNotifications();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(createAccount ? 'अकाउंट तैयार हो गया।' : 'Login सफल हुआ।')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = AppData.instance.online.currentUser;
    final permanent = current != null && !current.isAnonymous;
    if (permanent) verified = current.emailVerified;
    return Scaffold(
      appBar: AppBar(title: const Text('Billi Billi Account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.account_circle, size: 82),
            const SizedBox(height: 12),
            Text(
              permanent
                  ? 'Signed in${current.email == null ? '' : ': ${current.email}'}'
                  : 'Anonymous account',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              permanent
                  ? 'आपका अकाउंट Firebase Authentication से जुड़ा है।'
                  : 'अभी temporary account चल रहा है। Email + Password जोड़ने से आपका online account स्थायी हो सकता है।',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            if (!permanent) ...[
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(value: true, label: Text('Create account'), icon: Icon(Icons.person_add_alt_1)),
                  ButtonSegment<bool>(value: false, label: Text('Login'), icon: Icon(Icons.login)),
                ],
                selected: {createAccount},
                onSelectionChanged: (value) => setState(() => createAccount = value.first),
              ),
              const SizedBox(height: 18),
              if (createAccount)
                TextField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
              if (createAccount) const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: obscure,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
              ),
              if (!createAccount)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: busy ? null : _resetPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: busy ? null : _submit,
                icon: busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(createAccount ? Icons.person_add : Icons.login),
                label: Text(createAccount ? 'Create account' : 'Login'),
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(current.displayName?.trim().isNotEmpty == true ? current.displayName! : 'Billi User'),
                subtitle: Text(current.email ?? 'Email account'),
                trailing: IconButton(
                  onPressed: busy ? null : _editName,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'नाम बदलें',
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(verified ? Icons.verified : Icons.mark_email_unread_outlined),
                  title: Text(verified ? 'Email verified' : 'Email verification बाकी है'),
                  subtitle: Text(verified ? 'आपका email verify हो चुका है।' : 'Account की सुरक्षा के लिए email verify करें।'),
                  trailing: verified
                      ? null
                      : TextButton(onPressed: busy ? null : _resendVerification, child: const Text('Resend')),
                ),
              ),
              if (!verified)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: busy ? null : _refreshVerification,
                    icon: const Icon(Icons.refresh),
                    label: const Text('मैंने email verify कर दिया'),
                  ),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () async {
                        setState(() => busy = true);
                        await AppData.instance.online.signOut();
                        await AppData.instance.setExplicitLogout();
                        if (mounted) {
                          setState(() => busy = false);
                        }
                      },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'नोट: Create account के समय अगर मौजूदा anonymous session मौजूद है, Billi Billi उसी Firebase user को email/password से link करने की कोशिश करता है ताकि उसका UID और online data बना रहे।',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String get language => AppSettings.instance.language.value;
  String t(String key) => AppSettings.text(language, key);

  Future<void> _chooseLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Text(t('choose_language'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ]),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: AppSettings.languages.length,
                  itemBuilder: (_, index) {
                    final item = AppSettings.languages[index];
                    final selected = item['code'] == language;
                    return ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(item['native']!),
                      subtitle: Text(item['name']!),
                      trailing: selected ? const Icon(Icons.check_circle) : null,
                      onTap: () => Navigator.pop(context, item['code']),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) await AppSettings.instance.setLanguage(selected);
  }

  Future<void> _setBiometric(bool enabled) async {
    if (!enabled) {
      await AppSettings.instance.setBool('billi_biometric_lock', AppSettings.instance.biometricLock, false);
      return;
    }
    final auth = LocalAuthentication();
    try {
      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      if (!supported || !canCheck) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric authentication is not available on this device.')));
        return;
      }
      final ok = await auth.authenticate(localizedReason: 'Authenticate to enable Billi Billi app lock', options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true));
      if (ok) {
        await AppSettings.instance.setBool('billi_biometric_lock', AppSettings.instance.biometricLock, true);
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not enable biometric lock.')));
    }
  }

  Future<void> _chooseCountry() async {
    final code = await showModalBottomSheet<String>(
      context: context, isScrollControlled: true,
      builder: (context) => SafeArea(child: SizedBox(height: MediaQuery.sizeOf(context).height * .82, child: Column(children: [
        Padding(padding: const EdgeInsets.all(18), child: Row(children: [Text(language == 'hi' ? 'देश / क्षेत्र चुनें' : 'Choose country / region', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))])),
        const Divider(height: 1),
        Expanded(child: ListView.builder(itemCount: AppSettings.countries.length, itemBuilder: (_, i) {
          final item = AppSettings.countries[i]; final selected = item['code'] == AppSettings.instance.country.value;
          return ListTile(leading: const Icon(Icons.public), title: Text(item['native']!), subtitle: Text(item['name']!), trailing: selected ? const Icon(Icons.check_circle) : null, onTap: () => Navigator.pop(context, item['code']));
        })),
      ]))),
    );
    if (code != null) await AppSettings.instance.setCountry(code);
  }

  Future<void> _deleteLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('delete_data')),
        content: Text(t('delete_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t('cancel'))),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: Text(t('delete'))),
        ],
      ),
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    final root = await getApplicationDocumentsDirectory();
    final media = Directory('${root.path}/billi_billi_media');
    if (await media.exists()) await media.delete(recursive: true);
    await prefs.clear();
    await AppSettings.instance.clearSecureData();
    await AppSettings.instance.init();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local app data deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppSettings.instance.language,
      builder: (context, code, _) {
        final rtl = AppSettings.instance.isRtl;
        return Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(title: Text(t('settings'))),
            body: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(t('account')),
                  subtitle: Text(code == 'hi' ? 'प्रोफ़ाइल और अकाउंट सेटिंग्स' : 'Profile and account settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountAuthPage()),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: AppSettings.instance.notifications,
                  builder: (_, value, __) => SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: Text(t('notifications')),
                    value: value,
                    onChanged: (v) => AppSettings.instance.setBool('billi_notifications', AppSettings.instance.notifications, v),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(t('privacy')),
                  subtitle: Text(t('privacy_desc')),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: AppSettings.instance.privateAccount,
                  builder: (_, value, __) => SwitchListTile(
                    secondary: const Icon(Icons.person_off_outlined),
                    title: Text(t('private_account')),
                    subtitle: Text(t('private_desc')),
                    value: value,
                    onChanged: (v) => AppSettings.instance.setBool('billi_private_account', AppSettings.instance.privateAccount, v),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: AppSettings.instance.biometricLock,
                  builder: (_, value, __) => SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: Text(t('biometric_lock')),
                    subtitle: Text(t('biometric_desc')),
                    value: value,
                    onChanged: _setBiometric,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: AppSettings.instance.dataSaver,
                  builder: (_, value, __) => SwitchListTile(
                    secondary: const Icon(Icons.data_saver_on),
                    title: Text(t('data_saver')),
                    subtitle: Text(t('data_saver_desc')),
                    value: value,
                    onChanged: (v) => AppSettings.instance.setBool('billi_data_saver', AppSettings.instance.dataSaver, v),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: AppSettings.instance.autoplay,
                  builder: (_, value, __) => SwitchListTile(
                    secondary: const Icon(Icons.play_circle_outline),
                    title: Text(t('autoplay')),
                    subtitle: Text(t('autoplay_desc')),
                    value: value,
                    onChanged: (v) => AppSettings.instance.setBool('billi_autoplay', AppSettings.instance.autoplay, v),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(t('language')),
                  subtitle: Text(AppSettings.languages.firstWhere((item) => item['code'] == code, orElse: () => AppSettings.languages.first)['native']!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _chooseLanguage,
                ),
                ValueListenableBuilder<String>(
                  valueListenable: AppSettings.instance.country,
                  builder: (_, countryCode, __) {
                    final item = AppSettings.countries.firstWhere((c) => c['code'] == countryCode, orElse: () => AppSettings.countries.first);
                    return ListTile(leading: const Icon(Icons.public), title: Text(code == 'hi' ? 'देश / क्षेत्र' : 'Country / Region'), subtitle: Text('${item['native']} — ${item['name']}'), trailing: const Icon(Icons.chevron_right), onTap: _chooseCountry);
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: AppSettings.instance.secureStorageReady,
                  builder: (_, ready, __) => ListTile(
                    leading: Icon(ready ? Icons.verified_user_outlined : Icons.warning_amber_outlined),
                    title: Text(t('security_status')),
                    subtitle: Text('${t('secure_storage')}: ${ready ? t('security_ready') : t('security_unavailable')}\n${t('secure_storage_desc')}'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: Text(language == 'hi' ? 'सिक्योरिटी सेंटर' : 'Security Center'),
                  subtitle: Text(language == 'hi' ? 'डिवाइस सुरक्षा और डेटा सुरक्षा की जानकारी' : 'Review device and data protection'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final biometric = await AppSettings.instance.checkBiometricAvailability();
                    if (!context.mounted) return;
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(language == 'hi' ? 'Billi Billi सुरक्षा केंद्र' : 'Billi Billi Security Center'),
                        content: Text(language == 'hi'
                            ? 'सुरक्षित डिवाइस स्टोरेज: ${AppSettings.instance.secureStorageReady.value ? 'सुरक्षित' : 'उपलब्ध नहीं'}\nबायोमेट्रिक: ${biometric ? 'उपलब्ध' : 'उपलब्ध नहीं'}\n\nस्थानीय सुरक्षा के साथ भी online/server data के लिए secure backend, authentication, authorization और HTTPS/TLS जरूरी हैं।'
                            : 'Secure device storage: ${AppSettings.instance.secureStorageReady.value ? 'Protected' : 'Unavailable'}\nBiometrics: ${biometric ? 'Available' : 'Unavailable'}\n\nClient-side protections do not replace a secure backend. Online/server data still requires authentication, authorization and HTTPS/TLS.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(t('cancel'))),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(t('delete_data')),
                  subtitle: Text(t('delete_data_desc')),
                  onTap: _deleteLocalData,
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(t('about')),
                  subtitle: const Text('Version 1.3.0'),
                  onTap: () => showAboutDialog(context: context, applicationName: 'Billi Billi', applicationVersion: '1.3.0', applicationLegalese: 'Billi Billi Video Sharing App'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(t('logout'), style: const TextStyle(color: Colors.red)),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(code == 'hi' ? 'लॉग आउट करें?' : 'Log out?'),
                        content: Text(code == 'hi'
                            ? 'आपका ऑनलाइन अकाउंट इस डिवाइस से साइन आउट हो जाएगा।'
                            : 'Your online account will be signed out on this device.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(t('cancel'))),
                          FilledButton.tonal(onPressed: () => Navigator.pop(dialogContext, true), child: Text(t('logout'))),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await AppData.instance.online.signOut();
                      await AppData.instance.setExplicitLogout();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AccountAuthPage()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
