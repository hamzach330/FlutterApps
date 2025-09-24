part of xcf_protocol;

class XCFCompanyInfo {
  final String companyName;
  final String technicianName;
  final String projectName;
  final String projectId;
  final String projectLocation;
  final String street;
  final String postcode;
  final String city;
  final String country;
  final String comment1;
  final String comment2;
  final String comment3;

  XCFCompanyInfo({
    required this.companyName,
    required this.projectId,
    required this.technicianName,
    required this.projectLocation,
    required this.projectName,
    required this.street,
    required this.postcode,
    required this.city,
    required this.country,
    required this.comment1,
    required this.comment2,
    required this.comment3,
  });
}
