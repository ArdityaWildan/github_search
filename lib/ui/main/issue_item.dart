import 'package:flutter/material.dart';
import 'package:github_search/model/issue.dart';
import 'package:github_search/ui/common/my_text.dart';
import 'package:github_search/ui/common/text_with_icon.dart';

import 'searchable_item.dart';

class IssueItem extends StatelessWidget {
  final Issue issue;
  final Function(String) launchUrl;

  const IssueItem({
    Key? key,
    required this.issue,
    required this.launchUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchableItem(
      action: () => launchUrl(issue.url),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(issue.title, size: 17),
                const SizedBox(height: 3),
                TextWithIcon(
                  text: issue.updatedAt,
                  icon: Icons.update,
                  iconColor: Colors.deepPurpleAccent,
                  textColor: Colors.deepPurpleAccent,
                ),
              ],
            ),
          ),
          MyText(
            issue.state,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
