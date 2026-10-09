
K Mart Flutter — Module 05B: Home data integration

This patch connects the Home Page data layer to the existing Supabase schema.

Added:
- CategoryModel
- ProductModel
- ProductRepository
- Riverpod home category/product providers
- Placeholder CategoriesScreen

Supabase tables used:
- categories
- products
- inventory (only when a store_id is supplied)

No database/schema changes are made.

Install:
Copy the lib/ files into:
C:\Users\Admin\Desktop\kmart_flutter_ui\kmart_flutter_ui\lib

Then run:
flutter pub get
flutter analyze lib
flutter run -d chrome

Important:
The home UI should use the providers rather than hardcoded catalogue data. If the current HomeScreen still contains its static demo lists, replace those sections using:
ref.watch(homeCategoriesProvider)
ref.watch(homeProductsProvider)

The current provider does not require a store selection, so products can load before Module 03's selected store is wired into the home provider. Store-specific inventory is only queried after a store ID is supplied.
