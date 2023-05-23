import 'package:flutter/material.dart';

import 'feeds_screen.dart';

class MoreTypesScreen extends StatefulWidget {
  MoreTypesScreen({Key? key}) : super(key: key);

  @override
  State<MoreTypesScreen> createState() => _MoreTypesScreenState();
}

class _MoreTypesScreenState extends State<MoreTypesScreen> {
  // List<String> _selectedFilters = [];
  List<String> _selectedCateFilters = [];
  List<String> _selectedTimeFilters = [];
  List<String> _selectedSortFilters = [];
  final List<String> _categories = [
    '已关注的发布者',
    '最近热度',
    '信息类型',
  ];

  final List<Color> _cardColors = [
    Colors.pink.shade200,
    Colors.orange.shade200,
    Colors.green.shade200,
  ];

  void _toggleFilter(String filter, List<String> selectedFilters, bool isSingle) {
    setState(() {
      if (selectedFilters.contains(filter)) {
        selectedFilters.remove(filter);
      } else {
        // 在卡片中只有一个按钮被选中
        if(isSingle){
          selectedFilters.clear();
        }
        selectedFilters.add(filter);
      }
    });
  }

  void _applyFilters() {
    Navigator.of(context).pop({
      'cateFilters': _selectedCateFilters,
      'timeFilters': _selectedTimeFilters,
      'sortFilters': _selectedSortFilters,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更多分类'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: 10),
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            _buildNarrowCard('信息类型', Colors.pink.shade200,['校园资讯', '二手交易'], _selectedCateFilters,false),
            _buildNarrowCard('发布时间', Colors.orange.shade200,['24小时内','一周内', '一月内'], _selectedTimeFilters,true),
            _buildCard('排序', Colors.green.shade200,[ '点赞量高优先', '评论量高优先'], _selectedSortFilters,true),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 50,
                width: 150,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                      '应用筛选',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowCard(String category, Color color, List<String> infoList, List<String> selectedFilters, bool isSingle) {
    // 只有一个按钮被选中的规则
    // final singleSelection = _selectedFilters.length == 1;

    return SizedBox(
      height: 100+ 50 * infoList.length.toDouble(),
      width: 1 * 190,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.all(10),
        child: Card(
          color: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // 处理卡片点击事件
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (String info in infoList)
                        _buildFilterButton(info,
                        selected: selectedFilters.contains(info),
                        onPressed: () => _toggleFilter(info, selectedFilters,isSingle),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String category, Color color, List<String> infoList, List<String> selectedFilters,bool isSingle) {
    return SizedBox(
      height: 1 * 150,
      width: 2 * 200,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Card(
          color: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {
              // 处理卡片点击事件
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (String info in infoList)
                        _buildFilterButton(info,
                          selected: selectedFilters.contains(info),
                          onPressed: () => _toggleFilter(info,selectedFilters, isSingle)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label,
      {bool selected = false, VoidCallback? onPressed}) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonColor = selected ? colorScheme.secondary : colorScheme.surface;
    final textColor =
    selected ? colorScheme.onSecondary : colorScheme.onSurface;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: buttonColor,
        onPrimary: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }
}

class FeedScreen extends StatelessWidget {
  final List<String> cateFilters;
  final List<String> timeFilters;
  final List<String> sortFilters;

  const FeedScreen({
    Key? key,
    required this.cateFilters,
    required this.timeFilters,
    required this.sortFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the selected filters to fetch and display the relevant posts
    return Scaffold(
      appBar: AppBar(
        title: Text('帖子'),
      ),
      body: Center(
        child: Text(
          '这里是根据筛选规则获取的帖子页面\n\n'
              '信息类型：${cateFilters.join(', ')}\n'
              '发布时间：${timeFilters.join(', ')}\n'
              '排序：${sortFilters.join(', ')}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}