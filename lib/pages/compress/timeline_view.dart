import 'package:epub_image_compressor/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'compress_logic.dart';

class TimelineView extends StatefulWidget {
  /// 存储压缩相关的业务逻辑和状态。
  final CompressLogic logic;

  const TimelineView({super.key, required this.logic});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final ScrollController _scrollController = ScrollController();
  int _lastLength = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom(int itemCount) {
    if (itemCount == 0 || itemCount == _lastLength) return;
    _lastLength = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final logs = widget.logic.state.timeline.value;
      _scrollToBottom(logs.length);
      return Container(
        width: double.infinity,
        decoration: widget.logic.state.buildBoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '任务日志:',
                        style: widget.logic.state
                            .buildTextStyle(16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: widget.logic.state.timeline.isEmpty
                          ? null
                          : widget.logic.clearTimeline,
                      icon: const Icon(
                        Icons.delete_sweep,
                        size: 16,
                      ),
                      label: Text(
                        '清除',
                        style: widget.logic.state.buildTextStyle(10),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
              ),
              widget.logic.state.buildHorizontalDivider(),
              Expanded(
                child: logs.isEmpty
                    ? const Text('暂无运行记录。')
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: logs.length,
                        itemBuilder: (_, index) => Text(
                          logs[index],
                          style: widget.logic.state.buildTextStyle(10,fontStyle: FontStyle.italic),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
