class QuerySnapshot{
  //文档快照数组
  List<dynamic> docs;
  // 定义文档数量的属性
  int get size => docs.length;

  // 定义是否为空的属性
  bool get empty => docs.isEmpty;

  //获取时间
  DateTime readTime;


  QuerySnapshot({required this.docs,required this.readTime});

}