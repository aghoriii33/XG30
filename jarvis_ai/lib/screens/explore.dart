import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_bottom_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<String> _filters = ["Favorites", "Research & Analytic", "Self-improvement"];
  String _selectedFilter = "Research & Analytic";

  final List<Map<String, dynamic>> _exploreItems = [
    {
      "title": "No Background",
      "description": "Remove image backgrounds cleanly to create subjects for flexible layouts.",
      "icon": Icons.photo_filter_rounded,
      "color": const Color(0xFFF43F5E),
    },
    {
      "title": "3D Object",
      "description": "Generate lifelike 3D models for design, presentation or product mockups.",
      "icon": Icons.threed_rotation_rounded,
      "color": const Color(0xFF3B82F6),
    },
    {
      "title": "Face Enhancement",
      "description": "Sharpen facial details while removing blemishes to beautify portraits.",
      "icon": Icons.face_retouching_natural_rounded,
      "color": const Color(0xFF10B981),
    },
    {
      "title": "Object Remover",
      "description": "Erase unwanted elements from photos without disturbing details.",
      "icon": Icons.blur_off_rounded,
      "color": const Color(0xFFF59E0B),
    },
    {
      "title": "Reflection Maker",
      "description": "Create mirror reflections for products to generate premium catalog displays.",
      "icon": Icons.flip_rounded,
      "color": const Color(0xFF8B5CF6),
    },
    {
      "title": "Noise Reduction",
      "description": "Reduce image noise and graininess to restore original clarity.",
      "icon": Icons.filter_hdr_rounded,
      "color": const Color(0xFFEC4899),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Search Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
                child: TextField(
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    hintText: 'Search tools, commands, recipes...',
                    hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 15),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Horizontal Filter Chips
            SizedBox(
              height: 40,
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
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
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

            // Category Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Image Generation",
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bento Feature List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                physics: const BouncingScrollPhysics(),
                itemCount: _exploreItems.length,
                itemBuilder: (context, index) {
                  final item = _exploreItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF110E1E).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tool icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              item['icon'],
                              color: item['color'],
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Tool title & description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['description'],
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Forward action button
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
                          onPressed: () {
                            // Pre-fill prompt in chat
                            context.push('/chat');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(activeRoute: '/explore'),
    );
  }
}
