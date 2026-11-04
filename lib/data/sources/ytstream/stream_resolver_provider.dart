import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for [StreamResolver].
final streamResolverProvider = Provider<StreamResolver>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StreamResolverImpl(cacheStorage: db.cacheDao);
});
