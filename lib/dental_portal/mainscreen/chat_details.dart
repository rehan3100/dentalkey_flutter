import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class ChatDetails extends StatelessWidget {
  final String message;
  final String? attachment;
  final String? replyMessage;
  final String? replyAttachment;
  final String createdOn;
  final String? modifiedOn;

  ChatDetails({
    required this.message,
    required this.attachment,
    required this.replyMessage,
    required this.replyAttachment,
    required this.createdOn,
    required this.modifiedOn,
  });

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return 'N/A';
    }
    DateTime dateTime = DateTime.parse(dateTimeStr);
    return timeago.format(dateTime);
  }

  Future<void> _downloadFile(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildMessageBubble(String text, String timestamp,
      {bool isReply = false,
      bool hasAttachment = false,
      String? attachmentUrl}) {
    return Align(
      alignment: isReply ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isReply ? Colors.grey[300] : Colors.blue[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
            if (hasAttachment && attachmentUrl != null) ...[
              SizedBox(height: 5),
              TextButton(
                onPressed: () => _downloadFile(attachmentUrl),
                child: Text('Download Attachment',
                    style: TextStyle(color: Colors.blue)),
              ),
            ],
            SizedBox(height: 5),
            Text(
              timestamp,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          reverse: true,
          children: [
            if (replyMessage != null || replyAttachment != null)
              _buildMessageBubble(
                replyMessage ?? 'No reply yet',
                _formatDateTime(modifiedOn),
                isReply: true,
                hasAttachment: replyAttachment != null,
                attachmentUrl: replyAttachment,
              ),
            _buildMessageBubble(
              message,
              _formatDateTime(createdOn),
              hasAttachment: attachment != null,
              attachmentUrl: attachment,
            ),
          ],
        ),
      ),
    );
  }
}
