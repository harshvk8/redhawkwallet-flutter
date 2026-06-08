class UniversityEmailValidator {
  static const List<String> _knownDomains = ['.edu', '.ac.uk', '.edu.au'];

  static bool isUniversityEmail(String email) {
    final domain = email.split('@').last.toLowerCase();
    return _knownDomains.any((suffix) => domain.endsWith(suffix));
  }
}
