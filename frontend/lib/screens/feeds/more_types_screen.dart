import 'package:flutter/material.dart';

import 'feeds_screen.dart';

class MoreTypesScreen extends StatefulWidget {
  MoreTypesScreen({Key? key}) : super(key: key);

  @override
  State<MoreTypesScreen> createState() => _MoreTypesScreenState();
}

class _MoreTypesScreenState extends State<MoreTypesScreen> {
  final List<String> _selectedCateFilters = [];
  final List<String> _selectedTimeFilters = [];
  final List<String> _selectedSortFilters = [];

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
      'isFilter': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更多分类'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(top: 10),
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            _buildNarrowCard('信息类型', Colors.pink.shade200,['校园资讯', '二手交易'], _selectedCateFilters,false),
            _buildNarrowCard('排序', Colors.green.shade200,[ '点赞量高优先', '评论量高优先'], _selectedSortFilters,true),
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
    return SizedBox(
      height: 100+ 50 * infoList.length.toDouble(),
      width: 1 * 190,
      child: Card(
        color: color,
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(10),
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
    );
  }

  Widget _buildFilterButton(String label,
      {bool selected = false, VoidCallback? onPressed}) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonColor = selected ? colorScheme.secondary : colorScheme.surface;
    final textColor =
    selected ? colorScheme.onSecondary : colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(label),
      ),
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