import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

enum OTPCorrectEvent { TRUE, FALSE }

class OTPCorrectBloc extends Bloc<OTPCorrectEvent, bool> {
  OTPCorrectBloc() : super(true);

  @override
  void onTransition(Transition<OTPCorrectEvent, bool> transition) {
    super.onTransition(transition);
    log(transition.toString());
  }

  @override
  Stream<bool> mapEventToState(OTPCorrectEvent event) async* {
    if (event is OTPCorrectEvent) {
      switch (event) {
        case OTPCorrectEvent.TRUE:
          yield true;
          break;
        case OTPCorrectEvent.FALSE:
          yield false;
          break;
      }
    }
  }
}

enum SubmitAvailableEvent { TRUE, FALSE }

class SubmitAvailableBloc extends Bloc<SubmitAvailableEvent, bool> {
  SubmitAvailableBloc() : super(false);

  @override
  Stream<bool> mapEventToState(SubmitAvailableEvent event) async* {
    if (event is SubmitAvailableEvent) {
      switch (event) {
        case SubmitAvailableEvent.TRUE:
          yield true;
          break;
        case SubmitAvailableEvent.FALSE:
          yield false;
          break;
      }
    }
  }
}
