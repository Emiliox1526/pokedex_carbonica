import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/favorites/favorites_local_datasource.dart';
import '../../../domain/entities/pokemon.dart';

/// State for the favorites screen.
class FavoritesState {
  /// List of favorite Pokemon.
  final List<Pokemon> favorites;

  /// Whether the favorites are being loaded.
  final bool isLoading;

  /// Error message, if any.
  final String? errorMessage;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  /// Creates a copy with updated values.
  FavoritesState copyWith({
    List<Pokemon>? favorites,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Gets the count of favorites.
  int get count => favorites.length;

  /// Checks if there are no favorites.
  bool get isEmpty => favorites.isEmpty;
}

/// Provider for the favorites data source.
final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((ref) {
  return FavoritesLocalDataSource();
});

/// StateNotifier for managing favorites state.
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesLocalDataSource _dataSource;

  FavoritesNotifier(this._dataSource) : super(const FavoritesState());

  /// Loads all favorites from local storage.
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final favorites = await _dataSource.getAllFavorites();
      state = state.copyWith(
        favorites: favorites,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar favoritos: ${e.toString()}',
      );
    }
  }

  /// Adds a Pokemon to favorites.
  Future<void> addFavorite(Pokemon pokemon) async {
    try {
      await _dataSource.addFavorite(pokemon);
      // Reload to get updated list
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al agregar favorito: ${e.toString()}',
      );
    }
  }

  /// Removes a Pokemon from favorites.
  Future<void> removeFavorite(int pokemonId) async {
    try {
      await _dataSource.removeFavorite(pokemonId);
      // Reload to get updated list
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al eliminar favorito: ${e.toString()}',
      );
    }
  }

  /// Checks if a Pokemon is a favorite.
  Future<bool> isFavorite(int pokemonId) async {
    return _dataSource.isFavorite(pokemonId);
  }

  /// Toggles a Pokemon's favorite status.
  Future<bool> toggleFavorite(Pokemon pokemon) async {
    try {
      final isNowFavorite = await _dataSource.toggleFavorite(pokemon);
      // Reload to get updated list
      await loadFavorites();
      return isNowFavorite;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al cambiar favorito: ${e.toString()}',
      );
      return false;
    }
  }
}

/// Provider for the favorites state.
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final dataSource = ref.watch(favoritesLocalDataSourceProvider);
  return FavoritesNotifier(dataSource);
});
