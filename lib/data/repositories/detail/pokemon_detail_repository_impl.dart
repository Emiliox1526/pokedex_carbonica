import '../../../domain/entities/detail/pokemon_detail.dart';
import '../../../domain/repositories/detail/pokemon_detail_repository.dart';
import '../../datasources/detail/pokemon_detail_remote_datasource.dart';
import '../../datasources/detail/pokemon_detail_local_datasource.dart';

/// Implementation of [PokemonDetailRepository].
///
/// Uses both remote and local data sources with a cache-first strategy.
class PokemonDetailRepositoryImpl implements PokemonDetailRepository {
  final PokemonDetailRemoteDataSource _remoteDataSource;
  final PokemonDetailLocalDataSource _localDataSource;

  /// Creates a repository with the given data sources.
  PokemonDetailRepositoryImpl({
    required PokemonDetailRemoteDataSource remoteDataSource,
    required PokemonDetailLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<PokemonDetail> getPokemonDetail(int id) async {
    try {
      // Try to get from remote
      final dto = await _remoteDataSource.getPokemonDetail(id);
      final entity = dto.toEntity();

      // Cache the result
      await _localDataSource.cachePokemonDetail(id, entity);

      return entity;
    } on PokemonDetailException catch (e) {
      // If network error, try to get from cache
      if (e.type == PokemonDetailExceptionType.noConnection ||
          e.type == PokemonDetailExceptionType.timeout) {
        final cached = await _localDataSource.getCachedPokemonDetail(id);
        if (cached != null) {
          return cached;
        }
      }
      rethrow;
    }
  }

  @override
  Future<PokemonDetail> getFormDetail(int pokemonId) async {
    try {
      final dto = await _remoteDataSource.getFormDetail(pokemonId);
      final entity = dto.toEntity();

      // Cache the form data
      await _localDataSource.cachePokemonDetail(pokemonId, entity);

      return entity;
    } on PokemonDetailException catch (e) {
      // If network error, try to get from cache
      if (e.type == PokemonDetailExceptionType.noConnection ||
          e.type == PokemonDetailExceptionType.timeout) {
        final cached = await _localDataSource.getCachedPokemonDetail(pokemonId);
        if (cached != null) {
          return cached;
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }

  @override
  Future<bool> hasCachedData(int id) async {
    return await _localDataSource.hasData(id);
  }

  @override
  Future<PokemonDetail?> getCachedDetail(int id) async {
    return await _localDataSource.getCachedPokemonDetail(id);
  }
}
