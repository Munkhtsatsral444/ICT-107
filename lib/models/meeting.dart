class Meeting {
  final int id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool enabled;

  const Meeting({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.enabled = true,
  });

  bool isActiveAt(DateTime currentTime) {
    return enabled &&
        !currentTime.isBefore(startTime) &&
        currentTime.isBefore(endTime);
  }

  Meeting copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    bool? enabled,
  }) {
    return Meeting(
      id: id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'enabled': enabled,
    };
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? 'Meeting',
      startTime: DateTime.parse(
        json['startTime'] as String,
      ),
      endTime: DateTime.parse(
        json['endTime'] as String,
      ),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
