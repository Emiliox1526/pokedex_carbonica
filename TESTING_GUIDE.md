# Testing Guide - Language Toggle Feature

## Quick Start

After pulling these changes, run:

```bash
flutter pub get
flutter run
```

The localization files will be automatically generated during the build process.

## Testing the Language Toggle

### 1. Open the App
Launch the app on your device or emulator.

### 2. Access the Language Toggle
1. Tap the menu icon (☰) in the top-left corner
2. The drawer will open showing the "Pokédex Regional" title
3. Scroll down to find the "Idioma de la Aplicación" / "App Language" section
4. You'll see the ES/EN toggle buttons

### 3. Switch Languages
1. Tap "EN" to switch to English
2. Notice that:
   - The drawer title changes to "Regional Pokédex"
   - Menu items change to English ("My Favorites", "Who is this Pokémon?")
   - The language label updates to show "English"
3. Tap "ES" to switch back to Spanish
4. Notice everything returns to Spanish

### 4. Close and Reopen the App
1. Close the app completely (force close)
2. Reopen the app
3. The app should remember your last selected language
4. This confirms locale persistence is working

## Comprehensive Testing Checklist

### Drawer
- [ ] Title shows "Pokédex Regional" (ES) / "Regional Pokédex" (EN)
- [ ] "Mis Favoritos" / "My Favorites" button
- [ ] "¿Quién es este Pokémon?" / "Who is this Pokémon?" button with "Juego de trivia" / "Trivia game" subtitle
- [ ] "Idioma de la Aplicación" / "App Language" label
- [ ] Current language shown as "Español" / "English"
- [ ] "Configuración" / "Settings" section title
- [ ] "Generación" / "Generation" section title
- [ ] ES/EN toggle buttons work correctly

### Main Pokemon List Screen
- [ ] Search bar placeholder: "Buscar por nombre o #ID" / "Search by name or #ID"
- [ ] Generation indicator: "Mostrando: Generación X" / "Showing: Generation X"
- [ ] Pagination: "Página X de Y" / "Page X of Y"
- [ ] Empty state: "No se encontraron Pokémon" / "No Pokémon found"
- [ ] Error state shows "Reintentar" / "Retry" button
- [ ] Loading state shows "Cargando..." / "Loading..."

### Pokemon Types
Test that all 18 types display correctly in both languages:

**Spanish → English:**
- Normal → Normal
- Fuego → Fire
- Agua → Water
- Planta → Grass
- Eléctrico → Electric
- Hielo → Ice
- Lucha → Fighting
- Veneno → Poison
- Tierra → Ground
- Volador → Flying
- Psíquico → Psychic
- Bicho → Bug
- Roca → Rock
- Fantasma → Ghost
- Dragón → Dragon
- Siniestro → Dark
- Acero → Steel
- Hada → Fairy

Test types in:
- [ ] Pokemon cards in the list
- [ ] Type filter chips in the drawer
- [ ] Pokemon detail screen type badges
- [ ] Evolution chain type icons

### Favorites Screen
1. Navigate to Favorites (tap "Mis Favoritos" in drawer)
2. Check translations:
   - [ ] Title: "Mis Favoritos" / "My Favorites"
   - [ ] Count: "X Pokémon favorito(s)" / "X favorite Pokémon"
   - [ ] Loading: "Cargando..." / "Loading..."
   - [ ] Error retry button: "Reintentar" / "Retry"

3. If no favorites:
   - [ ] "¡Aún no tienes favoritos!" / "No favorites yet!"
   - [ ] Description text is translated
   - [ ] "Toca el corazón para agregar favoritos" / "Tap the heart to add favorites"

### Pokemon Detail Screen
1. Open any Pokemon detail
2. Check translations:
   - [ ] Type badges show translated names
   - [ ] Share button: If sharing fails, shows error in current language
   - [ ] Copy to clipboard: Shows message in current language
   - [ ] Error state shows "Reintentar" / "Retry" button
   - [ ] Evolution tab: "No hay datos de evolución disponibles" / "No evolution data available" (if no evolution)

### Language Persistence
- [ ] Select Spanish → Close app → Reopen → App is in Spanish
- [ ] Select English → Close app → Reopen → App is in English
- [ ] Switch languages multiple times → Language always persists correctly

### Real-time Updates
When switching languages, verify that:
- [ ] All visible text updates immediately (no need to restart)
- [ ] Drawer text updates
- [ ] Main screen text updates
- [ ] If detail screen is open, close and reopen to see updates

## Known Behavior

### What Updates Immediately
- All text in the drawer
- Main screen after closing drawer
- Search placeholder
- Pagination controls

### What Requires Screen Refresh
- Pokemon detail screen (close and reopen Pokemon)
- This is normal Flutter behavior for screens already in navigation stack

## Accessibility Testing

### Screen Reader Support
1. Enable screen reader (TalkBack on Android / VoiceOver on iOS)
2. Navigate through the app
3. Verify all text is read in the correct language
4. Verify Pokemon types are read correctly in both languages

### Font Scaling
1. Change device font size to large
2. Verify all translated text displays properly
3. Check that nothing is cut off or overlapping

## Performance Testing

The language toggle should be:
- [ ] Instantaneous (no lag when switching)
- [ ] Smooth (no UI freezes)
- [ ] Memory efficient (no memory leaks after multiple switches)

## Edge Cases to Test

1. **First Launch:**
   - [ ] App should use system language if available (ES or EN)
   - [ ] If system language is not ES/EN, should default to ES

2. **Rapid Switching:**
   - [ ] Tap ES/EN repeatedly and quickly
   - [ ] App should handle this gracefully without crashes

3. **Offline:**
   - [ ] Disconnect internet
   - [ ] Switch languages
   - [ ] Should work normally (translations are bundled)

## Reporting Issues

If you find any issues:

1. **Untranslated Text:**
   - Note the screen and exact text
   - Note which language shows the issue
   - Take a screenshot

2. **Wrong Translation:**
   - Note the current translation
   - Suggest the correct translation
   - Provide context (Pokemon name, type, etc.)

3. **Technical Issues:**
   - Note steps to reproduce
   - Include error messages if any
   - Note device/emulator and OS version

## Screenshots for Comparison

### Drawer - Spanish
- Title: "Pokédex Regional"
- Favorites: "Mis Favoritos"
- Game: "¿Quién es este Pokémon?" / "Juego de trivia"
- Language: "Idioma de la Aplicación"
- Sections: "Configuración" / "Generación"

### Drawer - English
- Title: "Regional Pokédex"
- Favorites: "My Favorites"
- Game: "Who is this Pokémon?" / "Trivia game"
- Language: "App Language"
- Sections: "Settings" / "Generation"

### Pokemon Types Example
Spanish: Fuego, Agua, Planta, Eléctrico
English: Fire, Water, Grass, Electric

## Success Criteria

The implementation is successful when:
- ✅ All text in the app is translatable
- ✅ No hardcoded Spanish or English text remains
- ✅ Language selection persists across app restarts
- ✅ Switching languages updates all visible text
- ✅ Pokemon types are properly translated
- ✅ All 18 Pokemon types work correctly
- ✅ Error messages appear in the correct language
- ✅ Empty states appear in the correct language
- ✅ Accessibility features work in both languages
