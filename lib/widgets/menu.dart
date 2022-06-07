import 'package:flutter/material.dart';
import 'package:web_app/constants/color.dart';
import 'package:web_app/constants/config.dart';
import 'package:web_app/widgets/button.dart';

class SelectionMenu extends StatefulWidget {
  final void Function(String) onPressed;
  final List<String> selections;

  const SelectionMenu({
    Key? key,
    required this.selections,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<SelectionMenu> createState() => _SelectionMenuState();
}

class _SelectionMenuState extends State<SelectionMenu> {
  String _selection = "";

  @override
  void initState() {
    _selection = widget.selections.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(
          widget.selections.length,
          (index) => Expanded(
            child: MyTextButton(
              fontSize: 15,
              elevation: 0,
              title: widget.selections[index],
              onPressed: () => {
                setState(() {
                  _selection = widget.selections[index];
                  widget.onPressed(_selection);
                })
              },
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              color: _selection == widget.selections[index]
                  ? kYellowColor
                  : kPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class MainMenu extends StatelessWidget {
  final String pageRoute;

  const MainMenu({
    Key? key,
    required this.pageRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 35,
            child: Image.asset("images/avatar.png"),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "LobbeyTan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: kHeaderFontSize,
              ),
            ),
          ),
          Text(
            "Manager",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: kNormalFontSize,
            ),
          ),
          const SizedBox(
            height: 60,
          ),
          Expanded(
            child: ListView.separated(
              itemCount: kMenuItem.length,
              itemBuilder: (BuildContext context, int i) => MainMenuItem(
                icon: kMenuItem[i]['icon'] ?? Icons.warning,
                title: kMenuItem[i]['title'] ?? "",
                isSelected: pageRoute == kMenuItem[i]['route'],
                onPressed: () => {
                  Navigator.popAndPushNamed(context, kMenuItem[i]['route']),
                },
              ),
              separatorBuilder: (BuildContext context, i) =>
                  const SizedBox(height: 20),
            ),
          ),
          MainMenuItem(
            icon: Icons.exit_to_app_outlined,
            title: "Exit",
            onPressed: () => {},
          ),
        ],
      ),
    );
  }
}

class MainMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;
  final bool isSelected;

  const MainMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      elevation: 5,
      child: ListTile(
        enabled: true,
        onTap: onPressed,
        minLeadingWidth: 30,
        selected: isSelected,
        mouseCursor: SystemMouseCursors.click,
        textColor: Colors.white,
        iconColor: Colors.white.withOpacity(0.7),
        tileColor: kPrimaryColor.withBlue(255).withOpacity(0.1),
        selectedTileColor: kYellowColor,
        selectedColor: Colors.white,
        hoverColor: Colors.black,
        contentPadding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(kRadius),
            bottomRight: Radius.circular(kRadius),
          ),
        ),
        leading: Icon(
          icon,
          size: 25,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: kNormalFontSize,
          ),
        ),
      ),
    );
  }
}
