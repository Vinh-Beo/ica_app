import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ica_app/src/cores/themes/app_colors.dart';
import 'package:ica_app/src/utils/ext/app_gradient.dart';
import 'package:ica_app/src/utils/ext/app_text_style_ext.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PCustomizeAppBar extends StatefulWidget implements PreferredSizeWidget {
  // ignore: sort_constructors_first
  // ignore: use_key_in_widget_constructors
  const PCustomizeAppBar(
      {this.title,
      this.isShowLeadingButton = true,
      this.titleCenter = true,
      this.rightWidget,
      this.colorBackground = Colors.white,
      this.colorTitle = AppColors.colorTextPrimary,
      this.colorBackButton = AppColors.colorWhite,
      this.content,
      this.brightness = Brightness.dark,
      this.leftWidget,
      this.leadingWidth = 120,
      this.url,
      this.onLeftTap});

  final String? url;
  final String? title;
  final bool isShowLeadingButton;
  final bool? titleCenter;
  final Color? colorBackground;
  final Color? colorTitle;
  final Color? colorBackButton;
  final Widget? rightWidget;
  final Widget? leftWidget;
  final Widget? content;
  final Brightness? brightness;
  final double? leadingWidth;
  final void Function()? onLeftTap;

  @override
  _PCustomizeAppBarState createState() => _PCustomizeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  static Widget? buildRightRowWidget(Widget? child1, Widget? child2,
      {void Function()? onTap1, void Function()? onTap2}) {
    if (child1 == null || child2 == null) {
      return null;
    }
    return Container(
        width: const Size.fromHeight(kToolbarHeight * 1.9).height,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                onTap1?.call();
              },
              child: Center(
                child: child1,
              ),
            ),
            const SizedBox(width: 20),
            ClipOval(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () {
                      onTap2?.call();
                    },
                    child: Center(
                      child: child2,
                    )),
              ),
            ),
          ],
        ));
  }

  static Widget? buildRightWidget(Widget? child, {void Function()? onTap}) {
    if (child == null) {
      return null;
    }
    return Container(
      width: const Size.fromHeight(kToolbarHeight).height,
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () {
                onTap?.call();
              },
              child: Center(
                child: child,
              )),
        ),
      ),
    );
  }

  static Widget buildBackButton(BuildContext context, {Function? onTap}) {
    return Builder(
      builder: (BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 4),
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () {
                      if (onTap == null) {
                        Navigator.pop(context);
                      } else {
                        onTap.call();
                      }
                    },
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/back_arrow.svg',
                        width: 32,
                        height: 32,
                      ),
                    )),
              ),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          GestureDetector(
            onTap: () {
              if (onTap == null) {
                Navigator.pop(context);
              } else {
                onTap.call();
              }
            },
            child: Text(
              'Back',
              style: context.body1TextStyle()?.copyWith(color: Colors.black, fontSize: 15),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PCustomizeAppBarState extends State<PCustomizeAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: widget.colorBackground != null
          ? Container()
          : Container(
              decoration: const BoxDecoration(
              gradient: AppGradient.gradientPrimary,
            )),
      backgroundColor: widget.colorBackground,
      elevation: 0,
      leading: !widget.isShowLeadingButton
          ? Container()
          : widget.url != null
              ? CachedNetworkImage(
                  imageUrl: widget.url!,
                  width: 50,
                  height: 50,
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/img_avatar_unlogin.png',
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                )
              : widget.leftWidget ?? PCustomizeAppBar.buildBackButton(context, onTap: widget.onLeftTap),
      // titleSpacing: 12,
      title: widget.title != null
          ? Text(
              widget.title ?? '',
              style: context.headerStyle()?.copyWith(color: widget.colorTitle, fontWeight: FontWeight.w600),
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : widget.content ?? Container(),
      centerTitle: widget.titleCenter,
      leadingWidth: !widget.isShowLeadingButton ? 0 : widget.leadingWidth,
      actions: <Widget>[widget.rightWidget ?? Container()],
      //brightness: widget.brightness,
    );
  }
}
