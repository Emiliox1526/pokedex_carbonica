import 'models.dart';

/// Sample portal data for the FRLG Kanto map
/// Coordinates are in pixels relative to the 7700x6400 map image
const List<MapPortalGroup> portalsData = [
  // Pallet Town to Viridian City
  MapPortalGroup(
    color: '#4CAF50',
    area: 'Route 1',
    portals: [
      Portal(
        portal1: PortalPoint(x: 3850, y: 6100),
        portal2: PortalPoint(x: 3850, y: 5700),
      ),
    ],
  ),
  
  // Viridian City to Pewter City
  MapPortalGroup(
    color: '#2196F3',
    area: 'Route 2',
    portals: [
      Portal(
        portal1: PortalPoint(x: 3800, y: 5400),
        portal2: PortalPoint(x: 3800, y: 4900),
      ),
    ],
  ),
  
  // Pewter City to Cerulean City
  MapPortalGroup(
    color: '#FF9800',
    area: 'Route 3-4',
    portals: [
      Portal(
        portal1: PortalPoint(x: 3900, y: 4700),
        portal2: PortalPoint(x: 4800, y: 4700),
      ),
      Portal(
        portal1: PortalPoint(x: 4800, y: 4700),
        portal2: PortalPoint(x: 4900, y: 4250),
      ),
    ],
  ),
  
  // Cerulean City to Vermilion City
  MapPortalGroup(
    color: '#9C27B0',
    area: 'Route 5-6',
    portals: [
      Portal(
        portal1: PortalPoint(x: 4500, y: 4400),
        portal2: PortalPoint(x: 4500, y: 4850),
      ),
    ],
  ),
  
  // Underground Path 5-6
  MapPortalGroup(
    color: '#795548',
    area: 'Underground Path',
    portals: [
      Portal(
        portal1: PortalPoint(x: 4550, y: 4400),
        portal2: PortalPoint(x: 4550, y: 4850),
      ),
    ],
  ),
  
  // Vermilion City to Lavender Town
  MapPortalGroup(
    color: '#E91E63',
    area: 'Route 11-12',
    portals: [
      Portal(
        portal1: PortalPoint(x: 4600, y: 5000),
        portal2: PortalPoint(x: 5800, y: 5000),
      ),
      Portal(
        portal1: PortalPoint(x: 5800, y: 5000),
        portal2: PortalPoint(x: 5800, y: 4600),
      ),
    ],
  ),
  
  // Lavender Town to Celadon City
  MapPortalGroup(
    color: '#00BCD4',
    area: 'Route 8-7',
    portals: [
      Portal(
        portal1: PortalPoint(x: 5600, y: 4300),
        portal2: PortalPoint(x: 3800, y: 4300),
      ),
    ],
  ),
  
  // Underground Path 7-8
  MapPortalGroup(
    color: '#795548',
    area: 'Underground Path 2',
    portals: [
      Portal(
        portal1: PortalPoint(x: 5600, y: 4350),
        portal2: PortalPoint(x: 3800, y: 4350),
      ),
    ],
  ),
  
  // Celadon City to Saffron City
  MapPortalGroup(
    color: '#FFEB3B',
    area: 'Route 7',
    portals: [
      Portal(
        portal1: PortalPoint(x: 3900, y: 4300),
        portal2: PortalPoint(x: 4200, y: 4300),
      ),
    ],
  ),
  
  // Saffron City to Cerulean City
  MapPortalGroup(
    color: '#8BC34A',
    area: 'Route 5',
    portals: [
      Portal(
        portal1: PortalPoint(x: 4500, y: 4200),
        portal2: PortalPoint(x: 4500, y: 3900),
      ),
    ],
  ),
  
  // Saffron City to Lavender Town
  MapPortalGroup(
    color: '#FFC107',
    area: 'Route 8',
    portals: [
      Portal(
        portal1: PortalPoint(x: 4700, y: 4300),
        portal2: PortalPoint(x: 5500, y: 4300),
      ),
    ],
  ),
  
  // Lavender Town to Fuchsia City
  MapPortalGroup(
    color: '#673AB7',
    area: 'Route 12-13-14-15',
    portals: [
      Portal(
        portal1: PortalPoint(x: 5800, y: 4600),
        portal2: PortalPoint(x: 5800, y: 5400),
      ),
      Portal(
        portal1: PortalPoint(x: 5800, y: 5400),
        portal2: PortalPoint(x: 5200, y: 5400),
      ),
    ],
  ),
  
  // Celadon City to Fuchsia City
  MapPortalGroup(
    color: '#3F51B5',
    area: 'Route 16-17-18',
    portals: [
      Portal(
        portal1: PortalPoint(x: 3100, y: 4400),
        portal2: PortalPoint(x: 3100, y: 5200),
      ),
      Portal(
        portal1: PortalPoint(x: 3100, y: 5200),
        portal2: PortalPoint(x: 4800, y: 5200),
      ),
    ],
  ),
  
  // Fuchsia City to Cinnabar Island
  MapPortalGroup(
    color: '#FF5722',
    area: 'Route 19-20',
    portals: [
      Portal(
        portal1: PortalPoint(x: 4900, y: 5600),
        portal2: PortalPoint(x: 2900, y: 5900),
      ),
    ],
  ),
  
  // Cinnabar Island to Pallet Town
  MapPortalGroup(
    color: '#009688',
    area: 'Route 21',
    portals: [
      Portal(
        portal1: PortalPoint(x: 2900, y: 6000),
        portal2: PortalPoint(x: 3500, y: 6000),
      ),
    ],
  ),
  
  // Viridian City to Indigo Plateau
  MapPortalGroup(
    color: '#607D8B',
    area: 'Route 22-23',
    portals: [
      Portal(
        portal1: PortalPoint(x: 3500, y: 5600),
        portal2: PortalPoint(x: 3200, y: 5200),
      ),
      Portal(
        portal1: PortalPoint(x: 3200, y: 5200),
        portal2: PortalPoint(x: 3200, y: 3600),
      ),
      Portal(
        portal1: PortalPoint(x: 3200, y: 3600),
        portal2: PortalPoint(x: 3850, y: 3000),
      ),
    ],
  ),
  
  // Cerulean City to Cerulean Cave
  MapPortalGroup(
    color: '#00E676',
    area: 'Cerulean Cave',
    portals: [
      Portal(
        portal1: PortalPoint(x: 5000, y: 3900),
        portal2: PortalPoint(x: 5100, y: 3800),
      ),
    ],
  ),
  
  // Pewter City to Diglett Cave to Vermilion City
  MapPortalGroup(
    color: '#6D4C41',
    area: 'Diglett Cave',
    portals: [
      Portal(
        portal1: PortalPoint(x: 3700, y: 4800),
        portal2: PortalPoint(x: 4100, y: 5100),
      ),
    ],
  ),
  
  // Rock Tunnel
  MapPortalGroup(
    color: '#424242',
    area: 'Rock Tunnel',
    portals: [
      Portal(
        portal1: PortalPoint(x: 5300, y: 4100),
        portal2: PortalPoint(x: 5600, y: 4400),
      ),
    ],
  ),
];
