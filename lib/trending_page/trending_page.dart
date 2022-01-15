import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:trending_page_app/constants/widgets.dart';
import 'package:trending_page_app/error_page/error_page.dart';
import 'package:trending_page_app/state/models/trendingRepoModel.dart';
import 'package:trending_page_app/state/starred_repo/action.dart';
import 'package:trending_page_app/state/store.dart';
import 'package:trending_page_app/state/trending_repo/actions.dart';
import 'package:trending_page_app/trending_page/local_widgets/loading_card.dart';
import 'package:trending_page_app/trending_page/local_widgets/trending_card.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({Key? key}) : super(key: key);

  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Store? _store;
  int expandedRepo = -1;
  bool isLoading = true;
  bool isError = false;
  List<int> starredRepos = [];

  void _successCallback() {
    print('Success Callback Called');
    setState(() {
      isLoading = false;
      if (isError) {
        isError = false;
      }
    });
  }

  void _errorCallback() {
    print('Error Callback Called');
    setState(() {
      isError = true;
    });
  }

  _fetchTrendingRepo(store) {
    _store = store;
    store.dispatch(LoadTrendingRepo(
      successCallback: _successCallback,
      errorCallback: _errorCallback,
      forceFetch: false,
    ));
    store.dispatch(LoadStarredRepo(
      successCallback: _successCallback,
      errorCallback: _errorCallback,
    ));
  }

  void _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    if (_store != null) {
      _store!.dispatch(LoadTrendingRepo(
        successCallback: _successCallback,
        errorCallback: _errorCallback,
        forceFetch: true,
      ));
    }
    _refreshController.refreshCompleted();
  }

  void starRepo(TrendingRepo repo) {
    _store!.dispatch(AddStarredRepo(
      successCallback: _successCallback,
      errorCallback: _errorCallback,
      repo: repo,
    ));
  }

  void unStarRepo(TrendingRepo repo) {
    _store!.dispatch(RemoveStarredRepo(
      successCallback: _successCallback,
      errorCallback: _errorCallback,
      repo: repo,
    ));
  }

  bool _checkStarred(List<TrendingRepo> starredRepoList, int rank) {
    for (TrendingRepo repo in starredRepoList) {
      if (repo.rank == rank) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: baseAppBar('Trending'),
        body: StoreConnector<AppState, AppState>(
          onInit: _fetchTrendingRepo,
          converter: (_store) => _store.state,
          builder: (context, state) => Container(
            child: isError
                ? CustomErrorWidget(
                    retryCallback: _fetchTrendingRepo,
                    store: _store,
                  )
                : SmartRefresher(
                    controller: _refreshController,
                    enablePullDown: true,
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      itemCount:
                          isLoading ? 10 : state.trendingRepoList?.length,
                      itemBuilder: (context, index) {
                        return isLoading
                            ? LoadingCard()
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (expandedRepo == index) {
                                      expandedRepo = -1;
                                    } else {
                                      expandedRepo = index;
                                    }
                                  });
                                },
                                child: TrendingCard(
                                  username:
                                      state.trendingRepoList?[index].username,
                                  repoName: state
                                      .trendingRepoList?[index].repositoryName,
                                  description: state
                                      .trendingRepoList?[index].description,
                                  language:
                                      state.trendingRepoList?[index].language,
                                  languageColor: state
                                      .trendingRepoList?[index].languageColor,
                                  stars: (state.trendingRepoList?[index]
                                              .totalStars !=
                                          null)
                                      ? state
                                          .trendingRepoList![index].totalStars!
                                          .toDouble()
                                      : 0,
                                  forks: (state
                                              .trendingRepoList?[index].forks !=
                                          null)
                                      ? state.trendingRepoList![index].forks!
                                          .toDouble()
                                      : 0,
                                  avatarUrl: state.trendingRepoList?[index]
                                      .builtBy![0].avatar,
                                  expanded: expandedRepo == index,
                                  isStarred: _checkStarred(
                                      state.starredRepoList!,
                                      state.trendingRepoList![index].rank!),
                                  repo: state.trendingRepoList![index],
                                  starRepoCallback: starRepo,
                                  unstarRepoCallback: unStarRepo,
                                ),
                              );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
