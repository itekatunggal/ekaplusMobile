class MemberStatusHelper {
  static const Set<String> _processingAliases = {
    'manual_required',
    'syncing',
    'aborted',
    'partial_success',
    'processing',
    'process',
    'in_progress',
    'pending',
  };
  static const Set<String> _inReviewAliases = {
    'in_review',
    'in review',
    'review',
    'under_review',
  };

  static String normalize(String? rawStatus) {
    final status = (rawStatus ?? '').trim().toLowerCase();

    if (status == 'draft') return 'Draft';
    if (status == 'request') return 'Request';
    if (status == 'approved' || status == 'approve') return 'Approved';
    if (status == 'rejected' || status == 'reject') return 'Rejected';
    if (_inReviewAliases.contains(status) ||
        _processingAliases.contains(status)) {
      return 'In Review';
    }

    return 'In Review';
  }

  static bool isDraft(String? rawStatus) {
    return normalize(rawStatus).toLowerCase() == 'draft';
  }

  static bool isRejected(String? rawStatus) {
    return normalize(rawStatus).toLowerCase() == 'rejected';
  }

  static bool isApproved(String? rawStatus) {
    return normalize(rawStatus).toLowerCase() == 'approved';
  }

  static bool isInReview(String? rawStatus) {
    return normalize(rawStatus).toLowerCase() == 'in review';
  }

  static bool isPendingSubmission(String? rawStatus) {
    final normalized = normalize(rawStatus).toLowerCase();
    return normalized == 'request' || normalized == 'in review';
  }
}
