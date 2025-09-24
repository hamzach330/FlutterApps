import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class ContentInput extends StatelessWidget {
  static const route = '/input';
  static Widget buildRoute(dynamic params) => const ContentInput();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const ContentInput({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Theme.of(context).defaultWhiteSpace),
      children: [
        const UICTitle("Regular Inputs & Label Positions"),
        
        const UICSpacer(),

        UICTextInput(
          labelSide: UICTextInputLabelSide.top,
          label: "Top Label",
          controller: TextEditingController()
        ),

        const UICSpacer(),

        UICTextInput(
          labelSide: UICTextInputLabelSide.top,
          label: "Invalid Top Label",
          invalid: true,
          controller: TextEditingController()
        ),

        const UICSpacer(),

        UICTextInput(
          labelSide: UICTextInputLabelSide.left,
          label: "Left Label",
          controller: TextEditingController()
        ),

        const UICSpacer(),

        UICTextInput(
          labelSide: UICTextInputLabelSide.bottom,
          label: "Bottom Label",
          controller: TextEditingController()
        ),

        const UICSpacer(5),

        const UICTitle("Password Input"),
        
        const UICSpacer(),

        UICTextInput(
          labelSide: UICTextInputLabelSide.top,
          label: "Password Label",
          obscureText: true,
          controller: TextEditingController()
        ),

        const UICSpacer(5),

        const UICTitle("Switches, Checkboxes, Radiobuttons"),

        const UICSpacer(),
        
        UICSwitch(
          label: "Platform adaptive switch",
          onChanged: () {},
          value: false,
        )

      ]
    );
  }
}
