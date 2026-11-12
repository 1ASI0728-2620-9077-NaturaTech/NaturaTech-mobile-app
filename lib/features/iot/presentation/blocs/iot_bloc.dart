import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_latest_reading_use_case.dart';
import 'iot_event.dart';
import 'iot_state.dart';

class IotBloc extends Bloc<IotEvent, IotState> {
  final GetLatestReadingUseCase getLatestReading;

  IotBloc(this.getLatestReading) : super(IotInitial()) {
    on<FetchLatestTelemetry>((event, emit) async {
      emit(IotLoading());
      try {
        final reading = await getLatestReading.execute(event.nodeId);
        emit(IotLoaded(reading));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });
  }
}