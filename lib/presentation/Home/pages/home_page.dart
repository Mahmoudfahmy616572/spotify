import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/common/appbar/basic_appbar.dart';
import 'package:spotify/presentation/Home/widgets/new_songs.dart';
import 'package:spotify/presentation/Home/widgets/recently_played_widget.dart';
import 'package:spotify/presentation/Profile/profile_page.dart';

import '../../../core/config/assets/app_images.dart';
import '../../../core/config/assets/app_vectors.dart';
import '../widgets/play_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BasicAppbar(
          isLeading: true,
          title: SvgPicture.asset(
            AppVectors.logo,
            width: 108.w,
            height: 33.h,
            fit: BoxFit.fill,
          ),
          actions: IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ),
        body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _topHomeCard(),
                _tabs(),
                SizedBox(
                  height: 260.h,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const NewSongs(),
                      Container(),
                      Container(),
                      Container(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                const RecentlyPlayedWidget(),
                SizedBox(
                  height: 20.h,
                ),
                SizedBox(height: 500.h, child: const GetPlayList())
              ],
            ),
          ),
        ));
  }

  Widget _tabs() {
    return TabBar(
        padding: EdgeInsets.only(right: 16.w, top: 40.h, bottom: 40.h),
        controller: _tabController,
        dividerColor: Colors.transparent,
        isScrollable: true,
        unselectedLabelColor: Colors.grey,
        labelColor: Colors.white,
        tabs: [
          Text(
            "News",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
          ),
          Text(
            "Video",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
          ),
          Text(
            "Artists",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
          ),
          Text(
            "Podcast",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
          ),
        ]);
  }

  Widget _topHomeCard() {
    return SizedBox(
      height: 140.h,
      child: Center(
        child: Stack(children: [
          Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(AppVectors.topHomeCard)),
          Padding(
            padding: EdgeInsets.only(right: 50.w),
            child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(AppImages.topHomeImage)),
          ),
        ]),
      ),
    );
  }
}
