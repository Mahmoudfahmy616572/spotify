import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850] ?? Colors.grey[800]!,
      highlightColor: Colors.grey[750] ?? Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey[850] ?? Colors.grey[800],
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

class SongListShimmer extends StatelessWidget {
  final int itemCount;
  const SongListShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => Row(
        children: [
          ShimmerWidget(width: 56.w, height: 56.h, borderRadius: 8),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(width: 180.w, height: 14.h, borderRadius: 4),
                SizedBox(height: 8.h),
                ShimmerWidget(width: 120.w, height: 12.h, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalCardShimmer extends StatelessWidget {
  final int itemCount;
  final double cardWidth;
  final double cardHeight;
  final bool circular;

  const HorizontalCardShimmer({
    super.key,
    this.itemCount = 5,
    this.cardWidth = 140,
    this.cardHeight = 180,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    final double totalHeight = (circular ? cardWidth : cardHeight) + 36;
    return SizedBox(
      height: totalHeight.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerWidget(
              width: cardWidth.w,
              height: circular ? cardWidth.w : cardHeight.h,
              borderRadius: circular ? 100 : 12,
            ),
            SizedBox(height: 8.h),
            ShimmerWidget(width: (cardWidth * 0.7).w, height: 12.h, borderRadius: 4),
            SizedBox(height: 6.h),
            ShimmerWidget(width: (cardWidth * 0.5).w, height: 10.h, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

class ChartListShimmer extends StatelessWidget {
  final int itemCount;
  const ChartListShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, __) => Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            ShimmerWidget(width: 46.w, height: 46.h, borderRadius: 8),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget(width: 140.w, height: 13.h, borderRadius: 4),
                  SizedBox(height: 6.h),
                  ShimmerWidget(width: 90.w, height: 11.h, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
