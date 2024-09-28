import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  List<Map<String, String>> quoteHistory = [];
  int currentIndex = -1;
  String quote = 'Swipe to get a random quote!';
  String person = '';
  String imageUrl = '';
  bool isLoading = false;
  double opacity = 1.0;
  double scale = 1.0;

  @override
  void initState() {
    super.initState();
  }

  String getRandomPlaceholder() {
    var random = Random();
    List<String> placeholders = [
      'assets/images/space_bg_quotify.png',
    ];
    return placeholders[random.nextInt(placeholders.length)];
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      opacity = 0.0;});

    var random = Random();
    int index_num = random.nextInt(485);
    String url = ('https://appcollection.in/quotify/fetch-quote.php?id=$index_num');

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String newQuote = data['quote'];
        String newPerson = data['speaker'];
        String? image_base = data['image'];

        setState(() {
          quote = newQuote;
          person = newPerson;
          imageUrl = (image_base == null || image_base.isEmpty)
              ? getRandomPlaceholder()
              : image_base;
          if (currentIndex == quoteHistory.length - 1) {
            quoteHistory.add({
              'quote': newQuote,
              'person': newPerson,
              'imageUrl': imageUrl,
            });
            currentIndex++;
          }

          isLoading = false;
        });


        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            opacity = 1.0;
          });
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        setState(() {
          isLoading = false;
          opacity = 1.0;
        });
      }
    } catch (e) {
      print('An error occurred: $e');
      setState(() {
        isLoading = false;
        opacity = 1.0;
      });
    }
  }
  void showPreviousQuote() {
    if (currentIndex > 0) {
      setState(() {
        isLoading = true;
        opacity = 0.0;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          currentIndex--;
          quote = quoteHistory[currentIndex]['quote']!;
          person = quoteHistory[currentIndex]['person']!;
          imageUrl = quoteHistory[currentIndex]['imageUrl']!;
          isLoading = false;
          opacity = 1.0;
        });
      });
    }
  }

  void showNextQuote() {
    if (currentIndex < quoteHistory.length - 1) {
      setState(() {
        isLoading = true;
        opacity = 0.0;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          currentIndex++;
          quote = quoteHistory[currentIndex]['quote']!;
          person = quoteHistory[currentIndex]['person']!;
          imageUrl = quoteHistory[currentIndex]['imageUrl']!;
          isLoading = false;
          opacity = 1.0;
        });
      });
    } else {
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: Stack(
        children: [
          Positioned(
            child: Align(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 500),
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        image: (imageUrl.isNotEmpty)
                            ? DecorationImage(
                          image: imageUrl.startsWith('assets')
                              ? AssetImage(imageUrl) as ImageProvider
                              : NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                            : const DecorationImage(
                          image: AssetImage('assets/images/placeholder.png'),
                          fit: BoxFit.cover,
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/images/applogo.png'),
                          ),
                        ),
                        child: const SizedBox(
                          width: 54,
                          height: 54,
                        ),
                      ),
                      Text(
                        'Quotify',
                        style: GoogleFonts.getFont(
                          'Inria Serif',
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Stack(
                      children: [
                        AnimatedOpacity(
                          opacity: opacity,
                          duration: const Duration(milliseconds: 500),
                          child: GestureDetector(
                            onPanEnd: (details) {
                              if (details.velocity.pixelsPerSecond.dx < 0) {
                                setState(() {
                                  scale = 0.95;
                                });
                                showNextQuote();
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  setState(() {
                                    scale = 1.0;
                                  });
                                });
                              } else if (details.velocity.pixelsPerSecond.dx > 0) {
                                setState(() {
                                  scale = 0.95;
                                });
                                showPreviousQuote();
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  setState(() {
                                    scale = 1.0;
                                  });
                                });
                              }
                            },
                            child: AnimatedScale(
                              scale: scale,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '"$quote"',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont(
                                        'Inria Serif',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 30,
                                        color: const Color(0xFFFFFFFF),
                                        shadows: [
                                          Shadow(
                                            blurRadius: 4.0,
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '- $person',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont(
                                        'Inria Serif',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                        color: const Color(0xFFBBBBBB),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isLoading)
                          Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
