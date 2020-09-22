import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';

void main() {
  testWidgets('cell 값이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );

    // then
    final cell1 = find.text('header0 value 0');
    expect(cell1, findsOneWidget);

    final cell2 = find.text('header0 value 1');
    expect(cell2, findsOneWidget);

    final cell3 = find.text('header0 value 2');
    expect(cell3, findsOneWidget);
  });

  testWidgets('header 탭 후 정렬 되어야 한다.', (WidgetTester tester) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );

    Finder headerInkWell = find.descendant(
        of: find.byKey(columns.first.key), matching: find.byType(InkWell));

    // then
    await tester.tap(headerInkWell);
    // Ascending
    expect(rows[0].cells['header0'].value, 'header0 value 0');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 2');

    await tester.tap(headerInkWell);
    // Descending
    expect(rows[0].cells['header0'].value, 'header0 value 2');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 0');

    await tester.tap(headerInkWell);
    // Original
    expect(rows[0].cells['header0'].value, 'header0 value 0');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 2');
  });

  testWidgets('셀 값 변경 후 헤더를 탭하면 변경 된 값에 맞게 정렬 되어야 한다.',
      (WidgetTester tester) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    PlutoStateManager stateManager;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      ),
    );

    Finder firstCell = find.byKey(rows.first.cells['header0'].key);

    // 셀 선택
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    expect(stateManager.isEditing, false);

    // 수정 상태로 변경
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    // 수정 상태 확인
    expect(stateManager.isEditing, true);

    // TODO : 셀 값 변경 (1) 안되서 (2) 강제로
    // (1)
    // await tester.pump(Duration(milliseconds:800));
    //
    // await tester.enterText(
    //     find.descendant(of: firstCell, matching: find.byType(TextField)),
    //     'cell value4');
    // (2)
    stateManager.changeCellValue(
        stateManager.currentCell.key, 'header0 value 4');

    // 다음 행으로 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

    expect(rows[0].cells['header0'].value, 'header0 value 4');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 2');

    Finder headerInkWell = find.descendant(
        of: find.byKey(columns.first.key), matching: find.byType(InkWell));

    await tester.tap(headerInkWell);
    // Ascending
    expect(rows[0].cells['header0'].value, 'header0 value 1');
    expect(rows[1].cells['header0'].value, 'header0 value 2');
    expect(rows[2].cells['header0'].value, 'header0 value 4');

    await tester.tap(headerInkWell);
    // Descending
    expect(rows[0].cells['header0'].value, 'header0 value 4');
    expect(rows[1].cells['header0'].value, 'header0 value 2');
    expect(rows[2].cells['header0'].value, 'header0 value 1');

    await tester.tap(headerInkWell);
    // Original
    expect(rows[0].cells['header0'].value, 'header0 value 4');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 2');
  });

  testWidgets(
      '0,4번 컬림이 고정 된 상태에서'
      '2번 컬럼 고정 후 방향키 이동시 정상적으로 이동 되어야 한다.', (WidgetTester tester) async {
    // given
    final columns = [
      ColumnHelper.textColumn('headerL', fixed: PlutoColumnFixed.Left).first,
      ...ColumnHelper.textColumn('headerB', count: 3),
      ColumnHelper.textColumn('headerR', fixed: PlutoColumnFixed.Right).first,
    ];
    final rows = RowHelper.count(10, columns);

    PlutoStateManager stateManager;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      ),
    );

    // 세번 째 컬럼 왼쪽 고정
    stateManager.toggleFixedColumn(columns[2].key, PlutoColumnFixed.Left);

    // 첫번 째 컬럼의 첫번 째 셀
    Finder firstCell = find.byKey(rows.first.cells['headerL0'].key);

    // 셀 선택
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    // 첫번 째 셀 값 확인
    expect(stateManager.currentCell.value, 'headerL0 value 0');

    // 셀 우측 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // 왼쪽 고정 시킨 두번 째 컬럼(headerB1)의 첫번 째 셀 값 확인
    expect(stateManager.currentCell.value, 'headerB1 value 0');

    // 셀 우측 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // 왼쪽 고정 컬럼 두개 다음에 Body 의 첫번 째 컬럼의 값 확인
    expect(stateManager.currentCell.value, 'headerB0 value 0');

    // 셀 다시 왼쪽 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

    // 고정 컬럼 두번 째 셀 값 확인
    expect(stateManager.currentCell.value, 'headerB1 value 0');

    // 셀 우측 끝으로 이동해서 우측 고정 된 셀 값 확인
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // 우측 끝 고정 컬럼 값 확인
    expect(stateManager.currentCell.value, 'headerR0 value 0');

    // 셀 다시 왼쪽 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

    // 우측 고정 컬럼 바로 전 컬럼인 Body 의 마지막 컬럼 셀 값 확인
    expect(stateManager.currentCell.value, 'headerB2 value 0');
  });

  testWidgets(
      'WHEN Fixed one column on the right when there are no fixed columns in the grid.'
      'THEN showFixedColumn changes to true and the column is moved to the right and should disappear from its original position.',
      (WidgetTester tester) async {
    // given
    final columns = [
      ...ColumnHelper.textColumn('header', count: 10),
    ];
    final rows = RowHelper.count(10, columns);

    PlutoStateManager stateManager;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      ),
    );

    // when
    // first cell of first column
    Finder firstCell = find.byKey(rows.first.cells['header0'].key);

    // select first cell
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    // Check first cell value of first column
    expect(stateManager.currentCell.value, 'header0 value 0');

    // Check showFixedColumn before fixing column.
    expect(stateManager.layout.showFixedColumn, false);

    // Fix the 3rd column
    stateManager.toggleFixedColumn(columns[2].key, PlutoColumnFixed.Right);

    // Await re-build by toggleFixedColumn
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Check showFixedColumn after fixing column.
    expect(stateManager.layout.showFixedColumn, true);

    // Move current cell position to 3rd column (0 -> 1 -> 2)
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // Check currentColumn
    expect(stateManager.currentColumn.title, isNot('header2'));
    expect(stateManager.currentColumn.title, 'header3');

    // Move current cell position to 10rd column (2 -> 9)
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // Check currentColumn
    expect(stateManager.currentColumn.title, 'header2');
  });

  testWidgets(
      'WHEN selecting a specific cell without grid header'
      'THEN That cell should be selected.', (WidgetTester tester) async {
    // given
    final columns = [
      ...ColumnHelper.textColumn('header', count: 10),
    ];
    final rows = RowHelper.count(10, columns);

    PlutoStateManager stateManager;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      ),
    );

    // when
    // first cell of first column
    Finder firstCell = find.byKey(rows.first.cells['header0'].key);

    // select first cell
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    Offset selectedCellOffset =
        tester.getCenter(find.byKey(rows[7].cells['header5'].key));

    stateManager.setCurrentSelectingPositionWithOffset(selectedCellOffset);

    // then
    expect(stateManager.currentSelectingPosition.rowIdx, 7);
    expect(stateManager.currentSelectingPosition.columnIdx, 5);
  });

  testWidgets(
      'WHEN selecting a specific cell with grid header'
      'THEN That cell should be selected.', (WidgetTester tester) async {
    // given
    final columns = [
      ...ColumnHelper.textColumn('header', count: 10),
    ];
    final rows = RowHelper.count(10, columns);

    PlutoStateManager stateManager;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              createHeader: (stateManager) => Text('grid header'),
            ),
          ),
        ),
      ),
    );

    // when
    // first cell of first column
    Finder firstCell = find.byKey(rows.first.cells['header0'].key);

    // select first cell
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    Offset selectedCellOffset =
        tester.getCenter(find.byKey(rows[5].cells['header3'].key));

    stateManager.setCurrentSelectingPositionWithOffset(selectedCellOffset);

    // then
    expect(stateManager.currentSelectingPosition.rowIdx, 5);
    expect(stateManager.currentSelectingPosition.columnIdx, 3);
  });

  group('applyColumnRowOnInit', () {
    testWidgets(
        'number column'
        'WHEN applyFormatOnInit value of Column is true(default value)'
        'THEN cell value of the column should be changed to format.',
        (WidgetTester tester) async {
      // given
      final columns = [
        PlutoColumn(
          title: 'header',
          field: 'header',
          type: PlutoColumnType.number(),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'header': PlutoCell(value: 'not a number')}),
        PlutoRow(cells: {'header': PlutoCell(value: 12)}),
        PlutoRow(cells: {'header': PlutoCell(value: '12')}),
        PlutoRow(cells: {'header': PlutoCell(value: -10)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567)}),
        PlutoRow(cells: {'header': PlutoCell(value: 12.12345)}),
      ];

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        ),
      );

      // then
      expect(stateManager.rows[0].cells['header'].value, 0);
      expect(stateManager.rows[1].cells['header'].value, 12);
      expect(stateManager.rows[2].cells['header'].value, 12);
      expect(stateManager.rows[3].cells['header'].value, -10);
      expect(stateManager.rows[4].cells['header'].value, 1234567);
      expect(stateManager.rows[5].cells['header'].value, 12);
    });

    testWidgets(
        'number column'
        'WHEN applyFormatOnInit value of Column is false'
        'THEN cell value of the column should not be changed to format.',
        (WidgetTester tester) async {
      // given
      final columns = [
        PlutoColumn(
          title: 'header',
          field: 'header',
          type: PlutoColumnType.number(applyFormatOnInit: false),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'header': PlutoCell(value: 'not a number')}),
        PlutoRow(cells: {'header': PlutoCell(value: 12)}),
        PlutoRow(cells: {'header': PlutoCell(value: '12')}),
        PlutoRow(cells: {'header': PlutoCell(value: -10)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567)}),
        PlutoRow(cells: {'header': PlutoCell(value: 12.12345)}),
      ];

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        ),
      );

      // then
      expect(stateManager.rows[0].cells['header'].value, 'not a number');
      expect(stateManager.rows[1].cells['header'].value, 12);
      expect(stateManager.rows[2].cells['header'].value, '12');
      expect(stateManager.rows[3].cells['header'].value, -10);
      expect(stateManager.rows[4].cells['header'].value, 1234567);
      expect(stateManager.rows[5].cells['header'].value, 12.12345);
    });

    testWidgets(
        'number column'
        'WHEN format allows prime numbers'
        'THEN cell value should be displayed as a decimal number according to the number of digits in the format.',
        (WidgetTester tester) async {
      // given
      final columns = [
        PlutoColumn(
          title: 'header',
          field: 'header',
          type: PlutoColumnType.number(format: '#,###.#####'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'header': PlutoCell(value: 1234567)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567.1234)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567.12345)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567.123456)}),
      ];

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        ),
      );

      // then
      expect(stateManager.rows[0].cells['header'].value, 1234567);
      expect(stateManager.rows[1].cells['header'].value, 1234567.1234);
      expect(stateManager.rows[2].cells['header'].value, 1234567.12345);
      expect(stateManager.rows[3].cells['header'].value, 1234567.12346);
    });

    testWidgets(
        'number column'
        'WHEN negative is false'
        'THEN negative numbers should not be displayed in the cell value.',
        (WidgetTester tester) async {
      // given
      final columns = [
        PlutoColumn(
          title: 'header',
          field: 'header',
          type: PlutoColumnType.number(negative: false),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'header': PlutoCell(value: 12345)}),
        PlutoRow(cells: {'header': PlutoCell(value: -12345)}),
        PlutoRow(cells: {'header': PlutoCell(value: 333.333)}),
        PlutoRow(cells: {'header': PlutoCell(value: -333.333)}),
        PlutoRow(cells: {'header': PlutoCell(value: 0)}),
        PlutoRow(cells: {'header': PlutoCell(value: -0)}),
      ];

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        ),
      );

      // then
      expect(stateManager.rows[0].cells['header'].value, 12345);
      expect(stateManager.rows[1].cells['header'].value, 0);
      expect(stateManager.rows[2].cells['header'].value, 333);
      expect(stateManager.rows[3].cells['header'].value, 0);
      expect(stateManager.rows[4].cells['header'].value, 0);
      expect(stateManager.rows[5].cells['header'].value, 0);
    });

    testWidgets(
        'WHEN Row does not have sortIdx'
        'THEN sortIdx must be set in Row', (WidgetTester tester) async {
      // given
      final columns = [
        ...ColumnHelper.textColumn('header', count: 1),
      ];
      final rows = [
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
      ];

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
                createHeader: (stateManager) => Text('grid header'),
              ),
            ),
          ),
        ),
      );

      // then
      expect(stateManager.rows[0].sortIdx, 0);
      expect(stateManager.rows[1].sortIdx, 1);
      expect(stateManager.rows[2].sortIdx, 2);
      expect(stateManager.rows[3].sortIdx, 3);
      expect(stateManager.rows[4].sortIdx, 4);
    });

    testWidgets(
        'WHEN Row has sortIdx'
        'THEN sortIdx is not changed', (WidgetTester tester) async {
      // given
      final columns = [
        ...ColumnHelper.textColumn('header', count: 1),
      ];
      final rows = [
        PlutoRow(sortIdx: 5, cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(sortIdx: 6, cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(sortIdx: 7, cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(sortIdx: 8, cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(sortIdx: 9, cells: {'header0': PlutoCell(value: 'value')}),
      ];

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
                createHeader: (stateManager) => Text('grid header'),
              ),
            ),
          ),
        ),
      );

      // then
      expect(stateManager.rows[0].sortIdx, 5);
      expect(stateManager.rows[1].sortIdx, 6);
      expect(stateManager.rows[2].sortIdx, 7);
      expect(stateManager.rows[3].sortIdx, 8);
      expect(stateManager.rows[4].sortIdx, 9);
    });
  });

  group('moveColumn', () {
    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        '0번 컬럼을 2번 컬럼으로 이동.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 100),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        ),
      );

      // when
      stateManager.moveColumn(columns[0].key, 250);

      // then
      expect(columns[0].title, 'body1');
      expect(columns[1].title, 'body2');
      expect(columns[2].title, 'body0');
    });

    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        '9번 컬럼을 0번 컬럼으로 이동.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 100),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        ),
      );

      // when
      stateManager.moveColumn(columns[9].key, 50);

      // then
      expect(columns[0].title, 'body9');
      expect(columns[1].title, 'body0');
      expect(columns[2].title, 'body1');
      expect(columns[3].title, 'body2');
      expect(columns[4].title, 'body3');
      expect(columns[5].title, 'body4');
      expect(columns[6].title, 'body5');
      expect(columns[7].title, 'body6');
      expect(columns[8].title, 'body7');
      expect(columns[9].title, 'body8');
    });

    testWidgets(
        '넓이가 충분하고 '
        '고정 컬럼이 없는 상태에서 '
        '3번 컬럼을 고정 왼쪽 토글 하고 '
        '5번 컬럼을 0번 컬럼으로 이동.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 100),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 500,
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        ),
      );

      // when
      stateManager.toggleFixedColumn(columns[3].key, PlutoColumnFixed.Left);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      stateManager.moveColumn(columns[5].key, 50);
      //
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 3번 컬럼을 토글하면 컬럼 위치는 바뀌지 않고 고정 컬럼으로 상태만 바뀜.
      // 그리고 5번 컬럼을 이동 시키면 고정 컬럼이 노출 되는 상태에서 3번 컬럼 앞으로 이동.
      // 0, 1, 2, 5, 3, 4, 6, 7, 8, 9 상태가 됨.

      // then
      expect(columns[0].title, 'body0');
      expect(columns[1].title, 'body1');
      expect(columns[2].title, 'body2');
      expect(columns[3].title, 'body5');
      expect(columns[3].fixed, PlutoColumnFixed.Left);
      expect(columns[4].title, 'body3');
      expect(columns[4].fixed, PlutoColumnFixed.Left);
      expect(columns[5].title, 'body4');
      expect(columns[6].title, 'body6');
      expect(columns[7].title, 'body7');
      expect(columns[8].title, 'body8');
      expect(columns[9].title, 'body9');
    });

    testWidgets(
        '넓이가 충분하지 않고 '
        '고정 컬럼이 없는 상태에서 '
        '3번 컬럼을 고정 왼쪽 토글 하고 '
        '5번 컬럼을 0번 컬럼으로 이동.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 100),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 50,
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        ),
      );

      stateManager.setLayout(
          BoxConstraints(maxWidth: 50, maxHeight: 300), 0, 0);

      // when
      stateManager.toggleFixedColumn(columns[3].key, PlutoColumnFixed.Left);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      stateManager.setLayout(
          BoxConstraints(maxWidth: 50, maxHeight: 300), 0, 0);

      stateManager.moveColumn(columns[5].key, 50);
      //
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 3번 컬럼을 토글하면 컬럼 위치는 바뀌지 않고 고정 컬럼으로 상태만 바뀜.
      // 그리고 5번 컬럼을 이동 시키면 넓이가 충분하지 않은 상태에서
      // 왼쪽 끝에는 0번 컬럼이 위치하게 되고, 5번 컬럼이 0번 컬럼 앞으로 이동.
      // 0번 컬럼이 고정 컬럼이 아니어서 5번도 고정 컬럼이 아니게 됨.

      // then
      expect(columns[0].title, 'body5');
      expect(columns[0].fixed, PlutoColumnFixed.None);
      expect(columns[1].title, 'body0');
      expect(columns[2].title, 'body1');
      expect(columns[3].title, 'body2');
      expect(columns[4].title, 'body3');
      expect(columns[4].fixed, PlutoColumnFixed.Left);
      expect(columns[5].title, 'body4');
      expect(columns[6].title, 'body6');
      expect(columns[7].title, 'body7');
      expect(columns[8].title, 'body8');
      expect(columns[9].title, 'body9');
    });
  });
}
