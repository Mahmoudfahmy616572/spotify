import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show SizeExtension;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spotify/common/appbar/basic_appbar.dart';
import 'package:spotify/data/models/songs/songs_model.dart';

import '../songsPlayPage/songs_play_page.dart';

class DownloadedsongsPage extends StatelessWidget {
  const DownloadedsongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BasicAppbar(
          title: Row(
            children: [
              Text(
                "Downloaded Songs",
                style: TextStyle(fontSize: 27.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        body: ValueListenableBuilder(
            valueListenable: Hive.box("offline_songs").listenable(),
            builder: (context, Box pathBox, _) {
              final downloadedIds = pathBox.keys.toList();
              if (downloadedIds.isEmpty) {
                return const Center(child: Text("No offline music yet"));
              }
              return ListView.builder(
                  itemCount: downloadedIds.length,
                  itemBuilder: (context, index) {
                    final String songId = downloadedIds[index];
                    final metaBox = Hive.box("songs_metadata");
                    final dynamic rawData = metaBox.get(songId);

                    // 2. SAFETY CHECK: If metadata doesn't exist yet, don't crash
                    if (rawData == null) {
                      return const SizedBox
                          .shrink(); // Hide the item if metadata is missing
                    }
                    final Map<String, dynamic> songMap =
                        Map<String, dynamic>.from(rawData as Map);

                    final song = SongModel.fromJson(songMap);
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(song.imageUrl,
                            width: 50.w, height: 50.h, fit: BoxFit.cover),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      trailing:
                          const Icon(Icons.check_circle, color: Colors.green),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongsPlayPage(
                              songModel: song,
                              songs: [
                                song
                              ], // You can pass an empty list or fetch related songs
                              index:
                                  0, // Since it's a single song, index can be 0
                            ),
                          ),
                        );
                      },
                    );
                  });
            }));
  }
}
