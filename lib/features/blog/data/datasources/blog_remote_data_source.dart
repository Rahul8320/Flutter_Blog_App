import 'dart:io';

import 'package:blog_app/core/constant/supabase_config.dart';
import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class IBlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage({required File image, required String blogId});
  Future<List<BlogModel>> getAllBlogs();
}

class BlogRemoteDataSource implements IBlogRemoteDataSource {
  SupabaseClient supabaseClient;
  BlogRemoteDataSource(this.supabaseClient);

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      final blogData = await supabaseClient
          .from(SupabaseConfigs.blogTableName)
          .insert(blog.toJson())
          .select();

      return BlogModel.fromJson(blogData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }  catch (e) {
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
          .from(SupabaseConfigs.imageContainerName)
          .upload(blogId, image);

      return supabaseClient.storage
          .from(SupabaseConfigs.imageContainerName)
          .getPublicUrl(blogId);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final blogs = await supabaseClient.from(SupabaseConfigs.blogTableName).select('*, '
          '${SupabaseConfigs.authTableName} (name)');
      return blogs
          .map(
            (blog) => BlogModel.fromJson(blog).copyWith(
              posterName: blog[SupabaseConfigs.authTableName]['name'],
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
