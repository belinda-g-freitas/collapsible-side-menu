class Utils {
  static bool pathStartsWith(List<int> full, List<int> path) {
    if (path.length != full.length) return false;
    for (int i = 0; i < path.length; i++) {
      if (path[i] != full[i]) return false;
    }
    return true;
  }
}
