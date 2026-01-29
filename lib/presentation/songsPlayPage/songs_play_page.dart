import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/common/appbar/basic_appbar.dart';
import 'package:spotify/core/config/theme/app_colors.dart';
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:spotify/presentation/songsPlayPage/cubit/cubit/song_player_cubit.dart';

import '../../core/config/assets/app_vectors.dart';

class SongsPlayPage extends StatelessWidget {
  const SongsPlayPage({super.key, required this.songModel});
  final SongModel songModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        title: Text(
          "Now playing",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: Icon(Icons.more_vert_rounded),
      ),
      body: BlocProvider(
        create: (context) =>
            SongPlayerCubit()..loadSong(songModel.urlSongsbase),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0.h),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: Colors.grey[300],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    width: 160.w,
                    imageUrl: songModel.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.music_note),
                    placeholder: (context, url) => Container(
                      height: 150.h,
                      width: 160.w,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(songModel.title,
                            style: TextStyle(
                                fontSize: 20.sp, fontWeight: FontWeight.w600)),
                        Text(songModel.artist,
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        AppVectors.loveSong,
                        width: 35.w,
                        height: 35.h,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.h,
                ),
                _songPlayer(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _songPlayer(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
        builder: (context, state) {
      final getSong = context.read<SongPlayerCubit>();
      if (state is SongPlayerLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is SongPlayerLoaded) {
        return Column(
          children: [
            Slider(
              activeColor: AppColors.primaryColor,
              value: getSong.songPosition.inSeconds.toDouble(),
              min: 0.0,
              max: getSong.songDuration.inSeconds.toDouble(),
              onChanged: (value) {
                context
                    .read<SongPlayerCubit>()
                    .seekTo(Duration(seconds: value.toInt()));
              },
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(getSong.songPosition)),
                Text(formatDuration(getSong.songDuration)),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            GestureDetector(
              onTap: () {
                getSong.playOrpauseSong();
              },
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.primaryColor),
                child: getSong.audioPlayer.playing
                    ? const Icon(
                        Icons.pause,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
              ),
            )
          ],
        );
      } else if (state is SongPlayerFailure) {
        return Center(
          child: Text(state.errorMessage!),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
}
