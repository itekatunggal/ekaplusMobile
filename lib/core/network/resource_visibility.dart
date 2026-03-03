class ResourceVisibility {
  const ResourceVisibility._();

  static bool isDisabledValue(dynamic value) {
    if (value is num) return value == 1;
    if (value is bool) return value;

    final raw = value?.toString().trim().toLowerCase() ?? '';
    return raw == '1' || raw == 'true' || raw == 'disabled';
  }

  static bool isVisibleRecord(
    Map<String, dynamic> row, {
    String disabledKey = 'disabled',
    String statusKey = 'status',
  }) {
    final disabled = isDisabledValue(row[disabledKey]);
    final statusDisabled = isDisabledValue(row[statusKey]);
    return !disabled && !statusDisabled;
  }

  static List<Map<String, dynamic>> filterVisibleRows(
    List<dynamic> rows, {
    String disabledKey = 'disabled',
    String statusKey = 'status',
  }) {
    return rows.whereType<Map<String, dynamic>>().where((row) {
      return isVisibleRecord(
        row,
        disabledKey: disabledKey,
        statusKey: statusKey,
      );
    }).toList();
  }
}
