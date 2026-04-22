/// User model mapped from /api/auth/me and /api/auth/login responses
class User {
  final String customerId;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? bio;
  final bool isEmailVerified;
  final bool isMobileVerified;
  final bool isActive;
  final String? createdAt;
  final String loyaltyTier;
  final double walletBalance;

  User({
    required this.customerId,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.bio,
    this.isEmailVerified = false,
    this.isMobileVerified = false,
    this.isActive = true,
    this.createdAt,
    this.loyaltyTier = 'Bronze',
    this.walletBalance = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      customerId: json['customer_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      phone: json['phone'],
      bio: json['bio'],
      isEmailVerified: json['is_email_verified'] ?? false,
      isMobileVerified: json['is_mobile_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
      loyaltyTier: json['loyalty_tier'] ?? 'Bronze',
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
    'full_name': fullName,
    'email': email,
    'role': role,
    'phone': phone,
    'bio': bio,
    'is_email_verified': isEmailVerified,
    'is_mobile_verified': isMobileVerified,
    'is_active': isActive,
    'created_at': createdAt,
    'loyalty_tier': loyaltyTier,
    'wallet_balance': walletBalance,
  };
}
