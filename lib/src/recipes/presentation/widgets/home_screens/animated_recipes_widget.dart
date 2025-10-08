// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ica_app/src/recipes/data/recipe_repository.dart';
import 'package:ica_app/src/recipes/presentation/widgets/home_screens/loaded_recipes_widget.dart';

class AnimatedRecipesWidget extends ConsumerWidget {
  const AnimatedRecipesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final recipes = ref.watch(recipesProvider);
    return recipes.when(
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: Center(
          child: Text(error.toString()),
        ),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      data: (recipes) => LoadedRecipesWidget(
        recipes: recipes,
      ),
    );
  }
}
