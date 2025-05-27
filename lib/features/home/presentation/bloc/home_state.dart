part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryEntity> categories;
  final List<LocationEntity> locations;
  final List<ItemPreviewEntity> recentFoundItems;
  final List<ItemPreviewEntity> recentLostItems;

  const HomeLoaded({
    required this.categories,
    required this.locations,
    required this.recentFoundItems,
    required this.recentLostItems,
  });

  @override
  List<Object> get props => [categories, locations, recentFoundItems, recentLostItems];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}