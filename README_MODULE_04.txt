K Mart Flutter — Module 04 UI Patch

This patch recreates the Header / Navigation from the uploaded K Mart website source.

Copy these files into:
C:\Users\Admin\Desktop\kmart_flutter_ui\kmart_flutter_ui

Files:
- lib/core/theme/app_colors.dart
- lib/core/widgets/header/kmart_header.dart
- lib/screens/home/home_screen.dart
- assets/images/logo.png

Make sure pubspec.yaml contains:
  flutter:
    assets:
      - .env
      - assets/images/

Then run:
flutter pub get
flutter analyze lib
flutter run -d chrome

The header callbacks are intentionally placeholders for later modules:
Location = Module 03
Categories = Module 06
Search = Module 07
Cart = Module 10
Orders = Module 17
Account = Module 18
