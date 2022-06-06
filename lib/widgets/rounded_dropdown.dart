import 'package:flutter/material.dart';
import 'package:web_app/constants/color.dart';
import 'package:web_app/constants/config.dart';
import 'package:web_app/widgets/text_field.dart';

class DropdownMenu extends StatefulWidget {
  final String? initialValue;
  final List<String> items;
  final double rightOffset;
  final double overlayMaxHeight;
  final TextEditingController? controller;
  final void Function(String?)? onSelected;

  const DropdownMenu({
    Key? key,
    this.controller,
    this.onSelected,
    this.initialValue,
    this.rightOffset = 10,
    this.items = const [],
    this.overlayMaxHeight = 250,
  }) : super(key: key);

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  final GlobalKey _key = GlobalKey();
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlay();

        Overlay.of(context)!.insert(_overlayEntry);
      } else {
        _overlayEntry.remove();
      }
      setState(() {});
    });

    _controller.text = widget.initialValue ?? widget.items.first;
  }

  OverlayEntry _createOverlay() {
    RenderBox renderBox = _key.currentContext!.findRenderObject()! as RenderBox;
    Size widgetSize = renderBox.size;
    Size screenSize = MediaQuery.of(context).size;

    var offset = renderBox.localToGlobal(Offset.zero);

    double height = (widget.items.length > 4)
        ? widget.overlayMaxHeight
        : (20 + (48 * widget.items.length)).toDouble();

    bool willOverflowY =
        (offset.dy + widgetSize.height + 5 + height) > screenSize.height;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 10,
        top: (willOverflowY)
            ? offset.dy - height - 10
            : offset.dy + widgetSize.height + 5.0,
        width: widgetSize.width + 20,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
          elevation: 4,
          child: SizedBox(
            height: height,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: widget.items.length,
              itemBuilder: (BuildContext context, int index) {
                String val = widget.items[index];
                return ListTile(
                  hoverColor: kPrimaryColor.withOpacity(0.2),
                  title: Text(
                    val,
                    style: const TextStyle(
                      fontSize: kNormalFontSize,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    if (widget.onSelected != null) widget.onSelected!(val);
                    _controller.text = val;
                    setState(() {
                      _focusNode.unfocus();
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _focusNode.requestFocus();
      }),
      child: Focus(
        focusNode: _focusNode,
        child: RoundedTextField(
          key: _key,
          maxLines: 1,
          enabled: false,
          controller: _controller,
          suffixIcon: Icon(
            (_focusNode.hasFocus)
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 28,
          ),
          suffixIconConstraints: BoxConstraints.tightFor(
            width: 34 + widget.rightOffset,
            height: 34,
          ),
        ),
      ),
    );
  }
}
