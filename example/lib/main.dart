import 'package:calendart/calendart.dart';
import 'package:demo_items/demo_items.dart';
import 'package:editors/editors.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: HomePage());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _demos = <String, Widget>{
    'Simple Calendar with Single Selection':
        SimpleCalendarWithSingleSelection(),
    'Simple Calendar with Multi Selection': SimpleCalendarWithSingleSelection(),
  };

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: _demos.length,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Calendar Sample App'),
              bottom: TabBar(
                  tabs: _demos.keys.map((_) => Tab(child: Text(_))).toList()),
            ),
            body: TabBarView(children: _demos.values.toList())),
      );
}

class SimpleCalendarWithSingleSelection extends StatefulWidget {
  const SimpleCalendarWithSingleSelection();

  @override
  _SimpleCalendarWithSingleSelectionState createState() =>
      _SimpleCalendarWithSingleSelectionState();
}

class _SimpleCalendarWithSingleSelectionState
    extends State<SimpleCalendarWithSingleSelection> {
  final _calendarProperties = CalendarProperties();
  GlobalKey<CalendarState> _calendarKey;
  double _width;
  double _height;
  double _separatorWidth;
  double _separatorHeight;

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.all(16),
        children: [
          Column(
            children: [
              DemoItem<CalendarProperties>(
                properties: _calendarProperties,
                childBuilder: (properties) {
                  final separatorWidth =
                      properties.separatorWidth.value?.toDouble() ?? 0.0;
                  final separatorHeight =
                      properties.separatorHeight.value?.toDouble() ?? 0.0;

                  final width = properties.columns.value *
                          (properties.width.value.toDouble() + separatorWidth) -
                      separatorWidth;
                  final height = properties.rows.value *
                          (properties.height.value.toDouble() +
                              separatorHeight) -
                      separatorHeight;
                  // update calendar widget if size changed
                  if (width != _width ||
                      height != _height ||
                      separatorWidth != _separatorWidth ||
                      separatorHeight != _separatorHeight) {
                    _width = width;
                    _height = height;
                    _separatorWidth = separatorWidth;
                    _separatorHeight = separatorHeight;
                    _calendarKey = GlobalKey<CalendarState>();
                  }
                  Calendar createCalendar<T>() => Calendar<T>(
                        key: _calendarKey,
                        displayDate: DateTime(
                            properties.year.value, properties.month.value),
                        columns: properties.columns.value,
                        rows: properties.rows.value,
                      );
                  return ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: width, maxHeight: height),
                    child: () {
                      switch (properties.selectionType.value) {
                        case SelectionType.single:
                          return createCalendar<DateTime>();
                        case SelectionType.multi:
                          return createCalendar<Set<DateTime>>();
                        case SelectionType.range:
                          return createCalendar<DatesRange>();
                        default:
                          return createCalendar();
                      }
                    }(),
                  );
                },
              ),
            ],
          ),
        ],
      );
}

enum SelectionType { none, single, multi, range }

class DemoItem<TProperties extends CalendarProperties>
    extends DemoItemBase<TProperties> {
  const DemoItem({
    Key key,
    @required TProperties properties,
    @required ChildBuilder<TProperties> childBuilder,
  }) : super(key: key, properties: properties, childBuilder: childBuilder);
  @override
  _DemoItemState<TProperties> createState() => _DemoItemState<TProperties>();
}

class _DemoItemState<TProperties extends CalendarProperties>
    extends DemoItemStateBase<TProperties> {
  PreferredSizeWidget _buildHorizontalSeparator(double width, bool custom) {
    final size = Size.fromWidth(width);
    return PreferredSize(
      preferredSize: size,
      child: SizedBox.fromSize(
          size: size,
          child: custom
              ? Container(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blueAccent.withOpacity(0),
                              Colors.blueAccent,
                              Colors.blueAccent.withOpacity(0),
                            ]),
                      ),
                    ),
                  ),
                )
              : null),
    );
  }

  PreferredSizeWidget _buildVerticalSeparator(double height, bool custom) {
    final size = Size.fromHeight(height);
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: SizedBox.fromSize(
          size: size,
          child: custom
              ? Container(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      alignment: Alignment.center,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.blueAccent.withOpacity(0),
                          Colors.blueAccent,
                          Colors.blueAccent.withOpacity(0),
                        ]),
                      ),
                    ),
                  ),
                )
              : null),
    );
  }

  @override
  Widget buildChild() {
    final properties = widget.properties;
    final separatorWidth = properties.separatorWidth.value?.toDouble() ?? 0.0;
    final separatorHeight = properties.separatorHeight.value?.toDouble() ?? 0.0;

    return CalendarContext(
        parameters: CalendarParameters(
          firstDayOfWeekIndex: properties.firstDayOfWeekIndex.value,
          showDaysOfWeek: properties.showDaysOfWeek.value,
          decoratorBuilder: properties.showDecorator.value
              ? (context, date, calendar) => Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.blueAccent,
                        Colors.blueAccent.withOpacity(0),
                      ],
                      stops: [0.0, 0.5],
                    )),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('${date.month} ${date.year}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: calendar),
                    ]),
                  )
              : null,
          horizontalSeparator: separatorWidth == 0.0
              ? const PreferredSize(
                  preferredSize: Size.fromWidth(0), child: SizedBox())
              : _buildHorizontalSeparator(
                  separatorWidth, properties.customSeparators.value),
          verticalSeparator: separatorHeight == 0.0
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(0), child: SizedBox())
              : _buildVerticalSeparator(
                  separatorHeight, properties.customSeparators.value),
          scrollDirection: properties.scrollDirection.value,
        ),
        child: super.buildChild());
  }

  @override
  Widget buildProperties() {
    final editors = widget.properties.editors;
    return EditorsContext(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: editors.length,
        itemBuilder: (context, index) => editors[index].build(),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),
    );
  }
}

class CalendarProperties {
  final year = IntEditor(title: 'Year', value: DateTime.now().year);
  final month = IntEditor(
      title: 'Month', value: DateTime.now().month, minValue: 1, maxValue: 12);
  final width = IntEditor(title: 'Width', value: 300);
  final height = IntEditor(title: 'Height', value: 300);
  final columns = IntEditor(title: 'Columns', value: 1, minValue: 1);
  final rows = IntEditor(title: 'Rows', value: 1, minValue: 1);
  final scrollDirection = EnumEditor<Axis>(
      title: 'Scroll Direction',
      getList: () => Axis.values,
      value: Axis.horizontal);
  final selectionType = EnumEditor<SelectionType>(
      title: 'Selection Type',
      getList: () => SelectionType.values,
      value: SelectionType.single);
  final showDaysOfWeek = BoolEditor(title: 'Show Days of Week', value: true);
  final showDecorator = BoolEditor(title: 'Show Custom Decorator', value: true);
  final separatorWidth = IntEditor(title: 'Separator Width', value: 32);
  final separatorHeight = IntEditor(title: 'Separator Height', value: 32);
  final customSeparators = BoolEditor(title: 'Custom Separators', value: true);
  final firstDayOfWeekIndex = EnumEditor<int>(
      title: 'First Day of Week Index',
      value: 0,
      getList: () => [0, 1, 2, 3, 4, 5, 6]);

  List<Editor> get editors => [
        year,
        month,
        width,
        height,
        columns,
        rows,
        scrollDirection,
        selectionType,
        showDaysOfWeek,
        showDecorator,
        separatorWidth,
        separatorHeight,
        customSeparators,
        firstDayOfWeekIndex,
      ];
}
