# FRD Fashion Store – Flutter Mobile App

A customer-facing fashion e-commerce mobile application built with **Flutter** for the frontend and designed for **Firebase** integration as the backend.

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, theme, routes
├── auth_service.dart                  # Authentication logic
├── firestore_service.dart             # Firestore CRUD operations
│
├── consts/
│   ├── consts.dart                    # Barrel export for all consts
│   ├── colors.dart                    # App color palette
│   ├── images.dart                    # Asset image paths
│   ├── strings.dart                   # All string constants
│   └── styles.dart                    # Font family constants
│
├── models/
│   ├── product_model.dart             # Product & CartItem data models
│   ├── app_data.dart                  # Static product/category seed data
│   └── app_state.dart                 # Provider-based state (cart, wishlist, search)
│
├── views/
│   ├── splash_screen/
│   │   └── splash_screen.dart         # Launch screen
│   │
│   ├── auth_screen/
│   │   ├── login_screen.dart          # Login UI
│   │   └── signup_screen.dart         # Registration UI
│   │
│   ├── home_screen/
│   │   ├── home.dart                  # Bottom navigation shell
│   │   ├── home_screen.dart           # Main home feed (slider, categories, products)
│   │   ├── todays_deal_screen.dart    # Today's deals listing
│   │   ├── flash_sale_screen.dart     # Flash sale products
│   │   └── top_brands_screen.dart     # Top brands section
│   │
│   ├── category_screen/
│   │   ├── category_screen.dart       # All categories grid
│   │   └── categories/
│   │       ├── women_dress_screen.dart
│   │       ├── girls_dress_screen.dart
│   │       ├── girls_watches_screen.dart
│   │       ├── boys_glasses_screen.dart
│   │       ├── kids_dresses_screen.dart
│   │       └── t_shirts_screen.dart
│   │
│   ├── product_screen/
│   │   └── product_detail_screen.dart # Product detail with add-to-cart
│   │
│   ├── cart_screen/
│   │   └── cart_screen.dart           # Cart with qty management & checkout
│   │
│   ├── checkout_screen/
│   │   ├── address_screen.dart        # Delivery address management
│   │   └── payment_method_screen.dart # Payment methods UI
│   │
│   ├── order_screen/
│   │   └── delivery_tracking_screen.dart  # Order tracking
│   │
│   └── profile_screen/
│       └── profile_screen.dart        # User profile, wishlist, menu
│
└── widgets/
    └── app_widgets.dart               # Shared reusable widgets
```

---

## Features Implemented

| Feature | Status |
|---|---|
| Splash Screen | ✅ |
| Login / Registration UI | ✅ |
| Home (Slider, Categories, Featured, Flash Sale) | ✅ |
| Product Listing by Category | ✅ |
| Product Detail Screen | ✅ |
| Add to Cart / Remove / Update Qty | ✅ |
| Cart Total Calculation | ✅ |
| Wishlist (toggle & view) | ✅ |
| Search | ✅ |
| Address Management | ✅ |
| Payment Methods UI | ✅ |
| Delivery Tracking Screen | ✅ |
| User Profile Screen | ✅ |
| Firebase-ready services (auth_service, firestore_service) | ✅ |

---

## Tech Stack

- **Flutter** (Dart) – cross-platform mobile UI framework
- **Provider** – state management (cart, wishlist, search)
- **Firebase** (planned) – Authentication + Firestore

---

## Firebase Setup Instructions

1. **Create Firebase Project**
   - Go to [https://console.firebase.google.com](https://console.firebase.google.com)
   - Create a new project named `FRD-FashionStore`

2. **Add Android App**
   - Package name: `com.example.frd_fashion_store_app`
   - Download `google-services.json`
   - Place it in `android/app/`

3. **Enable Authentication**
   - Firebase Console → Authentication → Sign-in methods
   - Enable **Email/Password**

4. **Enable Firestore**
   - Firebase Console → Firestore Database → Create database
   - Start in **test mode** for development

5. **Add Firebase dependencies to `pubspec.yaml`**

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
```

6. **Initialize Firebase in `main.dart`**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(/* ... */);
}
```

7. **Pre-load Products into Firestore**

Each product document should follow this schema:

```json
{
  "name": "Stylish Women Dress",
  "image": "https://your-image-url.com/p1.jpg",
  "price": "LKR 7500",
  "oldPrice": "LKR 10500",
  "category": "Women Dress",
  "rating": 4.5,
  "reviews": 120,
  "description": "Beautiful stylish women dress..."
}
```

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected device / emulator
flutter run

# Build APK
flutter build apk --release
```

---

## State Management

App uses **Provider** pattern via `AppState`:

- `cartItems` – list of `CartItem` objects
- `cartTotal` – computed total in LKR
- `wishlist` – list of wishlisted `Product` objects
- `searchQuery` – current search string
- `selectedCategory` – active category filter

---

## Categories

- Women Dress
- Girls Dress
- Girls Watches
- Boys Glasses
- Kids Dresses
- T-Shirts

---

## Module

CIT211 – Mobile Software Development  
Faculty of Computing and IT  
Bachelor of Science in Applied Information Technology
