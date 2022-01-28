import 'package:flutter/material.dart';
import 'package:github_search/model/repository.dart';
import 'package:github_search/ui/common/my_text.dart';
import 'package:github_search/ui/common/text_with_icon.dart';

import 'searchable_item.dart';

class RepositoryItem extends StatelessWidget {
  final Repository repository;
  final Function(String) launchUrl;

  const RepositoryItem({
    Key? key,
    required this.repository,
    required this.launchUrl,
  }) : super(key: key);

  Widget get defaultSpacing => const SizedBox(height: 3);

  @override
  Widget build(BuildContext context) {
    return SearchableItem(
      action: () => launchUrl(repository.url),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(repository.name, size: 17),
                defaultSpacing,
                TextWithIcon(
                  text: repository.owner,
                  icon: Icons.person,
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                ),
                defaultSpacing,
                TextWithIcon(
                  text: repository.createdAt,
                  icon: Icons.history,
                  iconColor: Colors.deepPurpleAccent,
                  textColor: Colors.deepPurpleAccent,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextWithIcon(
                text: repository.totalWatchers.toString(),
                icon: Icons.remove_red_eye_outlined,
                iconColor: Colors.redAccent,
              ),
              defaultSpacing,
              TextWithIcon(
                text: repository.totalStars.toString(),
                icon: Icons.star,
                iconColor: Colors.orangeAccent,
              ),
              defaultSpacing,
              TextWithIcon(
                text: repository.totalForks.toString(),
                icon: Icons.copy,
                iconColor: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
