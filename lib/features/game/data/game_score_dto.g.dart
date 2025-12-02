// GENERATED CODE - MANUAL IMPLEMENTATION

part of 'game_score_dto.dart';

class GameScoreDTOAdapter extends TypeAdapter<GameScoreDTO> {
  @override
  final int typeId = GameScoreDTO.hiveTypeId;

  @override
  GameScoreDTO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameScoreDTO(
      id: fields[0] as String,
      score: fields[1] as int,
      correctAnswers: fields[2] as int,
      totalQuestions: fields[3] as int,
      bestStreak: fields[4] as int,
      dateTimestamp: fields[5] as int,
      totalTimeSeconds: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameScoreDTO obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.correctAnswers)
      ..writeByte(3)
      ..write(obj.totalQuestions)
      ..writeByte(4)
      ..write(obj.bestStreak)
      ..writeByte(5)
      ..write(obj.dateTimestamp)
      ..writeByte(6)
      ..write(obj.totalTimeSeconds);
  }
}
