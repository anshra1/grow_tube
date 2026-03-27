void main() {
  final list = [1, 2, 3];
  list.add(4); // ✅ allowed
  list[3] = 55; // ❌ not allowed
  print(list);
}
