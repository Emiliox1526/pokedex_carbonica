import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_remote_datasource.dart';
import '../datasources/pokemon_local_datasource.dart';
import '../models/pokemon_dto.dart';

/// Implementación del repositorio de Pokémon.
///
/// Esta clase implementa la lógica de obtención de datos con cache,
/// combinando el data source remoto (GraphQL) y local (Hive).
/// Sigue el patrón Repository del Domain-Driven Design.
class PokemonRepositoryImpl implements PokemonRepository {
  /// Data source remoto para consultas GraphQL.
  final PokemonRemoteDataSource _remoteDataSource;

  /// Data source local para persistencia con Hive.
  final PokemonLocalDataSource _localDataSource;

  /// Servicio de conectividad.
  final Connectivity _connectivity;

  /// Número de Pokémon por página (fijo en 20 según requisitos).
  static const int pageSize = 20;

  /// Constructor que inyecta las dependencias.
  PokemonRepositoryImpl({
    required PokemonRemoteDataSource remoteDataSource,
    required PokemonLocalDataSource localDataSource,
    Connectivity? connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity ?? Connectivity();

  @override
  Future<PaginatedPokemonList> getPokemonList(PokemonFilter filter) async {
    // Forzar el tamaño de página a 20
    final normalizedFilter = filter.copyWith(pageSize: pageSize);

    // Verificar conectividad
    final connectivityResult = await _connectivity. checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;

    if (hasConnection) {
      try {
        // Intentar obtener datos de la API
        final remotePokemon = await _remoteDataSource.getPokemonList(normalizedFilter);
        final totalCount = await _remoteDataSource.getTotalPokemonCount(normalizedFilter);

        // Guardar en cache local
        await _localDataSource.cachePokemonList(remotePokemon, normalizedFilter);
        await _localDataSource.cacheTotalCount(totalCount, normalizedFilter);

        return _buildPaginatedList(
          remotePokemon,
          normalizedFilter,
          totalCount,
        );
      } on PokemonRemoteException catch (e) {
        // Si hay error de red, intentar usar cache
        return _tryLocalFallback(normalizedFilter, e);
      }
    } else {
      // Sin conexión, usar cache local
      return _getFromCache(normalizedFilter);
    }
  }

  @override
  Future<int> getTotalPokemonCount(PokemonFilter filter) async {
    final normalizedFilter = filter.copyWith(pageSize: pageSize);

    final connectivityResult = await _connectivity.checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;

    if (hasConnection) {
      try {
        return await _remoteDataSource.getTotalPokemonCount(normalizedFilter);
      } on PokemonRemoteException {
        // Intentar cache
        final cachedCount = await _localDataSource.getCachedTotalCount(normalizedFilter);
        return cachedCount ?? 0;
      }
    } else {
      // Sin conexión, usar cache
      final cachedCount = await _localDataSource.getCachedTotalCount(normalizedFilter);
      return cachedCount ?? 0;
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }

  @override
  Future<bool> hasCachedData() async {
    return _localDataSource.hasData();
  }

  /// Intenta usar datos del cache local como fallback.
  Future<PaginatedPokemonList> _tryLocalFallback(
    PokemonFilter filter,
    PokemonRemoteException originalError,
  ) async {
    final cached = await _localDataSource.getCachedPokemonList(filter);
    final cachedCount = await _localDataSource.getCachedTotalCount(filter);

    if (cached != null && cached.isNotEmpty) {
      return _buildPaginatedList(cached, filter, cachedCount ?? cached.length);
    }

    // Si no hay cache, relanzar el error original
    throw originalError;
  }

  /// Obtiene datos solo del cache local.
  Future<PaginatedPokemonList> _getFromCache(PokemonFilter filter) async {
    final cached = await _localDataSource.getCachedPokemonList(filter);
    final cachedCount = await _localDataSource.getCachedTotalCount(filter);

    if (cached != null && cached.isNotEmpty) {
      return _buildPaginatedList(cached, filter, cachedCount ?? cached.length);
    }

    throw PokemonRemoteException(
      message: 'Sin conexión a internet y no hay datos en cache',
      type: PokemonRemoteExceptionType.noConnection,
    );
  }

  /// Construye el objeto PaginatedPokemonList a partir de los datos.
  PaginatedPokemonList _buildPaginatedList(
    List<PokemonDTO> pokemons,
    PokemonFilter filter,
    int totalCount,
  ) {
    final totalPages = (totalCount / filter.pageSize).ceil();

    return PaginatedPokemonList(
      pokemons: pokemons.map((dto) => dto.toEntity()).toList(),
      currentPage: filter.page,
      totalPages: totalPages,
      totalCount: totalCount,
      hasNextPage: filter.page < totalPages,
      hasPreviousPage: filter.page > 1,
    );
  }
}
