import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:aspiro_trade/services/widget_service.dart';
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

      // Single source of truth for premium. Emitting the new state is all this
      // cubit does — cache-agent's BlocListener in app_initializer watches this
      // transition (via PremiumGate.isPremium) and owns the reaction: evict
      // persisted caches THEN invalidateMarketData() so blocs refetch in the
      // correct order. We intentionally do NOT fire the bus here, to avoid a
      // double-trigger / refetch-before-eviction race.
      emit(ProfileLoaded(users: users, limits: limits));
      WidgetService.pushPremiumStatus(
        isPremium: limits.isPremium,
        premiumUntil: limits.premiumUntil,
      );
    }
    catch(error){
      emit(ProfileFailure(error: error));
    }
  }

  Future<void> deleteAccount()async{
    try{
      await _usersRepository.deleteAccount();

      emit(DeleteSuccess());
    }catch(error){emit(ProfileFailure(error: error));}
  }
 }
