// GENERATED CODE - MANUAL IMPLEMENTATION

part of 'game_achievement_dto.dart';

class GameAchievementDTOAdapter extends TypeAdapter<GameAchievementDTO> {
  @override
  final int typeId = GameAchievementDTO.hiveTypeId;

  @override
  GameAchievementDTO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameAchievementDTO(
      type: fields[0] as String,
      isUnlocked: fields[1] as bool,
      unlockedDateTimestamp: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, GameAchievementDTO obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.isUnlocked)
      ..writeByte(2)
      ..write(obj.unlockedDateTimestamp);
  }
}
