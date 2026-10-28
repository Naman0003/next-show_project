// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_concierge_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiConciergeControllerHash() =>
    r'2ac655538dfafc5a1f244808b728adfba543feac';

/// Idle -> Listening (voice) -> Fetching -> Success, with Error reachable
/// from either Listening (mic permission/recognition failure) or Fetching
/// (search failure).
///
/// Copied from [AiConciergeController].
@ProviderFor(AiConciergeController)
final aiConciergeControllerProvider = AutoDisposeNotifierProvider<
    AiConciergeController, AiConciergeState>.internal(
  AiConciergeController.new,
  name: r'aiConciergeControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiConciergeControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AiConciergeController = AutoDisposeNotifier<AiConciergeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
