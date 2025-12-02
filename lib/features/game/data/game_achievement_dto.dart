import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../domain/entities/game/game_achievement.dart';

part 'game_achievement_dto.g.dart';

/// Data Transfer Object para persistir logros con Hive.
///
/// Esta clase mapea la entidad GameAchievement para almacenamiento local.
@HiveType(typeId: GameAchievementDTO.hiveTypeId)
class GameAchievementDTO {
  /// Hive type ID for this DTO.
  static const int hiveTypeId = 2;

  /// Tipo de logro (como string para persistencia).
  @HiveField(0)
  final String type;

  /// Indica si el logro está desbloqueado.
  @HiveField(1)
  final bool isUnlocked;

  /// Timestamp de desbloqueo en milisegundos (null si no desbloqueado).
  @HiveField(2)
  final int? unlockedDateTimestamp;

  /// Constructor del DTO.
  const GameAchievementDTO({
    required this.type,
    required this.isUnlocked,
    this.unlockedDateTimestamp,
  });

  /// Crea un DTO a partir de una entidad de dominio.
  factory GameAchievementDTO.fromEntity(GameAchievement entity) {
    return GameAchievementDTO(
      type: entity.type.name,
      isUnlocked: entity.isUnlocked,
      unlockedDateTimestamp: entity.unlockedDate?.millisecondsSinceEpoch,
    );
  }

  /// Convierte el DTO a una entidad de dominio.
  GameAchievement toEntity() {
    return GameAchievement(
      type: _parseAchievementType(type),
      isUnlocked: isUnlocked,
      unlockedDate: unlockedDateTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(unlockedDateTimestamp!)
          : null,
    );
  }

  /// Parsea el string a AchievementType.
  /// Throws [ArgumentError] if the type is unknown to aid debugging.
  static AchievementType _parseAchievementType(String type) {
    switch (type) {
      case 'noviceTrainer':
        return AchievementType.noviceTrainer;
      case 'connoisseur':
        return AchievementType.connoisseur;
      case 'pokemonMaster':
        return AchievementType.pokemonMaster;
      case 'speedster':
        return AchievementType.speedster;
      case 'onFire':
        return AchievementType.onFire;
      case 'legend':
        return AchievementType.legend;
      default:
        // Log warning for unknown types but don't crash the app
        assert(() {
          debugPrint('Warning: Unknown achievement type: $type');
          return true;
        }());
        return AchievementType.noviceTrainer;
    }
  }

  /// Convierte el DTO a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'isUnlocked': isUnlocked,
      'unlockedDateTimestamp': unlockedDateTimestamp,
    };
  }

  /// Crea un DTO a partir de un mapa JSON.
  factory GameAchievementDTO.fromJson(Map<String, dynamic> json) {
    return GameAchievementDTO(
      type: json['type'] as String,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedDateTimestamp: json['unlockedDateTimestamp'] as int?,
    );
  }

  @override
  String toString() =>
      'GameAchievementDTO(type: $type, unlocked: $isUnlocked)';
}
