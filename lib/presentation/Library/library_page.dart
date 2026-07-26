import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify/common/appbar/basic_appbar.dart';
import 'package:spotify/presentation/DownloadedSongs/downloadedSongs.dart';
import 'package:spotify/presentation/LikedSongs/LikedSongs.dart'
    show LikedsongsPage;
import 'package:spotify/presentation/LikedSongs/cubit/favourite_songs_cubit.dart';
import 'package:spotify/presentation/LikedSongs/cubit/favourite_songs_state.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BasicAppbar(
          isLeading: true,
          title: Row(
            children: [
              Text(
                'Your Library',
                style: TextStyle(
                    fontSize: 27.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _listOfLikedSongs(context),
                _listOfDownloadedSongs(context),
                SizedBox(height: 20.h),
                const Text("Recently Added",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildFilterChips()
              ],
            ))
          ],
        ));
  }
}

Widget _listOfLikedSongs(context) {
  return ListTile(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => LikedsongsPage()));
    },
    leading: Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [Colors.deepPurple, Colors.blueAccent]),
          borderRadius: BorderRadius.circular(4.r)),
      child: Icon(
        Icons.favorite,
        color: Colors.white,
      ),
    ),
    title: Text("Liked Songs", style: TextStyle(fontWeight: FontWeight.bold)),
    subtitle: BlocBuilder<FavouriteSongsCubit, FavouriteSongsState>(
        builder: (context, state) {
      int count = 0;

      if (state is FavouriteSongsLoaded) count = state.favouriteSongsIds.length;
      return Text(
        "$count songs",
        style: TextStyle(fontSize: 16.sp),
      );
    }),
  );
}

Widget _listOfDownloadedSongs(context) {
  return ListTile(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => DownloadedsongsPage()));
      },
      leading: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Colors.deepPurple, Colors.blueAccent]),
            borderRadius: BorderRadius.circular(4.r)),
        child: Icon(
          Icons.download_done,
          color: Colors.white,
        ),
      ),
      title: const Text("Downloaded",
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text("Available offline"));
}

Widget _buildFilterChips() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.all(16.w),
    child: Row(
      children: ["Playlists", "Artists", "Albums", "Podcasts"].map((label) {
        return Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: Chip(label: Text(label), backgroundColor: Colors.white10),
        );
      }).toList(),
    ),
  );
}
