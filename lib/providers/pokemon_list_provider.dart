import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../queries/get_pokemon_list.dart';

class PokemonListProvider extends ChangeNotifier {
  PokemonListProvider({
    required this.client,
    this.pageSize = 30,
  });

  final GraphQLClient client;
  final int pageSize;

  final List<Map<String, dynamic>> _pokemons = [];
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  String _searchText = '';
  final Set<String> _selectedTypes = {};
  int? _selectedGeneration;

  UnmodifiableListView<Map<String, dynamic>> get pokemons => UnmodifiableListView(_pokemons);
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  Set<String> get selectedTypes => Set.unmodifiable(_selectedTypes);
  int? get selectedGeneration => _selectedGeneration;

  Future<void> loadInitial() async {
    _isInitialLoading = true;
    _errorMessage = null;
    _hasMore = true;
    _pokemons.clear();
    notifyListeners();

    try {
      final fetched = await _fetchPokemons(offset: 0);
      _pokemons.addAll(fetched);
      _hasMore = fetched.length == pageSize;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMore() async {
    if (_isInitialLoading || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final fetched = await _fetchPokemons(offset: _pokemons.length);
      _pokemons.addAll(fetched);
      _hasMore = fetched.length == pageSize;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void updateSearch(String value) {
    final normalized = value.toLowerCase().trim();
    if (normalized == _searchText) return;
    _searchText = normalized;
    loadInitial();
  }

  void toggleType(String type, bool selected) {
    final normalized = type.toLowerCase();
    if (selected) {
      if (_selectedTypes.add(normalized)) {
        loadInitial();
      }
    } else {
      if (_selectedTypes.remove(normalized)) {
        loadInitial();
      }
    }
  }

  void selectGeneration(int? generation) {
    if (_selectedGeneration == generation) return;
    _selectedGeneration = generation;
    loadInitial();
  }

  Future<List<Map<String, dynamic>>> _fetchPokemons({required int offset}) async {
    final result = await client.query(
      QueryOptions(
        document: gql(paginatedPokemonListQuery),
        variables: {
          'limit': pageSize,
          'offset': offset,
          'where': _buildWhereClause(),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception ?? Exception('Error al cargar los Pokémon');
    }

    final data = result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Map<String, dynamic>? _buildWhereClause() {
    final List<Map<String, dynamic>> andConditions = [];

    if (_searchText.isNotEmpty) {
      final parsedId = int.tryParse(_searchText);
      final List<Map<String, dynamic>> orConditions = [
        {
          'name': {'_ilike': '%$_searchText%'}
        },
      ];
      if (parsedId != null) {
        orConditions.add({
          'id': {'_eq': parsedId}
        });
      }
      andConditions.add({'_or': orConditions});
    }

    if (_selectedGeneration != null) {
      final start = _startIdFor(_selectedGeneration!);
      final end = _endIdFor(_selectedGeneration!);
      andConditions.add({
        'id': {
          '_gte': start,
          '_lte': end,
        }
      });
    }

    if (_selectedTypes.isNotEmpty) {
      andConditions.add({
        'pokemon_v2_pokemontypes': {
          'pokemon_v2_type': {
            'name': {
              '_in': _selectedTypes.toList(),
            },
          },
        },
      });
    }

    if (andConditions.isEmpty) return null;
    if (andConditions.length == 1) return andConditions.first;

    return {
      '_and': andConditions,
    };
  }

  int _startIdFor(int gen) {
    const startIds = [1, 152, 252, 387, 494, 650, 722, 810, 906];
    return startIds[gen - 1];
  }

  int _endIdFor(int gen) {
    const endIds = [151, 251, 386, 493, 649, 721, 809, 905, 1025];
    return endIds[gen - 1];
  }
}