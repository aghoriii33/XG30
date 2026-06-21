import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final List<Map<String, dynamic>> _historyItems = [
    {
      'title': 'I need some UI inspiration for...',
      'color': const Color(0xFF2563EB),
    },
    {
      'title': 'Show me some color palettes...',
      'color': const Color(0xFFEC4899),
    },
    {
      'title': 'What are the best mobile apps...',
      'color': const Color(0xFF8B5CF6),
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider);
    final userName = user?.name ?? 'User';
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Top Bar: Menu + Name + Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      Text(
                        "Hi, ",
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        userName,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Sleek User Avatar Popup Menu
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    color: const Color(0xFF0C0E14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    onSelected: (value) {
                      if (value == 'logout') {
                        ref.read(authServiceProvider.notifier).signOut();
                        context.go('/login');
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text(
                          user?.email ?? 'Not signed in',
                          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Sign Out",
                              style: GoogleFonts.outfit(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1.5),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=120&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Title Greeting
              Text(
                "How may I help\nyou today?",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions Grid (Talk, Chat, Search)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grid Area
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Tall Button: Talk with Sundae
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.push('/voice'),
                              child: Container(
                                height: 180,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_outward_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.keyboard_voice_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Talk with\nSundae",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right Split Column (Chat with Bot + Search by Image)
                          Expanded(
                            child: Column(
                              children: [
                                // Chat with Bot
                                GestureDetector(
                                  onTap: () => context.push('/chat'),
                                  child: Container(
                                    height: 82,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEC4899),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Chat with Bot",
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_outward_rounded,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Search by Image
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    height: 82,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B5CF6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.image_search_rounded, color: Colors.white, size: 20),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Search by Image",
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_outward_rounded,
                                            color: Colors.white,
                                            size: 12,
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

                      const SizedBox(height: 32),

                      // History Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "History",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "See all",
                              style: GoogleFonts.outfit(
                                color: Colors.blue[400],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // History List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _historyItems.length,
                        itemBuilder: (context, index) {
                          final item = _historyItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Left Icon Circle
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: item['color'].withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.query_stats_rounded,
                                    color: item['color'],
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Text Title
                                Expanded(
                                  child: Text(
                                    item['title'],
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Options Dots
                                Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white.withOpacity(0.4),
                                  size: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF0C0E14),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_filled, color: Colors.blueAccent),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.grey),
              onPressed: () {},
            ),
            // Middle Glowing AI orb button
            GestureDetector(
              onTap: () => context.push('/voice'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
