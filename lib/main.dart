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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    CreatePage(),
    ReelsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: Colors.white12,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
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
      child: CustomScrollView(
        slivers: [
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
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
              ),
            ],
          ),
          const SliverToBoxAdapter(
            child: StoriesSection(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const PostCard();
              },
              childCount: 5,
            ),
          ),
        ],
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
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Text(
                    index == 0 ? '+' : '${index + 1}',
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

class PostCard extends StatefulWidget {
  const PostCard({super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool liked = false;
  bool saved = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: const Text(
            'Billi Billi User',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('India'),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: Colors.white10,
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 70,
                color: Colors.white54,
              ),
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  liked = !liked;
                });
              },
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? Colors.red : Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.send_outlined),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  saved = !saved;
                });
              },
              icon: Icon(
                saved ? Icons.bookmark : Icons.bookmark_border,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'Billi Billi community post',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search people, videos, hashtags...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Search Billi Billi',
                style: TextStyle(fontSize: 22),
              ),
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
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final ImagePicker picker = ImagePicker();

  VideoPlayerController? controller;
  XFile? selectedVideo;
  bool loading = false;

  Future<void> pickVideo(ImageSource source) async {
    try {
      setState(() {
        loading = true;
      });

      final XFile? video = await picker.pickVideo(
        source: source,
      );

      if (video == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      await controller?.dispose();

      final newController = VideoPlayerController.file(
        File(video.path),
      );

      await newController.initialize();

      setState(() {
        selectedVideo = video;
        controller = newController;
        loading = false;
      });

      await newController.play();
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video open नहीं हुआ: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoController = controller;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              if (loading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),

              if (videoController != null &&
                  videoController.value.isInitialized)
                Column(
                  children: [
                    AspectRatio(
                      aspectRatio: videoController.value.aspectRatio,
                      child: VideoPlayer(videoController),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      iconSize: 50,
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
                    const SizedBox(height: 15),
                  ],
                ),

              ElevatedButton.icon(
                onPressed: () {
                  pickVideo(ImageSource.gallery);
                },
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: const Text('Choose from Gallery'),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: () {
                  pickVideo(ImageSource.camera);
                },
                icon: const Icon(
                  Icons.camera_alt_outlined,
                ),
                label: const Text('Open Camera'),
              ),

              if (selectedVideo != null)
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    'Video selected successfully',
                    style: TextStyle(
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.black,
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            ),
            Positioned(
              left: 15,
              bottom: 30,
              child: Text(
                '@billi_billi_user\nReel ${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Positioned(
              right: 15,
              bottom: 30,
              child: Column(
                children: [
                  Icon(Icons.favorite_border, size: 32),
                  SizedBox(height: 20),
                  Icon(Icons.comment_outlined, size: 32),
                  SizedBox(height: 20),
                  Icon(Icons.send_outlined, size: 32),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 25),
          const CircleAvatar(
            radius: 48,
            child: Icon(Icons.person, size: 55),
          ),
          const SizedBox(height: 12),
          const Text(
            'Billi Billi User',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('@billi_billi_user'),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ProfileStat(number: '0', label: 'Posts'),
              ProfileStat(number: '0', label: 'Followers'),
              ProfileStat(number: '0', label: 'Following'),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String number;
  final String label;

  const ProfileStat({
    super.key,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }
}
