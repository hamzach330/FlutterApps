part of '../module.dart';

class XCFParametersConfiguration extends StatefulWidget {
  const XCFParametersConfiguration({
    super.key
  });

  @override
  State<XCFParametersConfiguration> createState() => _XCFParametersConfigurationState();
}

class _XCFParametersConfigurationState extends State<XCFParametersConfiguration> {
  late final XCFProtocol xcf = Provider.of<XCFProtocol>(context, listen: false);
  final formKey = GlobalKey<FormState>();
  final userType = XCFUserType.Torhersteller;
  bool invalid = false;

  @override
  initState() {
    super.initState();
  }

  Future<void> save () async {
    invalid = false;
    if(formKey.currentState?.validate() ?? false) {
      xcf.setAllParameters();
    } else {
      setState(() {
        invalid = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<XCFProtocol>(
      builder: (context, xcf, child) {
        if(xcf.loadingParameters) {
          return UICProgressIndicator.small();
        }
        final theme = Theme.of(context);
        return Form(
          key: formKey,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(invalid) UICInfo(
                margin: EdgeInsets.all(theme.defaultWhiteSpace),
                style: UICColorScheme.error,
                child: Text("Bitte überprüfen Sie Ihre Eingaben.".i18n),
              ),

              UICElevatedButton(
                onPressed: save,
                child: Text("Speichern".i18n)
              ),
              ...xcf.parameters.values.map((parameter) => SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        
                    if (parameter.options.isNotEmpty  && parameter.paratyp != XCFParameterTypes.BOOL) DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: int.tryParse(parameter.value) ?? 0,
                      onChanged: (v) {
                        setState(() {
                          parameter.value = v.toString();
                        });
                      },
                      items: parameter.options.entries.map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: Text(entry.value, softWrap: true, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      )).toList(),
                      decoration: InputDecoration(
                        labelText: "(P.${parameter.id}) ${parameter.funktion}",
                        border: const OutlineInputBorder(),
                      ),
                    ),
        
                    if (parameter.options.isEmpty && parameter.paratyp != XCFParameterTypes.BOOL) UICTextFormField(
                      initialValue: parameter.value,
                      label: "(P.${parameter.id}) ${parameter.funktion}",
                      hintText: parameter.kurzTextBA,
                      onChanged: (v) {
                        parameter.value = v;
                        formKey.currentState?.validate();
                      },
                      validator: (v) {
        
                        if(parameter.paratyp == XCFParameterTypes.PASSWORT) {
                          if((v?.length ?? 0) < 4) {
                            return "Das Passwort muss 4 Zeichen lang sein.".i18n;
                          } else {
                            return null;
                          }
                        }
        
                        final value = double.tryParse(v?.trim() ?? "");
                        final invalidMin = parameter.min != null && value != null && value < parameter.min!;
                        final invalidMax = parameter.max != null && value != null && value > parameter.max!;
        
                        if(invalidMin && invalidMax || value == null) {
                          return "Bitte geben Sie einen Wert zwischen %s und %s ein.".i18n.fill([
                            parameter.min.toString(),
                            parameter.max.toString()
                          ]);
                        } else if (invalidMin) {
                          return "Bitte geben Sie einen Wert größer als %s ein.".i18n.fill([parameter.min.toString()]);
                        } else if (invalidMax) {
                          return "Bitte geben Sie einen Wert kleiner als %s ein.".i18n.fill([parameter.max.toString()]);
                        }
        
                        return null;
                      },
                      obscureText: parameter.obscure,
                      onObscure: parameter.paratyp != "PASSWORT" ? null :  () {
                        setState(() {
                          parameter.obscure = !parameter.obscure;
                        });
                      },
                      isDense: false,
                    ),
        
                    if (parameter.paratyp == XCFParameterTypes.BOOL) Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text("(P.${parameter.id}) ${parameter.funktion}", textAlign: TextAlign.left)),
                          UICSwitch(
                            value: parameter.value == "1",
                            onChanged: () {
                              setState(() {
                                parameter.value = parameter.value == "1" ? "0" : "1";
                              });
                            },
                          )
                        ]
                      ),
                    ),
                    
                  ],
                ),
              ))
            ]
          ),
        );
      }
    );
  }
}

 