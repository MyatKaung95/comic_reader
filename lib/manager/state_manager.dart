import 'package:comic_reader/model/chapter.dart';
import 'package:comic_reader/model/comic.dart';
import 'package:flutter_riverpod/all.dart';

final comicSelected = StateProvider((ref) => Comic());
final chapterSelected = StateProvider((ref) => Chapter());
