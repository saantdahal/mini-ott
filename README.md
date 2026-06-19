# Mini OTT Platform

A comprehensive Over-The-Top (OTT) streaming platform with content management, interactive voting, monetization, and secure access controls. This mono-repository contains three core components: an admin dashboard, mobile application, and backend server.

---

## Project Overview

The Mini OTT Platform is an end-to-end entertainment ecosystem developed for **Bytecode Developers Pvt. Ltd.** It providess:

- **Admin Dashboard:** Professional administrative console for managing video content, monetization (coin system), real-time interactive voting, user analytics, and anti-piracy measures
- **Mobile Application:** Feature-rich Flutter app for streaming content with clean architecture and multi-flavor support
- **Backend Server:** Node.js server handling core business logic, authentication, and data management

### Core Features

- **Video Management (CMS):** Upload, organize, manage episodes/seasons, and configure "First 10 Free" logic
- **Monetization Engine:** Coin system, user balance tracking, and voucher generation
- **Interactive Voting:** Real-time polls and contest result controls for live streaming
- **User Analytics:** Track user growth, watch-time, and financial transactions
- **Security & Anti-Piracy:** Anti-screen recording controls and secure data protection
- **Multi-Flavor Support:** Separate development and production environments on mobile

---

## Project Structure

```
mini-ott-platform/
├── admin/                    # Next.js Admin Dashboard
│   ├── src/
│   │   ├── app/             # Next.js App Router
│   │   │   ├── (auth)/      # Authentication pages
│   │   │   ├── (dashboard)/ # Protected admin routes
│   │   │   ├── globals.css  # Global styles
│   │   │   └── api/         # API proxy routes
│   │   └── components/      # Reusable React components
│   ├── public/              # Static assets
│   ├── package.json         # Dependencies
│   ├── next.config.mjs      # Next.js configuration
│   └── README.md            # Admin-specific documentation
│
├── mobile/                  # Flutter Mobile Application
│   ├── lib/
│   │   ├── app/             # App configuration & theme
│   │   │   ├── flavor/      # Flavor configuration (dev/prod)
│   │   │   ├── routes/      # Navigation & routing
│   │   │   └── theme/       # Color palette & themes
│   │   ├── core/            # Core infrastructure
│   │   │   ├── di/          # Dependency injection (GetIt)
│   │   │   ├── error/       # Exception & error handling
│   │   │   ├── network/     # API client & interceptors
│   │   │   ├── services/    # Token, storage, logging services
│   │   │   └── utils/       # Validators, formatters, extensions
│   │   ├── features/        # Feature modules (Auth, Splash, Common)
│   │   └── shared/          # Shared models & widgets
│   ├── android/             # Android native configuration
│   ├── ios/                 # iOS native configuration
│   ├── pubspec.yaml         # Flutter dependencies
│   └── README.md            # Mobile-specific documentation
│
├── server/                  # Node.js Express Backend
│   ├── routes/              # API endpoints
│   ├── views/               # View templates
│   ├── public/              # Static files
│   ├── bin/                 # Server startup script
│   ├── app.js               # Express application setup
│   ├── package.json         # Dependencies
│   └── README.md            # Server-specific documentation
│
└── README.md                # This file - Overall project documentation
```

---

## Tech Stack

### Admin Dashboard

- **Framework:** [Next.js](https://nextjs.org/) (App Router)
- **Styling:** [Tailwind CSS](https://tailwindcss.com/)
- **Data Fetching:** TanStack Query / SWR
- **Authentication:** NextAuth.js (Role-based Access Control)
- **UI Icons:** [Lucide React](https://lucide.dev/)
- **Rendering:** Hybrid (SSR for secure logs, Client-side for interactive charts)

### Mobile Application

- **Framework:** [Flutter](https://flutter.dev/)
- **Architecture:** Clean Architecture with dependency injection
- **State Management:** [Riverpod](https://riverpod.dev/)
- **HTTP Client:** [Retrofit](https://pub.dev/packages/retrofit) & Dio
- **Dependency Injection:** [GetIt](https://pub.dev/packages/get_it)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
- **Local Storage:** SharedPreferences
- **Build Configuration:** Multiple flavors (dev/prod)

### Backend Server

- **Runtime:** Node.js
- **Framework:** Express.js
- **View Engine:** Jade/Pug
- **Styling:** CSS

---

## Getting Started

### Prerequisites

- **Admin & Server:** Node.js 16+ and npm
- **Mobile:** Flutter SDK, Android Studio/Xcode, and Dart

### Installation

#### 1. Admin Dashboard

```bash
cd admin
npm install
npm run dev
```

Runs on `http://localhost:3000` with hot-reload support.

#### 2. Mobile Application

```bash
cd mobile
flutter pub get
flutter run -t lib/main_dev.dart          # For development
flutter run -t lib/main_prod.dart         # For production
```

#### 3. Backend Server

```bash
cd server
npm install
npm start
```

---

## Admin Dashboard Features

### Scope & Capabilities

- **Video Management (CMS):** Upload videos, manage episodes/seasons, set "First 10 Free" logic
- **Monetization Engine:** Manage Coin system, track user balances, generate vouchers
- **Interactive Voting:** Real-time polls and contest result controls
- **User Analytics:** Dashboard for tracking user growth, watch-time, and transactions
- **Security Controls:** Anti-screen recording, secure SSR activity logs
- **Protected Routes:** Role-based access control with authentication

### Key Pages

- Content Management (Video/Episode/Season)
- Voting & Live Session Controls
- Finance & Coin System
- User Activity Logs
- Admin Dashboard Overview

---

## Mobile Application Features

### Architecture Highlights

- **Clean Architecture:** Separation of concerns with Presentation, Domain, and Data layers
- **Dependency Injection:** GetIt configuration for service orchestration
- **Multi-Flavor Support:** Dev and prod builds with environment-specific configuration
- **Advanced State Management:** Riverpod providers for reactive UI updates
- **Error Handling:** Custom exception hierarchy and error mapping

### Key Features

- Authentication & Session Management
- Splash screen with flavor-specific branding
- Centralized logging and error tracking
- Network status monitoring
- Secure token storage and management
- Form validation and input formatting
- Theme configuration and centralized color palette

---

## Security & Best Practices

- **Admin:** NextAuth.js role-based access control, server-side rendering for sensitive data
- **Mobile:** Secure token storage, authentication interceptors, session validation
- **Backend:** Express middleware for authentication and data protection
- **Anti-Piracy:** Screen recording prevention and secure playback controls

---

## Documentation

Each component has its own detailed README:

- [Admin Dashboard Documentation](admin/README.md)
- [Mobile Application Documentation](mobile/README.md)

Additional resources:

- [Admin Agents](admin/AGENTS.md) - AI agent tooling for admin development
- [Claude Notes](admin/CLAUDE.md) - Development insights and best practices

---

## Development Workflow

### Branch Strategy

Use feature branches for development:

```bash
git checkout -b feature/your-feature-name
git push -u origin feature/your-feature-name
```

### Code Quality

- **Admin:** Next.js ESLint configuration
- **Mobile:** Dart analyzer and format checker
- **Server:** Node.js conventions

---

## Deployment

### Admin Dashboard

```bash
cd admin
npm run build
npm run start
```

### Mobile Application

```bash
cd mobile
# Android
flutter build apk --flavor=prod -t lib/main_prod.dart

# iOS
flutter build ios --flavor=prod -t lib/main_prod.dart
```

### Server

```bash
cd server
npm install --production
npm start
```

---

## Support & Contribution

For questions or issues:

1. Check the component-specific README files
2. Review code documentation in `AGENTS.md` and `CLAUDE.md`
3. Consult API documentation in relevant route files

---

## License

This project is developed for **Bytecode Developers Pvt. Ltd. By Himalayan CodeWorks**

---

**Last Updated:** March 2025
