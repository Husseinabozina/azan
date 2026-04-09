enum HomeDisplayMode {
  standard('standard'),
  displayBoard('display_board');

  const HomeDisplayMode(this.id);

  final String id;

  static HomeDisplayMode fromId(String? raw) {
    return HomeDisplayMode.values.firstWhere(
      (mode) => mode.id == raw,
      orElse: () => HomeDisplayMode.standard,
    );
  }
}
