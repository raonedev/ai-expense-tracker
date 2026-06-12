import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/category/category_model.dart';

part 'category_state.freezed.dart';

@freezed
abstract class CategoryState with _$CategoryState {
  const factory CategoryState({
    @Default(true) bool isLoading,
    @Default([]) List<CategoryModel> categories,
    String? errorMessage,
  }) = _CategoryState;
}