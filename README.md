<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

[![pub package](https://img.shields.io/pub/v/collapsible_side_menu.svg)](https://pub.dartlang.org/packages/collapsible_side_menu)
[![codecov](https://codecov.io/gh/belinda-g-freitas/collapsible_side_menu/branch/main/graph/badge.svg?token=XBhsIZBbZG)](https://codecov.io/gh/belinda-g-freitas/collapsible_side_menu)
<a href="https://pub.dev/packages/collapsible_side_menu"><img alt="GitHub Repo stars" src="https://github.com/belinda-g-freitas/collapsible-side-menu"></a>
<a href="https://github.com/belinda-g-freitas/collapsible-side-menu/graphs/contributors"><img alt="GitHub contributors" src="https://img.shields.io/belinda-g-freitas/contributors/belinda-g-freitas/collapsible_side_menu"></a>
<a href="https://githubc.com/belinda-g-freitas/collapsible_side_menu/issues?q=is%3Aissue+is%3Aclosed"><img src="https://img.shields.io/github/issues-closed-raw/belinda-g-freitas/collapsible_side_menu" alt="GitHub closed issues"></a>
<a href="https://github.com/belinda-g-freitas/collapsible_side_menu"><img src="https://img.shields.io/github/contributors/belinda-g-freitas/collapsible_side_menu?logo=github&labelColor=333940" alt="contributors"></a>
![GitHub Sponsors](https://img.shields.io/github/sponsors/belinda-g-freitas)

# collapsible_side_menu

`collapsible_side_menu` is a highly customizable Flutter package for building a collapsible side menu, with text direction (LTR & RTL) and sub-menu features.

| Mobile |                                                                           Desktop                                                                           |                                                                                                            Web                                                                                                            |
| :----: | :---------------------------------------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| TODO:  | <video controls><source src="https://github.com/belinda-g-freitas/collapsible_side_menu/assets/collapsible_side_menu_desktop.mp4" type="video/mp4"></video> | <a href="https://github.com/belinda-g-freitas/collapsible_side_menu/assets/collapsible_side_menu_web.png"><img src="https://github.com/belinda-g-freitas/collapsible_side_menu/assets/collapsible_side_menu_web.png"></a> |

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Quick start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  collapsible_side_menu: ^1.0.0+1
```

OR

```sh
flutter pub add collapsible_side_menu
```

### Basic usage

```dart
SideMenu(
  defaultIndex: 3,
  defaultBehaviour: .open,
  toggleButtonStyle: const ToggleButtonStyle(topPosition: 55, iconSize: 16),
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
                  onTap: () {
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
        SideMenuTileData(onTap: () {}, title: 'Vehicle', leading: const Icon(Icons.car_rental, size: 18)),
        SideMenuTileData(
          onTap: () {},
          title: 'Conversations',
          leading: const Icon(Icons.chat_bubble_outline, size: 18),
          selectedLeading: const Icon(Icons.chat_bubble, size: 18),
          badgeBuilder: (tile) =>
              Badge.count(count: 100, maxCount: 9, offset: Offset(menuData.textDirection == .rtl ? 2 : -2, -4), child: tile),
        ),
        SideMenuTileData(title: 'Labels', leading: const Icon(Icons.label_outline), selectedLeading: const Icon(Icons.label)),
        SideMenuTileData(
          onTap: () {
            showAdaptiveAboutDialog(context: context);
          },
          title: 'About',
          leading: const Icon(Icons.info_outline, size: 18),
          selectedLeading: const Icon(Icons.info, size: 18),
        ),
        SideMenuTileData(
          onTap: () {
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


```

### Elements, types, usage and description

| Element                            |  Type  |  Usage  |                                                                       Description |
| :--------------------------------- | :----: | :-----: | --------------------------------------------------------------------------------: |
| <a href="#0">SideMenu</a>          | Widget |  Menu   |                                                              The side menu widget |
| <a href="#1">SideMenuStyle</a>     | Class  |  Style  |                                                              Menu container style |
| <a href="#2">MenuTileStyle</a>     | Class  |  Style  |                                                                   Menu tile style |
| <a href="#3">SubMenuTileStyle</a>  | Class  |  Style  |                                                               Menu sub-tile style |
| <a href="#4">ToggleButtonStyle</a> | Class  |  Style  |                                      Toggle button style (to open/close the menu) |
| SideMenuController                 | Class  |  Data   |                                                                   Menu controller |
| SideMenuBuilderData                | Class  | Builder |                                                                      Menu builder |
| SideMenuData                       | Class  |  Data   |                                                            Data to build the menu |
| SideMenuItemAnimationData          | Class  |  Data   |       Add custom animation to menu elements (header, custom child, items, footer) |
| SideMenuTitleData                  | Class  |  Data   | Add a simple text with custom style (with no background or tap callback) to items |
| SideMenuDividerData                | Class  |  Data   |                                              Add a custom divider widget to items |
| SideMenuTileData                   | Class  |  Data   |                                                              Data to build a tile |
| SideMenuSubTileData                | Class  |  Data   |                                                          Data to build a sub-tile |
| TileBadgeBuilder                   | Class  | Builder |                                                   Data to build a badge on a tile |
| CustomChildPosition                |  Enum  |  Enum   |                                                      Position of the custom child |

<br>
<table>
  <tr>
    <th>Style class</th>
    <th>Parameters</th>
    <th>Type</th>
    <th>Default</th>
  </tr>

  <!--  -->
  <tr id="0">
    <td rowspan="10">SideMenu</td>
    <td>builder</td>
    <td>SideMenuBuilder</td>
    <td>none</td>
  </tr>
  <tr>
    <td>controller</td>
    <td>SideMenuController?</td>
    <td>null</td>
  </tr>
  <tr>
    <td>defaultBehaviour</td>
    <td>MenuBehaviour</td>
    <td>MenuBehaviour.auto</td>
  </tr>
  <tr>
    <td>minWidth</td>
    <td>double</td>
    <td>MenuConstants.minWidth</td>
  </tr>
  <tr>
    <td>maxWidth</td>
    <td>double</td>
    <td>MenuConstants.maxWidth</td>
  </tr>
  <tr>
    <td>hasToggleButton</td>
    <td>bool</td>
    <td>true</td>
  </tr>
  <tr>
    <td>toggleButtonStyle</td>
    <td>ToggleButtonStyle?</td>
    <td>null</td>
  </tr>
  <tr>
    <td>duration</td>
    <td>Duration</td>
    <td>MenuConstants.duration</td>
  </tr>
  <tr>
    <td>menuStyle</td>
    <td>SideMenuStyle?</td>
    <td>null</td>
  </tr>
  <tr>
    <td>defaultIndex</td>
    <td>int?</td>
    <td>null</td>
  </tr>

  <!--  -->
  <tr id="1">
    <td rowspan="7">SideMenuStyle</td>
    <td>backgroundColor</td>
    <td>Color?</td>
    <td>colorScheme.primary</td>
  </tr>
  <tr>
    <td>boxShadow</td>
    <td>BoxShadow?</td>
    <td>null</td>
  </tr>
  <tr>
    <td>textDirection</td>
    <td>TextDirection?</td>
    <td>Directionality.of(context)</td>
  </tr>
  <tr>
    <td>borderRadius</td>
    <td>BorderRadiusGeometry</td>
    <td>MenuConstants.borderRadius</td>
  </tr>
  <tr>
    <td>padding</td>
    <td>EdgeInsetsGeometry</td>
    <td>MenuConstants.menuInnerPadding</td>
  </tr>
  <tr>
    <td>margin</td>
    <td>EdgeInsetsGeometry</td>
    <td>MenuConstants.outerPadding</td>
  </tr>
  <tr>
    <td>defaultTileStyle</td>
    <td>MenuTileStyle</td>
    <td>null</td>
  </tr>

  <!--  -->
  <tr id="2">
    <td rowspan="17">MenuTileStyle</td>
    <td>titleStyle</td>
    <td>TextStyle?</td>
    <td>TextStyle(fontSize: 13.7)</td>
  </tr>
  <tr>
    <td>selectedTitleStyle</td>
    <td>TextStyle?</td>
    <td>TextStyle(fontSize: 13.7, fontWeight: .w500)</td>
  </tr>
  <tr>
    <td>color</td>
    <td>Color?</td>
    <td>Set depending on menu background color luminance (if not null), else set to colorScheme.onPrimary</td>
  </tr>
  <tr>
    <td>selectedColor</td>
    <td>Color?</td>
    <td>It's set to Colors.black or Colors.white depending on colorScheme.inversePrimary luminance</td>
  </tr>
  <tr>
    <td>hoverColor</td>
    <td>Color?</td>
    <td>colorScheme.onSecondaryContainer</td>
  </tr>
  <tr>
    <td>backgroundColor</td>
    <td>Color</td>
    <td>MenuConstants.transparent</td>
  </tr>
  <tr>
    <td>selectedBackgroundColor</td>
    <td>Color?</td>
    <td>colorScheme.inversePrimary</td>
  </tr>
  <tr>
    <td>borderRadius</td>
    <td>BorderRadius</td>
    <td>MenuConstants.borderRadius</td>
  </tr>
  <tr>
    <td>decoration</td>
    <td>Decoration?</td>
    <td>BoxDecoration(borderRadius: MenuConstants.borderRadius)</td>
  </tr>
  <tr>
    <td>selectedDecoration</td>
    <td>Decoration?</td>
    <td>BoxDecoration(color: colorScheme.inversePrimary, borderRadius: MenuConstants.borderRadius)</td>
  </tr>
  <tr>
    <td>selectedIndicator</td>
    <td>Decoration?</td>
    <td>BoxDecoration(borderRadius: MenuConstants.borderRadius) with the right color</td>
  </tr>
  <tr>
    <td>padding</td>
    <td>EdgeInsetsGeometry</td>
    <td>EdgeInsets.zero</td>
  </tr>
  <tr>
    <td>margin</td>
    <td>EdgeInsetsGeometry</td>
    <td>MenuConstants.tileMargin</td>
  </tr>
  <tr>
    <td>subTileStyle</td>
    <td> SubMenuTileStyle?</td>
    <td>refer to <a href="#3">SubMenuTileStyle</a> section</td>
  </tr>
  <tr>
    <td>tileHeight</td>
    <td>double</td>
    <td>MenuConstants.tileHeight</td>
  </tr>
  <tr>
    <td>subTileHeight</td>
    <td>double</td>
    <td>MenuConstants.subTileHeight</td>
  </tr>
  <tr>
    <td>horizontalSpacing</td>
    <td>double</td>
    <td>MenuConstants.horizontalSpacing</td>
  </tr>
  
  <!--  -->
  <tr id="3">
    <td rowspan="15">SubMenuTileStyle</td>
    <td>titleStyle</td>
    <td>TextStyle?</td>
    <td>TextStyle(fontSize: 12.3)</td>
  </tr>
  <tr>
    <td>selectedTitleStyle</td>
    <td>TextStyle?</td>
    <td>TextStyle(fontSize: 12.3, fontWeight: .w500)</td>
  </tr>
  <tr>
    <td>selectedColor</td>
    <td>Color?</td>
    <td>colorScheme.onSecondaryContainer</td>
  </tr>
  <tr>
    <td>backgroundColor</td>
    <td>Color</td>
    <td>MenuConstants.transparent</td>
  </tr>
  <tr>
    <td>color</td>
    <td>Color?</td>
    <td>Set depending on background color luminance (if not null), else set to colorScheme.onSecondary</td>
  </tr>
  <tr>
    <td>hoverColor</td>
    <td>Color?</td>
    <td>colorScheme.onSecondaryContainer</td>
  </tr>
  <tr>
    <td>selectedBackgroundColor</td>
    <td>Color?</td>
    <td>null</td>
  </tr>
  <tr>
    <td>borderRadius</td>
    <td>BorderRadius</td>
    <td>MenuConstants.borderRadius</td>
  </tr>
  <tr>
    <td>decoration</td>
    <td>Decoration?</td>
    <td>BoxDecoration(borderRadius: MenuConstants.borderRadius)</td>
  </tr>
  <tr>
    <td>selectedDecoration</td>
    <td>Decoration?</td>
    <td>BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: MenuConstants.borderRadius)</td>
  </tr>
  <tr>
    <td>padding</td>
    <td>EdgeInsetsGeometry</td>
    <td>EdgeInsets.zero</td>
  </tr>
  <tr>
    <td>margin</td>
    <td>EdgeInsetsGeometry</td>
    <td>MenuConstants.tileMargin</td>
  </tr>
  <tr>
    <td>horizontalSpacing</td>
    <td>double</td>
    <td>MenuConstants.horizontalSpacing</td>
  </tr>
  <tr>
    <td>defaultSubTilesStyle</td>
    <td>SubMenuTileStyle?</td>
    <td>null</td>
  </tr>
  <tr>
    <td>tileHeight</td>
    <td>double</td>
    <td>MenuConstants.subTileHeight</td>
  </tr>

  <!--  -->
  <tr id="4">
    <td rowspan="5">ToggleButtonStyle</td>
    <td>iconColor</td>
    <td>Color?</td>
    <td>null</td>
  </tr>
  <tr>
    <td>topPosition</td>
    <td>double</td>
    <td>20</td>
  </tr>
  <tr>
    <td>opacity</td>
    <td>double</td>
    <td>0.7</td>
  </tr>
  <tr>
    <td>iconSize</td>
    <td>double</td>
    <td>20</td>
  </tr>
  <tr>
    <td>icon</td>
    <td>IconData?</td>
    <td>null</td>
  </tr>

</table>

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
