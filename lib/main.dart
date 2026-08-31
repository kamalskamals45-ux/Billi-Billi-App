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
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainScreen(),
    );
  }
}

enum MediaType {
  photo,
  video,
}

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

  final ValueNotifier<String> searchText =
      ValueNotifier<String>('');

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPosts();
  }

  Future<Directory> _mediaDirectory() async {
    final Directory root =
        await getApplicationDocumentsDirectory();

    final Directory directory =
        Directory('${root.path}/billi_billi_media');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  Future<void> _loadPosts() async {
    final List<String> values =
        _prefs?.getStringList('billi_posts') ??
            <String>[];

    final List<MediaPost> loaded =
        <MediaPost>[];

    for (final String value in values) {
      final List<String> parts = value.split('|');

      if (parts.length < 7) {
        continue;
      }

      try {
        final File file = File(parts[0]);

        if (!await file.exists()) {
          continue;
        }

        loaded.add(
          MediaPost(
            path: parts[0],
            type: parts[1] == 'video'
                ? MediaType.video
                : MediaType.photo,
            caption:
                parts[2].replaceAll(r'\n', '\n'),
            liked: parts[3] == '1',
            saved: parts[4] == '1',
            likes: int.tryParse(parts[5]) ?? 0,
            comments: int.tryParse(parts[6]) ?? 0,
          ),
        );
      } catch (_) {
        continue;
      }
    }

    posts.value = loaded;
    _refreshSaved();
  }

  Future<void> _savePosts() async {
    final List<String> values =
        posts.value.map((MediaPost post) {
      final String safeCaption = post.caption
          .replaceAll('|', ' ')
          .replaceAll('\n', r'\n');

      return <String>[
        post.path,
        post.type == MediaType.video
            ? 'video'
            : 'photo',
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
        .where((MediaPost post) => post.saved)
        .toList(growable: false);
  }

  Future<String?> copyMediaToAppFolder(
    String sourcePath,
  ) async {
    try {
      final File source = File(sourcePath);

      if (!await source.exists()) {
        return null;
      }

      final Directory directory =
          await _mediaDirectory();

      String extension = 'mp4';

      if (sourcePath.contains('.')) {
        extension =
            sourcePath.split('.').last.toLowerCase();
      }

      final String fileName =
          'billi_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final File destination = await source.copy(
        '${directory.path}/$fileName',
      );

      return destination.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> addPost({
    required String path,
    required MediaType type,
    String caption = '',
  }) async {
    final MediaPost newPost = MediaPost(
      path: path,
      type: type,
      caption: caption.trim(),
    );

    posts.value = <MediaPost>[
      newPost,
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

    posts.value =
        List<MediaPost>.from(posts.value);

    await _savePosts();
  }

  Future<void> toggleSave(MediaPost post) async {
    post.saved = !post.saved;

    posts.value =
        List<MediaPost>.from(posts.value);

    await _savePosts();
  }

  Future<void> addComment(MediaPost post) async {
    post.comments++;

    posts.value =
        List<MediaPost>.from(posts.value);

    await _savePosts();
  }

  Future<void> deletePost(MediaPost post) async {
    posts.value = posts.value
        .where((MediaPost item) => item != post)
        .toList();

    await _savePosts();

    try {
      final File file = File(post.path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  List<MediaPost> filteredPosts() {
    final String query =
        searchText.value.trim().toLowerCase();

    if (query.isEmpty) {
      return posts.value;
    }

    return posts.value.where((MediaPost post) {
      final String type =
          post.type == MediaType.video
              ? 'video'
              : 'photo';

      return post.caption
              .toLowerCase()
              .contains(query) ||
          type.contains(query) ||
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

class _MainScreenState
    extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AppData.instance.init();
  }

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
        destinations:
            const <NavigationDestination>[
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<MediaPost>>(
        valueListenable: AppData.instance.posts,
        builder: (
          BuildContext context,
          List<MediaPost> items,
          Widget? child,
        ) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.black,
                floating: true,
                title: const Text(
                  'Billi Billi',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationsPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SavedPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.bookmark_border,
                    ),
                  ),
                ],
              ),
              const SliverToBoxAdapter(
                child: StoriesSection(),
              ),
              if (items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.video_collection_outlined,
                            size: 80,
                            color: Colors.white38,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'अभी कोई पोस्ट नहीं है',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Create में जाकर अपना पहला फोटो या वीडियो पोस्ट करें।',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (
                      BuildContext context,
                      int index,
                    ) {
                      return MediaPostCard(
                        post: items[index],
                      );
                    },
                    childCount: items.length,
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
      height: 115,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        itemCount: 8,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return Padding(
            padding:
                const EdgeInsets.only(right: 14),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      Colors.deepPurple.shade700,
                  child: index == 0
                      ? const Icon(
                          Icons.add,
                          size: 30,
                        )
                      : Text(
                          '$index',
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 5),
                Text(
                  index == 0
                      ? 'Your story'
                      : 'User $index',
                  style:
                      const TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MediaPostCard extends StatefulWidget {
  const MediaPostCard({
    super.key,
    required this.post,
  });

  final MediaPost post;

  @override
  State<MediaPostCard> createState() =>
      _MediaPostCardState();
}

class _MediaPostCardState
    extends State<MediaPostCard> {
  @override
  Widget build(BuildContext context) {
    final MediaPost post = widget.post;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: const Text(
            'Billi Billi User',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text('Billi Billi'),
          trailing:
              PopupMenuButton<String>(
            onSelected: (String value) async {
              if (value == 'delete') {
                await AppData.instance
                    .deletePost(post);

                if (mounted) {
                  setState(() {});
                }
              }
            },
            itemBuilder:
                (BuildContext context) {
              return const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete post'),
                ),
              ];
            },
          ),
        ),
        if (post.type == MediaType.photo)
          AspectRatio(
            aspectRatio: 1,
            child: Image.file(
              File(post.path),
              fit: BoxFit.cover,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return const SizedBox(
                  height: 350,
                  child: Center(
                    child: Text(
                      'फोटो उपलब्ध नहीं है',
                    ),
                  ),
                );
              },
            ),
          )
        else
          VideoPost(
            path: post.path,
          ),
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () async {
                await AppData.instance
                    .toggleLike(post);

                if (mounted) {
                  setState(() {});
                }
              },
              icon: Icon(
                post.liked
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: post.liked
                    ? Colors.red
                    : Colors.white,
              ),
            ),
            if (post.likes > 0)
              Text('${post.likes}'),
            IconButton(
              onPressed: () {
                _showCommentDialog(context);
              },
              icon: const Icon(
                Icons.chat_bubble_outline,
              ),
            ),
            if (post.comments > 0)
              Text('${post.comments}'),
            IconButton(
              onPressed: () {
                _copyPath(context);
              },
              icon: const Icon(
                Icons.share_outlined,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                await AppData.instance
                    .toggleSave(post);

                if (mounted) {
                  setState(() {});
                }
              },
              icon: Icon(
                post.saved
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            18,
          ),
          child: Text(
            post.caption.isEmpty
                ? post.type == MediaType.video
                    ? 'Billi Billi वीडियो पोस्ट'
                    : 'Billi Billi फोटो पोस्ट'
                : post.caption,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCommentDialog(
    BuildContext context,
  ) async {
    final TextEditingController controller =
        TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text('Comment'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration:
                const InputDecoration(
              hintText: 'अपना कमेंट लिखें...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text
                    .trim()
                    .isNotEmpty) {
                  await AppData.instance
                      .addComment(widget.post);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (mounted) {
                  setState(() {});
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _copyPath(
    BuildContext context,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: widget.post.path),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'मीडिया path clipboard में कॉपी हो गया।',
        ),
      ),
    );
  }
}

class VideoPost extends StatefulWidget {
  const VideoPost({
    super.key,
    required this.path,
  });

  final String path;

  @override
  State<VideoPost> createState() =>
      _VideoPostState();
}

class _VideoPostState extends State<VideoPost> {
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
      final File file = File(widget.path);

      if (!await file.exists()) {
        if (!mounted) {
          return;
        }

        setState(() {
          loading = false;
          error = true;
        });

        return;
      }

      final VideoPlayerController newController =
          VideoPlayerController.file(file);

      await newController.initialize();
      await newController.setLooping(true);

      if (!mounted) {
        await newController.dispose();
        return;
      }

      setState(() {
        controller = newController;
        loading = false;
      });

      await newController.play();
    } catch (_) {
      if (!mounted) {
        return;
      }

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
    final VideoPlayerController? video =
        controller;

    if (loading) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error ||
        video == null ||
        !video.value.isInitialized) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text('वीडियो उपलब्ध नहीं है'),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (video.value.isPlaying) {
            video.pause();
          } else {
            video.play();
          }
        });
      },
      child: AspectRatio(
        aspectRatio: video.value.aspectRatio,
        child: VideoPlayer(video),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() =>
      _SearchPageState();
}

class _SearchPageState
    extends State<SearchPage> {
  final TextEditingController controller =
      TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    AppData.instance.searchText.value = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              onChanged: (String value) {
                AppData.instance.searchText.value =
                    value;
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search Billi Billi...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                          AppData.instance
                              .searchText.value = '';
                          setState(() {});
                        },
                        icon:
                            const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<
                List<MediaPost>>(
              valueListenable:
                  AppData.instance.posts,
              builder: (
                BuildContext context,
                List<MediaPost> items,
                Widget? child,
              ) {
                final List<MediaPost> filtered =
                    AppData.instance.filteredPosts();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'कोई पोस्ट नहीं मिली',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    final MediaPost post =
                        filtered[index];

                    return MediaPostCard(
                      post: post,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() =>
      _CreatePageState();
}

class _CreatePageState
    extends State<CreatePage> {
  final ImagePicker picker = ImagePicker();

  XFile? selectedFile;
  MediaType? selectedType;

  VideoPlayerController? previewController;

  final TextEditingController captionController =
      TextEditingController();

  bool saving = false;

  @override
  void dispose() {
    previewController?.dispose();
    captionController.dispose();
    super.dispose();
  }

  Future<void> _pickGallery() async {
    try {
      final XFile? file =
          await picker.pickMedia();

      if (file == null) {
        return;
      }

      await _setSelectedFile(file);
    } catch (e) {
      _showMessage(
        'Gallery से media चुनने में समस्या हुई।',
      );
    }
  }

  Future<void> _pickVideoCamera() async {
    try {
      final XFile? file =
          await picker.pickVideo(
        source: ImageSource.camera,
      );

      if (file == null) {
        return;
      }

      await _setSelectedFile(
        file,
        forceVideo: true,
      );
    } catch (_) {
      _showMessage(
        'Camera से वीडियो बनाने में समस्या हुई।',
      );
    }
  }

  Future<void> _pickPhotoCamera() async {
    try {
      final XFile? file =
          await picker.pickImage(
        source: ImageSource.camera,
      );

      if (file == null) {
        return;
      }

      await _setSelectedFile(
        file,
        forcePhoto: true,
      );
    } catch (_) {
      _showMessage(
        'Camera से फोटो लेने में समस्या हुई।',
      );
    }
  }

  Future<void> _setSelectedFile(
    XFile file, {
    bool forceVideo = false,
    bool forcePhoto = false,
  }) async {
    await previewController?.dispose();
    previewController = null;

    MediaType type;

    if (forceVideo) {
      type = MediaType.video;
    } else if (forcePhoto) {
      type = MediaType.photo;
    } else {
      final String name =
          file.name.toLowerCase();

      final bool isVideo =
          name.endsWith('.mp4') ||
              name.endsWith('.mov') ||
              name.endsWith('.avi') ||
              name.endsWith('.mkv') ||
              name.endsWith('.webm');

      type = isVideo
          ? MediaType.video
          : MediaType.photo;
    }

    if (type == MediaType.video) {
      try {
        final VideoPlayerController video =
            VideoPlayerController.file(
          File(file.path),
        );

        await video.initialize();
        await video.setLooping(true);

        previewController = video;
      } catch (_) {
        previewController = null;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      selectedFile = file;
      selectedType = type;
    });
  }

  Future<void> _publish() async {
    if (selectedFile == null ||
        selectedType == null) {
      _showMessage(
        'पहले फोटो या वीडियो चुनें।',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    final String? savedPath =
        await AppData.instance.copyMediaToAppFolder(
      selectedFile!.path,
    );

    if (savedPath == null) {
      if (mounted) {
        setState(() {
          saving = false;
        });

        _showMessage(
          'Media save नहीं हो सका।',
        );
      }

      return;
    }

    await AppData.instance.addPost(
      path: savedPath,
      type: selectedType!,
      caption: captionController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      saving = false;
      selectedFile = null;
      selectedType = null;
    });

    await previewController?.dispose();
    previewController = null;
    captionController.clear();

    _showMessage(
      'Post successfully publish हो गई ✅',
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            const Text(
              'Create',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _preview(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    saving ? null : _pickGallery,
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: const Text(
                  'Choose from Gallery',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: saving
                        ? null
                        : _pickVideoCamera,
                    icon: const Icon(
                      Icons.videocam_outlined,
                    ),
                    label: const Text('Video'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: saving
                        ? null
                        : _pickPhotoCamera,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                    ),
                    label: const Text('Photo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: captionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Caption लिखें...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed:
                    saving ? null : _publish,
                icon: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.publish,
                      ),
                label: Text(
                  saving
                      ? 'Publishing...'
                      : 'Publish',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview() {
    if (selectedFile == null) {
      return Container(
        height: 330,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.perm_media_outlined,
              size: 80,
              color: Colors.white38,
            ),
            SizedBox(height: 15),
            Text(
              'अपना फोटो या वीडियो चुनें',
            ),
          ],
        ),
      );
    }

    if (selectedType == MediaType.photo) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(20),
        child: Image.file(
          File(selectedFile!.path),
          width: double.infinity,
          height: 330,
          fit: BoxFit.cover,
          errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            return const SizedBox(
              height: 330,
              child: Center(
                child:
                    Text('Preview उपलब्ध नहीं है'),
              ),
            );
          },
        ),
      );
    }

    final VideoPlayerController? video =
        previewController;

    if (video == null ||
        !video.value.isInitialized) {
      return Container(
        height: 330,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!video.value.isPlaying) {
      video.play();
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: video.value.aspectRatio,
        child: VideoPlayer(video),
      ),
    );
  }
}

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() =>
      _ReelsPageState();
}

class _ReelsPageState
    extends State<ReelsPage> {
  final PageController pageController =
      PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<
          List<MediaPost>>(
        valueListenable:
            AppData.instance.posts,
        builder: (
          BuildContext context,
          List<MediaPost> items,
          Widget? child,
        ) {
          final List<MediaPost> videos =
              items
                  .where(
                    (MediaPost post) =>
                        post.type ==
                        MediaType.video,
                  )
                  .toList();

          if (videos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
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
                      fontWeight:
                          FontWeight.bold,
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
              return ReelItem(
                post: videos[index],
              );
            },
          );
        },
      ),
    );
  }
}
class ReelItem extends StatefulWidget {
  const ReelItem({
    super.key,
    required this.post,
  });

  final MediaPost post;

  @override
  State<ReelItem> createState() =>
      _ReelItemState();
}

class _ReelItemState
    extends State<ReelItem> {
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
      final File file =
          File(widget.post.path);

      if (!await file.exists()) {
        if (!mounted) {
          return;
        }

        setState(() {
          loading = false;
          error = true;
        });

        return;
      }

      final VideoPlayerController video =
          VideoPlayerController.file(file);

      await video.initialize();
      await video.setLooping(true);

      if (!mounted) {
        await video.dispose();
        return;
      }

      controller = video;

      setState(() {
        loading = false;
      });

      await video.play();
    } catch (_) {
      if (!mounted) {
        return;
      }

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
    final VideoPlayerController? video =
        controller;

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error ||
        video == null ||
        !video.value.isInitialized) {
      return const Center(
        child: Text(
          'Reel उपलब्ध नहीं है',
        ),
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
          right: 10,
          bottom: 90,
          child: Column(
            children: <Widget>[
              IconButton(
                onPressed: () async {
                  await AppData.instance
                      .toggleLike(widget.post);

                  if (mounted) {
                    setState(() {});
                  }
                },
                iconSize: 36,
                icon: Icon(
                  widget.post.liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.post.liked
                      ? Colors.red
                      : Colors.white,
                ),
              ),
              Text(
                '${widget.post.likes}',
              ),
              const SizedBox(height: 12),
              IconButton(
                onPressed: () {
                  _showCommentBox(context);
                },
                iconSize: 32,
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              Text(
                '${widget.post.comments}',
              ),
              const SizedBox(height: 12),
              IconButton(
                onPressed: () async {
                  await AppData.instance
                      .toggleSave(widget.post);

                  if (mounted) {
                    setState(() {});
                  }
                },
                iconSize: 32,
                icon: Icon(
                  widget.post.saved
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
              ),
              const SizedBox(height: 12),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content:
                          Text('वीडियो शेयर करें'),
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
          left: 16,
          right: 80,
          bottom: 25,
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

  Future<void> _showCommentBox(
    BuildContext context,
  ) async {
    final TextEditingController controller =
        TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.grey.shade900,
      builder: (
        BuildContext sheetContext,
      ) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom:
                MediaQuery.of(sheetContext)
                        .viewInsets
                        .bottom +
                    20,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: <Widget>[
              const Text(
                'कमेंट करें',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration:
                    const InputDecoration(
                  hintText:
                      'अपना कमेंट लिखें...',
                  border:
                      OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (controller.text
                        .trim()
                        .isEmpty) {
                      return;
                    }

                    await AppData.instance
                        .addComment(widget.post);

                    if (sheetContext.mounted) {
                      Navigator.pop(
                        sheetContext,
                      );
                    }

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child:
                      const Text('पोस्ट करें'),
                ),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  String username = 'Billi Billi User';
  String bio =
      'Billi Billi पर आपका स्वागत है ❤️';

  void _editProfile() {
    final TextEditingController nameController =
        TextEditingController(
      text: username,
    );

    final TextEditingController bioController =
        TextEditingController(
      text: bio,
    );

    showDialog<void>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'प्रोफाइल एडिट करें',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(
                  labelText: 'नाम',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration:
                    const InputDecoration(
                  labelText: 'Bio',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('रद्द करें'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  username =
                      nameController.text
                              .trim()
                              .isEmpty
                          ? 'Billi Billi User'
                          : nameController.text
                              .trim();

                  bio = bioController.text
                      .trim();
                });

                Navigator.pop(
                  dialogContext,
                );
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
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 70,
                    backgroundColor:
                        Colors.deepPurple,
                    child: Icon(
                      Icons.person,
                      size: 75,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '@billi_billi_user',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      color:
                          Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ValueListenableBuilder<
                      List<MediaPost>>(
                    valueListenable:
                        AppData.instance.posts,
                    builder: (
                      BuildContext context,
                      List<MediaPost> posts,
                      Widget? child,
                    ) {
                      return Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceEvenly,
                        children: <Widget>[
                          _stat(
                            '${posts.length}',
                            'Posts',
                          ),
                          _stat(
                            '0',
                            'Followers',
                          ),
                          _stat(
                            '0',
                            'Following',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  OutlinedButton(
                    onPressed:
                        _editProfile,
                    style:
                        OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 35,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style:
                          TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ListTile(
                    leading: const Icon(
                      Icons.bookmark_outline,
                    ),
                    title:
                        const Text('Saved Posts'),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SavedPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                    ),
                    title:
                        const Text('Settings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.language,
                    ),
                    title:
                        const Text('Language'),
                    subtitle: const Text(
                      'Hindi / English',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                    ),
                    title:
                        const Text(
                      'About Billi Billi',
                    ),
                    subtitle:
                        const Text(
                      'Version 1.0.0',
                    ),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName:
                            'Billi Billi',
                        applicationVersion:
                            '1.0.0',
                        applicationLegalese:
                            'Billi Billi Video Sharing App',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    String number,
    String label,
  ) {
    return Column(
      children: <Widget>[
        Text(
          number,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: ValueListenableBuilder<
          List<MediaPost>>(
        valueListenable:
            AppData.instance.savedPosts,
        builder: (
          BuildContext context,
          List<MediaPost> items,
          Widget? child,
        ) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.bookmark_border,
                    size: 70,
                    color: Colors.white38,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'अभी कोई saved post नहीं है',
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (
              BuildContext context,
              int index,
            ) {
              return MediaPostCard(
                post: items[index],
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationsPage
    extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notifications'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.notifications_none,
              size: 70,
              color: Colors.white38,
            ),
            SizedBox(height: 15),
            Text(
              'अभी कोई notification नहीं है',
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage
    extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(
              Icons.notifications_outlined,
            ),
            title:
                const Text('Notifications'),
            trailing:
                Switch(
              value: true,
              onChanged: (_) {},
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.dark_mode_outlined,
            ),
            title:
                const Text('Dark Mode'),
            trailing:
                const Icon(Icons.check),
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
            ),
            title:
                const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName:
                    'Billi Billi',
                applicationVersion:
                    '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
