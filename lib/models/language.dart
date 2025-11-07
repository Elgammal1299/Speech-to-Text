enum Language {
  english('en_US', 'English', 'EN'),
  arabic('ar_SA', 'العربية', 'AR');

  final String localeId;
  final String displayName;
  final String shortCode;

  const Language(this.localeId, this.displayName, this.shortCode);
}
