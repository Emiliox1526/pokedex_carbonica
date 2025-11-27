import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../domain/usecases/get_pokemon_list_usecase.dart';
import '../../data/datasources/pokemon_remote_datasource.dart';
import '../../data/datasources/pokemon_local_datasource.dart';
import '../../data/repositories/pokemon_repository_impl.dart';

/// Estado de la lista de Pokémon.
/// 
/// Esta clase inmutable representa el estado completo de la pantalla
/// de lista de Pokémon, incluyendo datos, paginación, filtros y errores.
class PokemonListState {
  /// Lista de Pokémon actual.
  final List<Pokemon> pokemons;
  
  /// Indica si está cargando la primera página.
  final bool isInitialLoading;
  
  /// Indica si está cargando datos (cualquier operación).
  final bool isLoading;
  
  /// Mensaje de error, si existe.
  final String? errorMessage;
  
  /// Página actual (base 1).
  final int currentPage;
  
  /// Total de páginas disponibles.
  final int totalPages;
  
  /// Total de Pokémon que coinciden con el filtro.
  final int totalCount;
  
  /// Texto de búsqueda actual.
  final String searchText;
  
  /// Generación seleccionada (null = todas).
  final int? selectedGeneration;
  
  /// Tipos seleccionados para filtrar.
  final Set<String> selectedTypes;
  
  /// Indica si los datos vienen del cache.
  final bool isFromCache;

  /// Constructor del estado.
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

  /// Crea una copia del estado con los valores especificados.
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

  /// Indica si hay página anterior.
  bool get hasPreviousPage => currentPage > 1;

  /// Indica si hay página siguiente.
  bool get hasNextPage => currentPage < totalPages;

  /// Texto de información de paginación.
  String get paginationInfo =>
      totalPages > 0 ? 'Página $currentPage de $totalPages' : 'Página 1';
}

/// Provider del cliente GraphQL.
/// 
/// Must be overridden with the real GraphQL client in the application.
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
/// 
/// Este es el provider principal que maneja todo el estado de la pantalla
/// de lista de Pokémon, incluyendo paginación, filtros y errores.
final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
  final useCase = ref.watch(getPokemonListUseCaseProvider);
  return PokemonListNotifier(useCase);
});

/// Notifier para manejar el estado de la lista de Pokémon.
/// 
/// Esta clase contiene toda la lógica de negocio para la gestión
/// del estado de la lista de Pokémon con Riverpod.
class PokemonListNotifier extends StateNotifier<PokemonListState> {
  /// Caso de uso para obtener la lista de Pokémon.
  final GetPokemonListUseCase _useCase;

  /// Constructor que inyecta el caso de uso.
  PokemonListNotifier(this._useCase) : super(const PokemonListState());

  /// Inicializa el data source local.
  Future<void> initializeLocalDataSource(
    PokemonLocalDataSource localDataSource,
  ) async {
    await localDataSource.initialize();
  }

  /// Carga la primera página de Pokémon.
  Future<void> loadInitial() async {
    state = state.copyWith(
      isInitialLoading: true,
      isLoading: true,
      clearError: true,
    );

    await _loadPage(1);
  }

  /// Carga una página específica.
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    if (page == state.currentPage) return;

    state = state.copyWith(isLoading: true);
    await _loadPage(page);
  }

  /// Avanza a la página siguiente.
  Future<void> nextPage() async {
    if (state.hasNextPage) {
      await goToPage(state.currentPage + 1);
    }
  }

  /// Retrocede a la página anterior.
  Future<void> previousPage() async {
    if (state.hasPreviousPage) {
      await goToPage(state.currentPage - 1);
    }
  }

  /// Actualiza el texto de búsqueda.
  void updateSearch(String text) {
    final normalized = text.toLowerCase().trim();
    if (normalized == state.searchText) return;
    
    state = state.copyWith(
      searchText: normalized,
      currentPage: 1,
    );
    loadInitial();
  }

  /// Selecciona una generación para filtrar.
  void selectGeneration(int? generation) {
    if (generation == state.selectedGeneration) return;
    
    if (generation == null) {
      state = state.copyWith(clearGeneration: true, currentPage: 1);
    } else {
      state = state.copyWith(selectedGeneration: generation, currentPage: 1);
    }
    loadInitial();
  }

  /// Activa o desactiva un tipo en el filtro.
  void toggleType(String type, bool selected) {
    final normalized = type.toLowerCase();
    final newTypes = Set<String>.from(state.selectedTypes);
    
    if (selected) {
      newTypes.add(normalized);
    } else {
      newTypes.remove(normalized);
    }
    
    state = state.copyWith(selectedTypes: newTypes, currentPage: 1);
    loadInitial();
  }

  /// Limpia todos los filtros.
  void clearFilters() {
    state = state.copyWith(
      searchText: '',
      clearGeneration: true,
      selectedTypes: {},
      currentPage: 1,
    );
    loadInitial();
  }

  /// Carga una página de Pokémon.
  Future<void> _loadPage(int page) async {
    try {
      final filter = PokemonFilter(
        searchText: state.searchText.isEmpty ? null : state.searchText,
        generation: state.selectedGeneration,
        types: state.selectedTypes,
        page: page,
        pageSize: 20,
      );

      final result = await _useCase.execute(filter);

      state = state.copyWith(
        pokemons: result.pokemons,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        totalCount: result.totalCount,
        isInitialLoading: false,
        isLoading: false,
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

  /// Convierte excepciones a mensajes amigables.
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
