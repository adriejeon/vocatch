import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/hive_service.dart';
import '../../../data/models/vocabulary_group_model.dart';

/// 단어장 그룹 상태를 관리하는 Provider
class GroupNotifier extends StateNotifier<List<VocabularyGroupModel>> {
  GroupNotifier() : super([]) {
    _loadGroups();
  }

  void _loadGroups() {
    final box = HiveService.getGroupsBox();
    state = box.values.toList();
  }

  /// 그룹 생성
  Future<void> createGroup(String name) async {
    final box = HiveService.getGroupsBox();
    final now = DateTime.now();
    final group = VocabularyGroupModel(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: now,
      updatedAt: now,
      wordIds: [],
    );
    await box.put(group.id, group);
    _loadGroups();
  }

  /// 그룹 업데이트
  Future<void> updateGroup(VocabularyGroupModel group) async {
    final box = HiveService.getGroupsBox();
    final updatedGroup = group.copyWith(updatedAt: DateTime.now());
    await box.put(group.id, updatedGroup);
    _loadGroups();
  }

  /// 그룹 삭제
  Future<void> deleteGroup(String groupId) async {
    final box = HiveService.getGroupsBox();
    await box.delete(groupId);
    _loadGroups();
  }

  /// 그룹에 단어 추가
  Future<void> addWordToGroup(String groupId, String wordId) async {
    final box = HiveService.getGroupsBox();
    final group = box.get(groupId);
    if (group != null) {
      final wordIds = List<String>.from(group.wordIds);
      if (!wordIds.contains(wordId)) {
        wordIds.add(wordId);
        final updatedGroup = group.copyWith(
          wordIds: wordIds,
          updatedAt: DateTime.now(),
        );
        await box.put(groupId, updatedGroup);
        _loadGroups();
      }
    }
  }

  /// 그룹에서 단어 제거
  Future<void> removeWordFromGroup(String groupId, String wordId) async {
    final box = HiveService.getGroupsBox();
    final group = box.get(groupId);
    if (group != null) {
      final wordIds = List<String>.from(group.wordIds);
      wordIds.remove(wordId);
      final updatedGroup = group.copyWith(
        wordIds: wordIds,
        updatedAt: DateTime.now(),
      );
      await box.put(groupId, updatedGroup);
      _loadGroups();
    }
  }

  /// 그룹 이름 변경
  Future<void> renameGroup(String groupId, String newName) async {
    final box = HiveService.getGroupsBox();
    final group = box.get(groupId);
    if (group != null) {
      final updatedGroup = group.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await box.put(groupId, updatedGroup);
      _loadGroups();
    }
  }
}

/// 단어장 그룹 Provider
final groupProvider =
    StateNotifierProvider<GroupNotifier, List<VocabularyGroupModel>>((ref) {
  return GroupNotifier();
});
