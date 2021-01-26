import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PageViewChild extends StatefulWidget {
  const PageViewChild({
    Key key,
    @required this.fullScreenSize,
    @required this.isRow,
    @required this.imagePath,
    @required this.isSvgPicture,
    @required this.textContent,
    @required this.isImageBig
  }) : super(key: key);

  final Size fullScreenSize;
  final String textContent;
  final bool isRow;
  final bool isSvgPicture;
  final bool isImageBig;
  final List<String> imagePath;

  @override
  _PageViewChildState createState() => _PageViewChildState();
}

class _PageViewChildState extends State<PageViewChild> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                  height:widget.fullScreenSize.height*0.3,
                  width: double.infinity,
                  child: widget.isRow == false ?
                  FittedBox(
                      child:widget.isSvgPicture == false ?
                      Image.asset(widget.imagePath[0])
                          :SvgPicture.asset(widget.imagePath[0]),
                      fit: BoxFit.fitHeight)
                    : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          height:widget.fullScreenSize.height*0.3,
                          width: widget.fullScreenSize.width/2-24,
                          child: FittedBox(
                            child:SvgPicture.asset(widget.imagePath[0]),
                            fit: BoxFit.fitHeight
                          )
                      ),
                      SizedBox(width:16),
                      Container(
                          height:widget.fullScreenSize.height*0.3,
                          width: widget.fullScreenSize.width/2-24,
                          child: FittedBox(
                              child:SvgPicture.asset(widget.imagePath[1]),
                              fit: BoxFit.fitHeight
                          )
                      ),
                    ],
                  )
              ),
              flex: widget.isImageBig ? 28 : 20
            ),
            Expanded(
              child: SizedBox(),
              flex:2
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FittedBox(
                      child: Text(widget.textContent,style:TextStyle(fontSize: 16, height: 1.5)),
                      fit:BoxFit.fitWidth
                  ),
                ],
              ),
              flex: widget.isImageBig ? 23 : 31
            ),
          ],
        )
    );
  }
}
