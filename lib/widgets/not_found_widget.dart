import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';

class NotFoundWidget extends StatelessWidget {
  final String title;
  final String desc;
  const NotFoundWidget({super.key,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      height: MediaQuery.sizeOf(context).height*0.15,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: AppColors.appSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),),
            SizedBox(height: 16,),
            Text(desc,style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),)
          ],
        ),
      ),
    );
  }
}
