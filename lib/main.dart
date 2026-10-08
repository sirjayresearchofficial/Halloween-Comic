Dart


import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const HalloweenComicApp());

class HalloweenComicApp extends StatelessWidget {
  const HalloweenComicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spooky Comic Creator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: Colors.deepOrange,
          secondary: Colors.orangeAccent,
        ),
      ),
      home: const ComicCreatorScreen(),
    );
  }
}

class ComicCreatorScreen extends StatefulWidget {
  const ComicCreatorScreen({super.key});

  @override
  State<ComicCreatorScreen> createState() => _ComicCreatorScreenState();
}

class _ComicCreatorScreenState extends State<ComicCreatorScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // App Selections
  String selectedCharacter = 'Vampire Lord';
  String selectedTwist = 'Funny';
  bool isPaid = false; 

  // 25 Halloween Character Choices
  final List<String> characters = [
    'Vampire Lord', 'Zombie Chef', 'Witchy Coder', 'Pumpkin King', 
    'Ghostly Phantom', 'Mummy Medic', 'Franken-Bot', 'Werewolf Walker',
    'Swamp Creature', 'Skeleton Jester', 'Grim Reaper', 'Demon DJ',
    'Voodoo Shaman', 'Alien Invader', 'Banshee Singer', 'Cyclops Bouncer',
    'Dark Angel', 'Headless Horseman', 'Invisible Man', 'Mad Scientist',
    'Pharaoh Curse', 'Plague Doctor', 'Scarecrow Stalker', 'Sirens Echo', 'Zombie Unicorn'
  ];

  // Open your specific PayPal Hosted Payment Link
  Future<void> _openPayPalPaymentLink(BuildContext context) async {
    final Uri paypalUrl = Uri.parse('https://www.paypal.com/ncp/payment/ZAQWDWDKJQY82');

    try {
      if (await canLaunchUrl(paypalUrl)) {
        await launchUrl(paypalUrl, mode: LaunchMode.externalApplication);
        
        // Prompt user to confirm payment after returning from browser
        _showPaymentConfirmationDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PayPal checkout link.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Payment Confirmation Dialog
  void _showPaymentConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('🎃 Complete Your Unlock'),
          content: const Text(
            'Did you finish your \$2.50 payment on PayPal? Click below to instantly unlock your HD comic, custom twists, and share options!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not Yet', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                setState(() {
                  isPaid = true; // Unlocks panels 3 & 4 and enables sharing!
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Confirmed! HD Comic Unlocked 🎃')),
                );
              },
              child: const Text('I Have Paid - Unlock Now'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎃 Halloween Comic Creator'),
        backgroundColor: Colors.deepOrange[900],
      ),
      body: Column(
        children: [
          // 1. Character & Twist Customization Dropdowns
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[900],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Character: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  DropdownButton<String>(
                    value: selectedCharacter,
                    dropdownColor: Colors.grey[850],
                    items: characters.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => selectedCharacter = val!),
                  ),
                  const SizedBox(width: 20),
                  const Text('Twist: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  DropdownButton<String>(
                    value: selectedTwist,
                    dropdownColor: Colors.grey[850],
                    items: ['Scary', 'Funny', 'Cute']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedTwist = val!),
                  ),
                ],
              ),
            ),
          ),

          // 2. Swipeable 4-Panel Horizontal Comic Viewer (Panels 1-4)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 4,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                // Panels 3 and 4 are locked/blurred with watermarks if unpaid
                bool needsBlur = index >= 2 && !isPaid; 
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.deepOrange, width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Panel ${index + 1} of 4',
                              style: const TextStyle(color: Colors.deepOrange, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              index < 2 
                                ? 'Setup: $selectedCharacter is preparing for a wild Halloween night!'
                                : 'Climax Twist ($selectedTwist): The shocking unmasked reveal happens here!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            const Icon(Icons.image, size: 80, color: Colors.grey),
                          ],
                        ),
                      ),
                      if (needsBlur)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock, size: 60, color: Colors.deepOrange),
                                const SizedBox(height: 10),
                                const Text(
                                  '🔒 Locked Climax & Twist!\nUnlock full HD comic & download for \$2.50',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  onPressed: () => _openPayPalPaymentLink(context),
                                  icon: const Icon(Icons.payment),
                                  label: const Text('Pay \$2.50 via PayPal'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Page Indicators (Dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => Container(
              margin: const EdgeInsets.all(4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.deepOrange : Colors.grey,
              ),
            )),
          ),
          const SizedBox(height: 10),

          // 3. Share Button & Download Option
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaid ? Colors.green : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: isPaid ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comic saved & ready to share on social media with app link!')),
                );
              } : null,
              icon: const Icon(Icons.share),
              label: Text(isPaid ? 'Download & Share Comic with App Link' : 'Unlock Comic First to Share'),
            ),
          ),
        ],
      ),
    );
  }
}
