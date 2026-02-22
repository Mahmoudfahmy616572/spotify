import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/common/helper/is_dark_mode.dart';
import 'package:spotify/core/config/assets/app_vectors.dart';
import 'package:spotify/presentation/Home/cubit/getSongsCubitAndState/get_songs_cubit.dart';
import 'package:spotify/presentation/Home/cubit/getSongsCubitAndState/get_songs_state.dart';
import 'package:spotify/presentation/songsPlayPage/songs_play_page.dart';

import '../../../data/models/songs/songs_model.dart';

class NewSongs extends StatelessWidget {
  const NewSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => GetSongsCubit()..fetchSongs(),
        child: BlocBuilder<GetSongsCubit, GetSongsState>(
            builder: (context, state) {
          if (state is GetSongsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GetSongsLoaded) {
            final songs = state.songs;
            return _listSongs(songs);
          }
          if (state is GetSongsFailure) {
            return Center(child: Text(state.errorMessage));
          }
          return const SizedBox.shrink(
            child: Text("Unknown error"),
          );
        }));
  }

  Widget _listSongs(List<SongModel> songs) {
    return ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemBuilder: (context, index) => SizedBox(
              width: 147.w,
              height: 185.h,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SongsPlayPage(
                                songModel: songs[index],
                                songs: songs,
                                index: index,
                              )));
                },
                child: Column(children: [
                  Expanded(
                      child: Stack(
                    children: [
                      Container(
                        width: 147.w,
                        height: 185.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          color: Colors.grey[300],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          width: 160.w,
                          imageUrl: songs[index].imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.music_note),
                          placeholder: (context, url) => Container(
                            height: 150.h,
                            width: 160.w,
                            color: Colors.grey[300],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15.h,
                        right: 0.w,
                        child: Container(
                          width: 35.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.isDarkMode
                                  ? const Color(0xff959595)
                                  : const Color(0xFFE6E6E6)),
                          child: Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: SvgPicture.asset(
                              AppVectors.playMusicIcon,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    songs[index].title,
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: context.isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    songs[index].artist,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ]),
              ),
            ),
        separatorBuilder: (context, index) => SizedBox(
              width: 14.w,
            ),
        itemCount: songs.length);
  }
}
