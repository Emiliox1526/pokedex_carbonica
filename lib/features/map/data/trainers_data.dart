import 'models.dart';

/// Sample trainer data for the FRLG Kanto map
/// Coordinates are in pixels relative to the 7700x6400 map image
const List<TrainerData> trainersData = [
  // Route 1 trainers
  TrainerData(
    name: 'Youngster',
    numPokemon: 1,
    pokemonLevels: [3],
    x: 3850,
    y: 5800,
    walker: true,
  ),
  TrainerData(
    name: 'Bug Catcher',
    numPokemon: 2,
    pokemonLevels: [4, 4],
    x: 3750,
    y: 5600,
  ),
  
  // Viridian Forest trainers
  TrainerData(
    name: 'Bug Catcher',
    numPokemon: 3,
    pokemonLevels: [6, 6, 6],
    x: 3900,
    y: 5200,
  ),
  TrainerData(
    name: 'Lass',
    numPokemon: 2,
    pokemonLevels: [7, 7],
    x: 3950,
    y: 5100,
    spinner: true,
    tooltipPosition: TooltipPosition.right,
  ),
  
  // Pewter City Gym
  TrainerData(
    name: 'Jr. Trainer',
    numPokemon: 2,
    pokemonLevels: [11, 11],
    x: 3600,
    y: 4800,
  ),
  TrainerData(
    name: 'Brock',
    numPokemon: 2,
    pokemonLevels: [12, 14],
    x: 3600,
    y: 4700,
    tooltipPosition: TooltipPosition.top,
  ),
  
  // Route 3 trainers
  TrainerData(
    name: 'Youngster',
    numPokemon: 1,
    pokemonLevels: [10],
    x: 4100,
    y: 4600,
    walker: true,
  ),
  TrainerData(
    name: 'Bug Catcher',
    numPokemon: 3,
    pokemonLevels: [9, 9, 9],
    x: 4200,
    y: 4550,
  ),
  TrainerData(
    name: 'Lass',
    numPokemon: 2,
    pokemonLevels: [11, 11],
    x: 4300,
    y: 4500,
    spinner: true,
  ),
  
  // Mt. Moon trainers
  TrainerData(
    name: 'Hiker',
    numPokemon: 4,
    pokemonLevels: [10, 10, 10, 10],
    x: 4500,
    y: 4400,
  ),
  TrainerData(
    name: 'Super Nerd',
    numPokemon: 2,
    pokemonLevels: [11, 11],
    x: 4550,
    y: 4350,
  ),
  
  // Route 4 trainers
  TrainerData(
    name: 'Picnicker',
    numPokemon: 1,
    pokemonLevels: [13],
    x: 4700,
    y: 4300,
  ),
  
  // Cerulean City Gym
  TrainerData(
    name: 'Swimmer',
    numPokemon: 2,
    pokemonLevels: [16, 16],
    x: 5000,
    y: 4200,
  ),
  TrainerData(
    name: 'Misty',
    numPokemon: 2,
    pokemonLevels: [18, 21],
    x: 5000,
    y: 4100,
    tooltipPosition: TooltipPosition.top,
  ),
  
  // Route 24 & 25 trainers
  TrainerData(
    name: 'Camper',
    numPokemon: 2,
    pokemonLevels: [14, 14],
    x: 5100,
    y: 3900,
    walker: true,
  ),
  TrainerData(
    name: 'Picnicker',
    numPokemon: 1,
    pokemonLevels: [16],
    x: 5200,
    y: 3850,
  ),
  
  // Vermilion City Gym
  TrainerData(
    name: 'Sailor',
    numPokemon: 2,
    pokemonLevels: [18, 18],
    x: 4200,
    y: 5000,
  ),
  TrainerData(
    name: 'Lt. Surge',
    numPokemon: 3,
    pokemonLevels: [21, 18, 24],
    x: 4200,
    y: 4900,
    tooltipPosition: TooltipPosition.top,
  ),
  
  // Rock Tunnel trainers
  TrainerData(
    name: 'Hiker',
    numPokemon: 3,
    pokemonLevels: [21, 21, 21],
    x: 5400,
    y: 4000,
  ),
  TrainerData(
    name: 'Picnicker',
    numPokemon: 2,
    pokemonLevels: [22, 22],
    x: 5450,
    y: 3950,
  ),
  
  // Celadon City Gym
  TrainerData(
    name: 'Lass',
    numPokemon: 2,
    pokemonLevels: [23, 23],
    x: 3200,
    y: 4300,
  ),
  TrainerData(
    name: 'Erika',
    numPokemon: 3,
    pokemonLevels: [29, 24, 29],
    x: 3200,
    y: 4200,
    tooltipPosition: TooltipPosition.top,
  ),
  
  // Pokemon Tower trainers
  TrainerData(
    name: 'Channeler',
    numPokemon: 2,
    pokemonLevels: [23, 23],
    x: 5700,
    y: 4400,
  ),
  TrainerData(
    name: 'Channeler',
    numPokemon: 3,
    pokemonLevels: [24, 24, 24],
    x: 5750,
    y: 4350,
  ),
  
  // Saffron City Gym
  TrainerData(
    name: 'Psychic',
    numPokemon: 2,
    pokemonLevels: [38, 38],
    x: 4400,
    y: 3800,
  ),
  TrainerData(
    name: 'Sabrina',
    numPokemon: 4,
    pokemonLevels: [38, 37, 38, 43],
    x: 4400,
    y: 3700,
    tooltipPosition: TooltipPosition.top,
  ),
  
  // Fuchsia City Gym
  TrainerData(
    name: 'Tamer',
    numPokemon: 2,
    pokemonLevels: [43, 43],
    x: 5000,
    y: 5400,
  ),
  TrainerData(
    name: 'Koga',
    numPokemon: 4,
    pokemonLevels: [37, 39, 37, 43],
    x: 5000,
    y: 5300,
    tooltipPosition: TooltipPosition.top,
  ),
  
  // Cinnabar Island Gym
  TrainerData(
    name: 'Burglar',
    numPokemon: 2,
    pokemonLevels: [47, 47],
    x: 2800,
    y: 6000,
  ),
  TrainerData(
    name: 'Blaine',
    numPokemon: 4,
    pokemonLevels: [42, 40, 42, 47],
    x: 2800,
    y: 5900,
    tooltipPosition: TooltipPosition.top,
  ),
  
  // Viridian City Gym
  TrainerData(
    name: 'Cooltrainer',
    numPokemon: 5,
    pokemonLevels: [43, 43, 43, 43, 43],
    x: 3600,
    y: 5600,
  ),
  TrainerData(
    name: 'Giovanni',
    numPokemon: 5,
    pokemonLevels: [45, 42, 44, 45, 50],
    x: 3600,
    y: 5500,
    tooltipPosition: TooltipPosition.top,
  ),
  
  // Victory Road trainers
  TrainerData(
    name: 'Cooltrainer',
    numPokemon: 5,
    pokemonLevels: [47, 47, 47, 47, 47],
    x: 3200,
    y: 3400,
  ),
  TrainerData(
    name: 'Black Belt',
    numPokemon: 3,
    pokemonLevels: [48, 48, 48],
    x: 3250,
    y: 3350,
  ),
  
  // Elite Four
  TrainerData(
    name: 'Lorelei',
    numPokemon: 5,
    pokemonLevels: [52, 51, 52, 54, 54],
    x: 3850,
    y: 2800,
    tooltipPosition: TooltipPosition.top,
  ),
  TrainerData(
    name: 'Bruno',
    numPokemon: 5,
    pokemonLevels: [51, 53, 53, 54, 56],
    x: 3850,
    y: 2700,
    tooltipPosition: TooltipPosition.top,
  ),
  TrainerData(
    name: 'Agatha',
    numPokemon: 5,
    pokemonLevels: [54, 54, 56, 56, 58],
    x: 3850,
    y: 2600,
    tooltipPosition: TooltipPosition.top,
  ),
  TrainerData(
    name: 'Lance',
    numPokemon: 5,
    pokemonLevels: [56, 54, 54, 58, 60],
    x: 3850,
    y: 2500,
    tooltipPosition: TooltipPosition.top,
  ),
  TrainerData(
    name: 'Champion',
    numPokemon: 6,
    pokemonLevels: [59, 57, 59, 61, 63, 65],
    x: 3850,
    y: 2400,
    tooltipPosition: TooltipPosition.top,
  ),
];
