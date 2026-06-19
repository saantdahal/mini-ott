enum NotificationType {
  newContent('new_content', 'New Content'),
  voting('voting', 'Voting'),
  payment('payment', 'Payment'),
  promotion('promotion', 'Promotion'),
  system('system', 'System'),
  other('other', 'Other');

  final String value;
  final String displayName;

  const NotificationType(this.value, this.displayName);

  factory NotificationType.fromValue(String? value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.other,
    );
  }
}
