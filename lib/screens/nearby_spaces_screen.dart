import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_sidebar.dart';

class NearbySpacesScreen extends StatefulWidget {
  const NearbySpacesScreen({super.key});

  @override
  State<NearbySpacesScreen> createState() => _NearbySpacesScreenState();
}

class _NearbySpacesScreenState extends State<NearbySpacesScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  bool _isSidebarOpen = false;

  // Sample recommended places (replace with your actual data source)
  final List<Map<String, dynamic>> _recommendedPlaces = [
    {
      'name': 'Sample Place 1',
      'lat': 0.0, // Replace with actual coordinates
      'lng': 0.0,
      'description': 'A great place to work',
    },
    // Add more places here
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _hasLocationPermission = status.isGranted;
    });
    if (status.isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _updateMapMarkers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error getting location. Please try again.'),
        ),
      );
    }
  }

  void _updateMapMarkers() {
    if (_currentPosition == null) return;

    Set<Marker> markers = {};

    // Add current location marker
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Current Location'),
      ),
    );

    // Add recommended places markers
    for (var place in _recommendedPlaces) {
      markers.add(
        Marker(
          markerId: MarkerId(place['name']),
          position: LatLng(place['lat'], place['lng']),
          infoWindow: InfoWindow(
            title: place['name'],
            snippet: place['description'],
            onTap: () => _launchDirections(place['lat'], place['lng']),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });

    // Move camera to current location
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 14,
        ),
      ),
    );
  }

  Future<void> _launchDirections(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch Google Maps'),
        ),
      );
    }
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
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
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : !_hasLocationPermission
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Location permission is required',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _checkLocationPermission,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.blue.shade900,
                                      ),
                                      child: const Text('Grant Permission'),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: _currentPosition != null
                                            ? LatLng(
                                                _currentPosition!.latitude,
                                                _currentPosition!.longitude,
                                              )
                                            : const LatLng(0, 0),
                                        zoom: 14,
                                      ),
                                      onMapCreated: (controller) {
                                        _mapController = controller;
                                        _updateMapMarkers();
                                      },
                                      markers: _markers,
                                      myLocationEnabled: true,
                                      myLocationButtonEnabled: true,
                                      zoomControlsEnabled: true,
                                      mapToolbarEnabled: true,
                                      mapType: MapType.normal,
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      right: 16,
                                      child: FloatingActionButton(
                                        onPressed: _getCurrentLocation,
                                        backgroundColor: Colors.blue.shade900,
                                        child: const Icon(Icons.my_location),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ],
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 