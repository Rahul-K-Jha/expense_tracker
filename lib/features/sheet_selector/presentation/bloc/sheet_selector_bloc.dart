import 'package:flutter_bloc/flutter_bloc.dart';
import 'sheet_selector_event.dart';
import 'sheet_selector_state.dart';

class SheetSelectorBloc extends Bloc<SheetSelectorEvent, SheetSelectorState> {
  SheetSelectorBloc() : super(SheetSelectorInitial());
} 