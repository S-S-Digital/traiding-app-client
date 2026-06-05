import 'package:aspiro_trade/repositories/digest/digest.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'digest_state.dart';

class DigestCubit extends Cubit<DigestState> {
  DigestCubit({required this.digestRepository}) : super(DigestInitial());

  final DigestRepositoryI digestRepository;

  Future<void> fetchDigests() async {
    emit(DigestLoading());
    try {
      final digests = await digestRepository.fetchLatestDigests();
      emit(DigestLoaded(digests: digests));
    } catch (e) {
      emit(DigestFailure(error: e));
    }
  }
}
