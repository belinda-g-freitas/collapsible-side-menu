import 'package:flutter/material.dart';

import 'package:collapsible_side_menu/collapsible_side_menu.dart';
import 'package:collapsible_side_menu_example/color_scheme_preview.dart';

import 'main.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _controller = SideMenuController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: .start,
        children: [
          // menu
          SideMenu(
            controller: _controller,
            // defaultIndex: 3,
            // defaultBehaviour: .open,
            toggleButtonStyle: const ToggleButtonStyle(topPosition: 55, iconSize: 16),
            menuStyle: SideMenuStyle(
              // textDirection: .rtl,
            ),
            builder: (menuData, activeIndex) {
              return SideMenuData(
                header: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Row(
                      spacing: 10,
                      mainAxisSize: .min,
                      children: [
                        Flexible(child: CircleAvatar(radius: 22, child: FlutterLogo())),
                        if (menuData.isOpen)
                          Flexible(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  'Joanna Doe',
                                  overflow: .ellipsis,
                                  style: const TextStyle(fontWeight: .w500, fontSize: 14.5),
                                ),
                                Text(
                                  'joanna.doe.404@flutter.dev',
                                  overflow: .ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: .w300),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const Divider(thickness: .5),
                  ],
                ),
                footer: Column(
                  mainAxisAlignment: .end,
                  crossAxisAlignment: .start,
                  children: [
                    const Divider(thickness: .5),
                    Text('v1.0.1+1', style: TextStyle(fontSize: menuData.isOpen ? 12 : 10)),
                  ],
                ),
                items: [
                  SideMenuTileData(
                    title: 'User management',
                    leading: const Icon(Icons.person_outline, size: 18),
                    selectedLeading: const Icon(Icons.person, size: 18),
                    subTiles: [
                      SideMenuSubTileData(title: 'Customers'),
                      SideMenuSubTileData(
                        title: 'Employees',
                        subTiles: [
                          SideMenuSubTileData(title: 'Drivers'),
                          SideMenuSubTileData(title: 'HR'),
                          SideMenuSubTileData(title: 'Accountants'),
                          SideMenuSubTileData(title: 'Marketing'),
                        ],
                      ),
                      SideMenuSubTileData(
                        title: 'Admins',
                        subTiles: [
                          SideMenuSubTileData(
                            onTap: (_) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sudo')));
                            },
                            title: 'Sudo',
                            leading: Icon(Icons.shield, size: 18),
                          ),
                          SideMenuSubTileData(title: 'Super-admins'),
                          SideMenuSubTileData(title: 'Admins'),
                        ],
                      ),
                      SideMenuSubTileData(title: 'Salaries', trailing: Icon(Icons.attach_money, size: 18)),
                    ],
                  ),
                  //
                  SideMenuDividerData(),
                  SideMenuTitleData(title: 'OTHERS'),
                  SideMenuTileData(onTap: (_) {}, title: 'Vehicle', leading: const Icon(Icons.car_rental, size: 18)),
                  SideMenuTileData(
                    onTap: (_) {},
                    title: 'Conversations',
                    leading: const Icon(Icons.chat_bubble_outline, size: 18),
                    selectedLeading: const Icon(Icons.chat_bubble, size: 18),
                    badgeBuilder: (tile) =>
                        Badge.count(count: 100, maxCount: 9, offset: Offset(menuData.textDirection == .rtl ? 2 : -2, -4), child: tile),
                  ),
                  SideMenuTileData(title: 'Labels', leading: const Icon(Icons.label_outline), selectedLeading: const Icon(Icons.label)),
                  SideMenuTileData(
                    onTap: (_) {
                      showAdaptiveAboutDialog(context: context);
                    },
                    title: 'About',
                    leading: const Icon(Icons.info_outline, size: 18),
                    selectedLeading: const Icon(Icons.info, size: 18),
                  ),
                  SideMenuTileData(
                    onTap: (_) {
                      showLicensePage(context: context);
                    },
                    title: 'Licenses',
                    leading: const Icon(Icons.copyright_outlined, size: 18),
                    selectedLeading: const Icon(Icons.copyright, size: 18),
                  ),
                ],
              );
            },
          ),
          // app content
          Expanded(
            child: Padding(
              padding: const .symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: .start,
                spacing: 15,
                children: [
                  SegmentedButton<ThemeMode>(
                    segments: ThemeMode.values.map((e) => ButtonSegment(value: e, label: Text(e.name))).toList(),
                    selected: {themeModeNotifier.value},
                    onSelectionChanged: (value) => themeModeNotifier.value = value.first,
                  ),
                  Expanded(child: ColorSchemePreview()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
