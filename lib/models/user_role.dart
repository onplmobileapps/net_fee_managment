enum UserRole {
  admin,
  wasooli;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.wasooli:
        return 'Collection Agent';
    }
  }

  static UserRole fromString(String roleStr) {
    if (roleStr.toLowerCase() == 'admin') {
      return UserRole.admin;
    }
    return UserRole.wasooli;
  }
}
