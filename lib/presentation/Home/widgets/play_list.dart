import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/common/helper/is_dark_mode.dart';
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:spotify/presentation/Home/cubit/FavoutriteCubitAndState/cubit/favourite_songs_cubit.dart';
import 'package:spotify/presentation/Home/cubit/getSongsCubitAndState/get_songs_cubit.dart';

import '../../../core/config/assets/app_vectors.dart';
import '../../songsPlayPage/songs_play_page.dart';
import '../cubit/getSongsCubitAndState/get_songs_state.dart';

class GetPlayList extends StatelessWidget {
  const GetPlayList({super.key});

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
            return Padding(
              padding: EdgeInsets.all(20.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Playlist",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.h,
                            color: context.isDarkMode
                                ? const Color(0xFFDBDBDB)
                                : const Color(0xFF131313)),
                      ),
                      Text(
                        "see more",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12.h,
                            color: context.isDarkMode
                                ? const Color(0xFFC6C6C6)
                                : const Color(0xFF131313)),
                      ),
                    ],
                  ),
                  Expanded(child: _playlist(state.songs, context)),
                ],
              ),
            );
          }
          if (state is GetSongsFailure) {
            return Center(
                child: Column(
              children: [
                Icon(
                  Icons.music_note_sharp,
                  size: 30.h,
                ),
                Text(state.errorMessage),
              ],
            ));
          }
          return const Text("SORRY TRY AGAIN LATER, UNKNOWN ERROR ");
        },
      ),
    );
  }

  Widget _playlist(List<SongModel> songs, BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (contex, index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SongsPlayPage(
                                  songs: songs,
                                  index: index,
                                  songModel: songs[index],
                                )));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
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
                      SizedBox(
                        width: 23.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            songs[index].title,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17.h,
                                color: contex.isDarkMode
                                    ? const Color(0xFFD6D6D6)
                                    : const Color(0xFF000000)),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            songs[index].artist,
                            style: TextStyle(
                                fontSize: 15.h,
                                color: contex.isDarkMode
                                    ? const Color(0xFFD6D6D6)
                                    : const Color(0xFF000000)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      songs[index].duration.replaceAll(".", ":"),
                      style: TextStyle(
                          color: context.isDarkMode
                              ? const Color(0xff959595)
                              : const Color(0xFF000000)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: 40.h,
                    ),
                    BlocBuilder<FavouriteSongsCubit, FavouriteSongsState>(
                      builder: (context, state) {
                        bool isFavourite = context
                            .read<FavouriteSongsCubit>()
                            .isFavourite(songs[index].id);
                        return IconButton(
                          onPressed: () {
                            context
                                .read<FavouriteSongsCubit>()
                                .toggleFavourite(songs[index].id);
                          },
                          icon: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
        separatorBuilder: (context, index) => SizedBox(
              height: 34.w,
            ),
        itemCount: songs.length);
  }
}
