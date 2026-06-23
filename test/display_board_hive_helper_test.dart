// import 'package:azan/core/helpers/display_board_hive_helper.dart';
// import 'package:azan/core/models/display_announcement.dart';
// import 'package:azan/core/models/home_display_mode.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   group('Display board announcement helpers', () {
//     test('HomeDisplayMode.fromId falls back to standard', () {
//       expect(
//         HomeDisplayMode.fromId('display_board'),
//         HomeDisplayMode.displayBoard,
//       );
//       expect(HomeDisplayMode.fromId('unknown'), HomeDisplayMode.standard);
//       expect(HomeDisplayMode.fromId(null), HomeDisplayMode.standard);
//     });

//     test(
//       'normalizeAnnouncements reorders sortOrder and keeps one active pin',
//       () {
//         final normalized = DisplayBoardHiveHelper.normalizeAnnouncements([
//           const DisplayAnnouncement(
//             id: 5,
//             title: 'A',
//             body: 'A body',
//             active: true,
//             pinned: true,
//             sortOrder: 7,
//           ),
//           const DisplayAnnouncement(
//             id: 8,
//             title: 'B',
//             body: 'B body',
//             active: true,
//             pinned: true,
//             sortOrder: 1,
//           ),
//           const DisplayAnnouncement(
//             id: 2,
//             title: 'C',
//             body: 'C body',
//             active: false,
//             pinned: true,
//             sortOrder: 9,
//           ),
//         ]);

//         expect(normalized.map((item) => item.sortOrder).toList(), [0, 1, 2]);
//         expect(
//           normalized
//               .where((item) => item.pinned)
//               .map((item) => item.id)
//               .toList(),
//           [8],
//         );
//       },
//     );

//     test(
//       'resolveDisplayAnnouncementForFrame returns pinned item when present',
//       () {
//         final pinned = const DisplayAnnouncement(
//           id: 2,
//           title: 'Pinned',
//           body: 'Pinned body',
//           active: true,
//           pinned: true,
//           sortOrder: 1,
//         );
//         final items = [
//           const DisplayAnnouncement(
//             id: 1,
//             title: 'A',
//             body: 'A body',
//             active: true,
//             pinned: false,
//             sortOrder: 0,
//           ),
//           pinned,
//         ];

//         expect(resolveDisplayAnnouncementForFrame(items, 0)?.id, pinned.id);
//         expect(resolveDisplayAnnouncementForFrame(items, 5)?.id, pinned.id);
//       },
//     );

//     test(
//       'resolveDisplayAnnouncementForFrame rotates active items by sortOrder',
//       () {
//         final items = [
//           const DisplayAnnouncement(
//             id: 11,
//             title: 'Later',
//             body: 'Later body',
//             active: true,
//             pinned: false,
//             sortOrder: 2,
//           ),
//           const DisplayAnnouncement(
//             id: 7,
//             title: 'First',
//             body: 'First body',
//             active: true,
//             pinned: false,
//             sortOrder: 0,
//           ),
//           const DisplayAnnouncement(
//             id: 9,
//             title: 'Second',
//             body: 'Second body',
//             active: true,
//             pinned: false,
//             sortOrder: 1,
//           ),
//         ];

//         expect(resolveDisplayAnnouncementForFrame(items, 0)?.id, 7);
//         expect(resolveDisplayAnnouncementForFrame(items, 1)?.id, 9);
//         expect(resolveDisplayAnnouncementForFrame(items, 2)?.id, 11);
//         expect(resolveDisplayAnnouncementForFrame(items, 3)?.id, 7);
//       },
//     );
//   });
// }
