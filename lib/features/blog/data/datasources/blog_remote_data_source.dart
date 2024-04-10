import 'dart:io';

import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class IBlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage({required File image, required String blogId});
  Future<List<BlogModel>> getAllBlogs();
}

class BlogRemoteDataSource implements IBlogRemoteDataSource {
  static const String _blogTableName = "blogs";
  static const String _blogImageStorageName = "blog_images";

  SupabaseClient supabaseClient;
  BlogRemoteDataSource(this.supabaseClient);

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      final blogData = await supabaseClient
          .from(_blogTableName)
          .insert(blog.toJson())
          .select();

      return BlogModel.fromJson(blogData.first);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage({
    required File image,
    required String blogId,
  }) async {
    try {
      await supabaseClient.storage
          .from(_blogImageStorageName)
          .upload(blogId, image);

      return supabaseClient.storage
          .from(_blogImageStorageName)
          .getPublicUrl(blogId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final blogs = await supabaseClient.from(_blogTableName).select('*, '
          'profiles (name)');
      return blogs
          .map(
            (blog) => BlogModel.fromJson(blog).copyWith(
              posterName: blog['profiles']['name'],
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
