import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';

class BottomSheetApp {

  static void bottomSheetFetchImage(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.sizeOf(context).height*0.65,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              color: Colors.amber.shade200,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AppTextView(title: 'Upload', textStyle: TextStyle(

                    ))
                  ],
                )
              ],
            ),
          );
        });

  }
}
