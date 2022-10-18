import 'package:equatable/equatable.dart';

class ImageEntity extends Equatable {
  final String size;
  final String text;

  const ImageEntity({
    required this.size,
    required this.text,
  });

  @override
  List<Object> get props => [size, text];
}
