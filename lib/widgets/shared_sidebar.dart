import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

class SharedSidebar extends StatefulWidget {
  final String currentRoute;
  final bool isOpen;
  final VoidCallback onToggle;

  const SharedSidebar({
    super.key,
    required this.currentRoute,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  State<SharedSidebar> createState() => _SharedSidebarState();
}

class _SharedSidebarState extends State<SharedSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _sidebarAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isOpen) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(SharedSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required String route,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.white.withOpacity(0.3), width: 1) : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Blur overlay
            if (widget.isOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onToggle,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5 * _fadeAnimation.value,
                      sigmaY: 5 * _fadeAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                    ),
                  ),
                ),
              ),
            
            // Sidebar
            Positioned(
              left: _sidebarAnimation.value * 250,
              top: 0,
              bottom: 0,
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        IconButton(
                          onPressed: widget.onToggle,
                          icon: Icon(
                            widget.isOpen ? Icons.chevron_left : Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ).animate()
                          .fadeIn()
                          .scale(),
                        const SizedBox(height: 20),
                        _buildSidebarItem(
                          icon: Icons.home_outlined,
                          title: 'Home',
                          route: '/dashboard',
                          isSelected: widget.currentRoute == '/dashboard',
                          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                        ),
                        _buildSidebarItem(
                          icon: Icons.location_on_outlined,
                          title: 'Nearby Spaces',
                          route: '/dashboard',
                          isSelected: widget.currentRoute == '/dashboard',
                          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                        ),
                        _buildSidebarItem(
                          icon: Icons.add_circle_outline,
                          title: 'Add New Space',
                          route: '/dashboard',
                          isSelected: widget.currentRoute == '/dashboard',
                          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                        ),
                        _buildSidebarItem(
                          icon: Icons.favorite_outline,
                          title: 'Favorites',
                          route: '/dashboard',
                          isSelected: widget.currentRoute == '/dashboard',
                          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                        ),
                        _buildSidebarItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          route: '/settings',
                          isSelected: widget.currentRoute == '/settings',
                          onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
                        ),
                        _buildSidebarItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          route: '/dashboard',
                          isSelected: widget.currentRoute == '/dashboard',
                          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                        ),
                        const Spacer(),
                        _buildSidebarItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          route: '/login',
                          onTap: () {
                            AuthService().signOut();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 