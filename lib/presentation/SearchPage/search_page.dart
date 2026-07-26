import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocBuilder, BlocProvider, ReadContext;
import 'package:flutter_screenutil/flutter_screenutil.dart' show SizeExtension;
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:spotify/presentation/SearchPage/cubit/cubit/search_songs_cubit.dart';
import 'package:spotify/presentation/SearchPage/cubit/cubit/search_songs_state.dart';
import 'package:spotify/presentation/songsPlayPage/songs_play_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Timer? debounce;

    return BlocProvider(
      create: (context) => SearchSongsCubit(),
      child: Scaffold(
          body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Search",
                    style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Builder(builder: (searchcontext) {
                return TextField(
                  onChanged: (query) {
                    if (debounce?.isActive ?? false) debounce!.cancel();
                    if (query.trim().isEmpty) {
                      searchcontext.read<SearchSongsCubit>().searchSongs('');
                      return;
                    }
                    debounce = Timer(const Duration(milliseconds: 500), () {
                      searchcontext.read<SearchSongsCubit>().searchSongs(query);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "what do you want to listen to ?",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchcontext.read<SearchSongsCubit>().searchSongs('');
                      },
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor:
                        Colors.white10,
                  ),
                );
              }),
              Expanded(child: BlocBuilder<SearchSongsCubit, SearchSongsState>(
                builder: (context, state) {
                  if (state is SearchSongsLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is SearchSongsLoaded) {
                    return _searchResults(state.songs);
                  }
                  return _buildBrowseAll();
                },
              ))
            ],
          ),
        ),
      )),
    );
  }
}

Widget _searchResults(List<SongModel> songs) {
  if (songs.isEmpty) {
    return Center(child: Text("No results found"));
  }
  return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: song.imageUrl,
              width: 50.w,
              height: 50.h,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.music_note),
            ),
          ),
          title: Text(
            song.title,
          ),
          subtitle: Text(song.artist),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongsPlayPage(
                  songModel: song,
                  songs: songs,
                  index: index,
                ),
              ),
            );
          },
        );
      });
}

Widget _buildBrowseAll() {
  return GridView.builder(
    padding: EdgeInsets.only(top: 20.h),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      childAspectRatio: 1.6,
    ),
    itemCount: 8,
    itemBuilder: (context, index) => Container(
      decoration: BoxDecoration(
          color: Colors.primaries[index % Colors.primaries.length],
          borderRadius: BorderRadius.circular(8.r)),
      padding: EdgeInsets.all(12.r),
      child: Text("Genre Name",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}
