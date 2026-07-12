import '../models/opportunity.dart';

/// Returns 0–100: percentage of the opportunity's required skills the student
/// has. Returns null when either side has no skills — callers treat null as
/// "score unavailable" and hide the badge entirely.
int? computeMatchScore(List<String> studentSkills, Opportunity opportunity) {
  if (studentSkills.isEmpty || opportunity.requiredSkills.isEmpty) return null;
  final have = studentSkills.map((s) => s.toLowerCase()).toSet();
  final matched = opportunity.requiredSkills
      .where((s) => have.contains(s.toLowerCase()))
      .length;
  return ((matched / opportunity.requiredSkills.length) * 100).round();
}
