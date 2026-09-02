import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    language.value = _prefs?.getString('billi_language') ?? 'hi';
  }

  Future<void> setLanguage(String code) async {
    language.value = code;
    await _prefs?.setString('billi_language', code);
  }

  static String text(String code, String key) {
    const en = {
      'settings': 'Settings', 'account': 'Account', 'notifications': 'Notifications',
      'privacy': 'Privacy & Security', 'language': 'Language', 'about': 'About Billi Billi',
      'home': 'Home', 'search': 'Search', 'create': 'Create', 'reels': 'Reels',
      'profile': 'Profile', 'save': 'Saved', 'logout': 'Logout',
      'choose_language': 'Choose app language', 'global': 'Global',
    };
    const hi = {
      'settings': 'सेटिंग्स', 'account': 'खाता', 'notifications': 'सूचनाएँ',
      'privacy': 'गोपनीयता और सुरक्षा', 'language': 'भाषा', 'about': 'Billi Billi के बारे में',
      'home': 'होम', 'search': 'खोजें', 'create': 'बनाएँ', 'reels': 'रील्स',
      'profile': 'प्रोफ़ाइल', 'save': 'सेव किए गए', 'logout': 'लॉग आउट',
      'choose_language': 'ऐप की भाषा चुनें', 'global': 'वैश्विक',
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
      'fr': {'settings':'Paramètres','account':'Compte','notifications':'Notifications','privacy':'Confidentialité et sécurité','language':'Langue','about':'À propos de Billi Billi','home':'Accueil','search':'Rechercher','create':'Créer','reels':'Reels','profile':'Profil','save':'Enregistrés','logout':'Déconnexion','choose_language':\"Choisir la langue de l’application\",'global':'Mondial'},
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BilliBilliApp());
}

class BilliBilliApp extends StatefulWidget {
  const BilliBilliApp({super.key});

  @override
  State<BilliBilliApp> createState() => _BilliBilliAppState();
}

class _BilliBilliAppState extends State<BilliBilliApp> {
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    await AppSettings.instance.init();
    if (mounted) setState(() => ready = true);
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

    return ValueListenableBuilder<String>(
      valueListenable: AppSettings.instance.language,
      builder: (context, language, _) {
        return MaterialApp(
          title: 'Billi Billi',
          debugShowCheckedModeBanner: false,
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
  });

  final String path;
  final MediaType type;
  final String caption;
  bool liked;
  bool saved;
  int likes;
  int comments;
}

class AppData {
  AppData._();

  static final AppData instance = AppData._();

  final ValueNotifier<List<MediaPost>> posts =
      ValueNotifier<List<MediaPost>>(<MediaPost>[]);

  final ValueNotifier<List<MediaPost>> savedPosts =
      ValueNotifier<List<MediaPost>>(<MediaPost>[]);

  final ValueNotifier<String> searchText = ValueNotifier<String>('');

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPosts();
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

  Future<void> toggleLike(MediaPost post) async {
    post.liked = !post.liked;
    if (post.liked) {
      post.likes++;
    } else if (post.likes > 0) {
      post.likes--;
    }
    posts.value = List<MediaPost>.from(posts.value);
    await _savePosts();
  }

  Future<void> toggleSave(MediaPost post) async {
    post.saved = !post.saved;
    posts.value = List<MediaPost>.from(posts.value);
    await _savePosts();
  }

  Future<void> addComment(MediaPost post) async {
    post.comments++;
    posts.value = List<MediaPost>.from(posts.value);
    await _savePosts();
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
      bottomNavigationBar: NavigationBar(
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
                    tooltip: 'Notifications',
                    onPressed: () => _openNotifications(context),
                    icon: const Icon(Icons.notifications_none),
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
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: const Text(
            'Billi Billi User',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Billi Billi'),
          trailing: PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                await AppData.instance.deletePost(post);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete post'),
              ),
            ],
          ),
        ),
        if (post.type == MediaType.photo)
          AspectRatio(
            aspectRatio: 1,
            child: Image.file(
              File(post.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _MediaError(),
            ),
          )
        else
          VideoPost(path: post.path),
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
                  await AppData.instance.addComment(widget.post);
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
  const VideoPost({super.key, required this.path});

  final String path;

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
      final controller = VideoPlayerController.file(File(widget.path));
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

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_search);
  }

  void _search() {
    AppData.instance.searchText.value = controller.text;
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = AppData.instance.filteredPosts();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
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
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      'कोई पोस्ट नहीं मिली',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, index) =>
                        MediaPostCard(post: results[index]),
                  ),
          ),
        ],
      ),
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

    await AppData.instance.addPost(
      path: savedPath,
      type: video != null ? MediaType.video : MediaType.photo,
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
      const SnackBar(content: Text('पोस्ट सफलतापूर्वक सेव हो गई ✅')),
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<MediaPost>>(
        valueListenable: AppData.instance.posts,
        builder: (context, posts, _) {
          final photos =
              posts.where((p) => p.type == MediaType.photo).length;
          final videos =
              posts.where((p) => p.type == MediaType.video).length;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: const Text('Profile'),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        child: Icon(Icons.person, size: 52),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Billi Billi User',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Billi Billi creator',
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Stat(value: '$photos', label: 'Photos'),
                          _Stat(value: '$videos', label: 'Videos'),
                          _Stat(
                            value: '${posts.length}',
                            label: 'Posts',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SavedPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bookmark_border),
                              label: const Text('Saved'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings_outlined),
                              label: const Text('Settings'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('आपकी पोस्ट यहां दिखाई देंगी।')),
                )
              else
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ProfileTile(post: posts[index]),
                    childCount: posts.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                ),
            ],
          );
        },
      ),
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
            const ColoredBox(child: Icon(Icons.broken_image)),
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

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.favorite)),
            title: Text('Billi Billi'),
            subtitle: Text('नई activity और likes यहां दिखाई देंगे।'),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person_add)),
            title: Text('Followers'),
            subtitle: Text('नए followers की जानकारी यहां दिखाई देगी।'),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
            title: Text('Comments'),
            subtitle: Text('आपकी पोस्ट के comments यहां दिखाई देंगे।'),
          ),
        ],
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
  bool notifications = true;
  bool privateAccount = false;

  String get language => AppSettings.instance.language.value;

  String t(String key) => AppSettings.text(language, key);

  Future<void> _chooseLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade950,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .82,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Text(
                        t('choose_language'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
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
                        trailing: selected
                            ? const Icon(Icons.check_circle)
                            : null,
                        onTap: () => Navigator.pop(context, item['code']),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      await AppSettings.instance.setLanguage(selected);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppSettings.instance.language,
      builder: (context, code, _) {
        return Scaffold(
          appBar: AppBar(title: Text(t('settings'))),
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(t('account')),
                subtitle: Text(
                  code == 'hi'
                      ? 'प्रोफ़ाइल और अकाउंट सेटिंग्स'
                      : 'Profile and account settings',
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(t('notifications')),
                subtitle: Text(
                  code == 'hi'
                      ? 'लाइक, कमेंट और अन्य सूचनाएँ'
                      : 'Likes, comments and other alerts',
                ),
                value: notifications,
                onChanged: (value) => setState(() => notifications = value),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(t('privacy')),
                subtitle: Text(
                  code == 'hi'
                      ? 'गोपनीयता और सुरक्षा विकल्प'
                      : 'Privacy and security options',
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(t('language')),
                subtitle: Text(
                  AppSettings.languages.firstWhere(
                    (item) => item['code'] == code,
                    orElse: () => AppSettings.languages.first,
                  )['native']!,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _chooseLanguage,
              ),
              ListTile(
                leading: const Icon(Icons.public),
                title: code == 'hi'
                    ? const Text('देश / क्षेत्र')
                    : const Text('Country / Region'),
                subtitle: Text(t('global')),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(t('about')),
                subtitle: const Text('Version 1.0.0'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Billi Billi',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Billi Billi Video Sharing App',
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  t('logout'),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
