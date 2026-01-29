import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/common/appbar/basic_appbar.dart';
import 'package:spotify/common/helper/is_dark_mode.dart';
import 'package:spotify/presentation/Home/widgets/new_songs.dart';

import '../../../core/config/assets/app_images.dart';
import '../../../core/config/assets/app_vectors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        ),
        body: Column(
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
            )
          ],
        ));
  }

  Widget _tabs() {
    return TabBar(
        padding: EdgeInsets.only(right: 16.w, top: 40.h, bottom: 40.h),
        controller: _tabController,
        dividerColor: Colors.transparent,
        isScrollable: true,
        unselectedLabelColor: Colors.grey,
        labelColor: context.isDarkMode ? Colors.white : Colors.black,
        tabs: const [
          Text(
            "News",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Text(
            "Vedio",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Text(
            "Artists",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Text(
            "Podcast",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
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
            padding: const EdgeInsets.only(right: 50),
            child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(AppImages.topHomeImage)),
          ),
        ]),
      ),
    );
  }
}
