import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify/common/helper/is_dark_mode.dart';
import 'package:spotify/presentation/songsPlayPage/cubit/song_player_cubit.dart';
import 'package:spotify/presentation/songsPlayPage/songs_play_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is! SongPlayerLoaded) {
          return const SizedBox.shrink();
        }
        final cubit = context.read<SongPlayerCubit>();
        if (cubit.playList.isEmpty) {
          return const SizedBox.shrink();
        }

        if (cubit.currentIndex >= cubit.playList.length ||
            cubit.currentIndex < 0) {
          return const SizedBox.shrink();
        }
        final song = cubit.playList[cubit.currentIndex];
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SongsPlayPage(
                          songModel: song,
                          songs: cubit.playList,
                          index: cubit.currentIndex,
                        )));
          },
          child: Container(
            height: 60.h,
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? const Color(0xffededed):

                   const Color(0xff282828),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: Image.network(song.imageUrl,
                      width: 45.w, height: 45.h, fit: BoxFit.cover),
                ),
                SizedBox(width: 10.w),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    "${song.title} - ${song.artist}",
                    style: TextStyle(
                        color:
                            context.isDarkMode ? Colors.black : Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                      cubit.audioPlayer.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: context.isDarkMode ? Colors.black : Colors.white),
                  onPressed: () => cubit.playOrpauseSong(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
