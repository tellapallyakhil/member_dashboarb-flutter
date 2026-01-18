# 📱 Member Dashboard App

A modern, feature-rich social sharing Flutter application with a stunning premium UI design. Share posts, rate content, comment, and connect with other members!

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features

### 🔐 Authentication
- **User Registration** - Create new accounts with email/password
- **User Login** - Secure login with Firebase Authentication
- **Logout** - Safe logout from profile page

### 📝 Posts
- **Create Posts** - Share text content with the community
- **View Posts** - Beautiful card-based post display
- **Delete Posts** - Remove your own posts
- **Copy Text** - Long press to copy post content
- **Link Detection** - URLs are automatically detected and styled

### ⭐ Rating System
- **1-5 Star Rating** - Rate any post from 1 to 5 stars
- **Average Rating** - See the average rating on each post
- **Rating Count** - View total number of ratings
- **User-specific** - Your rating is saved and displayed

### 💬 Comments
- **Add Comments** - Comment on any post
- **Delete Comments** - Remove your own comments
- **Real-time Updates** - Comments sync instantly
- **Comment Count** - See comment count on posts

### 👤 User Profiles
- **Profile Page** - View any user's profile
- **User Stats** - Posts count, average rating, total reviews
- **User's Posts** - See all posts by a specific user
- **Manage Posts** - Delete your own posts from profile

### 🔖 Bookmarks
- **Save Posts** - Bookmark posts for later
- **Easy Access** - Tap bookmark icon on any post

### 🔗 Enhanced Links
- **Auto-detection** - URLs are automatically recognized
- **Styled Chips** - Links appear as beautiful styled chips
- **Link Options** - Tap for multiple options:
  - Open in Browser
  - Open in Incognito (Android)
  - Copy Link
  - Share Link
- **Smart Icons** - Platform-specific icons (YouTube, GitHub, etc.)

## 🎨 Premium UI Design

### Design Features
- 🌙 **Dark Theme** - Modern dark color palette
- 💜 **Gradient Accents** - Purple to pink gradients throughout
- ✨ **Glassmorphism** - Frosted glass card effects
- 🎭 **Animations** - Smooth transitions and micro-interactions
- 🌟 **Floating Particles** - Animated background effects
- 📱 **Responsive** - Works on mobile, tablet, and desktop

### Color Palette
| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#6C63FF` | Main accent color |
| Secondary | `#FF6584` | Gradient end, highlights |
| Accent | `#00D4FF` | Links, special elements |
| Background | `#0F0E17` | App background |
| Surface | `#1A1825` | Cards, surfaces |

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
- **State Management**: StatefulWidget with StreamBuilder
- **Packages**:
  - `firebase_core`
  - `firebase_auth`
  - `cloud_firestore`
  - `url_launcher`
  - `flutter_linkify`

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart        # Theme configuration
├── widgets/
│   ├── animated_widgets.dart # Reusable animated components
│   └── link_handler.dart     # Link handling utilities
├── screens/
│   ├── login_screen.dart     # Login page
│   ├── register_screen.dart  # Registration page
│   ├── dashboard_screen.dart # Main feed
│   ├── upload_screen.dart    # Create post
│   ├── profile_screen.dart   # User profile
│   └── comment_sheet.dart    # Comments bottom sheet
└── services/
    ├── auth_service.dart     # Authentication logic
    └── firestore_service.dart# Database operations
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x or higher)
- Firebase project with Firestore and Authentication enabled
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/tellapallyakhil/member_dashboarb-flutter.git
   cd member_dashboard_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Enable Email/Password authentication
   - Enable Cloud Firestore
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)
   - Configure `firebase_options.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

The app features:
- Beautiful login screen with animated particles
- Premium gradient buttons and glass cards
- Star rating system on each post
- User profile with statistics
- Enhanced link handling with options

## 🔥 Firebase Structure

```
Firestore Database:
├── posts/
│   ├── {postId}/
│   │   ├── text: string
│   │   ├── email: string
│   │   ├── ratings/
│   │   │   └── {userEmail}/
│   │   │       └── rating: number
│   │   └── comments/
│   │       └── {commentId}/
│   │           ├── commentText: string
│   │           └── commentedBy: string
└── users/
    └── {userEmail}/
        └── bookmarks/
            └── {postId}/
                └── savedAt: timestamp
```

## 🤝 Contributing

Contributions are welcome! Feel free to:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Akhil Tellapally**
- GitHub: [@tellapallyakhil](https://github.com/tellapallyakhil)

---

⭐ **Star this repo if you found it helpful!**
