// GENERATED CODE - MANUAL IMPLEMENTATION

part of 'pokemon_dto.dart';

class PokemonDTOAdapter extends TypeAdapter<PokemonDTO> {
  @override
  final int typeId = 0;

  @override
  PokemonDTO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PokemonDTO(
      id: fields[0] as int,
      name: fields[1] as String,
      types: (fields[2] as List).cast<String>(),
      imageUrl: fields[3] as String?,
      abilities: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PokemonDTO obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.types)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.abilities);
  }
}
