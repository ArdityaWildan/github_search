import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_search/repository/github_cache_repository.dart';
import 'repository/github_remote_repository.dart';
import 'ui/main/main_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GithubRemoteRepository>(
          create: (context) => GithubRemoteRepository(),
        ),
        RepositoryProvider<GithubCacheRepository>(
          create: (context) => GithubCacheRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'GitHub Search',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Bahnschrift',
        ),
        home: const MainContainer(),
      ),
    );
  }
}
