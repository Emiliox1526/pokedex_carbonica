import '../data/pokemon_detail_data.dart';

abstract class PokemonDetailRepository {
  /// Obtiene la información detallada de un Pokémon por ID.
  Future<PokemonDetail> getPokemonDetail(int id);

  /// Obtiene la información detallada de una variante de forma.
  Future<PokemonDetail> getFormDetail(int pokemonId);

  /// Limpia la caché de detalles de Pokémon.
  Future<void> clearCache();

  /// Indica si hay datos cacheados para el Pokémon con [id].
  Future<bool> hasCachedData(int id);

  /// Obtiene el detalle cacheado de un Pokémon, si existe.
  Future<PokemonDetail?> getCachedDetail(int id);
}