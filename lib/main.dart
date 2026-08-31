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

    final Directory dir =
        Directory('${root.path}/billi_billi_media');

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
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
    }

    posts.value = loaded;
    _refreshSaved();
  }

  Future<void> _savePosts() async {
    final List<String> values =
        posts.value.map((MediaPost post) {
      final String caption = post.caption
          .replaceAll('|', ' ')
          .replaceAll('\n', r'\n');

      return <String>[
        post.path,
        post.type == MediaType.video
            ? 'video'
            : 'photo',
        caption,
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

      final Directory dir =
          await _mediaDirectory();

      final String extension =
          sourcePath.contains('.')
              ? sourcePath.split('.').last.toLowerCase()
              : 'mp4';

      final String fileName =
          'billi_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final File saved =
          await source.copy('${dir.path}/$fileName');

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
    final List<Widget> pages =
        <Widget>[
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
        onDestinationSelected:
            (int index) {
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
      child: ValueListenableBuilder<
          List<MediaPost>>(
        valueListenable:
            AppData.instance.posts,
        builder: (
          BuildContext context,
          List<MediaPost> posts,
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
              if (posts.isEmpty)
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
                        post: posts[index],
                      );
                    },
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
        padding:
            const EdgeInsets.symmetric(
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
                      Colors.white24,
                  child: index == 0
                      ? const Icon(
                          Icons.add,
                          size: 30,
                        )
                      : Text(
                          '${index + 1}',
                          style:
                              const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                ),
                const SizedBox(height: 5),
                Text(
                  index == 0
                      ? 'Your story'
                      : 'User ${index + 1}',
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
              }
            },
            itemBuilder: (
              BuildContext context,
            ) {
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
          padding:
              const EdgeInsets.fromLTRB(
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

    if (!context.mounted) return;

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

class _VideoPostState
    extends State<VideoPost> {
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
        if (mounted) {
          setState(() {
            loading = false;
            error = true;
          });
        }
        return;
      }

      final VideoPlayerController newController =
          VideoPlayerController.file(file);

      await newController.initialize();

      if (!mounted) {
        await newController.dispose();
        return;
      }

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
    final VideoPlayerController? video =
        controller;

    if (loading) {
      return const AspectRatio(
        aspectRatio: 9 / 16,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error ||
        video == null ||
        !video.value.isInitialized) {
      return const SizedBox(
        height: 350,
        child: Center(
          child: Text('वीडियो चल नहीं पाया'),
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
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio:
                video.value.aspectRatio,
            child: VideoPlayer(video),
          ),
          if (!video.value.isPlaying)
            const CircleAvatar(
              radius: 30,
              child: Icon(
                Icons.play_arrow,
                size: 38,
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              video,
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
  State<SearchPage> createState() =>
      _SearchPageState();
}

class _SearchPageState
    extends State<SearchPage> {
  final TextEditingController controller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_search);
  }

  void _search() {
    AppData.instance.searchText.value =
        controller.text;
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<MediaPost> results =
        AppData.instance.filteredPosts();

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText:
                    'Search people, videos, hashtags...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon:
                    controller.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed:
                                controller.clear,
                            icon: const Icon(
                              Icons.clear,
                            ),
                          ),
                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      'कोई पोस्ट नहीं मिली',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      return MediaPostCard(
                        post: results[index],
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
  final ImagePicker picker =
      ImagePicker();

  VideoPlayerController? videoController;

  XFile? selectedVideo;
  XFile? selectedPhoto;

  bool loading = false;
  bool posting = false;

  Future<void> pickVideo(
    ImageSource source,
  ) async {
    if (loading || posting) return;

    setState(() {
      loading = true;
    });

    try {
      final XFile? video =
          await picker.pickVideo(
        source: source,
        maxDuration:
            const Duration(minutes: 5),
      );

      if (video == null) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        return;
      }

      final VideoPlayerController newController =
          VideoPlayerController.file(
        File(video.path),
      );

      await newController.initialize();
      await videoController?.dispose();

      if (!mounted) {
        await newController.dispose();
        return;
      }

      setState(() {
        selectedVideo = video;
        selectedPhoto = null;
        videoController = newController;
        loading = false;
      });

      await newController.play();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'वीडियो open नहीं हुआ: $e',
      );
    }
  }

  Future<void> pickPhoto(
    ImageSource source,
  ) async {
    if (loading || posting) return;

    setState(() {
      loading = true;
    });

    try {
      final XFile? photo =
          await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1800,
      );

      if (photo == null) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        return;
      }

      await videoController?.dispose();

      if (!mounted) return;

      setState(() {
        selectedPhoto = photo;
        selectedVideo = null;
        videoController = null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'फोटो open नहीं हुई: $e',
      );
    }
  }

  Future<void> postMedia() async {
    if (posting) return;

    final XFile? video = selectedVideo;
    final XFile? photo = selectedPhoto;

    if (video == null && photo == null) {
      _showMessage(
        'पहले फोटो या वीडियो चुनें।',
      );
      return;
    }

    setState(() {
      posting = true;
    });

    final String sourcePath =
        video?.path ?? photo!.path;

    final String? savedPath =
        await AppData.instance
            .copyMediaToAppFolder(
      sourcePath,
    );

    if (savedPath == null) {
      if (mounted) {
        setState(() {
          posting = false;
        });

        _showMessage(
          'मीडिया सेव नहीं हो पाया।',
        );
      }
      return;
    }

    await AppData.instance.addPost(
      path: savedPath,
      type: video != null
          ? MediaType.video
          : MediaType.photo,
    );

    await videoController?.dispose();

    if (!mounted) return;

    setState(() {
      videoController = null;
      selectedVideo = null;
      selectedPhoto = null;
      posting = false;
    });

    _showMessage(
      'पोस्ट सफलतापूर्वक सेव हो गई ✅',
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? video =
        videoController;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const Text(
              'Create',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Billi Billi पर फोटो और वीडियो बनाएं',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            if (loading)
              const CircularProgressIndicator(),
            if (selectedPhoto != null)
              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 15,
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(14),
                  child: Image.file(
                    File(selectedPhoto!.path),
                    height: 330,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (video != null &&
                video.value.isInitialized)
              Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio:
                          video.value.aspectRatio,
                      child: VideoPlayer(video),
                    ),
                  ),
                  IconButton(
                    iconSize: 55,
                    onPressed: () {
                      setState(() {
                        if (video.value.isPlaying) {
                          video.pause();
                        } else {
                          video.play();
                        }
                      });
                    },
                    icon: Icon(
                      video.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 15),
            _CreateButton(
              icon:
                  Icons.video_library_outlined,
              text:
                  'Gallery से वीडियो चुनें',
              onPressed:
                  loading || posting
                      ? null
                      : () => pickVideo(
                            ImageSource.gallery,
                          ),
            ),
            const SizedBox(height: 12),
            _CreateButton(
              icon:
                  Icons.videocam_outlined,
              text:
                  'Camera से वीडियो रिकॉर्ड करें',
              onPressed:
                  loading || posting
                      ? null
                      : () => pickVideo(
                            ImageSource.camera,
                          ),
            ),
            const SizedBox(height: 12),
            _CreateButton(
              icon:
                  Icons.photo_library_outlined,
              text:
                  'Gallery से फोटो चुनें',
              onPressed:
                  loading || posting
                      ? null
                      : () => pickPhoto(
                            ImageSource.gallery,
                          ),
            ),
            const SizedBox(height: 12),
            _CreateButton(
              icon:
                  Icons.camera_alt_outlined,
              text: 'Camera से फोटो लें',
              onPressed:
                  loading || posting
                      ? null
                      : () => pickPhoto(
                            ImageSource.camera,
                          ),
            ),
            if (selectedVideo != null ||
                selectedPhoto != null)
              Padding(
                padding:
                    const EdgeInsets.only(
                  top: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    onPressed:
                        loading || posting
                            ? null
                            : postMedia,
                    icon: const Icon(
                      Icons.cloud_upload_outlined,
                    ),
                    label: Text(
                      posting
                          ? 'Posting...'
                          : 'Post करें',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton
    extends StatelessWidget {
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
          List<MediaPost> posts,
          Widget? child,
        ) {
          final List<MediaPost> videos =
              posts
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
        if (mounted) {
          setState(() {
            loading = false;
            error = true;
          });
        }
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
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: video.value.size.width,
              height: video.value.size.height,
              child: VideoPlayer(video),
            ),
          ),
          if (!video.value.isPlaying)
            const Center(
              child: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.play_arrow,
                  size: 38,
                ),
              ),
            ),
          Positioned(
            right: 12,
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
                Text(
                  '${widget.post.likes}',
                ),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () async {
                    await AppData.instance
                        .addComment(widget.post);

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  iconSize: 32,
                  icon:  const Icon(
                    Icons.share_outlined,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 15,
            right: 80,
            bottom: 25,
            child: Text(
              widget.post.caption.isEmpty
                  ? 'Billi Billi Reel\n#BilliBilli #Shorts'
                  : '${widget.post.caption}\n#BilliBilli #Shorts',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              video,
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
          title:
              const Text('प्रोफाइल एडिट करें'),
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
              TextField(
                controller: bioController,
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
                Navigator.pop(dialogContext);
              },
              child:
                  const Text('रद्द करें'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  username = nameController
                          .text
                          .trim()
                          .isEmpty
                      ? 'Billi Billi User'
                      : nameController.text
                          .trim();

                  bio = bioController.text.trim();
                });

                Navigator.pop(dialogContext);
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
      child: ValueListenableBuilder<
          List<MediaPost>>(
        valueListenable:
            AppData.instance.posts,
        builder: (
          BuildContext context,
          List<MediaPost> posts,
          Widget? child,
        ) {
          final int videos = posts
              .where(
                (MediaPost post) =>
                    post.type ==
                    MediaType.video,
              )
              .length;

          final int photos = posts
              .where(
                (MediaPost post) =>
                    post.type ==
                    MediaType.photo,
              )
              .length;

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                title: Text(username),
                actions: <Widget>[
                  IconButton(
                    onPressed: _editProfile,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SettingsPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.settings_outlined,
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(
                          Icons.person,
                          size: 55,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        username,
                        style:
                            const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bio,
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceEvenly,
                        children: <Widget>[
                          _ProfileStat(
                            value:
                                '${posts.length}',
                            label: 'Posts',
                          ),
                          _ProfileStat(
                            value: '$videos',
                            label: 'Videos',
                          ),
                          _ProfileStat(
                            value: '$photos',
                            label: 'Photos',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed:
                              _editProfile,
                          child: const Text(
                            'प्रोफाइल एडिट करें',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
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
                          label: const Text(
                            'Saved Posts',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'आपकी पोस्ट यहां दिखाई देंगी।',
                    ),
                  ),
                )
              else
                SliverGrid(
                  delegate:
                      SliverChildBuilderDelegate(
                    (
                      BuildContext context,
                      int index,
                    ) {
                      final MediaPost post =
                          posts[index];

                      if (post.type ==
                          MediaType.photo) {
                        return Image.file(
                          File(post.path),
                          fit: BoxFit.cover,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return const Icon(
                              Icons.broken_image,
                            );
                          },
                        );
                      }

                      return const ColoredBox(
                        color: Colors.white12,
                        child: Center(
                          child: Icon(
                            Icons.play_circle,
                            size: 42,
                          ),
                        ),
                      );
                    },
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

class _ProfileStat
    extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
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
          label,
          style: const TextStyle(
            color: Colors.white60,
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
          List<MediaPost> posts,
          Widget? child,
        ) {
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'अभी कोई saved post नहीं है।',
                style: TextStyle(
                  fontSize: 19,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (
              BuildContext context,
              int index,
            ) {
              return MediaPostCard(
                post: posts[index],
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
      body: ListView(
        children: const <Widget>[
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.favorite),
            ),
            title: Text('Likes'),
            subtitle: Text(
              'आपकी पोस्ट के likes यहां दिखाई देंगे।',
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Icon(
                Icons.person_add,
              ),
            ),
            title: Text('Followers'),
            subtitle: Text(
              'नए followers की जानकारी यहां दिखाई देगी।',
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Icon(
                Icons.comment_outlined,
              ),
            ),
            title: Text('Comments'),
            subtitle: Text(
              'आपकी पोस्ट के comments यहां दिखाई देंगे।',
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage
    extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  bool dataSaver = false;
  bool autoplay = true;
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          const ListTile(
            leading:
                Icon(Icons.account_circle_outlined),
            title: Text('Account'),
            subtitle: Text(
              'Profile और account settings',
            ),
          ),
          SwitchListTile(
            secondary: const Icon(
              Icons.data_saver_on_outlined,
            ),
            title: const Text(
              'Data Saver',
            ),
            subtitle: const Text(
              'वीडियो डेटा की खपत कम करें',
            ),
            value: dataSaver,
            onChanged: (bool value) {
              setState(() {
                dataSaver = value;
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(
              Icons.play_circle_outline,
            ),
            title: const Text(
              'Video Autoplay',
            ),
            subtitle: const Text(
              'वीडियो अपने आप चलाएं',
            ),
            value: autoplay,
            onChanged: (bool value) {
              setState(() {
                autoplay = value;
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(
              Icons.notifications_outlined,
            ),
            title: const Text(
              'Notifications',
            ),
            subtitle: const Text(
              'App notifications',
            ),
            value: notifications,
            onChanged: (bool value) {
              setState(() {
                notifications = value;
              });
            },
          ),
          const ListTile(
            leading:
                Icon(Icons.lock_outline),
            title: Text('Privacy'),
            subtitle: Text(
              'Privacy और security',
            ),
          ),
          const ListTile(
            leading:
                Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text(
              'Hindi / English',
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.info_outline),
            title:
                const Text('About Billi Billi'),
            subtitle:
                const Text('Version 1.0.0'),
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
    );
  }
}
