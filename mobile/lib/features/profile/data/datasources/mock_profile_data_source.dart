import '../../domain/entities/user_profile.dart';

/// Mock data for UI development and testing
/// Remove or disable in production
class MockUserProfile {
  static UserProfile get mockProfile => UserProfile(
    id: 'user-123-abc-def',
    email: 'sakarch.dev@gmail.com',
    name: 'Sakarc Chaulagain',
    phone: '+977-9861234567',
    avatarUrl:
        'https://api.dicebear.com/7.x/avataaars/svg?seed=sakarch&scale=80',
    gender: 'Male',
    dateOfBirth: '1995-06-15',
    country: 'Nepal',
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
    isEmailVerified: true,
    status: 'active',
  );

  static UserProfile get fallbackProfile => UserProfile(
    id: 'guest-123',
    email: 'demo@pulse.local',
    name: 'Demo User',
    phone: '+977-9800000000',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=demo&scale=80',
    gender: 'Male',
    dateOfBirth: '2000-01-01',
    country: 'Nepal',
    createdAt: DateTime.now(),
    isEmailVerified: false,
    status: 'active',
  );

  /// Get mock profile based on environment (development/production)
  /// Set [useMockData] to true to force mock data
  static UserProfile getMockProfile({bool useMockData = false}) {
    if (useMockData) {
      return mockProfile;
    }
    // In production, fall back to minimal user
    return fallbackProfile;
  }
}
