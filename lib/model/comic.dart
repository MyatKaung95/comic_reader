import 'chapter.dart';

class Comic {
  String category, name, image;
  List<Chapter> chapters;

  Comic({this.category, this.name, this.image, this.chapters});

  Comic.fromJson(Map<String, dynamic> json) {
    category = json['Category'];
    name = json['Name'];
    image = json['Image'];

    if (json['Chapters'] != null) {
      chapters = new List<Chapter>();
      json['Chapters'].forEach((v) {
        chapters.add(new Chapter.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Category'] = this.category;
    data['Name'] = this.name;
    data['Image'] = this.image;
    if (this.chapters != null) {
      data['Chapters'] = this.chapters.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
