import 'package:flutter/material.dart';
import 'package:github_search/model/user.dart';
import 'package:github_search/ui/common/my_text.dart';

import 'searchable_item.dart';

class UserItem extends StatelessWidget {
  final User user;
  final Function(String) launchUrl;

  const UserItem({
    Key? key,
    required this.launchUrl,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchableItem(
      action: () => launchUrl(user.url),
      child: Row(
        children: [
          if (user.avatarUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                user.avatarUrl,
                width: 40,
                errorBuilder: (context, obj, stack) => const Icon(Icons.person),
              ),
            ),
          const SizedBox(width: 10),
          MyText(
            user.name,
            size: 17,
          ),
        ],
      ),
    );
  }
}
