import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../data/pokemon_data.dart';
import '../data/pokemon_repository.dart';

/// Caso de uso para obtener la lista de Pokémon.
/// Lo incluyo aquí como clase interna dado el contexto compactado.
class GetPokemonListUseCase {
  final PokemonRepository _repository;
  GetPokemonListUseCase(this._repository);
  Future<PaginatedPokemonList> execute(PokemonFilter filter) =>
      _repository.getPokemonList(filter);
}

/// Estado de la lista de Pokémon.
class PokemonListState {
  final List<Pokemon> pokemons;
  final bool isInitialLoading;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String searchText;
  final int? selectedGeneration;
  final Set<String> selectedTypes;
  final bool isFromCache;

  const PokemonListState({
    this.pokemons = const [],
    this.isInitialLoading = true,
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 0,
    this.totalCount = 0,
    this.searchText = '',
    this.selectedGeneration,
    this.selectedTypes = const {},
    this.isFromCache = false,
  });

  PokemonListState copyWith({
    List<Pokemon>? pokemons,
    bool? isInitialLoading,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? searchText,
    int? selectedGeneration,
    bool clearGeneration = false,
    Set<String>? selectedTypes,
    bool? isFromCache,
  }) {
    return PokemonListState(
      pokemons: pokemons ?? this.pokemons,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      searchText: searchText ?? this.searchText,
      selectedGeneration:
      clearGeneration ? null : (selectedGeneration ?? this.selectedGeneration),
      selectedTypes: selectedTypes ?? this.selectedTypes,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  bool get hasPreviousPage => currentPage > 1;
  bool get hasNextPage => currentPage < totalPages;
  String get paginationInfo =>
      totalPages > 0 ? 'Página $currentPage de $totalPages' : 'Página 1';
}

/// Provider del cliente GraphQL.
/// Debe ser overrideado con el cliente real en la app.
final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  throw UnimplementedError(
    'graphQLClientProvider must be overridden with the real GraphQL client',
  );
});

/// Provider del data source local.
final localDataSourceProvider = Provider<PokemonLocalDataSource>((ref) {
  return PokemonLocalDataSource();
});

/// Provider del data source remoto.
final remoteDataSourceProvider = Provider<PokemonRemoteDataSource>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return PokemonRemoteDataSource(client);
});

/// Provider del repositorio de Pokémon.
final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  final localDataSource = ref.watch(localDataSourceProvider);
  return PokemonRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Provider del caso de uso.
final getPokemonListUseCaseProvider = Provider<GetPokemonListUseCase>((ref) {
  final repository = ref.watch(pokemonRepositoryProvider);
  return GetPokemonListUseCase(repository);
});

/// Provider del estado de la lista de Pokémon.
final pokemonListProvider =
StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
  final useCase = ref.watch(getPokemonListUseCaseProvider);
  return PokemonListNotifier(useCase);
});

/// Notifier para manejar el estado de la lista de Pokémon.
class PokemonListNotifier extends StateNotifier<PokemonListState> {
  final GetPokemonListUseCase _useCase;

  final Map<String, _CachedPageData> _pageCache = {};
  static const int _maxCacheSize = 20;

  PokemonListNotifier(this._useCase) : super(const PokemonListState());

  Future<void> initializeLocalDataSource(
      PokemonLocalDataSource localDataSource,
      ) async {
    await localDataSource.initialize();
  }

  String _getCacheKey(int page) {
    return '${state.searchText}_${state.selectedGeneration}_${state.selectedTypes.join(',')}_$page';
  }

  void _trimCache() {
    while (_pageCache.length > _maxCacheSize) {
      String? oldestKey;
      DateTime? oldestTimestamp;
      for (final entry in _pageCache.entries) {
        if (oldestTimestamp == null ||
            entry.value.lastAccessed.isBefore(oldestTimestamp)) {
          oldestTimestamp = entry.value.lastAccessed;
          oldestKey = entry.key;
        }
      }
      if (oldestKey != null) {
        _pageCache.remove(oldestKey);
      }
    }
  }

  void _clearCacheOnFilterChange() {
    _pageCache.clear();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isInitialLoading: true,
      isLoading: true,
      clearError: true,
    );
    await _loadPage(1);
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    if (page == state.currentPage) return;
    state = state.copyWith(isLoading: true);
    await _loadPage(page);
  }

  Future<void> nextPage() async {
    if (state.hasNextPage) {
      await goToPage(state.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (state.hasPreviousPage) {
      await goToPage(state.currentPage - 1);
    }
  }

  void updateSearch(String text) {
    final normalized = text.toLowerCase().trim();
    if (normalized == state.searchText) return;
    _clearCacheOnFilterChange();
    state = state.copyWith(
      searchText: normalized,
      currentPage: 1,
    );
    loadInitial();
  }

  void selectGeneration(int? generation) {
    if (generation == state.selectedGeneration) return;
    _clearCacheOnFilterChange();
    if (generation == null) {
      state = state.copyWith(clearGeneration: true, currentPage: 1);
    } else {
      state = state.copyWith(selectedGeneration: generation, currentPage: 1);
    }
    loadInitial();
  }

  void toggleType(String type, bool selected) {
    final normalized = type.toLowerCase();
    final newTypes = Set<String>.from(state.selectedTypes);
    if (selected) {
      newTypes.add(normalized);
    } else {
      newTypes.remove(normalized);
    }
    _clearCacheOnFilterChange();
    state = state.copyWith(selectedTypes: newTypes, currentPage: 1);
    loadInitial();
  }

  void clearFilters() {
    _clearCacheOnFilterChange();
    state = state.copyWith(
      searchText: '',
      clearGeneration: true,
      selectedTypes: {},
      currentPage: 1,
    );
    loadInitial();
  }

  Future<void> _loadPage(int page) async {
    try {
      final cacheKey = _getCacheKey(page);
      final cachedData = _pageCache[cacheKey];
      if (cachedData != null) {
        cachedData.touch();
        state = state.copyWith(
          pokemons: cachedData.pokemons,
          currentPage: cachedData.currentPage,
          totalPages: cachedData.totalPages,
          totalCount: cachedData.totalCount,
          isInitialLoading: false,
          isLoading: false,
          isFromCache: true,
          clearError: true,
        );
        return;
      }

      final filter = PokemonFilter(
        searchText: state.searchText.isEmpty ? null : state.searchText,
        generation: state.selectedGeneration,
        types: state.selectedTypes,
        page: page,
        pageSize: 20,
      );

      final result = await _useCase.execute(filter);

      _pageCache[cacheKey] = _CachedPageData(
        pokemons: result.pokemons,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        totalCount: result.totalCount,
      );
      _trimCache();

      state = state.copyWith(
        pokemons: result.pokemons,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        totalCount: result.totalCount,
        isInitialLoading: false,
        isLoading: false,
        isFromCache: false,
        clearError: true,
      );
    } on PokemonRemoteException catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
        isInitialLoading: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error inesperado: ${e.toString()}',
        isInitialLoading: false,
        isLoading: false,
      );
    }
  }

  String _getErrorMessage(PokemonRemoteException e) {
    switch (e.type) {
      case PokemonRemoteExceptionType.noConnection:
        return 'Sin conexión a internet. Verifica tu conexión e intenta de nuevo.';
      case PokemonRemoteExceptionType.timeout:
        return 'La solicitud tardó demasiado. Intenta de nuevo.';
      case PokemonRemoteExceptionType.rateLimit:
        return 'Demasiadas solicitudes. Espera un momento e intenta de nuevo.';
      case PokemonRemoteExceptionType.serverError:
        return 'Error del servidor. Intenta de nuevo más tarde.';
    }
  }
}

class _CachedPageData {
  final List<Pokemon> pokemons;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  DateTime lastAccessed;

  _CachedPageData({
    required this.pokemons,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    DateTime? lastAccessed,
  }) : lastAccessed = lastAccessed ?? DateTime.now();

  void touch() {
    lastAccessed = DateTime.now();
  }
}