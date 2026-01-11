import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/log_repository.dart';

enum PlaceFilter { everyone, yourPlaces, friendsOnly }
enum ToGoFilter { all, visited, wishlist }

class UserLastTag {
  final String userId;
  final String displayName;
  final LatLng latLng;
  final DateTime taggedAt;
  final bool isFriend;

  UserLastTag({
    required this.userId,
    required this.displayName,
    required this.latLng,
    required this.taggedAt,
    required this.isFriend,
  });
}

class ToGoPlace {
  final String id;
  final String title;
  final LatLng latLng;
  final bool visited; // true=visited, false=wishlist

  ToGoPlace({
    required this.id,
    required this.title,
    required this.latLng,
    required this.visited,
  });
}

class EmojiRecord {
  final String id;
  final String emoji;
  final String title;
  final LatLng latLng;

  EmojiRecord({
    required this.id,
    required this.emoji,
    required this.title,
    required this.latLng,
  });
}

class TabMapScreen extends StatefulWidget {
  final LogRepository logRepository;

  const TabMapScreen({
    super.key,
    required this.logRepository,
  });

  @override
  State<TabMapScreen> createState() => _TabMapScreenState();
}

class _TabMapScreenState extends State<TabMapScreen> {
  final MapController _mapController = MapController();

  PlaceFilter _placeFilter = PlaceFilter.everyone;
  ToGoFilter _toGoFilter = ToGoFilter.all;

  LatLng? _myLatLng;
  StreamSubscription<Position>? _posSub;

  // TODO: later replace with DB (Supabase/Firestore) or use widget.logRepository
  final List<UserLastTag> _othersLastTags = [
    UserLastTag(
      userId: "u1",
      displayName: "Min",
      latLng: LatLng(37.7879, -122.4074),
      taggedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      isFriend: true,
    ),
    UserLastTag(
      userId: "u2",
      displayName: "Jae",
      latLng: LatLng(37.7869, -122.4090),
      taggedAt: DateTime.now().subtract(const Duration(hours: 3)),
      isFriend: false,
    ),
    UserLastTag(
      userId: "u3",
      displayName: "Yebin",
      latLng: LatLng(37.7890, -122.4060),
      taggedAt: DateTime.now().subtract(const Duration(minutes: 55)),
      isFriend: true,
    ),
  ];

  // kept (not used for markers in this demo)
  final List<ToGoPlace> _toGoPlaces = [
    ToGoPlace(
      id: "p1",
      title: "Cafe A",
      latLng: LatLng(37.7882, -122.4072),
      visited: true,
    ),
    ToGoPlace(
      id: "p2",
      title: "Museum B",
      latLng: LatLng(37.7872, -122.4086),
      visited: false,
    ),
    ToGoPlace(
      id: "p3",
      title: "Bookstore C",
      latLng: LatLng(37.7892, -122.4069),
      visited: true,
    ),
  ];

  // ---------------------------
  // ✅ helpers
  // ---------------------------
  LatLng _offset(LatLng base, double dLat, double dLng) {
    return LatLng(base.latitude + dLat, base.longitude + dLng);
  }

  String get _placeFilterEmoji {
    switch (_placeFilter) {
      case PlaceFilter.everyone:
        return "🌍";
      case PlaceFilter.yourPlaces:
        return "👤";
      case PlaceFilter.friendsOnly:
        return "👥";
    }
  }

  String get _placeFilterLabel {
    switch (_placeFilter) {
      case PlaceFilter.everyone:
        return "everyone";
      case PlaceFilter.yourPlaces:
        return "your places";
      case PlaceFilter.friendsOnly:
        return "friends only";
    }
  }

  // ✅ markers appear near your current location / map center
  List<EmojiRecord> get _activePlaceFilterMarkers {
    final base = _myLatLng ?? const LatLng(37.7879, -122.4074); // SF fallback

    switch (_placeFilter) {
      case PlaceFilter.everyone:
        return [
          EmojiRecord(
            id: "pf_e1",
            emoji: "🌍",
            title: "everyone spot",
            latLng: _offset(base, 0.0012, 0.0008),
          ),
          EmojiRecord(
            id: "pf_e2",
            emoji: "🗺️",
            title: "public place",
            latLng: _offset(base, -0.0010, -0.0006),
          ),
        ];
      case PlaceFilter.yourPlaces:
        return [
          EmojiRecord(
            id: "pf_y1",
            emoji: "👤",
            title: "your save",
            latLng: _offset(base, 0.0009, -0.0010),
          ),
          EmojiRecord(
            id: "pf_y2",
            emoji: "🏠",
            title: "your area",
            latLng: _offset(base, -0.0007, 0.0011),
          ),
        ];
      case PlaceFilter.friendsOnly:
        return [
          EmojiRecord(
            id: "pf_f1",
            emoji: "👥",
            title: "friend rec",
            latLng: _offset(base, 0.0013, -0.0003),
          ),
          EmojiRecord(
            id: "pf_f2",
            emoji: "🤝",
            title: "friends spot",
            latLng: _offset(base, -0.0012, 0.0004),
          ),
        ];
    }
  }

  List<EmojiRecord> get _activeToGoFilterMarkers {
    final base = _myLatLng ?? const LatLng(37.7879, -122.4074); // SF fallback

    switch (_toGoFilter) {
      case ToGoFilter.all:
        return [
          EmojiRecord(
            id: "tg_a1",
            emoji: "🧭",
            title: "to-go list",
            latLng: _offset(base, 0.0004, 0.0014),
          ),
          EmojiRecord(
            id: "tg_a2",
            emoji: "📍",
            title: "to-go spot",
            latLng: _offset(base, -0.0004, -0.0014),
          ),
        ];
      case ToGoFilter.visited:
        return [
          EmojiRecord(
            id: "tg_v1",
            emoji: "✅",
            title: "visited",
            latLng: _offset(base, 0.0016, 0.0002),
          ),
          EmojiRecord(
            id: "tg_v2",
            emoji: "🥳",
            title: "done!",
            latLng: _offset(base, -0.0015, -0.0001),
          ),
        ];
      case ToGoFilter.wishlist:
        return [
          EmojiRecord(
            id: "tg_w1",
            emoji: "🔖",
            title: "wishlist",
            latLng: _offset(base, 0.0002, -0.0017),
          ),
          EmojiRecord(
            id: "tg_w2",
            emoji: "✨",
            title: "want to go",
            latLng: _offset(base, -0.0002, 0.0017),
          ),
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _myLatLng = LatLng(pos.latitude, pos.longitude);
    });

    _mapController.move(_myLatLng!, 15.5);

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((p) {
      setState(() {
        _myLatLng = LatLng(p.latitude, p.longitude);
      });
    });
  }

  List<UserLastTag> get _filteredOthers {
    switch (_placeFilter) {
      case PlaceFilter.everyone:
        return _othersLastTags;
      case PlaceFilter.yourPlaces:
        return const [];
      case PlaceFilter.friendsOnly:
        return _othersLastTags.where((e) => e.isFriend).toList();
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // 내 위치
    if (_myLatLng != null) {
      markers.add(
        Marker(
          point: _myLatLng!,
          width: 44,
          height: 44,
          child: const _MyLocationDot(),
        ),
      );
    }

    // ✅ TOP filter emojis
    for (final e in _activePlaceFilterMarkers) {
      markers.add(
        Marker(
          point: e.latLng,
          width: 80,
          height: 80,
          child: _EmojiPin(
            emoji: e.emoji,
            title: e.title,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${e.emoji}  ${e.title}")),
            ),
          ),
        ),
      );
    }

    // ✅ BOTTOM filter emojis
    for (final e in _activeToGoFilterMarkers) {
      markers.add(
        Marker(
          point: e.latLng,
          width: 80,
          height: 80,
          child: _EmojiPin(
            emoji: e.emoji,
            title: e.title,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${e.emoji}  ${e.title}")),
            ),
          ),
        ),
      );
    }

    // other people last tag (still visible)
    for (final u in _filteredOthers) {
      markers.add(
        Marker(
          point: u.latLng,
          width: 100,
          height: 70,
          child: _UserTagMarker(
            label: u.displayName,
            isFriend: u.isFriend,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${u.displayName}'s last tag")),
              );
            },
          ),
        ),
      );
    }

    return markers;
  }

  void _openPlaceFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _FilterSheet(
          placeFilter: _placeFilter,
          onPlaceFilterChanged: (v) => setState(() => _placeFilter = v),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = _myLatLng ?? const LatLng(37.7879, -122.4074); // SF fallback

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 14.5,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.to_goling_mvp",
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // top-left pill filter
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: _openPlaceFilterSheet,
                  child: _PillButton(
                    emoji: _placeFilterEmoji,
                    label: _placeFilterLabel,
                  ),
                ),
              ),
            ),
          ),

          // bottom To-Go filter chips
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 120),
                child: Row(
                  children: [
                    _Chip(
                      selected: _toGoFilter == ToGoFilter.all,
                      label: "🧭 To-Go: all",
                      onTap: () => setState(() => _toGoFilter = ToGoFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      selected: _toGoFilter == ToGoFilter.visited,
                      label: "✅ visited",
                      onTap: () => setState(() => _toGoFilter = ToGoFilter.visited),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      selected: _toGoFilter == ToGoFilter.wishlist,
                      label: "🔖 wishlist",
                      onTap: () => setState(() => _toGoFilter = ToGoFilter.wishlist),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _UserTagMarker extends StatelessWidget {
  final String label;
  final bool isFriend;
  final VoidCallback onTap;

  const _UserTagMarker({
    required this.label,
    required this.isFriend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = isFriend ? "👥" : "🌍";

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x22000000))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Icon(Icons.place, color: isFriend ? Colors.green : Colors.black, size: 22),
        ],
      ),
    );
  }
}

class _EmojiPin extends StatelessWidget {
  final String emoji;
  final String title;
  final VoidCallback onTap;

  const _EmojiPin({
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
              boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x22000000))],
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [BoxShadow(blurRadius: 10, color: Color(0x22000000))],
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String emoji;
  final String label;

  const _PillButton({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x22000000))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _Chip({required this.selected, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x22000000))],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final PlaceFilter placeFilter;
  final ValueChanged<PlaceFilter> onPlaceFilterChanged;

  const _FilterSheet({
    required this.placeFilter,
    required this.onPlaceFilterChanged,
  });

  String _emojiFor(PlaceFilter f) {
    switch (f) {
      case PlaceFilter.everyone:
        return "🌍";
      case PlaceFilter.yourPlaces:
        return "👤";
      case PlaceFilter.friendsOnly:
        return "👥";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(blurRadius: 30, color: Color(0x33000000))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "showing places from",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _RadioRow(
            emoji: _emojiFor(PlaceFilter.everyone),
            title: "everyone (including you)",
            selected: placeFilter == PlaceFilter.everyone,
            onTap: () {
              onPlaceFilterChanged(PlaceFilter.everyone);
              Navigator.pop(context);
            },
          ),
          _RadioRow(
            emoji: _emojiFor(PlaceFilter.yourPlaces),
            title: "your places",
            selected: placeFilter == PlaceFilter.yourPlaces,
            onTap: () {
              onPlaceFilterChanged(PlaceFilter.yourPlaces);
              Navigator.pop(context);
            },
          ),
          _RadioRow(
            emoji: _emojiFor(PlaceFilter.friendsOnly),
            title: "friends only",
            selected: placeFilter == PlaceFilter.friendsOnly,
            onTap: () {
              onPlaceFilterChanged(PlaceFilter.friendsOnly);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String emoji;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.emoji,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.black : Colors.black26,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
