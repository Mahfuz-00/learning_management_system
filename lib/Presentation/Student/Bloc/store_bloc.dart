import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../Domain/Entities/store_item_entity.dart';
import '../../../Domain/Repositories/store_repository.dart';
import 'dart:developer';

abstract class StoreEvent extends Equatable {
  const StoreEvent();
  @override
  List<Object?> get props => [];
}

class LoadStoreItems extends StoreEvent {}

abstract class StoreState extends Equatable {
  const StoreState();
  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {}
class StoreLoading extends StoreState {}
class StoreLoaded extends StoreState {
  final List<StoreItemEntity> items;
  const StoreLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class StoreError extends StoreState {
  final String message;
  const StoreError(this.message);
  @override
  List<Object?> get props => [message];
}

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRepository repository;

  StoreBloc({required this.repository}) : super(StoreInitial()) {
    on<LoadStoreItems>((event, emit) async {
      log('Bloc: LoadStoreItems');
      emit(StoreLoading());
      final result = await repository.getStoreItems();
      result.fold(
        (failure) => emit(StoreError(failure.message)),
        (items) => emit(StoreLoaded(items)),
      );
    });
  }
}
