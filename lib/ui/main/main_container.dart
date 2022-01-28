import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_search/bloc/mode/mode_bloc.dart';
import 'package:github_search/bloc/search/search_bloc.dart';
import 'package:github_search/repository/github_cache_repository.dart';
import 'package:github_search/repository/github_remote_repository.dart';

import 'main_page.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ModeBloc>(
          create: (context) => ModeBloc(),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
            githubRemoteRepository: context.read<GithubRemoteRepository>(),
            githubCacheRepository: context.read<GithubCacheRepository>(),
          ),
        ),
      ],
      child: const MainPage(),
    );
  }
}
