
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class ContentBigControls extends StatelessWidget {
  static const route = '/ContentBigControls';
  static Widget buildRoute(dynamic params) => const ContentBigControls();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const ContentBigControls({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Theme.of(context).defaultWhiteSpace),
      children: [
        const UICTitle("UIC Big Move"),
        
        const UICSpacer(),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UICBigMove(
              onUp: () => UICMessenger.of(context).addMessage(SuccessMessage("Up pressed")),
              onStop: () => UICMessenger.of(context).addMessage(SuccessMessage("Stop pressed")),
              onDown: () => UICMessenger.of(context).addMessage(SuccessMessage("Down pressed")),
              onRelease: () => UICMessenger.of(context).addMessage(ErrorMessage("Button released")),
            ),

            const UICSpacer(3),

            UICBigMove(
              onStop: () {},
              onDown: () {},
              // stopOpacity: .6,
            ),

            const UICSpacer(3),
            
            UICBigMove(
              onUp: () {},
              onStop: () {},
              // stopOpacity: .6,
            ),
          ],
        ),

        const UICSpacer(),
        
        const UICTitle("UIC Big Slider"),

        const UICSpacer(),

        UICBigSlider(
          onChangeEnd: (value) {},
          onChanged: (value) {},
          value: 0,
        ),

        const UICSpacer(),

        const UICTitle("UIC Big Switch"),

        const UICSpacer(),

        UICBigSwitch(
          switchOff: () {},
          switchOn: () {},
          state: true,
        ),

        const UICSpacer(),

        const UICTitle("UIC Color Slider"),

        const UICSpacer(),

        UICColorSlider(
          onChange: (_) {},
          onChangeEnd: (_) {},
        ),

        const UICSpacer(),

        UICColorSlider(
          min: 3,
          max: 15,
          divisions: 12,
          value: 3,
          backgroundGradient: const [
            Color(0xFFFFCD00),
            Color(0xBFFFCD00),
          ],
          onChange: (v) {},
          onChangeEnd: (_) {}
        ),

        const UICSpacer(),

        UICColorSlider(
          min: 1,
          max: 11,
          divisions: 10,
          value: 1,
          onChange: (v) {},
          onChangeEnd: (_) {},
          backgroundGradient: const [
            Colors.white,
            Colors.red
          ],
          altRightColor: Colors.white,
          altLeftColor: Colors.red,
        ),
      ],
    );
  }
}
