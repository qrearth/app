import 'dart:io';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:qr_earth/ui/home/widgets/safe_padding.dart';
import 'package:qr_earth/models/user.dart';
import 'package:qr_earth/network/api_client.dart';
import 'package:qr_earth/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:qr_earth/utils/global.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  static const _pageSize = 10;
  int totalUsers = 0;
  int totalPages = 1;

  late final _pagingController = PagingController<int, LeaderboardEntry>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => _fetchLeaderboard(pageKey));

  @override
  void initState() {
    super.initState();
    _fetchTotalUsers();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        forceMaterialTransparency: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafePadding(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/images/asset3.png",
              height: 200,
            ),
            const SizedBox(
              height: 20,
            ),
            const ListTile(
              leading: Text('Rank'),
              title: Text('Username'),
              trailing: Text('Recycled'),
            ),
            Expanded(
              child: PagingListener(
                controller: _pagingController,
                builder: (context, state, fetchNextPage) =>
                    PagedListView<int, LeaderboardEntry>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate<LeaderboardEntry>(
                    itemBuilder: (context, item, index) => Card(
                      elevation: 0,
                      color: (item.username == Global.user.username)
                          ? keyColor.withValues(alpha: 0.5)
                          : null,
                      child: ListTile(
                        leading: Text('${index + 1} / $totalUsers'),
                        title: Text('@${item.username}'),
                        trailing: Text(item.redeemedCodeCount.toString()),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<List<LeaderboardEntry>> _fetchLeaderboard(final int pageKey) async {
    final response = await ApiClient.leaderboard(
      page: pageKey,
      size: _pageSize,
    );

    if (response.statusCode == HttpStatus.ok) {
      Iterable leaderboardResponse = response.data["items"];
      totalPages = response.data["pages"];

      List<LeaderboardEntry> leaderboardList = List<LeaderboardEntry>.from(
        leaderboardResponse.map((x) => LeaderboardEntry.fromJson(x)),
      );

      return leaderboardList;
    }

    return [];
  }

  void _fetchTotalUsers() async {
    final response = await ApiClient.totalUsers();

    if (response.statusCode == HttpStatus.ok) {
      setState(() {
        totalUsers = response.data;
      });
    }
  }
}
