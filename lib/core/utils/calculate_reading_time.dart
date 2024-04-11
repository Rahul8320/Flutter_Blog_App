int calculateReadingTime(String content){
  const readingSpeed = 225;
  final wordCount = content.split(RegExp(r'\s+')).length;

  final readingTime = wordCount / readingSpeed;

  return readingTime.ceil();
}