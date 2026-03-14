abstract interface class IconKitProvider<TDeclaration, TResult> {
  Future<List<TDeclaration>> loadDeclarations();

  TResult? resolveIcon(TDeclaration declaration);
}

final class ResolvedSvgCandidate<TData> {
  const ResolvedSvgCandidate({required this.data, required this.sourcePath});

  final TData data;
  final String sourcePath;
}
