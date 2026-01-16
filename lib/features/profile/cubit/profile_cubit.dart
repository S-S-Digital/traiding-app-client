import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UsersRepositoryI usersRepository})
    : _usersRepository = usersRepository,
      super(ProfileInitial());

  final UsersRepositoryI _usersRepository;

  Future<void> start()async{
    try{
      final users = await _usersRepository.getCurrentUser();
      final limits = await _usersRepository.getLimits();

      emit(ProfileLoaded(users: users, limits: limits));
    }
    catch(error){
      emit(ProfileFailure(error: error));
    }
  }
}
