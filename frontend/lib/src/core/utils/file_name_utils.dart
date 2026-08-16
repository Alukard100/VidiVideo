String safeUploadFileName(String originalName) {
  final dotIndex = originalName.lastIndexOf('.');
  final extension =
      dotIndex >= 0 ? originalName.substring(dotIndex).toLowerCase() : '';

  return 'upload_${DateTime.now().millisecondsSinceEpoch}$extension';
}