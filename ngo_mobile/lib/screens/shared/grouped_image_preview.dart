import 'dart:io';

import 'package:flutter/material.dart';

class GroupedImagePreview extends StatelessWidget {
  final List<String> images;
  final String emptyText;
  final ValueChanged<int>? onRemove;
  final bool highlightLast;
  final int maxVisible;
  final double tileSize;
  final double singleImageHeight;

  const GroupedImagePreview({
    super.key,
    required this.images,
    this.emptyText = 'Aucune image',
    this.onRemove,
    this.highlightLast = false,
    this.maxVisible = 6,
    this.tileSize = 86,
    this.singleImageHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }
    if (images.length == 1) {
      return _buildSingleLargeImage(context, images.first);
    }

    final visibleCount = images.length > maxVisible ? maxVisible : images.length;
    final hiddenCount = images.length - visibleCount;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(visibleCount, (index) {
        final pathOrUrl = images[index];
        final isOverflowTile = hiddenCount > 0 && index == visibleCount - 1;
        return _buildTile(
          context,
          pathOrUrl: pathOrUrl,
          index: index,
          isOverflowTile: isOverflowTile,
          hiddenCount: hiddenCount,
        );
      }),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String pathOrUrl,
    required int index,
    required bool isOverflowTile,
    required int hiddenCount,
  }) {
    final isNetwork = pathOrUrl.startsWith('http');
    return Stack(
      children: [
        Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlightLast && index == images.length - 1
                  ? const Color(0xFF0FB37D)
                  : const Color(0xFFE7ECEF),
              width: highlightLast && index == images.length - 1 ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              onTap: () => _openFullScreenImage(context, pathOrUrl),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  isNetwork
                      ? Image.network(
                          pathOrUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _errorTile();
                          },
                        )
                      : Image.file(
                          File(pathOrUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _errorTile();
                          },
                        ),
                  if (isOverflowTile)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text(
                        '+$hiddenCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () => onRemove!(index),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSingleLargeImage(BuildContext context, String pathOrUrl) {
    final isNetwork = pathOrUrl.startsWith('http');
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: singleImageHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE7ECEF)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: InkWell(
              onTap: () => _openFullScreenImage(context, pathOrUrl),
              child: isNetwork
                  ? Image.network(
                      pathOrUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _errorTile(),
                    )
                  : Image.file(
                      File(pathOrUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _errorTile(),
                    ),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            right: 6,
            top: 6,
            child: InkWell(
              onTap: () => onRemove!(0),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _errorTile() {
    return Container(
      color: Colors.grey.withAlpha(51),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  void _openFullScreenImage(BuildContext context, String pathOrUrl) {
    final bool isNetwork = pathOrUrl.startsWith('http');
    showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: Stack(
          children: [
            Center(
              child: isNetwork
                  ? InteractiveViewer(
                      child: Image.network(
                        pathOrUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _errorTile(),
                      ),
                    )
                  : InteractiveViewer(
                      child: Image.file(
                        File(pathOrUrl),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _errorTile(),
                      ),
                    ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
