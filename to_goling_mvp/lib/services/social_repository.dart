import 'dart:async';

class TgUser {
  final String id;
  final String name;
  final String emoji;

  const TgUser({
    required this.id,
    required this.name,
    required this.emoji,
  });
}

class TgPost {
  final String id;
  final TgUser user;
  final DateTime createdAt;
  final String locationName;
  final String text;
  final String moodEmoji;
  final int likes;
  final int comments;
  final bool hasPhoto;

  const TgPost({
    required this.id,
    required this.user,
    required this.createdAt,
    required this.locationName,
    required this.text,
    required this.moodEmoji,
    required this.likes,
    required this.comments,
    required this.hasPhoto,
  });
}

/// Fake backend-style repository.
/// Later, replace internals with Supabase / Firebase
/// while keeping the same API.
class SocialRepository {
  SocialRepository._();

  static final SocialRepository instance = SocialRepository._();

  // ---- seed users ----
  final List<TgUser> _allUsers = const [
    TgUser(id: "u1", name: "Minsoo", emoji: "🧃"),
    TgUser(id: "u2", name: "Yebin", emoji: "🫧"),
    TgUser(id: "u3", name: "JeeSeung", emoji: "🎧"),
    TgUser(id: "u4", name: "Min", emoji: "🍒"),
    TgUser(id: "u5", name: "Hana", emoji: "🍋"),
    TgUser(id: "u6", name: "Joon", emoji: "🪩"),
  ];

  // ---- following set (Instagram-style) ----
  // "me" follows these users
  final Set<String> _followingIds = {"u1", "u2", "u3", "u4"};

  List<TgUser> get allUsers => List.unmodifiable(_allUsers);

  List<TgUser> get followingUsers =>
      _allUsers.where((u) => _followingIds.contains(u.id)).toList(growable: false);

  bool isFollowing(String userId) => _followingIds.contains(userId);

  int get followingCount => _followingIds.length;

  // stub (later from backend)
  int get followersCount => 128;

  Future<void> toggleFollow(String userId) async {
    // fake latency (feels real)
    await Future.delayed(const Duration(milliseconds: 180));
    if (_followingIds.contains(userId)) {
      _followingIds.remove(userId);
    } else {
      _followingIds.add(userId);
    }
  }

  Future<List<TgPost>> getFeedPosts() async {
    await Future.delayed(const Duration(milliseconds: 220));
    final now = DateTime.now();

    // seed posts from everyone
    final posts = <TgPost>[
      TgPost(
        id: "p1",
        user: _allUsers[0],
        createdAt: now.subtract(const Duration(minutes: 14)),
        locationName: "Inheon 3-gil",
        text: "I suddenly felt really good today… just walking around and logged this ⚡️",
        moodEmoji: "🌙",
        likes: 23,
        comments: 4,
        hasPhoto: true,
      ),
      TgPost(
        id: "p2",
        user: _allUsers[2],
        createdAt: now.subtract(const Duration(hours: 2)),
        locationName: "Nambu Ring Road",
        text: "Went to a cafe to get things done… ended up just chatting again lol",
        moodEmoji: "☕️",
        likes: 71,
        comments: 12,
        hasPhoto: false,
      ),
      TgPost(
        id: "p3",
        user: _allUsers[1],
        createdAt: now.subtract(const Duration(hours: 5)),
        locationName: "Dream Park",
        text: "Starting a running routine. Just 20 minutes today! 🏃‍♀️",
        moodEmoji: "🏃‍♀️",
        likes: 55,
        comments: 9,
        hasPhoto: true,
      ),
      TgPost(
        id: "p4",
        user: _allUsers[4],
        createdAt: now.subtract(const Duration(hours: 8)),
        locationName: "Nakseongdae",
        text: "Found a new bakery. Definitely coming back here 🥐",
        moodEmoji: "🥐",
        likes: 34,
        comments: 3,
        hasPhoto: true,
      ),
      TgPost(
        id: "p5",
        user: _allUsers[5],
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
        locationName: "Inheon 9-gil",
        text: "Updated my to-go list. Let’s go here next 🥯",
        moodEmoji: "📍",
        likes: 18,
        comments: 2,
        hasPhoto: false,
      ),
    ];

    // IMPORTANT: feed = only followed users (Instagram mode)
    final filtered = posts.where((p) => _followingIds.contains(p.user.id)).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }
}
