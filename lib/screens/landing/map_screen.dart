import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:safe_track/screens/landing/home/details/detail_screen.dart';
import '../../core/services/device_service.dart';
import '../../screens/landing/home/my_profile_drawer.dart'; // Your existing drawer

import '../../core/models/user_model.dart';
import '../../core/services/user_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Key to access Scaffold for opening drawera
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LocationData? _currentLocation;
  final MapController _mapController = MapController();
  double _currentZoom = 13;

  UserData? _currentUser;

  List<String> _allImeis = [];

  @override
  void initState() {
    super.initState();
    _fetchLocationAndMove();

    _loadUserData();

    _loadImeis();
  }

  Future<void> _loadUserData() async {
    final user = await UserPreferences().getUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadImeis() async {
    print("Starting to load IMEIs..."); // DEBUG 1
    try {
      final imeis = await DeviceService().getDeviceImeis();
      print("Loaded IMEIs: $imeis"); // DEBUG 2
      if (mounted) {
        setState(() {
          _allImeis = imeis;
        });
      }
    } catch (e) {
      print("Failed to load IMEIs: $e"); // DEBUG 3
    }
  }

  // Combines fetching location and moving the map
  Future<void> _fetchLocationAndMove() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check and request service
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (mounted) _showErrorSnackBar('Location services are disabled.');
        return;
      }
    }

    // Check and request permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) _showErrorSnackBar('Location permission denied.');
        return;
      }
    }

    try {
      LocationData locationData = await location.getLocation();
      if (mounted) {
        setState(() {
          _currentLocation = locationData;
        });
        _goToCurrentLocation(animate: false);
      }
    } catch (e) {
      print("Error fetching location: $e");
      if (mounted) {
        _showErrorSnackBar('Could not fetch location. Please try again.');
      }
    }
  }

  // Helper to show snackbar messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToCurrentLocation({bool animate = true}) {
    if (_currentLocation != null) {
      // Use moveAndRotate for smoother transitions if needed later
      _mapController.move(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        _currentZoom,
      );
    } else {
      _showErrorSnackBar('Current location not available yet.');
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const MyProfileDrawer(),
      body: Stack(
        children: [
          // --- MAP BACKGROUND ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation != null
                  ? LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    )
                  : const LatLng(32.9090, 74.8016), // Dudura, Jammu
              initialZoom: _currentZoom,
              minZoom: 3,
              maxZoom: 18,
              onPositionChanged: (position, hasGesture) {
                if (position.zoom != _currentZoom) {
                  if (mounted) {
                    setState(() {
                      _currentZoom = position.zoom;
                    });
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.png?key=uOv6PI7AYa13sqD3rQbo', // Your corrected MapTiler URL
                userAgentPackageName: 'com.safe_track.app',
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),

              // --- MOVED MapCompass INSIDE FlutterMap's children ---
              MapCompass(
                icon: Icon(
                  Icons.explore_outlined,
                  size: 36,
                  // Use theme color for compass icon
                  color: Colors.black87,
                ),
                hideIfRotatedNorth: true,
                alignment: Alignment.topRight, // Position within the map
                padding: const EdgeInsets.only(
                  top: 110,
                  right: 10,
                ), // Adjust padding as needed relative to map edges
              ),
              // --------------------------------------------------------
            ],
          ),

          // --- TOP SEARCH BAR AREA ---
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(Icons.search, color: Colors.grey),
                    ),
                    Expanded(
                      child: Autocomplete<String>(
                        // A. Define the options (IMEIs)
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          print(
                            "Search text: '${textEditingValue.text}'",
                          ); // DEBUG 4
                          print(
                            "Current list size: ${_allImeis.length}",
                          ); // DEBUG 5
                          if (textEditingValue.text == '') {
                            // If empty, return top 10 from the full list
                            return _allImeis.take(10);
                          }
                          // Filter logic
                          return _allImeis
                              .where((String imei) {
                                return imei.contains(textEditingValue.text);
                              })
                              .take(10); // Limit to top 10 recommendations
                        },

                        // B. What happens when user selects one
                        onSelected: (String selection) {
                          // 1. Close keyboard
                          FocusScope.of(context).unfocus();

                          // 2. Navigate
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DeviceDetailsScreen(imei: selection),
                            ),
                          );
                        },

                        // C. The Input Field (Keep your existing design)
                        fieldViewBuilder:
                            (
                              context,
                              textController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              return TextField(
                                controller: textController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  hintText: "Search Device",
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              );
                            },

                        // D. The List View (The Dropdown Styling)
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                20,
                              ), // Match your rounded style
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.width -
                                    80, // Adjust width
                                constraints: BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final String option = options.elementAt(
                                          index,
                                        );
                                        return ListTile(
                                          title: Text(option),
                                          onTap: () {
                                            onSelected(option);
                                          },
                                        );
                                      },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.person_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        print("Profile icon tapped");
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- ZOOM CONTROLS (Removed Compass from here) ---
          Positioned(
            // Adjust top position now that compass is removed
            top: MediaQuery.of(context).padding.top + 130, // Example adjustment
            right: 10,
            child: Container(
              // Keep zoom buttons together
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black26,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.add, color: colorScheme.onSurface),
                    onPressed: _zoomIn,
                    iconSize: 28,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 5,
                    endIndent: 5,
                    color: colorScheme.outlineVariant,
                  ),
                  IconButton(
                    icon: Icon(Icons.remove, color: colorScheme.onSurface),
                    onPressed: _zoomOut,
                    iconSize: 28,
                  ),
                ],
              ),
            ),
          ),

          // --- CURRENT LOCATION BUTTON ---
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15 + 20,
            right: 16,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // --- BOTTOM DRAGGABLE SHEET ---
          DraggableScrollableSheet(
            initialChildSize: 0.15,
            minChildSize: 0.15,
            maxChildSize: 0.8, // Increased maxChildSize to show more content
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface, // Theme-aware background
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Adjusted shadow
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController, // Important for scrolling
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  children: [
                    // --- Handle to indicate draggable ---
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- Tracking User Header ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tracking ${_currentUser?.firstName ?? 'User'}",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 24, // Larger text
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "100%",
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.battery_full,
                                color: Colors.green,
                                size: 24,
                              ), // Larger icon
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- Last Seen ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Last Login: ${_currentUser?.lastLoginAt ?? 'Unknown'}", // Updated date from image
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 18,
                        ), // Larger text
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- User ID ---
                    // buildInfoRow(
                    //   context,
                    //   icon: Icons.person_outline, // Added icon
                    //   label: "User Id:",
                    //   value: _currentUser?.uniqueId ?? 'Loading...',
                    //   theme: theme,
                    // ),

                    // --- GEO Number ---
                    buildInfoRow(
                      context,
                      icon: Icons.location_history, // Added icon
                      label: "GEO Number:",
                      value: "3",
                      valueSuffix: " Safe Zone",
                      valueSuffixColor: Colors.green, // Specific color
                      theme: theme,
                    ),

                    // --- Speed / Temperature ---
                    buildInfoRow(
                      context,
                      icon: Icons.speed, // Added icon
                      label: "28 Km/hr",
                      value: "32°C",
                      valueColor: colorScheme.onSurface, // Default value color
                      theme: theme,
                    ),

                    // --- SIM 1 / Signal Strength ---
                    buildInfoRow(
                      context,
                      icon: Icons.signal_cellular_alt, // Added icon
                      label: "SIM 1",
                      value: "Signal Strength:",
                      valueSuffix: "74%",
                      valueSuffixColor: Colors.green, // Specific color
                      theme: theme,
                    ),

                    // --- SOS ---
                    buildInfoRow(
                      context,
                      icon: Icons.sos, // Added icon
                      label: "SOS",
                      value: "Enable",
                      theme: theme,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60.0),
                      child: Divider(height: 1, thickness: 2),
                    ),
                    const SizedBox(height: 20),

                    // --- Guardian Contacts Header ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Guardian Contacts:",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18, // Larger text
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- Guardian Contact 1 ---
                    buildContactCard(
                      context,
                      name: "Rajesh Kumar",
                      phoneNumber: _currentUser?.mobile ?? 'N/A',
                      email: _currentUser?.email ?? 'N/A',
                      theme: theme,
                    ),
                    const SizedBox(height: 8),

                    // --- Guardian Contact 2 ---
                    buildContactCard(
                      context,
                      name: "Anita Sharma",
                      phoneNumber: "8899XXXXXX",
                      email: "anita.sharma@gmail.com",
                      theme: theme,
                      // You can add a name here if available
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60.0),
                      child: Divider(height: 1, thickness: 2),
                    ),
                    const SizedBox(height: 20),

                    // --- Device Details Header ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Device Details",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18, // Larger text
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- Device Details Info ---
                    buildInfoRow(
                      context,
                      icon: Icons.devices, // Added icon
                      label: "IMEI (Device):",
                      value: "168418618486",
                      theme: theme,
                    ),
                    buildInfoRow(
                      context,
                      icon: Icons.memory, // Added icon
                      label: "Firmware:",
                      value: "1dfv3515",
                      theme: theme,
                    ),
                    buildInfoRow(
                      context,
                      icon: Icons.sim_card, // Added icon
                      label: "SIM No:",
                      value:
                          "", // Assuming empty as per image, add if available
                      theme: theme,
                    ),
                    buildInfoRow(
                      context,
                      icon: Icons.phone_android, // Added icon
                      label: "MSDN No:",
                      value:
                          "", // Assuming empty as per image, add if available
                      theme: theme,
                    ),
                    buildInfoRow(
                      context,
                      icon: Icons.qr_code, // Added icon
                      label: "Profile Code:",
                      value: "14683515",
                      theme: theme,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60.0),
                      child: Divider(height: 1, thickness: 2),
                    ),
                    const SizedBox(height: 20),

                    // --- Location History ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Location History",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18, // Larger text
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ), // Changed color to primary
                      ),
                    ),
                    const SizedBox(height: 100), // Space to allow scrolling
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for Info Rows ---
  Widget buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    IconData? icon,
    String? valueSuffix,
    Color? valueSuffixColor,
    required ThemeData theme,
    Color? valueColor,
  }) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 20,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          if (icon != null) const SizedBox(width: 10),
          SizedBox(
            width: 120, // Fixed width for labels for alignment
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18, // Larger text
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18, // Larger text
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                ),
                if (valueSuffix != null)
                  Text(
                    valueSuffix,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18, // Larger text
                      fontWeight: FontWeight.w600, // Make suffix bold
                      color: valueSuffixColor ?? colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for Contact Cards ---
  Widget buildContactCard(
    BuildContext context, {
    required String name,
    required String phoneNumber,
    required String email,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18, // Larger text
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  phoneNumber,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16, // Larger text
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16, // Larger text
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Call Button
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement call functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calling!'), // Your message
                        duration: Duration(
                          seconds: 2,
                        ), // How long it stays visible
                        behavior: SnackBarBehavior
                            .floating, // Makes it float above bottom nav bar (optional)
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // MAil Button
              Container(
                decoration: BoxDecoration(
                  color: colorScheme
                      .secondary, // Use a secondary color for message
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.mail_rounded, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement message functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mail sent!'), // Your message
                        duration: Duration(
                          seconds: 2,
                        ), // How long it stays visible
                        behavior: SnackBarBehavior
                            .floating, // Makes it float above bottom nav bar (optional)
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
