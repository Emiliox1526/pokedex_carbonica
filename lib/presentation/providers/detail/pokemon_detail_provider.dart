import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../domain/entities/detail/pokemon_detail.dart';
import '../../../domain/entities/detail/pokemon_form_variant.dart';
import '../../../domain/repositories/detail/pokemon_detail_repository.dart';
import '../../../domain/usecases/detail/get_pokemon_detail_usecase.dart';
import '../../../domain/usecases/detail/get_form_detail_usecase.dart';
import '../../../data/datasources/detail/pokemon_detail_remote_datasource.dart';
import '../../../data/datasources/detail/pokemon_detail_local_datasource.dart';
import '../../../data/repositories/detail/pokemon_detail_repository_impl.dart';
import '../../providers/pokemon_list_provider.dart';

// ============================================================================
// Data Layer Providers
// ============================================================================

/// Provider for the Pokemon detail local data source.
final pokemonDetailLocalDataSourceProvider = Provider<PokemonDetailLocalDataSource>((ref) {
  return PokemonDetailLocalDataSource();
});

/// Provider for the Pokemon detail remote data source.
final pokemonDetailRemoteDataSourceProvider = Provider<PokemonDetailRemoteDataSource>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return PokemonDetailRemoteDataSource(client);
});

/// Provider for the Pokemon detail repository.
final pokemonDetailRepositoryProvider = Provider<PokemonDetailRepository>((ref) {
  final remoteDataSource = ref.watch(pokemonDetailRemoteDataSourceProvider);
  final localDataSource = ref.watch(pokemonDetailLocalDataSourceProvider);
  return PokemonDetailRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for the get Pokemon detail use case.
final getPokemonDetailUseCaseProvider = Provider<GetPokemonDetailUseCase>((ref) {
  final repository = ref.watch(pokemonDetailRepositoryProvider);
  return GetPokemonDetailUseCase(repository);
});

/// Provider for the get form detail use case.
final getFormDetailUseCaseProvider = Provider<GetFormDetailUseCase>((ref) {
  final repository = ref.watch(pokemonDetailRepositoryProvider);
  return GetFormDetailUseCase(repository);
});

// ============================================================================
// State Classes
// ============================================================================

/// State for the Pokemon detail screen.
class PokemonDetailState {
  /// The Pokemon detail data.
  final PokemonDetail? detail;

  /// The form data (if a different form is selected).
  final PokemonDetail? formDetail;

  /// Whether the main detail is loading.
  final bool isLoading;

  /// Whether form data is loading.
  final bool isLoadingForm;

  /// Error message, if any.
  final String? errorMessage;

  /// Currently selected tab index.
  final int selectedTab;

  /// Whether to show shiny sprite.
  final bool showShiny;

  /// Whether this Pokemon is a favorite.
  final bool isFavorite;

  /// Currently selected form ID.
  final int? selectedFormId;

  /// Current moves filter method.
  final String movesMethodFilter;

  /// Current moves sort order.
  final String movesSort;

  /// Current page for moves pagination.
  final int movesCurrentPage;

  /// Number of moves per page.
  final int movesPerPage;

  const PokemonDetailState({
    this.detail,
    this.formDetail,
    this.isLoading = true,
    this.isLoadingForm = false,
    this.errorMessage,
    this.selectedTab = 0,
    this.showShiny = false,
    this.isFavorite = false,
    this.selectedFormId,
    this.movesMethodFilter = 'level-up',
    this.movesSort = 'level',
    this.movesCurrentPage = 0,
    this.movesPerPage = 10,
  });

  /// Creates a copy with updated values.
  PokemonDetailState copyWith({
    PokemonDetail? detail,
    PokemonDetail? formDetail,
    bool? isLoading,
    bool? isLoadingForm,
    String? errorMessage,
    bool clearError = false,
    bool clearFormDetail = false,
    int? selectedTab,
    bool? showShiny,
    bool? isFavorite,
    int? selectedFormId,
    String? movesMethodFilter,
    String? movesSort,
    int? movesCurrentPage,
    int? movesPerPage,
  }) {
    return PokemonDetailState(
      detail: detail ?? this.detail,
      formDetail: clearFormDetail ? null : (formDetail ?? this.formDetail),
      isLoading: isLoading ?? this.isLoading,
      isLoadingForm: isLoadingForm ?? this.isLoadingForm,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedTab: selectedTab ?? this.selectedTab,
      showShiny: showShiny ?? this.showShiny,
      isFavorite: isFavorite ?? this.isFavorite,
      selectedFormId: selectedFormId ?? this.selectedFormId,
      movesMethodFilter: movesMethodFilter ?? this.movesMethodFilter,
      movesSort: movesSort ?? this.movesSort,
      movesCurrentPage: movesCurrentPage ?? this.movesCurrentPage,
      movesPerPage: movesPerPage ?? this.movesPerPage,
    );
  }

  /// Gets the currently active detail (form or base).
  PokemonDetail? get activeDetail => formDetail ?? detail;

  /// Gets available forms from the base detail.
  List<PokemonFormVariant> get availableForms => detail?.forms ?? [];

  /// Gets the currently selected form.
  PokemonFormVariant? get selectedForm {
    if (selectedFormId == null || availableForms.isEmpty) return null;
    try {
      return availableForms.firstWhere((f) => f.id == selectedFormId);
    } catch (_) {
      return availableForms.isNotEmpty ? availableForms.first : null;
    }
  }

  /// Whether there are multiple forms available.
  bool get hasMultipleForms => availableForms.length > 1;
}

// ============================================================================
// Main Provider (StateNotifier)
// ============================================================================

/// StateNotifier for managing Pokemon detail screen state.
class PokemonDetailNotifier extends StateNotifier<PokemonDetailState> {
  final GetPokemonDetailUseCase _getPokemonDetailUseCase;
  final GetFormDetailUseCase _getFormDetailUseCase;
  final int _pokemonId;

  /// Creates a notifier with the given use cases and Pokemon ID.
  PokemonDetailNotifier({
    required GetPokemonDetailUseCase getPokemonDetailUseCase,
    required GetFormDetailUseCase getFormDetailUseCase,
    required int pokemonId,
  })  : _getPokemonDetailUseCase = getPokemonDetailUseCase,
        _getFormDetailUseCase = getFormDetailUseCase,
        _pokemonId = pokemonId,
        super(const PokemonDetailState());

  /// Loads the Pokemon detail data.
  Future<void> loadDetail({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final detail = await _getPokemonDetailUseCase.execute(
        _pokemonId,
        forceRefresh: forceRefresh,
      );

      // Find the default form ID
      int? defaultFormId;
      if (detail.forms.isNotEmpty) {
        // Priority 1: Form matching the Pokemon ID
        final matchingForms = detail.forms.where((f) => f.pokemonId == _pokemonId);
        if (matchingForms.isNotEmpty) {
          defaultFormId = matchingForms.first.id;
        } else {
          // Priority 2: Default form
          final defaultForms = detail.forms.where(
            (f) => f.isDefault && f.category == PokemonFormCategory.defaultForm,
          );
          defaultFormId = defaultForms.isNotEmpty
              ? defaultForms.first.id
              : detail.forms.first.id;
        }
      }

      state = state.copyWith(
        detail: detail,
        isLoading: false,
        selectedFormId: defaultFormId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Loads data for a specific form variant.
  Future<void> loadFormDetail(PokemonFormVariant form) async {
    // If selecting the base Pokemon form, clear form detail
    if (form.pokemonId == _pokemonId) {
      state = state.copyWith(
        selectedFormId: form.id,
        clearFormDetail: true,
        movesCurrentPage: 0,
      );
      return;
    }

    state = state.copyWith(
      isLoadingForm: true,
      selectedFormId: form.id,
    );

    try {
      final formDetail = await _getFormDetailUseCase.execute(form.pokemonId);
      state = state.copyWith(
        formDetail: formDetail,
        isLoadingForm: false,
        movesCurrentPage: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingForm: false,
        errorMessage: 'Error loading form data: $e',
      );
    }
  }

  /// Selects a tab.
  void selectTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  /// Toggles shiny sprite display.
  void toggleShiny() {
    state = state.copyWith(showShiny: !state.showShiny);
  }

  /// Sets the favorite status.
  void setFavorite(bool isFavorite) {
    state = state.copyWith(isFavorite: isFavorite);
  }

  /// Toggles the favorite status.
  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite);
  }

  /// Sets the moves filter method.
  void setMovesMethod(String method) {
    state = state.copyWith(
      movesMethodFilter: method,
      movesCurrentPage: 0,
    );
  }

  /// Sets the moves sort order.
  void setMovesSort(String sort) {
    state = state.copyWith(
      movesSort: sort,
      movesCurrentPage: 0,
    );
  }

  /// Goes to a specific moves page.
  void setMovesPage(int page) {
    state = state.copyWith(movesCurrentPage: page);
  }

  /// Sets the number of moves per page.
  void setMovesPerPage(int perPage) {
    state = state.copyWith(
      movesPerPage: perPage,
      movesCurrentPage: 0,
    );
  }

  /// Selects a form by ID.
  void selectForm(PokemonFormVariant form) {
    loadFormDetail(form);
  }
}

// ============================================================================
// Family Provider
// ============================================================================

/// Provider family for Pokemon detail by ID.
///
/// Usage: `ref.watch(pokemonDetailProvider(25))` for Pikachu
final pokemonDetailProvider = StateNotifierProvider.family<
    PokemonDetailNotifier, PokemonDetailState, int>((ref, pokemonId) {
  final getPokemonDetailUseCase = ref.watch(getPokemonDetailUseCaseProvider);
  final getFormDetailUseCase = ref.watch(getFormDetailUseCaseProvider);

  return PokemonDetailNotifier(
    getPokemonDetailUseCase: getPokemonDetailUseCase,
    getFormDetailUseCase: getFormDetailUseCase,
    pokemonId: pokemonId,
  );
});
