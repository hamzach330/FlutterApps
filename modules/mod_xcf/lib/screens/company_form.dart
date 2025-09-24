part of '../module.dart';

class XCFCompanyForm extends StatefulWidget {
  const XCFCompanyForm({
    super.key,
    required this.onIsComplete,
    required this.onIsIncomplete,
  });

  final void Function() onIsComplete;
  final void Function() onIsIncomplete;

  @override
  State<XCFCompanyForm> createState() => _XCFCompanyFormState();
}

class _XCFCompanyFormState extends State<XCFCompanyForm> {
  late final xcf = Provider.of<XCFProtocol>(context, listen: false);
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String projectName = "";
  String projectLocation = "";
  String projectAddress = "";
  String projectId = "";
  String projectCompany = "";
  String projectTechnician = "";
  String street = "";
  String postcode = "";
  String city = "";
  String country = "";
  String comment1 = "";
  String comment2 = "";
  String comment3 = "";

  bool saving = false;


  XCFCompanyInfo? companyInfo;

  @override
  initState() {
    super.initState();
    unawaited(asyncInit());
  }

  asyncInit() async {
    companyInfo = await xcf.getCompanyInfo();
    setState(() {
      projectName = companyInfo?.projectName ?? "";
      projectLocation = companyInfo?.projectLocation ?? "";
      projectId = companyInfo?.projectId ?? "";
      projectCompany = companyInfo?.companyName ?? "";
      projectTechnician = companyInfo?.technicianName ?? "";
      street = companyInfo?.street ?? "";
      postcode = companyInfo?.postcode ?? "";
      city = companyInfo?.city ?? "";
      country = companyInfo?.country ?? "";
      comment1 = companyInfo?.comment1 ?? "";
      comment2 = companyInfo?.comment2 ?? "";
      comment3 = companyInfo?.comment3 ?? "";

      // projectAddress = companyInfo?.address ?? "";
      _formKey = GlobalKey<FormState>();
    });
    if(projectId.isNotEmpty) {
      widget.onIsComplete();
    }
  }

  Future<void> saveCompanyInfo () async {
    await xcf.setCompanyInfo(XCFCompanyInfo(
      companyName: projectCompany,
      projectId: projectId,
      technicianName: projectTechnician,
      projectLocation: projectLocation,
      projectName: projectName,
      city: city,
      country: country,
      postcode: postcode,
      street: street,
      comment1: comment1,
      comment2: comment2,
      comment3: comment3,
    ));

  }

  Future<void> save() async {
    if(saving) return;

    setState(() {
      saving = true;
    });
    if (_formKey.currentState?.validate() == true) {
      
      await saveCompanyInfo();
      widget.onIsComplete();
    }
    setState(() {
      saving = false;
    });
  }

  String? _validateAscii (String? v) {
    bool? isAscii = v?.codeUnits.every((c) => c <= 127 && c >= 32);

    if (isAscii == false || isAscii == null) {
      return "Keine Umlaute oder Sonderzeichen.".i18n;
    }

    return null;
  }

  String? _validateMaxLen (String? v, [int maxLen = 3]) {
    return max(maxLen, (v?.length ?? 0)) < maxLen ? "Maximal $maxLen Zeichen".i18n : null;
  }

  String? _validateMinLen (String? v, [int minLen = 3]) {
    return min(minLen, (v?.length ?? 0)) < minLen ? "Mindestens $minLen Zeichen".i18n : null;
  }

  String? _validateAsciiMinMaxLen (String? v, [int minLen = 3, int maxLen = 3]) {
    return _validateAscii(v) ?? _validateMinLen(v, minLen) ?? _validateMaxLen(v, maxLen);
  }

  Future<void> validate () async {
    if (_formKey.currentState?.validate() == true) {
      widget.onIsComplete();
    } else {
      widget.onIsIncomplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          UICTextFormField(
            initialValue: projectCompany,
            label: "Firma".i18n,
            hintText: "Firma".i18n,
            maxLength: 32,
            onChanged: (v) {
              projectCompany = v;
              validate();
            },
            validator: _validateAsciiMinMaxLen,
            isDense: false,
          ),

          UICTextFormField(
            initialValue: projectTechnician,
            label: "Monteur".i18n,
            hintText: "Monteur".i18n,
            maxLength: 32,
            onChanged: (v) {
              projectTechnician = v;
              validate();
            },
            validator: _validateAsciiMinMaxLen,
            isDense: false,
          ),

          const Divider(),

            
          Row(
            spacing: theme.defaultWhiteSpace,
            children: [
              Expanded(
                child: UICTextFormField(
                  initialValue: projectName,
                  label: "Bauvorhaben".i18n,
                  hintText: "Bauvorhaben".i18n,
                  maxLength: 32,
                  onChanged: (v) {
                    projectName = v;
                    validate();
                  },
                  validator: _validateAsciiMinMaxLen,
                  isDense: false,
                ),
              ),

              SizedBox(
                width: 150,
                child: UICTextFormField(
                  initialValue: projectId,
                  label: "Projektnummer".i18n,
                  hintText: "Projektnummer".i18n,
                  maxLength: 32,
                  onChanged: (v) {
                    projectId = v;
                    validate();
                  },
                  validator: _validateAsciiMinMaxLen,
                  isDense: false,
                ),
              ),
            ],
          ),

          UICTextFormField(
            initialValue: projectLocation,
            label: "Montageort".i18n,
            hintText: "Montageort".i18n,
            maxLength: 32,
            onSaved: (v) {
              projectLocation = v!;
            },
            onChanged: (v) {
              projectLocation = v;
              validate();
            },
            validator: _validateAsciiMinMaxLen,
            isDense: false,
          ),

          const Divider(),

          // End Address
          Row(
            spacing: theme.defaultWhiteSpace,
            children: [
              SizedBox(
                width: 150,
                child: UICTextFormField(
                  initialValue: postcode,
                  label: "Postleitzahl".i18n,
                  hintText: "Postleitzahl".i18n,
                  maxLength: 32,
                  onSaved: (v) {
                    postcode = v!;
                  },
                  onChanged: (v) {
                    postcode = v;
                    validate();
                  },
                  validator: _validateAsciiMinMaxLen,
                  isDense: false,
                ),
              ),
              Expanded(
                child: UICTextFormField(
                  initialValue: city,
                  label: "Ort".i18n,
                  hintText: "Ort".i18n,
                  maxLength: 32,
                  onSaved: (v) {
                    city = v!;
                  },
                  onChanged: (v) {
                    city = v;
                    validate();
                  },
                  validator: _validateAsciiMinMaxLen,
                  isDense: false,
                ),
              ),
            ],
          ),

          UICTextFormField(
            initialValue: street,
            label: "Straße".i18n,
            hintText: "Straße".i18n,
            maxLength: 32,
            onSaved: (v) {
              street = v!;
            },
            onChanged: (v) {
              street = v;
              validate();
            },
            validator: _validateAsciiMinMaxLen,
            isDense: false,
          ),

          UICTextFormField(
            initialValue: country,
            label: "Land".i18n,
            hintText: "Land".i18n,
            maxLength: 32,
            onSaved: (v) {
              country = v!;
            },
            onChanged: (v) {
              country = v;
              validate();
            },
            validator: _validateAsciiMinMaxLen,
            isDense: false,
          ),

          const Divider(),

          UICTextFormField(
            initialValue: comment1,
            label: "Kommentarfeld 1".i18n,
            hintText: "Kommentarfeld 1".i18n,
            maxLength: 32,
            onSaved: (v) {
              comment1 = v!;
            },
            onChanged: (v) {
              comment1 = v;
              validate();
            },
            validator: _validateAscii,
            isDense: false,
          ),

          UICTextFormField(
            initialValue: comment2,
            label: "Kommentarfeld 2".i18n,
            hintText: "Kommentarfeld 2".i18n,
            maxLength: 32,
            onSaved: (v) {
              comment2 = v!;
            },
            onChanged: (v) {
              comment2 = v;
              validate();
            },
            validator: _validateAscii,
            isDense: false,
          ),

          UICTextFormField(
            initialValue: comment3,
            label: "Kommentarfeld 3".i18n,
            hintText: "Kommentarfeld 3".i18n,
            maxLength: 32,
            onSaved: (v) {
              comment3 = v!;
            },
            onChanged: (v) {
              comment3 = v;
              validate();
            },
            validator: _validateAscii,
            isDense: false,
          ),

          // End Address

          UICElevatedButton(
            onPressed: save,
            style: UICColorScheme.success,
            child: saving ? UICProgressIndicator.small() : Text("Speichern".i18n),
          ),
        ]
      ),
    );
  }
}
