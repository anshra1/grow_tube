import 'package:objectbox/objectbox.dart';

@Entity()
class ClipboardHistoryModel {
  ClipboardHistoryModel({required this.copiedText, this.id = 0});
  @Id()
  int id;

  String copiedText;
}
