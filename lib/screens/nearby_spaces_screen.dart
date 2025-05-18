import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/shared_sidebar.dart';

class NearbySpacesScreen extends StatefulWidget {
  const NearbySpacesScreen({super.key});

  @override
  State<NearbySpacesScreen> createState() => _NearbySpacesScreenState();
}

class _NearbySpacesScreenState extends State<NearbySpacesScreen> {
  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Nearby Spaces',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggleSidebar,
                          icon: Icon(
                            _isSidebarOpen ? Icons.menu_open : Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ).animate().fadeIn().slideY(begin: -0.2),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'This is the Nearby Spaces section',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Here you can find and explore coding spaces near your location.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn().scale(),
                  ],
                ),
              ),
            ),
            // Shared Sidebar
            SharedSidebar(
              currentRoute: '/nearby',
              isOpen: _isSidebarOpen,
              onToggle: _toggleSidebar,
            ),
          ],
        ),
      ),
    );
  }
} 