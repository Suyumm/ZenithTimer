import 'dart:convert';
import 'package:crypto/crypto.dart';

// Isar 3 actually uses MurmurHash3 (32-bit) x 2, or sometimes CityHash, but in fact it uses Isar core fast hash.
// Since we have Isar available as a dependency, let's just use the hash function FROM ISAR.
import 'package:isar/isar.dart';

void main() {
  print(fastHash('SessionEntry'));
}

/// FNV-1a 64bit
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}
