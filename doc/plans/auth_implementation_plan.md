# Plan: Implementing Authentication (Google Sign-In)

## Overview
This plan details the implementation of the Authentication feature using **Firebase Auth** and **Google Sign-In**. The goal is to provide a robust, secure, and user-friendly sign-in experience that integrates seamlessly with the existing `AuthRepository` interface.

## 1. Prerequisites & Tech Stack Verification
*   **Firebase Auth**: Ensure `firebase_auth` is added to `pubspec.yaml`.
*   **Google Sign-In**: Ensure `google_sign_in` is added to `pubspec.yaml`.
*   **Configuration**:
    *   Verify `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are present and up-to-date.
    *   **SHA-1 Fingerprints**: Ensure Debug and Release SHA-1 keys are added to the Firebase Console for Google Sign-In to work.

## 2. Architecture & Components

### A. Domain Layer (Existing)
*   **`User` Entity**: `lib/src/features/auth/domain/entities/user.dart` (Already exists).
    *   *Action*: Review to ensure it maps correctly to Firebase User properties.
*   **`AuthRepository` Interface**: `lib/src/features/auth/domain/repositories/auth_repository.dart` (Already exists).
    *   *Action*: Update `signInWithGoogle` return type to `Future<Either<Failure, User>>` to standardize error handling (currently uses `String`).

### B. Data Layer (Implementation)
1.  **`AuthRemoteDataSource`** (Interface):
    *   Define the contract for external auth providers.
    *   Methods: `signInWithGoogle()`, `signOut()`, `authStateChanges`.
2.  **`FirebaseAuthDataSource`** (Concrete Implementation):
    *   Implements `AuthRemoteDataSource`.
    *   Uses `FirebaseAuth.instance` and `GoogleSignIn`.
    *   Handles the specific logic of opening the Google Sign-In sheet, obtaining credentials, and signing into Firebase.
    *   *Error Handling*: Catches `FirebaseAuthException` and `PlatformException`, wrapping them in domain-specific exceptions.
3.  **`AuthRepositoryImpl`**:
    *   Implements `AuthRepository`.
    *   Injects `AuthRemoteDataSource`.
    *   Maps `FirebaseUser` to Domain `User`.
    *   Handles the `Either` return types using `fpdart`.

### C. Presentation Layer (BLoC)
1.  **`AuthBloc`**:
    *   **Events**:
        *   `AuthCheckRequested`: Checks current status on app start.
        *   `AuthLoginRequested`: Triggers Google Sign-In.
        *   `AuthLogoutRequested`: Triggers Sign Out.
    *   **States**:
        *   `AuthInitial`: Unknown state.
        *   `AuthLoading`: Sign-in/out in progress.
        *   `AuthAuthenticated`: User is logged in (contains `User` object).
        *   `AuthUnauthenticated`: User is logged out.
        *   `AuthFailure`: Error occurred (contains error message).

### D. UI Components
1.  **`SignInButton`**: A reusable button widget complying with Google's branding guidelines.
2.  **`AuthWrapper`**: A widget or router guard that listens to `AuthBloc` state to redirect users (e.g., from Login Page to Dashboard).
3.  **Profile Section**: Update the Dashboard or Settings page to show the user's avatar and name, and provide a Logout button.

## 3. Implementation Flow

### Step 1: Data Layer Foundation
1.  Create `lib/src/features/auth/data/datasources/auth_remote_data_source.dart`.
2.  Create `lib/src/features/auth/data/repositories/auth_repository_impl.dart`.
3.  Implement `signInWithGoogle` logic:
    *   Trigger `GoogleSignIn.signIn()`.
    *   Get `GoogleSignInAuthentication`.
    *   Create `GoogleAuthCredential`.
    *   Call `FirebaseAuth.signInWithCredential`.

### Step 2: Dependency Injection
1.  Register `AuthRemoteDataSource` (as `FirebaseAuthDataSource`) in `injection_container.dart`.
2.  Register `AuthRepositoryImpl` in `injection_container.dart`.
3.  Register `AuthBloc` in `injection_container.dart`.

### Step 3: Business Logic (BLoC)
1.  Create `AuthBloc`, `AuthEvent`, `AuthState` in `lib/src/features/auth/presentation/bloc/`.
2.  Implement the logic to handle sign-in, sign-out, and stream listing for auth state changes.

### Step 4: UI Integration
1.  Integrate `AuthBloc` into the `App` widget (via `MultiBlocProvider`).
2.  Create/Update the Login Screen with the `SignInButton`.
3.  Update the `AppRouter` (GoRouter) to redirect based on auth state (optional, or handle via BLoC listener).

## 4. Error Handling & Edge Cases
*   **Network Errors**: Handle offline scenarios gracefully.
*   **User Cancellation**: If the user backs out of the Google Sign-In sheet, do not show an error "snack bar", just return to the unauthenticated state.
*   **Account Exists**: Handle cases where an account might already exist with different credentials (rare for Google-only, but good practice).

## 5. Verification Plan
*   **Manual Test**: Run on Emulator/Device. Click Sign-In. Verify Firebase Console shows the new user.
*   **Persistence**: Restart the app and verify the user remains logged in.
*   **Sign Out**: Verify clicking Sign Out clears the session and returns to the Login screen.
