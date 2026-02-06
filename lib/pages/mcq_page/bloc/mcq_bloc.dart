import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'mcq_event.dart';
part 'mcq_state.dart';

class McqBloc extends Bloc<McqEvent, McqState> {
  McqBloc() : super(McqInitial()) {
    on<McqEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
