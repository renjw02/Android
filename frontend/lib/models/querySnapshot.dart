import 'DocumentSnapshot.dart';
//查询快照
//QuerySnapshot是一个类，它表示一个查询的结果集。它包含了一个或多个文档快照，每个文档快照都是一个DocumentSnapshot对象，它包含了一个文档的数据和元数据。你可以使用docs属性来获取一个文档快照的数组，然后使用data()方法来获取每个文档快照的数据。
// 你也可以使用empty、size和readTime属性来获取QuerySnapshot的其他信息，比如是否为空、文档数量和获取时间。


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