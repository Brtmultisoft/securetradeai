import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Data/Api.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool isAPIcalled = false;
  var finaldata;
  bool checkdata = false;
  _getData() async {
    setState(() {
      isAPIcalled = true;
    });

    try {
      final res = await http.get(Uri.parse(videos));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print('📹 Video API Response: $data');

        if (data['status'] == "success" && data['data'] != null) {
          setState(() {
            finaldata = data['data'];
            isAPIcalled = false;
            checkdata = false;
          });
          return;
        }
      }

      setState(() {
        isAPIcalled = false;
        checkdata = true;
      });
    } catch (e) {
      print('❌ Error loading videos: $e');
      setState(() {
        isAPIcalled = false;
        checkdata = true;
      });
    }
  }

  // Extract YouTube video ID from various URL formats
  String? _extractYouTubeVideoId(String url) {
    if (url.isEmpty) return null;

    // If it's already just a video ID (11 characters)
    if (url.length == 11 && !url.contains('/') && !url.contains('=')) {
      return url;
    }

    // Extract from various YouTube URL formats
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0C0E12),
        appBar: AppBar(
          backgroundColor: const Color(0xFF161A1E),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Videos".tr,
            style: const TextStyle(
                fontFamily: fontFamily, fontSize: 20, color: Colors.white),
          ),
        ),
        body: isAPIcalled
            ? Center(
                child: CircularProgressIndicator(color: securetradeaicolor),
              )
            : checkdata
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/img/logo.png",
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No videos available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _getData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: securetradeaicolor,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildVideoList());
  }

  Widget _buildVideoList() {
    // Comprehensive null safety check
    if (finaldata == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.amber,
        ),
      );
    }

    if (finaldata.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/img/logo.png",
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'No videos found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getData,
              style: ElevatedButton.styleFrom(
                backgroundColor: securetradeaicolor,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: finaldata.length,
            itemBuilder: (context, index) {
              return _buildVideoItem(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(int index) {
    try {
      // Triple safety check
      if (finaldata == null ||
          index < 0 ||
          index >= finaldata.length ||
          finaldata[index] == null) {
        return const SizedBox.shrink();
      }

      final videoData = finaldata[index];

      // Safely extract title with type checking
      String videoTitle = 'Untitled Video';
      try {
        final titleData = videoData['title'];
        if (titleData != null) {
          videoTitle = titleData.toString();
        }
      } catch (e) {
        videoTitle = 'Video ${index + 1}';
      }

      // Safely extract video ID
      String videoId = '';
      try {
        final videoLinkData = videoData['video_link'];
        print('🔍 Raw video_link data: $videoLinkData');
        if (videoLinkData != null) {
          String rawVideoId = videoLinkData.toString();
          print('🔍 Raw video ID: $rawVideoId');

          // Extract YouTube video ID from URL
          String? extractedId = _extractYouTubeVideoId(rawVideoId);
          if (extractedId != null && extractedId.isNotEmpty) {
            videoId = extractedId;
          } else {
            videoId = 'dQw4w9WgXcQ'; // Fallback
          }
        }
      } catch (e) {
        videoId = 'dQw4w9WgXcQ'; // Fallback
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.all(10),
            child: Text(
              videoTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF2B3139),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF2A3A5A),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SimpleYouTubePlayer(
                videoId: videoId,
                videoTitle: videoTitle,
              ),
            ),
          ),
          const Divider(color: Color(0xFF2A3A5A)),
          const SizedBox(height: 10),
        ],
      );
    } catch (e, stackTrace) {
      // Comprehensive error handling for any type error
      print('❌ Error building video item $index: $e');
      print('📍 Stack trace: $stackTrace');

      return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2B3139),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 8),
            const Text(
              'Video Loading Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Error: ${e.toString()}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}

/// Simple YouTube Player Widget
class SimpleYouTubePlayer extends StatelessWidget {
  final String videoId;
  final String videoTitle;

  const SimpleYouTubePlayer({
    Key? key,
    required this.videoId,
    required this.videoTitle,
  }) : super(key: key);

  Future<void> _openYouTubeVideo(BuildContext context) async {
    final youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';
    final youtubeAppUrl = 'youtube://watch?v=$videoId';

    try {
      // Try to open in YouTube app first
      if (await canLaunchUrl(Uri.parse(youtubeAppUrl))) {
        await launchUrl(Uri.parse(youtubeAppUrl));
      } else {
        // Fallback to browser
        await launchUrl(Uri.parse(youtubeUrl));
      }
    } catch (e) {
      print('❌ Error opening video: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open video: $videoTitle'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openYouTubeVideo(context),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
