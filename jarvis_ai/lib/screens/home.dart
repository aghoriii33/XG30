import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> _filters = ["Content", "Writing", "Research & Analytic"];
  String _selectedFilter = "Content";

  final List<Map<String, dynamic>> _recentChats = [
    {
      "title": "Greeting assistant preview",
      "time": "Just now",
    },
    {
      "title": "UI inspiration for purple theme",
      "time": "2 hours ago",
    },
    {
      "title": "Visual Studio high based research",
      "time": "Yesterday",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider);
    final userName = user?.name ?? 'Alex Smith';
    final userEmail = user?.email ?? 'alex.smith@jarvis.ai';

    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Top Header: Avatar + Greetings + 3-Dot Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  // User Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5), width: 1.5),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=facearea&facepad=2&w=256&h=256&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Welcome Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good morning",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          userName,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 3-Dot Menu Trigger for Sign Out
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    color: const Color(0xFF131121),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
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
                          userEmail,
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
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Large Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "You're on a wave\nof productivity!",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Horizontal Filter Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bento Grid Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // Large Card: Image Generation
                    GestureDetector(
                      onTap: () => context.push('/explore'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131121).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.image_rounded,
                                color: Color(0xFF8B5CF6),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Image Generation",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Creates high-quality custom images based on any user prompt.",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Row with Left & Right Cards
                    Row(
                      children: [
                        // Left Card: Voice to Text (Vibrant Purple/Violet Gradient)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/voice'),
                            child: Container(
                              height: 140,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF6D28D9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.mic_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const Spacer(),
                                  Text(
                                    "Voice to text",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Right Card: Code snippets (Dark Grey Glass)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/chat'),
                            child: Container(
                              height: 140,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131121).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.code_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const Spacer(),
                                  Text(
                                    "Code snippets",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Recent Chat Section
                    Text(
                      "Recent chat",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // List of recent chats
                    ..._recentChats.map((chat) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8B5CF6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                chat['title']!,
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              chat['time']!,
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(activeRoute: '/home'),
    );
  }
}
