import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InformModal{
  informRecorderModal(BuildContext context, bool isGermanRecorder){
    final fullScreenSize = MediaQuery.of(context).size;
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context){
          return Container(
              height: isGermanRecorder ? fullScreenSize.height*0.5 : fullScreenSize.height*0.45,
              child: Column(
                children: [
                  Expanded(
                      child:Column(
                        mainAxisAlignment:  MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: InkWell(
                            child: SvgPicture.asset('assets/img/xbutton.svg'),
                            onTap: (){
                              Navigator.pop(context);
                            },
                          ),flex:2),
                          Expanded(child:SizedBox(), flex: 3,),
                        ],
                      ),
                      flex:5
                  ),
                  Expanded(
                    child:Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          topLeft:  Radius.circular(20.0),),
                        color:Colors.white,
                      ),
                      padding: EdgeInsets.fromLTRB(16,0,16,24),
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child:SizedBox(), flex:4),
                          Expanded(child:Text(isGermanRecorder ? '독일식 리코더' : '바로크식 리코더', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 18),), flex:3),
                          Expanded(child:SizedBox(), flex:2),
                          Expanded(child:Text(isGermanRecorder ? '바로크식의 "파"운지를 쉽게 하기 위해 개량한 리코더로 뒷면에 G로 표기합니다. '
                              '어린 학생들에게 친숙하게 다가가기 위해 일반적으로 많이 사용하는 음계의 운지법이 굉장히 쉬워 우리나라에서는 지금까지도'
                              ' 교육용으로 많이 사용됩니다. 하지만 음정이 불안하고 반음 운지나 트릴 운지에서 훨씬 까다롭습니다.' :
                          '예전부터 전통적으로 쓰였던 리코더로 정확하고 확실한 음정이 장점입니다. 일반적으로 리코더의 뒷면에 B또는 E로 표기하며 '
                              '리코더 앞면의 5번 홀이 4번 홀보다 크면 바로크식입니다. 대표적으로 "파"의 운지법에서 독일식과 차이를 보입니다.',
                          style:TextStyle(fontSize: 16, height: 2)), flex:26),
                        ],
                      )
                    ),
                    flex:38
                  ),
                ],
              )
          );
        }
    );
  }
}