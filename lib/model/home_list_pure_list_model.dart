class HomePureListConstructModel {
  HomePureListConstructModel(
      {this.list, this.banner, this.type, this.nav, this.tips});

  String? api;
  List<dynamic>? list;
  List<dynamic>? banner;
  List<dynamic>? nav;
  List<dynamic>? tips;

  dynamic last_ix;
  int? type = 0;

  factory HomePureListConstructModel.fromJson(
    Map<String, dynamic> json,
  ) {
    int type = 0;
    return HomePureListConstructModel(
        list: json["list"] != null
            ? List<dynamic>.from(json["list"].map((x) => x))
            : [],
        banner: json["banner"] != null
            ? List<dynamic>.from(json["banner"].map((x) => x))
            : [],
        nav: json["nav"] != null
            ? List<dynamic>.from(json["nav"].map((x) => x))
            : [],
        tips: json["tips"] != null
            ? List<dynamic>.from(json["tips"].map((x) => x))
            : [],
        type: type);
  }

  Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from((list ?? []).map((x) => x)),
        "banner": List<dynamic>.from((banner ?? []).map((x) => x)),
        "nav": List<dynamic>.from((nav ?? []).map((x) => x)),
        "tips": List<dynamic>.from((tips ?? []).map((x) => x)),
      };
}
