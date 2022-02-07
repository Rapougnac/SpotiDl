void main(List<String> args) {
  print(convertStringTimeToSeconds('01:15'));
}

int convertStringTimeToSeconds(String time) {
  final timeSplit = time.split(':');
  final seconds = int.parse(timeSplit[0]) * 60 + int.parse(timeSplit[1]);
  return seconds;
}