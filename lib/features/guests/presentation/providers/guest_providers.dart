import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/guests/data/repositories/guest_repository.dart';
import 'package:dawati/core/errors/failures.dart';

/// موفر قائمة الضيوف لمناسبة محددة
final guestsListProvider = FutureProvider.family<List<GuestModel>, String>((
  ref,
  eventId,
) async {
  final repo = ref.read(guestRepositoryProvider);
  final result = await repo.getGuests(eventId: eventId);
  if (result is Success<List<GuestModel>>) return result.data;
  return [];
});

/// موفر البحث في الضيوف (حالة محلية للبحث)
final guestSearchQueryProvider = StateProvider<String>((ref) => '');

/// موفر قائمة الضيوف المفلترة
final filteredGuestsProvider = Provider.family<List<GuestModel>, String>((
  ref,
  eventId,
) {
  final guestsAsync = ref.watch(guestsListProvider(eventId));
  final query = ref.watch(guestSearchQueryProvider).toLowerCase();

  return guestsAsync.maybeWhen(
    data: (guests) {
      if (query.isEmpty) return guests;
      return guests
          .where(
            (g) =>
                g.name.toLowerCase().contains(query) || g.phone.contains(query),
          )
          .toList();
    },
    orElse: () => [],
  );
});
