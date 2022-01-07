String safeFileName(String name, {String replacment = '\''}) {
  var regexPattern = r'((\<|\>)|(\:)|(\")|(\\)|(\/)|(\|)|(\?)|(\*))';
  var reg = RegExp(regexPattern);
  return name.replaceAll(reg, replacment);
}
