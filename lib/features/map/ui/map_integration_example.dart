import 'package:flutter/material.dart';

/// Example of how to integrate the interactive map into your app
/// 
/// This file demonstrates various ways to navigate to the interactive map screen

class MapIntegrationExamples extends StatelessWidget {
  const MapIntegrationExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Integration Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Simple navigation button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/interactive-map');
            },
            icon: const Icon(Icons.map),
            label: const Text('Open Interactive Map (Route)'),
          ),
          
          const SizedBox(height: 16),
          
          // Example 2: Direct navigation with import
          ElevatedButton.icon(
            onPressed: () {
              // Direct import approach:
              // import 'package:pokedex_carbonica/features/map/ui/interactive_map_screen.dart';
              // 
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const InteractiveMapScreen(),
              //   ),
              // );
            },
            icon: const Icon(Icons.explore),
            label: const Text('Open Interactive Map (Direct)'),
          ),
          
          const SizedBox(height: 16),
          
          // Example 3: Open with custom transition
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    // Would need to import InteractiveMapScreen
                    // return const InteractiveMapScreen();
                    return Container(); // Placeholder
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.animation),
            label: const Text('Open Map (Custom Transition)'),
          ),
          
          const SizedBox(height: 32),
          
          // Documentation section
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Integration Guide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Method 1: Use Named Route',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Navigator.pushNamed(context, '/interactive-map');",
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Method 2: Direct Navigation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Import the screen and use Navigator.push with MaterialPageRoute',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Method 3: From Drawer/Bottom Nav',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add a ListTile or BottomNavigationBarItem that navigates to the map',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Feature highlights
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive Map Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _FeatureItem(
                    icon: Icons.zoom_in,
                    text: 'Pinch to zoom (0.1x - 4.0x)',
                  ),
                  _FeatureItem(
                    icon: Icons.pan_tool,
                    text: 'Pan by dragging',
                  ),
                  _FeatureItem(
                    icon: Icons.person,
                    text: '40+ trainer locations',
                  ),
                  _FeatureItem(
                    icon: Icons.inventory_2,
                    text: '100+ item locations',
                  ),
                  _FeatureItem(
                    icon: Icons.location_on,
                    text: '20+ portal connections',
                  ),
                  _FeatureItem(
                    icon: Icons.filter_list,
                    text: 'Toggle visibility filters',
                  ),
                  _FeatureItem(
                    icon: Icons.info,
                    text: 'Tap markers for details',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _FeatureItem({
    required this.icon,
    required this.text,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example: Adding map button to existing Pokemon list screen
/// 
/// In your PokemonListScreen or home screen, add a FloatingActionButton:
/// 
/// ```dart
/// floatingActionButton: FloatingActionButton.extended(
///   onPressed: () {
///     Navigator.pushNamed(context, '/interactive-map');
///   },
///   icon: const Icon(Icons.map),
///   label: const Text('View Map'),
/// ),
/// ```

/// Example: Adding map to drawer
/// 
/// In your Drawer widget:
/// 
/// ```dart
/// ListTile(
///   leading: const Icon(Icons.map),
///   title: const Text('Kanto Map'),
///   onTap: () {
///     Navigator.pop(context); // Close drawer
///     Navigator.pushNamed(context, '/interactive-map');
///   },
/// ),
/// ```

/// Example: Adding map to bottom navigation bar
/// 
/// Add to your bottom navigation items:
/// 
/// ```dart
/// BottomNavigationBarItem(
///   icon: Icon(Icons.map),
///   label: 'Map',
/// ),
/// ```
/// 
/// Then in onTap:
/// 
/// ```dart
/// case 2: // Map tab index
///   Navigator.pushNamed(context, '/interactive-map');
///   break;
/// ```
