import 'package:equatable/equatable.dart';

class UserAttrEntity extends Equatable {
  final String user;
  final String totalPages;
  final String page;
  final String total;
  final String perPage;

  const UserAttrEntity({
    required this.user,
    required this.totalPages,
    required this.page,
    required this.total,
    required this.perPage,
  });

  @override
  List<Object> get props {
    return [
      user,
      totalPages,
      page,
      total,
      perPage,
    ];
  }
}
