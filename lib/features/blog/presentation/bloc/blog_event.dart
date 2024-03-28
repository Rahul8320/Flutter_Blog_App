part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

final class BlogUploadEvent extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final List<String> topics;
  final File image;

  BlogUploadEvent({
    required this.posterId,
    required this.title,
    required this.content,
    required this.topics,
    required this.image,
  });
}