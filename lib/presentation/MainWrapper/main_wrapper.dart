import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify/core/config/theme/app_colors.dart';
import 'package:spotify/presentation/Home/pages/home_page.dart';
import 'package:spotify/presentation/Home/widgets/miniPlayerBar/mini_player.dart';
import 'package:spotify/presentation/Library/library_page.dart';
import 'package:spotify/presentation/MainWrapper/cubit/cubit/navigation_cubit.dart';
import 'package:spotify/presentation/PremiumHub/premium_features_page.dart';

import '../SearchPage/search_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomePage(),
      SearchPage(),
      LibraryPage(),
      PremiumFeaturesPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
            extendBody: true,
            body: Stack(
              children: [
                IndexedStack(
                  index: currentIndex,
                  children: _screens,
                ),
                Positioned(
                  bottom: kBottomNavigationBarHeight + 21.h,
                  left: 0,
                  right: 0,
                  child: const MiniPlayer(),
                )
              ],
            ),
            bottomNavigationBar: ClipRect(
                child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (value) {
                  context.read<NavigationCubit>().updateIndex(value);
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: Colors.white.withOpacity(0.7),
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.search), label: 'Search'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.library_music), label: 'Library'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.explore), label: 'Discover'),
                ],
              ),
            )));
      },
    );
  }
}
