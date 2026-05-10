class SimSwapException implements Exception {
  final String? swapDate;
  final String message;

  SimSwapException({
    this.swapDate,
    this.message = 'A potential SIM swap was detected on your account.',
  });

  @override
  String toString() => message;
}
