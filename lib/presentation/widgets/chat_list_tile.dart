import 'package:chat_app/data/models/chat_room_model.dart';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chat;
  final String currentUserId;
  final VoidCallback? onTap;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    this.onTap,
  });

  String _getOtherUsername() {
    final otherUserId = chat.participants.firstWhere(
      (id) => id != currentUserId,
    );
    return chat.participantsName![otherUserId] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        child: Text(_getOtherUsername()[0].toUpperCase()),
      ),
      title: Text(
        _getOtherUsername(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage ?? 'No messages yet',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      trailing: StreamBuilder<int>(
        stream: getIt<ChatRepository>().getUnreadCount(chat.id, currentUserId),
        builder: (context, snapshot) {
          if(!snapshot.hasData || snapshot.data == 0) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(snapshot.data.toString(), style: TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }
}
