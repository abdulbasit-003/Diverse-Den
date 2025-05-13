import 'package:flutter/material.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/session_manager.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:bson/bson.dart';

class CommentSheet extends StatefulWidget {
  final String sku;
  const CommentSheet({super.key, required this.sku});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  List<Map<String, dynamic>> comments = [];
  final TextEditingController _controller = TextEditingController();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final session = await SessionManager.getUserSession();
    currentUserId = session['email'];
    final fetchedComments = await DatabaseService.getCommentsForSku(widget.sku);
    setState(() {
      comments = fetchedComments;
    });
  }

  Future<void> submitComment() async {
    if (_controller.text.trim().isEmpty || currentUserId == null) return;

    await DatabaseService.addComment(
      sku: widget.sku,
      businessId: ObjectId(), // Pass correct businessId if needed
      userId: currentUserId!,
      text: _controller.text.trim(),
    );

    _controller.clear();
    await load();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                decoration: BoxDecoration(
                  color: fieldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: comments.length,
                        itemBuilder: (_, index) {
                          final comment = comments[index];
                          final timestamp = comment['timestamp'];
                          String timeAgo = '';

                          if (timestamp != null) {
                            try {
                              final time = DateTime.parse(timestamp.toString());
                              timeAgo = timeago.format(time);
                            } catch (_) {}
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment['user'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      timeAgo,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  comment['text'] ?? '',
                                  style: const TextStyle(color: textColor),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Add a comment...",
                                  hintStyle: const TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.black26,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: textColor),
                              onPressed: submitComment,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

}
