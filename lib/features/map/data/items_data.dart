import 'models.dart';

/// Sample item data for the FRLG Kanto map
/// Coordinates are in pixels relative to the 7700x6400 map image
const List<ItemData> itemsData = [
  // Route 1 items
  ItemData(
    x: 3800,
    y: 5900,
    type: ItemType.normal,
  ),
  ItemData(
    x: 3820,
    y: 5750,
    type: ItemType.hidden,
  ),
  
  // Viridian Forest items
  ItemData(
    x: 3850,
    y: 5300,
    type: ItemType.normal,
  ),
  ItemData(
    x: 3900,
    y: 5250,
    type: ItemType.normal,
  ),
  ItemData(
    x: 3950,
    y: 5150,
    type: ItemType.hidden,
  ),
  
  // Pewter City items
  ItemData(
    x: 3650,
    y: 4750,
    type: ItemType.normal,
  ),
  
  // Route 3 items
  ItemData(
    x: 4000,
    y: 4650,
    type: ItemType.normal,
  ),
  ItemData(
    x: 4150,
    y: 4580,
    type: ItemType.hidden,
  ),
  
  // Mt. Moon items
  ItemData(
    x: 4450,
    y: 4450,
    type: ItemType.normal,
  ),
  ItemData(
    x: 4500,
    y: 4420,
    type: ItemType.tm,
  ),
  ItemData(
    x: 4550,
    y: 4380,
    type: ItemType.normal,
  ),
  ItemData(
    x: 4600,
    y: 4360,
    type: ItemType.hidden,
  ),
  
  // Route 4 items
  ItemData(
    x: 4750,
    y: 4250,
    type: ItemType.normal,
  ),
  
  // Cerulean City items
  ItemData(
    x: 4950,
    y: 4150,
    type: ItemType.normal,
  ),
  ItemData(
    x: 5050,
    y: 4120,
    type: ItemType.tm,
  ),
  
  // Route 24 & 25 items
  ItemData(
    x: 5150,
    y: 3920,
    type: ItemType.normal,
  ),
  ItemData(
    x: 5250,
    y: 3880,
    type: ItemType.hidden,
  ),
  ItemData(
    x: 5300,
    y: 3850,
    type: ItemType.tm,
  ),
  
  // Route 5 & 6 items
  ItemData(
    x: 4500,
    y: 4600,
    type: ItemType.normal,
  ),
  ItemData(
    x: 4450,
    y: 4900,
    type: ItemType.hidden,
  ),
  
  // Vermilion City items
  ItemData(
    x: 4150,
    y: 5050,
    type: ItemType.normal,
  ),
  ItemData(
    x: 4250,
    y: 5020,
    type: ItemType.tm,
  ),
  
  // Route 11 items
  ItemData(
    x: 4600,
    y: 5000,
    type: ItemType.normal,
  ),
  ItemData(
    x: 4700,
    y: 4980,
    type: ItemType.hidden,
  ),
  
  // Rock Tunnel items
  ItemData(
    x: 5350,
    y: 4050,
    type: ItemType.normal,
  ),
  ItemData(
    x: 5400,
    y: 4020,
    type: ItemType.tm,
  ),
  ItemData(
    x: 5450,
    y: 3980,
    type: ItemType.hidden,
  ),
  ItemData(
    x: 5500,
    y: 3950,
    type: ItemType.normal,
  ),
  
  // Lavender Town items
  ItemData(
    x: 5650,
    y: 4500,
    type: ItemType.normal,
  ),
  
  // Pokemon Tower items
  ItemData(
    x: 5700,
    y: 4450,
    type: ItemType.normal,
  ),
  ItemData(
    x: 5750,
    y: 4400,
    type: ItemType.tm,
  ),
  ItemData(
    x: 5800,
    y: 4370,
    type: ItemType.normal,
  ),
  
  // Celadon City items
  ItemData(
    x: 3150,
    y: 4350,
    type: ItemType.normal,
  ),
  ItemData(
    x: 3250,
    y: 4320,
    type: ItemType.tm,
  ),
  ItemData(
    x: 3300,
    y: 4280,
    type: ItemType.hidden,
  ),
  
  // Route 7 & 8 items
  ItemData(
    x: 4100,
    y: 4300,
    type: ItemType.normal,
  ),
  ItemData(
    x: 4900,
    y: 4300,
    type: ItemType.hidden,
  ),
  
  // Saffron City items
  ItemData(
    x: 4350,
    y: 3850,
    type: ItemType.normal,
  ),
  ItemData(
    x: 4450,
    y: 3820,
    type: ItemType.tm,
  ),
  
  // Route 12 & 13 items
  ItemData(
    x: 5800,
    y: 4800,
    type: ItemType.normal,
  ),
  ItemData(
    x: 5850,
    y: 4900,
    type: ItemType.hidden,
  ),
  ItemData(
    x: 5900,
    y: 5000,
    type: ItemType.tm,
  ),
  
  // Route 14 & 15 items
  ItemData(
    x: 5800,
    y: 5200,
    type: ItemType.normal,
  ),
  ItemData(
    x: 5750,
    y: 5300,
    type: ItemType.hidden,
  ),
  
  // Fuchsia City items
  ItemData(
    x: 4950,
    y: 5450,
    type: ItemType.normal,
  ),
  ItemData(
    x: 5050,
    y: 5420,
    type: ItemType.tm,
  ),
  
  // Safari Zone items
  ItemData(
    x: 4700,
    y: 5600,
    type: ItemType.normal,
  ),
  ItemData(
    x: 4750,
    y: 5650,
    type: ItemType.hidden,
  ),
  ItemData(
    x: 4800,
    y: 5700,
    type: ItemType.tm,
  ),
  ItemData(
    x: 4850,
    y: 5750,
    type: ItemType.normal,
  ),
  
  // Route 16, 17, 18 items
  ItemData(
    x: 3000,
    y: 4600,
    type: ItemType.normal,
  ),
  ItemData(
    x: 2950,
    y: 4900,
    type: ItemType.hidden,
  ),
  ItemData(
    x: 2900,
    y: 5200,
    type: ItemType.tm,
  ),
  
  // Cinnabar Island items
  ItemData(
    x: 2750,
    y: 6050,
    type: ItemType.normal,
  ),
  ItemData(
    x: 2850,
    y: 6020,
    type: ItemType.tm,
  ),
  
  // Pokemon Mansion items
  ItemData(
    x: 2650,
    y: 5900,
    type: ItemType.normal,
  ),
  ItemData(
    x: 2700,
    y: 5850,
    type: ItemType.hidden,
  ),
  ItemData(
    x: 2750,
    y: 5800,
    type: ItemType.tm,
  ),
  
  // Route 21 items
  ItemData(
    x: 3200,
    y: 5900,
    type: ItemType.normal,
  ),
  ItemData(
    x: 3300,
    y: 5950,
    type: ItemType.hidden,
  ),
  
  // Route 22 & 23 items
  ItemData(
    x: 3400,
    y: 5650,
    type: ItemType.normal,
  ),
  ItemData(
    x: 3350,
    y: 5400,
    type: ItemType.hidden,
  ),
  ItemData(
    x: 3300,
    y: 5150,
    type: ItemType.tm,
  ),
  
  // Victory Road items
  ItemData(
    x: 3150,
    y: 3450,
    type: ItemType.normal,
  ),
  ItemData(
    x: 3200,
    y: 3420,
    type: ItemType.tm,
  ),
  ItemData(
    x: 3250,
    y: 3380,
    type: ItemType.hidden,
  ),
  ItemData(
    x: 3300,
    y: 3350,
    type: ItemType.normal,
  ),
  
  // Indigo Plateau items
  ItemData(
    x: 3800,
    y: 2850,
    type: ItemType.normal,
  ),
  ItemData(
    x: 3900,
    y: 2820,
    type: ItemType.tm,
  ),
  
  // Cerulean Cave items
  ItemData(
    x: 5100,
    y: 3700,
    type: ItemType.normal,
  ),
  ItemData(
    x: 5150,
    y: 3650,
    type: ItemType.tm,
  ),
  ItemData(
    x: 5200,
    y: 3600,
    type: ItemType.hidden,
  ),
];
