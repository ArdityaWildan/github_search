import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_search/bloc/mode/mode_bloc.dart';
import 'package:github_search/bloc/mode/mode_event.dart';
import 'package:github_search/bloc/mode/mode_state.dart';
import 'package:github_search/bloc/search/search_bloc.dart';
import 'package:github_search/bloc/search/search_event.dart';
import 'package:github_search/bloc/search/search_state.dart';
import 'package:github_search/model/issue.dart';
import 'package:github_search/model/repository.dart';
import 'package:github_search/model/user.dart';
import 'package:github_search/repository/common_response.dart';
import 'package:github_search/ui/common/my_text.dart';
import 'package:github_search/ui/main/issue_item.dart';
import 'package:github_search/ui/main/repository_item.dart';
import 'package:github_search/ui/main/user_item.dart';
import 'package:github_search/ui/util.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../logger.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final queryController = TextEditingController();
  final scrollController = ScrollController();
  UiUtil? uiUtil;
  bool inputVisible = true;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    uiUtil = UiUtil(context);
    super.initState();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final searchBloc = context.read<SearchBloc>();
    final modeState = context.read<ModeBloc>().state;
    if (_isBottom &&
        modeState.displayType == DisplayType.infinite &&
        searchBloc.state.searchStatus != SearchStatus.searching &&
        !searchBloc.state.isReachedMax) {
      dlog('loading next');
      searchBloc.add(
        SearchFetch(
          modeState: modeState,
          query: queryController.text,
          fetchType: FetchType.next,
        ),
      );
    }
  }

  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    queryController.dispose();
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Search'),
      ),
      body: modeConsumer,
    );
  }

  Widget get modeConsumer => BlocConsumer<ModeBloc, ModeState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, modeState) {
          context.read<SearchBloc>().add(
                SearchFetch(
                  modeState: modeState,
                  query: queryController.text,
                ),
              );
          setState(() => inputVisible = true);
        },
        buildWhen: (previous, current) => previous != current,
        builder: searchConsumer,
      );

  Widget searchConsumer(BuildContext context, ModeState modeState) =>
      BlocConsumer<SearchBloc, SearchState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, searchState) => parentView(modeState, searchState),
        listenWhen: (previous, current) => previous != current,
        listener: (context, searchState) {
          if (modeState.displayType == DisplayType.paged &&
              scrollController.hasClients) {
            setState(() => inputVisible = true);
            scrollController.animateTo(
              0,
              duration: const Duration(seconds: 1),
              curve: Curves.bounceOut,
            );
          }
          final errorType = searchState.errorType;
          if (errorType != null) {
            String msg;
            switch (errorType) {
              case ResponseErrorType.connection:
                msg = 'Request failed. Please check your connection !';
                break;
              case ResponseErrorType.timeout:
                msg = 'Request failed. Timeout error.';
                break;
              case ResponseErrorType.auth:
                msg =
                    'You are unauthenticated. Thus you can only send up to 10 requests per minute.';
                break;
              case ResponseErrorType.server:
                msg = 'Internal server error occured.';
                break;
              case ResponseErrorType.unknown:
                msg = 'Cannot get data from the server.';
                break;
            }
            uiUtil?.alert(msg: msg);
          }
        },
      );

  Widget parentView(
    ModeState modeState,
    SearchState searchState,
  ) =>
      OrientationBuilder(
        builder: (context, orientation) => Container(
          color: Colors.grey[100],
          child: Column(
            children: [
              if (searchState.data.isEmpty || inputVisible)
                queryInput(modeState),
              verticalSpacing,
              modeSelector(orientation, modeState),
              verticalSpacing,
              Expanded(
                child: modeState.displayType == DisplayType.infinite
                    ? infiniteView(modeState, searchState)
                    : pagedView(modeState, searchState),
              ),
            ],
          ),
        ),
      );

  Widget modeSelector(Orientation orientation, ModeState modeState) {
    return orientation == Orientation.landscape
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              typeSelector(modeState),
              displaySelector(modeState),
            ],
          )
        : Column(
            children: [
              typeSelector(modeState),
              verticalSpacing,
              displaySelector(modeState),
            ],
          );
  }

  Widget get progressIndicator => const Center(
        child: CircularProgressIndicator(),
      );

  Widget infiniteView(ModeState modeState, SearchState searchState) {
    return searchState.data.isEmpty
        ? searchState.searchStatus == SearchStatus.searching
            ? progressIndicator
            : noResult
        : Column(
            children: [
              Expanded(
                child: resultsView(modeState, searchState),
              ),
              if (searchState.searchStatus == SearchStatus.searching)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: progressIndicator,
                ),
            ],
          );
  }

  Widget pagedView(ModeState modeState, SearchState searchState) {
    return Column(
      children: [
        Expanded(
          child: searchState.searchStatus == SearchStatus.searching
              ? progressIndicator
              : searchState.data.isEmpty
                  ? noResult
                  : resultsView(modeState, searchState),
        ),
        NumberPaginator(
          numberPages: searchState.lastPage,
          initialPage: searchState.page - 1,
          key: Key('${modeState.searchType}/${searchState.query}'),
          onPageChange: (p0) => context.read<SearchBloc>().add(
                SearchFetch(
                  query: queryController.text,
                  modeState: modeState,
                  page: p0 + 1,
                ),
              ),
          height: 50,
        ),
      ],
    );
  }

  Widget get verticalSpacing => const SizedBox(height: 10);

  Widget queryInput(ModeState modeState) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: queryController,
          style: const TextStyle(fontSize: 17),
          onSubmitted: (value) => context.read<SearchBloc>().add(
                SearchFetch(
                  query: value,
                  modeState: modeState,
                ),
              ),
          decoration: const InputDecoration(
            labelText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      );

  Widget typeSelector(ModeState modeState) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          selectorItem(
            action: () =>
                context.read<ModeBloc>().add(TypeChange(SearchType.user)),
            text: 'User',
            color: Colors.blue,
            isSelected: modeState.searchType == SearchType.user,
          ),
          selectorItem(
            action: () =>
                context.read<ModeBloc>().add(TypeChange(SearchType.repository)),
            text: 'Repository',
            color: Colors.blue,
            isSelected: modeState.searchType == SearchType.repository,
          ),
          selectorItem(
            action: () =>
                context.read<ModeBloc>().add(TypeChange(SearchType.issue)),
            text: 'Issue',
            color: Colors.blue,
            isSelected: modeState.searchType == SearchType.issue,
          ),
        ],
      );

  Widget displaySelector(ModeState modeState) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          selectorItem(
            action: () => context
                .read<ModeBloc>()
                .add(DisplayChange(DisplayType.infinite)),
            text: 'Infinity',
            color: Colors.deepOrange,
            isSelected: modeState.displayType == DisplayType.infinite,
          ),
          selectorItem(
            action: () =>
                context.read<ModeBloc>().add(DisplayChange(DisplayType.paged)),
            text: 'Paged',
            color: Colors.deepOrange,
            isSelected: modeState.displayType == DisplayType.paged,
          ),
        ],
      );

  Widget selectorItem({
    required Function() action,
    required String text,
    required bool isSelected,
    required Color color,
  }) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(
            color: color,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(26),
          ),
        ),
        child: MyText(
          text,
          color: isSelected ? Colors.white : color,
        ),
      ),
    );
  }

  Widget get noResult => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cancel_outlined),
            MyText('No data available'),
          ],
        ),
      );

  Widget resultsView(ModeState modeState, SearchState searchState) =>
      NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          final scrollDelta = notification.scrollDelta;
          // dlog(scrollDelta.toString());
          if (scrollDelta != null && scrollDelta.abs() > 1) {
            final scrollDir = scrollController.position.userScrollDirection;
            if (scrollDir == ScrollDirection.forward) {
              setState(() => inputVisible = true);
            } else if (scrollDir == ScrollDirection.reverse) {
              setState(() => inputVisible = false);
            }
          }

          return false;
        },
        child: ListView(
          controller: scrollController,
          key: modeState.displayType == DisplayType.infinite
              ? PageStorageKey('${modeState.searchType}/${searchState.query}')
              : null,
          children: searchState.data
              .map(
                (e) => (e is User)
                    ? UserItem(
                        user: e,
                        launchUrl: launchUrl,
                      )
                    : ((e is Repository)
                        ? RepositoryItem(
                            repository: e,
                            launchUrl: launchUrl,
                          )
                        : IssueItem(
                            issue: e as Issue,
                            launchUrl: launchUrl,
                          )),
              )
              .toList(),
        ),
      );

  void launchUrl(String url) {
    launch(url).then((value) {
      if (!value) uiUtil?.alert(msg: 'Tidak dapat membuka link');
    });
  }
}
