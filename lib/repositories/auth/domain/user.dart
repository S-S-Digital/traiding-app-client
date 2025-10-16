import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.phone,
    
  });

  
  final String id;
  final String email;
  final String phone;


  

  @override
  List<Object?> get props => [id, email, phone];
}
