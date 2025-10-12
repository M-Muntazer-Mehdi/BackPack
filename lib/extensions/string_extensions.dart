extension StringExtension on String {
  String capitalizeText() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
