import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/utils/text_styles.dart';

class ExpandedTile extends StatefulWidget {
  final String title;
  final Widget child;
  const ExpandedTile({super.key, required this.title, required this.child});

  @override
  State<ExpandedTile> createState() => _ExpandedTileState();
}

class _ExpandedTileState extends State<ExpandedTile>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;

  AnimationController? controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    controller!.duration = const Duration(milliseconds: 200);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration:
          ContainerProperties.shadowDecoration(blurRadius: 4, spreadRadius: 3),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (controller!.isCompleted) {
                controller!.reverse();
                return;
              }

              controller!.forward();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: subHeadingText(size: 16),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  )
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: CurvedAnimation(
              curve: Curves.ease,
              parent: controller!,
            ),
            child: widget.child,
          )
        ],
      ),
    );
  }
}
