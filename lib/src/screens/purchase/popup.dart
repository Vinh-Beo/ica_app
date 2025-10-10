import 'package:flutter/material.dart';

class MessageData {
  final String title;
  final String subtitle;
  final String time;
  final String? badge;
  final String avatarUrl;
  final String? groupNumber;

  MessageData({
    required this.title,
    required this.subtitle,
    required this.time,
    this.badge,
    required this.avatarUrl,
    this.groupNumber,
  });
}

class Popup extends StatefulWidget {
  const Popup({Key? key}) : super(key: key);

  @override
  State<Popup> createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  bool _showPopup = false;
  MessageData? _selectedMessage;

  final List<MessageData> messages = [
    MessageData(
      title: 'DOHA - Cá Biên',
      subtitle: 'Thế Vũ: Doha2 thêm Cá điều hồng:...',
      time: '18 minutes',
      badge: '2',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      groupNumber: '7',
    ),
    MessageData(
      title: 'My Cloud',
      subtitle: 'You: [File] NS-QD03-BM01 Đơn xin nghỉ...',
      time: '04/05/23',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
    ),
    MessageData(
      title: 'My Motivation',
      subtitle: 'You: [Photo]',
      time: '13 minutes',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
    ),
    MessageData(
      title: 'Team Project',
      subtitle: 'John: Meeting at 9AM tomorrow',
      time: '1 hour',
      badge: '5',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
    ),
  ];

  void _showMessagePopup(MessageData message) {
    setState(() {
      _showPopup = true;
      _selectedMessage = message;
    });
  }

  void _hidePopup() {
    setState(() {
      _showPopup = false;
      _selectedMessage = null;
    });
  }

  void _handleMenuAction(String action) {
    print('Action: $action for ${_selectedMessage?.title}');
    _hidePopup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3B66),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '21:44',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tabs
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Focused',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      const Text(
                        'Other',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Messages List
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageTile(messages[index]);
                    },
                  ),
                ),
              ],
            ),
            // Popup Overlay
            if (_showPopup && _selectedMessage != null)
              GestureDetector(
                onTap: _hidePopup,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Message Preview Card
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(
                                          _selectedMessage!.avatarUrl,
                                        ),
                                      ),
                                      if (_selectedMessage!.groupNumber != null)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              _selectedMessage!.groupNumber!,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedMessage!.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedMessage!.subtitle,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _selectedMessage!.time,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (_selectedMessage!.badge != null) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            _selectedMessage!.badge!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Menu Options
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildMenuItem(
                                    Icons.check_circle_outline,
                                    'Mark as read',
                                    () => _handleMenuAction('mark_read'),
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    Icons.push_pin_outlined,
                                    'Pin',
                                    () => _handleMenuAction('pin'),
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    Icons.notifications_off_outlined,
                                    'Mute',
                                    () => _handleMenuAction('mute'),
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    Icons.drive_file_move_outlined,
                                    'Move to Other',
                                    () => _handleMenuAction('move'),
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    Icons.visibility_off_outlined,
                                    'Hide',
                                    () => _handleMenuAction('hide'),
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    Icons.delete_outline,
                                    'Delete',
                                    () => _handleMenuAction('delete'),
                                    isDestructive: true,
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    Icons.check_circle_outline,
                                    'Multiple select',
                                    () => _handleMenuAction('multiple'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildMessageTile(MessageData message) {
    return GestureDetector(
      onLongPress: () => _showMessagePopup(message),
      onTap: () => print('Tapped: ${message.title}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(message.avatarUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                if (message.badge != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive ? Colors.red : Colors.black87,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56,
      color: Colors.grey.shade300,
    );
  }
}