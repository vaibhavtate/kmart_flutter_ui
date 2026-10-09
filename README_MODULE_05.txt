
K Mart Flutter — Module 05: Home Page

This patch replaces the temporary home screen with a mobile-first K Mart home page based on the existing K Mart website source.

Sections:
1. Hero carousel
2. Nearby store offers
3. Free delivery banner
4. Today's top deals
5. Shop by category
6. Popular products
7. Trust/benefit strip

Important:
- This first UI pass uses the same content/images as the existing website for visual parity.
- Product/category data will be connected to the existing Supabase repositories/providers after the UI is approved.
- Cart buttons are intentionally placeholders until Module 10.
- Navigation callbacks remain placeholders until the corresponding modules are completed.

Install:
Copy lib/screens/home/home_screen.dart into:
C:\Users\Admin\Desktop\kmart_flutter_ui\kmart_flutter_ui\lib\screens\home\home_screen.dart

Then run:
flutter pub get
flutter analyze lib
flutter run -d chrome
