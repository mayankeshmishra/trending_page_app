import 'package:redux/redux.dart';
import 'package:trending_page_app/service/trending_repo_service.dart';
import 'package:trending_page_app/state/models/trendingRepoModel.dart';

import 'package:trending_page_app/state/trending_repo/actions.dart';
import '../store.dart';

dynamic trendingRepoThunk(
  Store<AppState> store,
  dynamic action,
  NextDispatcher next,
) {
  if (action is LoadTrendingRepo) {
    fetchTrendingRepo(action.errorCallback, action.forceFetch)
        ?.then((trendingRepoList) {
      trendingRepoList = sortTrendingList(trendingRepoList);
      trendingRepoList.forEach((TrendingRepo repo) {
        print(repo.language);
      });
      action.successCallback!();
      return store.dispatch(
        LoadTrendingRepoSuccess(trendingRepoList: trendingRepoList),
      );
    }).catchError((e) => action.errorCallback!());
  }
  next(action);
}
