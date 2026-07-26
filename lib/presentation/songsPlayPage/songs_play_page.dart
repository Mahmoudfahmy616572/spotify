import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart' show LoopMode;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart'
    show ItemScrollController, ScrollablePositionedList;
import 'package:spotify/common/appbar/basic_appbar.dart';
import 'package:spotify/core/config/theme/app_colors.dart';
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:spotify/presentation/DownloadedSongs/cubit/download_songs_for_offline_cubit.dart';
import 'package:spotify/presentation/DownloadedSongs/cubit/download_songs_for_offline_state.dart';

import '../../core/config/assets/app_vectors.dart';
import '../LikedSongs/cubit/favourite_songs_cubit.dart';
import '../LikedSongs/cubit/favourite_songs_state.dart';
import '../Queue/cubit/queue_cubit.dart';
import '../Queue/queue_page.dart';
import 'cubit/lyrics/lyrics_cubit.dart';
import 'cubit/lyrics/lyrics_state.dart';
import 'cubit/song_player_cubit.dart';
import 'cubit/song_player_state.dart';

class SongsPlayPage extends StatefulWidget {
  const SongsPlayPage(
      {super.key,
      required this.songModel,
      required this.songs,
      required this.index});
  final SongModel songModel;
  final List<SongModel> songs;
  final int index;

  @override
  State<SongsPlayPage> createState() => _SongsPlayPageState();
}

class _SongsPlayPageState extends State<SongsPlayPage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  int _currentLineIndex = -1;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SongPlayerCubit>();

    if (cubit.playList.isEmpty ||
        cubit.playList[cubit.currentIndex].id != widget.songModel.id) {
      cubit.loadSong(widget.songs, widget.index, widget.songModel.imageUrl);
    }

    context.read<LyricsCubit>().fetchLyrics(
          trackName: widget.songModel.title,
          artistName: widget.songModel.artist,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        final cubit = context.read<SongPlayerCubit>();
        final backgroundColor = cubit.dominantColor;
        if (cubit.playList.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final currentIndexSong = cubit.playList[cubit.currentIndex];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                backgroundColor.withOpacity(0.6),
                const Color(0xff121212),
              ])),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: BasicAppbar(
              title: Text(
                "Now playing",
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB7B7B7)),
              ),
              actions: IconButton(
                icon: const Icon(
                  Icons.queue_music,
                  color: Color(0xFFB7B7B7),
                ),
                onPressed: () {
                  final playerCubit = context.read<SongPlayerCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: playerCubit,
                        child: BlocProvider(
                          create: (_) => QueueCubit(playerCubit)..loadQueue(),
                          child: const QueuePage(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15.0.r),
                child: Column(
                  children: [
                    Hero(
                      tag: 'album_art_${currentIndexSong.id}',
                      child: Container(
                        width: double.infinity,
                        height: 340.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          color: Colors.grey[300],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: _buildAlbumArtStack(currentIndexSong),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildSongInfo(currentIndexSong),
                    SizedBox(height: 40.h),
                    _songPlayer(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Row _buildSongInfo(SongModel song) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(song.title,
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text(song.artist,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white)),
            ],
          ),
        ),
        Row(
          children: [
            BlocBuilder<DownloadSongsForOfflineCubit,
                DownloadSongsForOfflineState>(
              builder: (context, state) {
                if (state is! DownloadSongsForOfflineLoaded) {
                  return IconButton(
                    onPressed: () {
                      context
                          .read<DownloadSongsForOfflineCubit>()
                          .downloadSongsForOffline(
                              widget.songs[widget.index]);
                    },
                    icon: const Icon(Icons.downloading_outlined),
                    color: Colors.grey,
                  );
                }
                final st = state;
                final progress =
                    st.downloads[widget.songs[widget.index].id] ?? 0.0;
                final isDownloaded =
                    st.completedIds.contains(widget.songs[widget.index].id);
                if (progress > 0 && progress < 1) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2.5,
                        color: Colors.green,
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.white),
                      ),
                    ],
                  );
                } else {
                  return IconButton(
                    onPressed: () {
                      context
                          .read<DownloadSongsForOfflineCubit>()
                          .downloadSongsForOffline(
                              widget.songs[widget.index]);
                    },
                    icon: isDownloaded
                        ? const Icon(Icons.download_done)
                        : const Icon(Icons.downloading_outlined),
                    color: isDownloaded ? Colors.green : Colors.grey,
                  );
                }
              },
            ),
            BlocBuilder<FavouriteSongsCubit, FavouriteSongsState>(
              builder: (context, state) {
                bool isFavourite = context
                    .watch<FavouriteSongsCubit>()
                    .isFavourite(widget.songs[widget.index].id);
                if (state is FavouriteSongsLoaded) {
                  isFavourite = state.favouriteSongsIds.contains(
                      widget.songs[widget.index].id.toString());
                }
                return IconButton(
                  onPressed: () {
                    context.read<FavouriteSongsCubit>().toggleFavourite(
                        widget.songs[widget.index]);
                  },
                  icon: Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                );
              },
            )
          ],
        ),
      ],
    );
  }

  Stack _buildAlbumArtStack(SongModel song) {
    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: song.imageUrl,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                const Icon(Icons.music_note),
          ),
        ),
        Positioned.fill(
          child: BlocBuilder<LyricsCubit, LyricsState>(
            builder: (context, lyricsState) {
              final bool hasLyrics =
                  lyricsState is LyricsLoaded && lyricsState.lyrics.isNotEmpty;
              if (!hasLyrics) return const SizedBox.shrink();

              return BlocBuilder<SongPlayerCubit, SongPlayerState>(
                builder: (context, playerState) {
                  final bool isvisible = playerState is SongPlayerLoaded &&
                      playerState.isLyricsVisible;
                  if (!isvisible) return const SizedBox.shrink();

                  final parsedLyrics = (lyricsState as LyricsLoaded).lyrics;

                  return StreamBuilder<Duration>(
                    stream: context
                        .read<SongPlayerCubit>()
                        .audioPlayer
                        .positionStream,
                    builder: (context, snapshot) {
                      final currentPosition =
                          snapshot.data ?? Duration.zero;

                      int activeIndex = parsedLyrics.lastIndexWhere(
                          (line) => currentPosition >= line.startTime);

                      if (activeIndex != -1 &&
                          activeIndex != _currentLineIndex &&
                          itemScrollController.isAttached) {
                        _currentLineIndex = activeIndex;
                        itemScrollController.scrollTo(
                          index: activeIndex,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                          alignment: 0.3,
                        );
                      }

                      return Container(
                        color: Colors.black.withOpacity(0.7),
                        child: ScrollablePositionedList.builder(
                          itemScrollController: itemScrollController,
                          itemCount: parsedLyrics.length,
                          itemBuilder: (context, index) {
                            final line = parsedLyrics[index];
                            final isHighlighted = index == activeIndex;

                            return AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isHighlighted ? 22.sp : 18.sp,
                                fontWeight: isHighlighted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isHighlighted
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 12.h),
                                child: Text(line.text,
                                    textAlign: TextAlign.center),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _songPlayer(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
        builder: (context, state) {
      final getSong = context.read<SongPlayerCubit>();
      if (state is SongPlayerLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is SongPlayerLoaded) {
        return StreamBuilder(
            stream: getSong.audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = getSong.songDuration;

              return Column(
                children: [
                  Slider(
                    activeColor: const Color(0xFFB7B7B7),
                    value: position.inSeconds
                        .toDouble()
                        .clamp(0.0, total.inSeconds.toDouble()),
                    min: 0.0,
                    max: total.inSeconds.toDouble() > 0
                        ? total.inSeconds.toDouble()
                        : 1.0,
                    onChanged: (value) {
                      context
                          .read<SongPlayerCubit>()
                          .seekTo(Duration(seconds: value.toInt()));
                    },
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(position),
                        style: const TextStyle(color: Color(0xFFB7B7B7)),
                      ),
                      Text(formatDuration(total),
                          style:
                              const TextStyle(color: Color(0xFFB7B7B7))),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => getSong.toggleRepeatMode(),
                        child: SvgPicture.asset(
                          AppVectors.repeate,
                          width: 30.w,
                          height: 30.h,
                          color: getSong.loopMode == LoopMode.off
                              ? const Color(0xFFA7A7A7)
                              : AppColors.primaryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => getSong.playPrevious(),
                        child: SvgPicture.asset(AppVectors.previousSong,
                            width: 30.w,
                            height: 30.h,
                            color: const Color(0xFFA7A7A7)),
                      ),
                      GestureDetector(
                        onTap: () => getSong.playOrpauseSong(),
                        child: Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor),
                          child: getSong.audioPlayer.playing
                              ? const Icon(Icons.pause,
                                  color: Colors.white)
                              : const Icon(Icons.play_arrow,
                                  color: Colors.white),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => getSong.playNext(),
                        child: SvgPicture.asset(AppVectors.nextSong,
                            width: 30.w,
                            height: 30.h,
                            color: const Color(0xFFA7A7A7)),
                      ),
                      GestureDetector(
                        onTap: () => getSong.toggleShuffleMode(),
                        child: SvgPicture.asset(
                          AppVectors.shuffle,
                          width: 30.w,
                          height: 30.h,
                          color: getSong.isShuffleMode
                              ? AppColors.primaryColor
                              : const Color(0xFFA7A7A7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Center(
                    child: BlocBuilder<LyricsCubit, LyricsState>(
                      builder: (context, lyricsState) {
                        final hasLyrics = lyricsState is LyricsLoaded &&
                            lyricsState.lyrics.isNotEmpty;
                        return TextButton(
                          onPressed: hasLyrics
                              ? () {
                                  context
                                      .read<SongPlayerCubit>()
                                      .toggleShowLyrics();
                                }
                              : null,
                          child: Text(
                            !hasLyrics
                                ? "No lyrics available"
                                : state.isLyricsVisible
                                    ? "Hide Lyrics"
                                    : "Show Lyrics",
                            style: TextStyle(
                              color: hasLyrics
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            });
      } else if (state is SongPlayerFailure) {
        return Center(
          child: Text(state.errorMessage ?? "Error"),
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
