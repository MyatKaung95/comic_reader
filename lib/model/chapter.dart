class Chapter {
  List<String> links;
  String name;

  Chapter({this.links, this.name});

  Chapter.fromJson(Map<String, dynamic> json) {
    name = json['Name'];

    if (json['Links'] != null) {
      links = json['Links'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    if (this.links != null) {
      data['Links'] = this.links;
    }

    return data;
  }
}
