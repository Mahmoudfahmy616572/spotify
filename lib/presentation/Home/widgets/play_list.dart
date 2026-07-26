import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:spotify/presentation/Home/cubit/get_songs_cubit.dart';
import 'package:spotify/presentation/LikedSongs/cubit/favourite_songs_cubit.dart';
import 'package:spotify/presentation/LikedSongs/cubit/favourite_songs_state.dart';

import '../../../core/config/assets/app_vectors.dart';
import '../../songsPlayPage/songs_play_page.dart';
import '../cubit/get_songs_state.dart';

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
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Playlist",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                            color: const Color(0xFFDBDBDB)),
                      ),
                      Text(
                        "see more",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12.sp,
                            color: const Color(0xFFC6C6C6)),
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
                  size: 30.r,
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
        itemBuilder: (context, index) => Row(
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
                            color: const Color(0xff959595)),
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
                                fontSize: 17.sp,
                                color: const Color(0xFFD6D6D6)),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            songs[index].artist,
                            style: TextStyle(
                                fontSize: 15.sp,
                                color: const Color(0xFFD6D6D6)),
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
                          color: const Color(0xff959595)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: 40.w,
                    ),
                    BlocBuilder<FavouriteSongsCubit, FavouriteSongsState>(
                      builder: (context, state) {
                        final song = songs[index];
                        bool isFavourite = context
                            .watch<FavouriteSongsCubit>()
                            .isFavourite(song.id);
                        return IconButton(
                          onPressed: () {
                            context
                                .read<FavouriteSongsCubit>()
                                .toggleFavourite(song);
                          },
                          icon: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
        separatorBuilder: (context, index) => SizedBox(
              height: 34.h,
            ),
        itemCount: songs.length);
  }
}
