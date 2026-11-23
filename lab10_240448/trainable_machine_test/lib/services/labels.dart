/// "0 Mug\n1 Bottle\n" becomes ['Mug', 'Bottle'].
/// Handles Windows line endings, blank lines and labels containing spaces.
List<String> parseLabels(String raw) => [
      for (final line in raw.split('\n'))
        if (line.trim().isNotEmpty)
          line.trim().replaceFirst(RegExp(r'^\d+\s+'), ''),
    ];
