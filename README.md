# Collectify — Game & Comic Tracker

Flutter app dengan Firebase untuk tracking koleksi game dan komik pribadi. Aplikasi ini bertujuan untuk mencatat game yang pernah dimainkan dan komik yang sudah dibaca lalu disimpan ke firestore dari firebase. jadi user punya koleksi riwayat tentang game dan komik lalu rating dan catatan pribadi. kekurangannya adalah tiap koleksi tidak bisa dilihat oleh user lain.

## Fitur
- Google Sign In
- Tab: Games | Comics
- CRUD (tambah, edit, hapus)
- Status tracking (Playing/Reading/Completed/dll)
- Rating bintang (0–5, half-star)
- Notes/review pribadi
- Cover image via URL atau ambil dari galeri
- Filter by status
- Dark mode gamer

---

## Setup

### 1. Buat Firebase Project
1. Buka [console.firebase.google.com](https://console.firebase.google.com)
2. Create project baru
3. Enable **Authentication** → Sign-in method → **Google**
4. Enable **Firestore Database** → Production mode

### 2. FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Ini akan generate file `lib/firebase_options.dart` otomatis.

### 3. Android — Google Sign In
Di `android/app/build.gradle`, pastikan `applicationId` sudah sesuai.

Tambahkan SHA-1 fingerprint di Firebase Console:
```bash
cd android && ./gradlew signingReport
```
Copy SHA-1 → Firebase Console → Project Settings → Android app → Add fingerprint.

Download ulang `google-services.json` dan taruh di `android/app/`.

### 4. Deploy Firestore Rules & Indexes
```bash
firebase deploy --only firestore
```

### 5. Install dependencies & run
```bash
flutter pub get
flutter run
```

---

## Struktur Project
```
lib/
├── main.dart                  # Entry point + AuthGate
├── models/
│   └── collection_item.dart   # Model data
├── screens/
│   ├── login_screen.dart      # Google Sign In
│   ├── home_screen.dart       # Tab navigation
│   ├── collection_list_screen.dart  # Grid list + filter
│   └── item_detail_screen.dart      # Detail view
├── services/
│   ├── auth_service.dart      # Firebase Auth
│   └── collection_service.dart # Firestore CRUD
├── utils/
│   └── app_theme.dart         # Dark theme + constants
└── widgets/
    ├── item_card.dart         # Grid card
    └── add_edit_item_sheet.dart # Bottom sheet form
```

## Firestore Schema
Collection: `collection`
```
{
  userId: string,
  type: "game" | "comic",
  title: string,
  coverUrl: string,
  status: string,
  rating: number (0.0 - 5.0),
  notes: string,
  genre: string | null,
  createdAt: timestamp,
  updatedAt: timestamp
}
```
