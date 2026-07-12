import 'package:hatch/models/app_user.dart';
import 'package:hatch/models/opportunity.dart';

/// Pure skill-match function used by tests and UI helpers.
/// Returns 0–100: percentage of [required] skills present in [have].
/// Returns 100 when [required] is empty (no skills needed → everyone qualifies).
int matchPercent(Set<String> have, List<String> required) {
  if (required.isEmpty) return 100;
  final normalHave = have.map((s) => s.toLowerCase().trim()).toSet();
  final matched = required
      .where((s) => normalHave.contains(s.toLowerCase().trim()))
      .length;
  return ((matched / required.length) * 100).round();
}

// Computes how well a student fits an opportunity, from 0.0 to 1.0.

// Score is the fraction of the role's required skills the student has, a role with no required skills scores 0.
double matchScore(AppUser student, Opportunity opportunity) {
  final required = opportunity.requiredSkills
      .map((s) => s.toLowerCase().trim())
      .where((s) => s.isNotEmpty)
      .toSet();
  if (required.isEmpty) return 0;

  final have = student.skills.map((s) => s.toLowerCase().trim()).toSet();
  final overlap = required.intersection(have).length;
  return overlap / required.length;
}

/// Opportunities sorted best-match first for a given student.
List<Opportunity> rankByMatch(AppUser student, List<Opportunity> opportunities) {
  final scored = [...opportunities];
  scored.sort((a, b) =>
      matchScore(student, b).compareTo(matchScore(student, a)));
  return scored;
}