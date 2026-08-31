import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BilliBilliApp());
}

class BilliBilliApp extends StatelessWidget {
  const BilliBilliApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    final values =
        _prefs?.getStringList('billi_posts') ?? <String>[];

    final loaded = <MediaPost>[];

    for (final value in values) {
      final parts = value.split('|');

      if (parts.length < 7) {
        continue;
      }

      final file = File(parts[0]);

      if (!await file.exists()) {
        continue;
      }

      loaded.add(
        MediaPost(
          path: parts[0],
          type: parts[1] == 'video'
              ? MediaType.video
              : MediaType.photo,
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
      final safeCaption = post.caption
          .replaceAll('|', ' ')
          .replaceAll('\n', r'\n');

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

    await _prefs?.setStringList(
      'billi_posts',
      values,
    );

    _refreshSaved();
  }

  void _refreshSaved() {
    savedPosts.value = posts.value
        .where((post) => post.saved)
        .toList(growable: false);
  }

  Future<String?> copyMediaToAppFolder(
    String sourcePath,
  ) async {
    try {
      final source = File(sourcePath);

      if (!await source.exists()) {
        return null;
      }

      final dir = await _mediaDirectory();

      final extension = sourcePath.contains('.')
          ? sourcePath.split('.').last.toLowerCase()
          : 'mp4';

      final name =
          'billi_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final saved = await source.copy(
        '${dir.path}/$name',
      );

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
      MediaPost(
        path: path,
        type: type,
        caption: caption,
      ),
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

    posts.value = List<MediaPost>.from(
      posts.value,
    );

    await _savePosts();
  }

  Future<void> toggleSave(MediaPost post) async {
    post.saved = !post.saved;

    posts.value = List<MediaPost>.from(
      posts.value,
    );

    await _savePosts();
  }

  Future<void> addComment(MediaPost post) async {
    post.comments++;

    posts.value = List<MediaPost>.from(
      posts.value,
    );

    await _savePosts();
  }

  Future<void> deletePost(MediaPost post) async {
    posts.value = posts.value
        .where((item) => item != post)
        .toList();

    await _savePosts();

    try {
      final file = File(post.path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  List<MediaPost> filteredPosts() {
    final query =
        searchText.value.trim().toLowerCase();

    if (query.isEmpty) {
      return posts.value;
    }

    return posts.value.where((post) {
      return post.caption
              .toLowerCase()
              .contains(query) ||
          (post.type == MediaType.video
                  ? 'video'
                  : 'photo')
              .contains(query) ||
          'billi billi'.contains(query);
    }).toList();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const HomePage(),
      const SearchPage(),
      const CreatePage(),
      const ReelsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
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
class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const HomePage(),
      const SearchPage(),
      const CreatePage(),
      const ReelsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: Colors.white12,
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
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

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<MediaPost>>(
        valueListenable: posts,
        builder: (
          BuildContext context,
          List<MediaPost> items,
          Widget? child,
        ) {
          final List<MediaPost> videos = items
              .where((MediaPost post) => post.type == MediaType.video)
              .toList();

          if (videos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.video_library_outlined,
                    size: 80,
                    color: Colors.white38,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'अभी कोई Reel उपलब्ध नहीं है',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create से अपना पहला वीडियो बनाएं',
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            );
          }

          return PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (
              BuildContext context,
              int index,
            ) {
              return ReelItem(post: videos[index]);
            },
          );
        },
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final MediaPost post;

  const ReelItem({
    super.key,
    required this.post,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  VideoPlayerController? controller;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final File file = File(widget.post.path);

      if (!await file.exists()) {
        if (!mounted) return;

        setState(() {
          loading = false;
          error = true;
        });

        return;
      }

      final VideoPlayerController newController =
          VideoPlayerController.file(file);

      await newController.initialize();

      if (!mounted) {
        await newController.dispose();
        return;
      }

      await newController.setLooping(true);
      await newController.play();

      setState(() {
        controller = newController;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? video = controller;

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error || video == null || !video.value.isInitialized) {
      return const Center(
        child: Text('Reel उपलब्ध नहीं है'),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              if (video.value.isPlaying) {
                video.pause();
              } else {
                video.play();
              }
            });
          },
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: video.value.size.width,
              height: video.value.size.height,
              child: VideoPlayer(video),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.post.liked = !widget.post.liked;

                    if (widget.post.liked) {
                      widget.post.likes++;
                    } else if (widget.post.likes > 0) {
                      widget.post.likes--;
                    }
                  });

                  posts.value = List<MediaPost>.from(posts.value);
                },
                iconSize: 34,
                icon: Icon(
                  widget.post.liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.post.liked
                      ? Colors.red
                      : Colors.white,
                ),
              ),
              Text('${widget.post.likes}'),
              const SizedBox(height: 15),
              IconButton(
                onPressed: () {
                  _showCommentBox(context);
                },
                iconSize: 32,
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              const SizedBox(height: 15),
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.post.saved = !widget.post.saved;
                  });

                  posts.value = List<MediaPost>.from(posts.value);
                },
                iconSize: 32,
                icon: Icon(
                  widget.post.saved
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
              ),
              const SizedBox(height: 15),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('वीडियो शेयर करें'),
                    ),
                  );
                },
                iconSize: 32,
                icon: const Icon(
                  Icons.share_outlined,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 15,
          right: 80,
          bottom: 30,
          child: Text(
            widget.post.caption.isEmpty
                ? 'Billi Billi Reel'
                : widget.post.caption,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showCommentBox(BuildContext context) {
    final TextEditingController commentController =
        TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'कमेंट करें',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'अपना कमेंट लिखें...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (commentController.text.trim().isEmpty) {
                      return;
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('कमेंट पोस्ट हो गया ✅'),
                      ),
                    );
                  },
                  child: const Text('पोस्ट करें'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Billi Billi User';
  String bio = 'Billi Billi पर आपका स्वागत है ❤️';

  void _editProfile() {
    final TextEditingController nameController =
        TextEditingController(text: username);

    final TextEditingController bioController =
        TextEditingController(text: bio);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('प्रोफाइल एडिट करें'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'नाम',
                ),
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('रद्द करें'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  username = nameController.text.trim().isEmpty
                      ? 'Billi Billi User'
                      : nameController.text.trim();

                  bio = bioController.text.trim();
                });

                Navigator.pop(context);
              },
              child: const Text('सेव'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.black,
            title: Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () {
                  _showSettings();
                },
                icon: const Icon(Icons.menu),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person,
                      size: 55,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _profileStat(
                        'Posts',
                        '${posts.value.length}',
                      ),
                      _profileStat(
                        'Followers',
                        '0',
                      ),
                      _profileStat(
                        'Following',
                        '0',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _editProfile,
                      child: const Text('प्रोफाइल एडिट करें'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(),
          ),
          ValueListenableBuilder<List<MediaPost>>(
            valueListenable: posts,
            builder: (
              BuildContext context,
              List<MediaPost> items,
              Widget? child,
            ) {
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'अभी कोई पोस्ट नहीं है',
                    ),
                  ),
                );
              }

              return SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (
                    BuildContext context,
                    int index,
                  ) {
                    final MediaPost post = items[index];

                    return Container(
                      color: Colors.white12,
                      child: post.type == MediaType.video
                          ? const Icon(
                              Icons.play_circle_outline,
                              size: 45,
                            )
                          : const Icon(
                              Icons.image_outlined,
                              size: 45,
                            ),
                    );
                  },
                  childCount: items.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String title, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'सेटिंग्स',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('सूचनाएं'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('प्राइवेसी'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('सुरक्षा'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('ऐप के बारे में'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
