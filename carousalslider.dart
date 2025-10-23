import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> bannerImages;
  final bool isLoading;

  const BannerCarousel({
    required this.bannerImages,
    this.isLoading = false,
    super.key,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;
  List<Widget> _cachedImageWidgets = [];
  bool _hasBuiltWidgets = false;
  bool _hasPrintedBannerCount = false; // Track if we've printed the count

  @override
  void initState() {
    super.initState();
    _buildImageWidgets();
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only rebuild if the banner images actually changed
    if (widget.bannerImages != oldWidget.bannerImages && !_hasBuiltWidgets) {
      _buildImageWidgets();
    }
  }

  void _buildImageWidgets() {
    if (widget.bannerImages.isEmpty) {
      _cachedImageWidgets = [];
      _hasBuiltWidgets = true;
      return;
    }

    // Only build widgets once unless images change
    if (_hasBuiltWidgets && _cachedImageWidgets.isNotEmpty) {
      return;
    }

    // PRINT BANNER COUNT ONLY ONCE
    if (!_hasPrintedBannerCount) {
      print("${DateTime.now()}: Loaded ${widget.bannerImages.length} banner images");
      _hasPrintedBannerCount = true;
    }

    _cachedImageWidgets = widget.bannerImages.map((imageString) {
      try {
        // Handle base64 data URI images
        if (imageString.startsWith('data:image/')) {
          final base64String = imageString.split(',').last;
          final imageBytes = base64.decode(base64String);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: MemoryImage(imageBytes),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        // Handle URL images
        else if (imageString.startsWith('http://') || imageString.startsWith('https://')) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageString,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[300],
                    ),
                    child: Icon(
                      Icons.error,
                      color: Colors.grey[600],
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          );
        }
        // Invalid image format
        else {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[300],
            ),
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[600],
              size: 50,
            ),
          );
        }
      } catch (e) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey[300],
          ),
          child: Icon(
            Icons.error,
            color: Colors.grey[600],
            size: 50,
          ),
        );
      }
    }).toList();
    
    _hasBuiltWidgets = true;
  }

  Widget _buildBannerShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildBannerShimmer(),
      );
    }

    if (widget.bannerImages.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_cachedImageWidgets.isEmpty) {
      return Container(
        height: 100,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Unable to load banners',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  items: _cachedImageWidgets,
                  options: CarouselOptions(
                    height: 180,
                    autoPlay: _cachedImageWidgets.length > 1,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    enlargeFactor: 0.2,
                    autoPlayInterval: const Duration(seconds: 4),
                    onPageChanged: (index, reason) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                  carouselController: _carouselController,
                ),
                if (_cachedImageWidgets.length > 1)
                  Positioned(
                    bottom: 8,
                    child: AnimatedSmoothIndicator(
                      activeIndex: _currentIndex,
                      count: _cachedImageWidgets.length,
                      effect: const WormEffect(
                        activeDotColor: Colors.white,
                        dotColor: Colors.white54,
                        dotHeight: 6,
                        dotWidth: 6,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}