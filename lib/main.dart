import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
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
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class VideoPost {
  final String path;
  bool liked;
  bool saved;
  int likes;

  VideoPost({
    required this.path,
    this.liked = false,
    this.saved = false,
    this.likes = 0,
  });
}

class AppData {
  AppData._();

  static final AppData instance = AppData._();

  final ValueNotifier<List<VideoPost>> posts =
      ValueNotifier<List<VideoPost>>(<VideoPost>[]);

  void addPost(String path) {
    final List<VideoPost> updatedPosts = <VideoPost>[
      VideoPost(path: path),
      ...posts.value,
    ];

    posts.value = updatedPosts;
  }

  void toggleLike(VideoPost post) {
    post.liked = !post.liked;

    if (post.liked) {
      post.likes++;
    } else if (post.likes > 0) {
      post.likes--;
    }

    posts.notifyListeners();
  }

  void toggleSave(VideoPost post) {
    post.saved = !post.saved;
    posts.notifyListeners();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = <Widget>[
      const HomePage(),
      const SearchPage(),
      CreatePage(
        onPostComplete: () {
          if (!mounted) return;

          setState(() {
            currentIndex = 0;
          });
        },
      ),
      const ReelsPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
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
      child: ValueListenableBuilder<List<VideoPost>>(
        valueListenable: AppData.instance.posts,
        builder: (
          BuildContext context,
          List<VideoPost> posts,
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
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.chat_bubble_outline,
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
                            'अभी कोई वीडियो पोस्ट नहीं है',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Create में जाकर अपना पहला वीडियो पोस्ट करें',
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
                  delegate: SliverChildBuilderDelegate(
                    (
                      BuildContext context,
                      int index,
                    ) {
                      return VideoPostCard(
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
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 8,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Text(
                    index == 0 ? '+' : '${index + 1}',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  index == 0
                      ? 'Your story'
                      : 'User ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VideoPostCard extends StatefulWidget {
  final VideoPost post;

  const VideoPostCard({
    super.key,
    required this.post,
  });

  @override
  State<VideoPostCard> createState() =>
      _VideoPostCardState();
}

class _VideoPostCardState extends State<VideoPostCard> {
  VideoPlayerController? controller;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
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
    final VideoPlayerController? videoController =
        controller;

    Widget videoWidget;

    if (loading) {
      videoWidget = const SizedBox(
        height: 350,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (error) {
      videoWidget = const SizedBox(
        height: 350,
        child: Center(
          child: Text('वीडियो चल नहीं पाया'),
        ),
      );
    } else if (videoController != null &&
        videoController.value.isInitialized) {
      videoWidget = AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (videoController.value.isPlaying) {
                videoController.pause();
              } else {
                videoController.play();
              }
            });
          },
          child: VideoPlayer(videoController),
        ),
      );
    } else {
      videoWidget = const SizedBox(
        height: 350,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(
            'Billi Billi User',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('India'),
        ),
        Container(
          width: double.infinity,
          color: Colors.black,
          child: videoWidget,
        ),
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                AppData.instance.toggleLike(
                  widget.post,
                );
              },
              icon: Icon(
                widget.post.liked
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: widget.post.liked
                    ? Colors.red
                    : Colors.white,
              ),
            ),
            if (widget.post.likes > 0)
              Text('${widget.post.likes}'),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.chat_bubble_outline,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.send_outlined,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                AppData.instance.toggleSave(
                  widget.post,
                );
              },
              icon: Icon(
                widget.post.saved
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'Billi Billi community post',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                hintText:
                    'Search people, videos, hashtags...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Search Billi Billi',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePage extends StatefulWidget {
  final VoidCallback onPostComplete;

  const CreatePage({
    super.key,
    required this.onPostComplete,
  });

  @override
  State<CreatePage> createState() =>
      _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final ImagePicker picker = ImagePicker();

  VideoPlayerController? controller;
  XFile? selectedVideo;

  bool loading = false;
  bool posting = false;

  Future<void> pickVideo(ImageSource source) async {
    if (loading || posting) return;

    setState(() {
      loading = true;
    });

    try {
      final XFile? video = await picker.pickVideo(
        source: source,
      );

      if (video == null) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        return;
      }

      final VideoPlayerController newController =
          VideoPlayerController.file(
        File(video.path),
      );

      await newController.initialize();

      await controller?.dispose();

      if (!mounted) {
        await newController.dispose();
        return;
      }

      setState(() {
        selectedVideo = video;
        controller = newController;
        loading = false;
      });

      await newController.play();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Video open नहीं हुआ: $e',
          ),
        ),
      );
    }
  }

  void postVideo() {
    final XFile? video = selectedVideo;

    if (video == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'पहले वीडियो चुनें या रिकॉर्ड करें।',
          ),
        ),
      );
      return;
    }

    if (posting) return;

    setState(() {
      posting = true;
    });

    controller?.pause();

    AppData.instance.addPost(video.path);

    controller?.dispose();

    setState(() {
      controller = null;
      selectedVideo = null;
      posting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'वीडियो सफलतापूर्वक पोस्ट हो गया ✅',
        ),
      ),
    );

    widget.onPostComplete();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? videoController =
        controller;

    return SafeArea(
      child: Center(
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
              const SizedBox(height: 10),
              const Text(
                'अपना वीडियो Billi Billi पर बनाएं',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 25),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              if (videoController != null &&
                  videoController.value.isInitialized)
                Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio:
                            videoController.value.aspectRatio,
                        child: VideoPlayer(
                          videoController,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      iconSize: 55,
                      onPressed: () {
                        setState(() {
                          if (videoController.value.isPlaying) {
                            videoController.pause();
                          } else {
                            videoController.play();
                          }
                        });
                      },
                      icon: Icon(
                        videoController.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: loading || posting
                      ? null
                      : () {
                          pickVideo(
                            ImageSource.gallery,
                          );
                        },
                  icon: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  label: const Text(
                    'Choose from Gallery',
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: loading || posting
                      ? null
                      : () {
                          pickVideo(
                            ImageSource.camera,
                          );
                        },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                  ),
                  label: const Text(
                    'Open Camera',
                  ),
                ),
              ),
              if (selectedVideo != null) ...<Widget>[
                const SizedBox(height: 20),
                const Text(
                  'Video selected successfully ✅',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    onPressed: posting
                        ?
null
    : postVideo,
icon: const Icon(Icons.cloud_upload_outlined),
label: const Text('Post Video'),
),
),
],
],
),
),
),
);
}
}
