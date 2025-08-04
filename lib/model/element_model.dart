class ElementModel {
  ElementModel({
    this.id,
    this.constructId,
    this.type,
    this.contentType,
    this.title,
    this.moreButton,
    this.morePageShowType,
    this.maxNum,
    this.showField,
    this.changeButton,
    this.sort,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.value,
  });

  int? id;
  int? constructId;
  int? type;
  int? contentType;
  String? title;
  int? moreButton;
  int? morePageShowType;
  int? maxNum;
  String? showField;
  int? changeButton;
  int? sort;
  int? status;
  String? createdAt;
  String? updatedAt;
  List? value;

  factory ElementModel.fromJson(Map<String?, dynamic> json) {
    return ElementModel(
      id: json["id"] ?? 0,
      constructId: json["construct_id"] ?? 0,
      type: json["type"] ?? 0,
      contentType: json["content_type"] ?? 0,
      title: json["title"] ?? "",
      moreButton: json["more_button"] ?? 0,
      morePageShowType: json["more_page_show_type"] ?? 0,
      maxNum: json["max_num"] ?? 0,
      showField: json["show_field"] ?? "",
      changeButton: json["change_button"] ?? 0,
      sort: json["sort"] ?? 0,
      status: json["status"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      value: json["value"] == null ? [] : List.from(json["value"]),
    );
  }

  Map<String?, dynamic> toJson() => {
        "id": id,
        "construct_id": constructId,
        "type": type,
        "content_type": contentType,
        "title": title,
        "more_button": moreButton,
        "more_page_show_type": morePageShowType,
        "max_num": maxNum,
        "show_field": showField,
        "change_button": changeButton,
        "sort": sort,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "value": value?.map((e) => e),
      };
}

class LinkModel {
  LinkModel({
    this.id,
    this.relatedId,
    this.elementId,
    this.linkUrl,
    this.resourceUrl,
    this.redirectType,
    this.name,
    this.desc,
    this.sort,
    this.createdAt,
    this.updatedAt,
    this.api,
    this.params,
    this.uiType,
  });

  int? id;
  dynamic relatedId;
  int? elementId;
  String? linkUrl;
  String? resourceUrl;
  int? redirectType;
  String? name;
  String? desc;
  int? sort;
  String? createdAt;
  String? updatedAt;
  String? api;
  Map? params;
  int? uiType;

  factory LinkModel.fromJson(Map<String?, dynamic> json) => LinkModel(
        id: json["id"] ?? 0,
        relatedId: json["related_id"] ?? 0,
        elementId: json["element_id"] ?? 0,
        linkUrl: json["link_url"] ?? "",
        resourceUrl: json["resource_url"] ?? "",
        redirectType: json["redirect_type"] ?? 0,
        name: json["name"] ?? "",
        desc: json["desc"] ?? "",
        sort: json["sort"] ?? 0,
        createdAt: json["created_at"] ?? "",
        updatedAt: json["updated_at"] ?? "",
        api: json["api"] ?? "",
        params: json["params"] == null ? {} : Map.from(json["params"]),
        uiType: json["ui_type"] ?? 0,
      );

  Map<String?, dynamic> toJson() => {
        "id": id,
        "related_id": relatedId,
        "element_id": elementId,
        "link_url": linkUrl,
        "resource_url": resourceUrl,
        "redirect_type": redirectType,
        "name": name,
        "desc": desc,
        "sort": sort,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "api": api,
        "params": params,
        "ui_type": uiType,
      };

  int? elementType() {
//     const TYPE_CARTOON_TOPLIST = 1;
// const TYPE_MH_TOPLIST = 2;
// const TYPE_MV_HORIZONTAL = 3;
// const TYPE_MV_VERTICAL = 4;
// const TYPE_CARTOON_HORIZONTAL = 5;
// const TYPE_CARTOON_VERTICAL = 6;
// const TYPE_BOOK = 7;
// const TYPE_BOOK_VERTICAL = 8;
// const TYPE_TOPIC = 9;
// const TYPE_PIC = 10;

    int? type = 0;
    switch (uiType) {
      case 3: // "视频列表-横屏"
        type = 14;
        break;
      case 4: // "视频列表-竖屏"
        type = 17;
        break;
      case 5: // "动漫列表-横屏"
        type = 14;
        break;
      case 6: // "动漫列表-竖屏"
        type = 17;
        break;
      case 7: // "漫画列表" 横屏
        // type = 2; //漫画都是竖屏封面
        // type = 8;
        type = 9; // 漫画列表改为3列显示
        break;
      case 8: // "漫画列表" 竖屏
        // type = 8;
        type = 9;
        break;
      case 9: // 合集列表
        type = 2;
        break;
      case 10: // 图片列表
        type = 11;
        break;
      default:
    }
    return type;
  }
}
