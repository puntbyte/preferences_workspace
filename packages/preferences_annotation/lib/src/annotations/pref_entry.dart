import 'package:meta/meta.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

@immutable
class PrefEntry<TypeEntry, TypeStorage> {
  final String? key;
  final bool? notifiable;
  final TypeEntry Function()? initial;

  final CustomConfig? getter;
  final CustomConfig? setter;
  final CustomConfig? remover;

  final CustomConfig? asyncGetter;
  final CustomConfig? asyncSetter;
  final CustomConfig? asyncRemover;

  final CustomConfig? streamer;

  final PrefConverter<dynamic, dynamic>? converter;
  final TypeStorage Function(TypeEntry value)? toStorage;
  final TypeEntry Function(TypeStorage value)? fromStorage;

  const PrefEntry({
    this.key,
    this.notifiable,
    this.initial,

    this.getter,
    this.setter,
    this.remover,

    this.asyncGetter,
    this.asyncSetter,
    this.asyncRemover,

    this.streamer,

    this.converter,
    this.toStorage,
    this.fromStorage,
  }) : assert(
         converter == null || (toStorage == null && fromStorage == null),
         'You can provide `converter` OR `toStorage`/`fromStorage`, but not '
         'both.',
       ),
       assert(
         (toStorage == null) == (fromStorage == null),
         'You must provide both `toStorage` and `fromStorage` together, or '
         'neither.',
       );
}
