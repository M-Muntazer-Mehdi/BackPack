import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';

class Dialogue extends StatefulWidget {
  final onTap;
  final header;
  final subheader;
  final action;
  final back;
  const Dialogue(
      {Key? key,
      this.onTap,
      required this.action,
      required this.back,
      required this.header,
      this.subheader = ''})
      : super(key: key);

  @override
  DialogueState createState() => DialogueState();
}

class DialogueState extends State<Dialogue> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 3),
                    blurRadius: 5),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.header,
                style: subHeadingText(size: 18),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                widget.subheader,
                style: regularText(size: 13),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.action != null)
                    ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                          ),
                          backgroundColor:
                              MaterialStatePropertyAll(AppColors.primaryColor),
                        ),
                        onPressed: () {
                          Get.back();
                          widget.onTap();
                        },
                        child: Text(widget.action)),
                  if (widget.back != null)
                    ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                          ),
                          backgroundColor: MaterialStatePropertyAll(
                              AppColors.scaffoldGrey.withOpacity(0.6)),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(widget.back)),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
