import 'dart:async';
import 'dart:math';

import 'package:algorithmvisualizer/sortList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'barPainter.dart';

void main() {
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Key key = UniqueKey();

  bool _isSnackBarActive = false;

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  //sorting algorithms
  List<SortList> sortAlgos = [
    SortList(sortName: 'Selection Sort'),
    SortList(sortName: 'Insertion Sort'),
    SortList(sortName: 'Bubble Sort'),
    SortList(sortName: 'Merge Sort'),
    SortList(sortName: 'Quick Sort'),
    SortList(sortName: 'Heap Sort'),
  ];

  //number list updated when random/sort is called
  List<int> _numbers = [];
  int _sampleSize = 300;

  //stream controller
  StreamController<List<int>> _streamController;
  Stream<List<int>> _stream;

  //slider Values
  double _currentSliderValue = 300;
  double _lowerValue = 50;
  double _higherValue = 500;

//selecting sorting algos
  SortList _selectedSort;
  String _currentSortAlgo = 'Bubble Sort';

  bool isSorted = false;
  bool isSorting = false;
  bool reset = false;

  int speed = 0;
  static int duration = 1500;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Duration _getDuration() {
    return Duration(microseconds: duration);
  }

  _reset() {
    isSorted = false;
    _numbers = [];
    for (int i = 0; i < _sampleSize; i++) {
      _numbers.add(Random().nextInt(_sampleSize));
    }
    _streamController.add(_numbers);
  }

  _setSortAlgo(String type) {
    setState(() {
      _currentSortAlgo = type;
    });
  }

  _checkAndResetIfSorted() async {
    if (isSorted) {
      _reset();
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  _changeSpeed() {
    if (speed >= 3) {
      speed = 0;
      duration = 1500;
    } else {
      speed++;
      duration = duration ~/ 2;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<List<int>>();
    _stream = _streamController.stream;
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Algorithm Visualizer'),
          actions: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: IconButton(
                  icon: Icon(Icons.refresh_sharp),
                  tooltip: 'Reset',
                  onPressed: () {
                    setState(() {
                      reset = true;
                    });
                    Phoenix.rebirth(context);
                  }),
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(padding: EdgeInsets.all(0.0), children: [
            Container(
              height: 150,
              child: DrawerHeader(
                child: Center(
                  child: Text(
                    'Algorithm\nVisualizer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      wordSpacing: 2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              title: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: Colors.red,
                        style: BorderStyle.solid,
                        width: 2.00)),
                padding: EdgeInsets.all(10.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SortList>(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                    ),
                    hint: Text('Sorting Algorithms'),
                    value: _selectedSort,
                    onChanged: (SortList value) {
                      setState(() {
                        _selectedSort = value;
                        print(value.sortName);
                      });
                    },
                    items: sortAlgos.map((SortList select) {
                      return DropdownMenuItem<SortList>(
                        value: select,
                        child: Text(
                          select.sortName,
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          _reset();
                          _setSortAlgo(select.sortName);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ]),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(10.0),
                color: Colors.amberAccent,
                child: StreamBuilder<Object>(
                    initialData: _numbers,
                    stream: _stream,
                    builder: (context, snapshot) {
                      List<int> numbers = snapshot.data;
                      int counter = 0;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: numbers.map((int num) {
                          counter++;
                          return CustomPaint(
                            painter: BarPainter(
                                width:
                                    (MediaQuery.of(context).size.width - 20) /
                                        _sampleSize,
                                value: num,
                                index: counter,
                                samplesize: _sampleSize),
                          );
                        }).toList(),
                      );
                    }),
              ),
            ),
            Expanded(
              flex: 0,
              child: Container(
                height: 40,
                color: Colors.black,
                child: Center(
                  child: Text(
                    _currentSortAlgo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Slider(
                value: _currentSliderValue,
                min: _lowerValue,
                max: _higherValue,
                activeColor: Colors.redAccent[400],
                inactiveColor: Colors.amberAccent[400],
                divisions: (_higherValue - _lowerValue).toInt(),
                label: _currentSliderValue.toInt().toString(),
                onChanged: isSorting
                    ? null
                    : (double value) {
                  setState(() {
                    _currentSliderValue = value;
                    _sampleSize = value.toInt();
                    _reset();
                  });
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: FlatButton(
                      child: Text('Randomize'),
                      onPressed: isSorting
                          ? null
                          : () {
                        _reset();
                        _setSortAlgo(_currentSortAlgo);
                      })),
              Expanded(
                  flex: 1,
                  child: FlatButton(
                      child: Text('Sort'),
                      onPressed: isSorting
                          ? null
                          : () {
                        _check();
                      })),
              Expanded(
                  child: FlatButton(
                    onPressed: isSorting ? null : _changeSpeed,
                    child: Text(
                      "${speed + 1}x",
                      style: TextStyle(fontSize: 20),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  bool _setSorting = false;

  _check() async {
    if (_setSorting) {
      _setSorting = false;
      _setSortStatus(false);
      return;
    }
    _setSorting = true;
    _setSortStatus(true);
    await _sort();
    if (_setSorting) {
      _setSorting = false;
      _setSortStatus(false);
      return;
    } else {
      _setSortStatus(false);
    }
  }

  void _setSortStatus(bool sorting) {
    if (mounted)
      setState(() {
        _setSorting = sorting;
      });
  }

  _sort() async {
    setState(() {
      isSorting = true;
    });

    await _checkAndResetIfSorted();

    Stopwatch stopwatch = new Stopwatch()
      ..start();

    switch (_currentSortAlgo) {
      case "Selection Sort":
        await _selectionSort();
        break;
      case "Insertion Sort":
        await _insertionSort();
        break;
      case "Bubble Sort":
        await _bubbleSort();
        break;
      case "Merge Sort":
        await _mergeSort(0, _sampleSize.toInt() - 1);
        break;
      case "Quick Sort":
        await _quickSort(0, _sampleSize.toInt() - 1);
        break;
      case "Heap Sort":
        await _heapSort();
        break;
    }
    stopwatch.stop();

    if (_isSnackBarActive) {
      _isSnackBarActive = true;
      _scaffoldKey.currentState.removeCurrentSnackBar();
    }
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        elevation: 6.0,
        backgroundColor: Colors.pink[700],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        content: Text(
            'Sorting completed in ${stopwatch.elapsed.inMilliseconds} ms.',
            textAlign: TextAlign.center)));

    if (mounted)
      setState(() {
        isSorting = false;
        isSorted = true;
        _isSnackBarActive = true;
      });
  }

  _selectionSort() async {
    int temp;
    for (int i = 0; i < _numbers.length; i++) {
      for (int j = i + 1; j < _numbers.length; j++) {
        if (_numbers[i] > _numbers[j]) {
          temp = _numbers[j];
          _numbers[j] = _numbers[i];
          _numbers[i] = temp;
        }
        await Future.delayed(_getDuration(), () {});
        if (!reset) _streamController.add(_numbers);
      }
    }
  }

  _insertionSort() async {
    int key, j;
    for (int i = 0; i < _numbers.length; i++) {
      key = _numbers[i];
      j = i - 1;
      while (j >= 0 && _numbers[j] > key) {
        _numbers[j + 1] = _numbers[j];
        j = j - 1;

        await Future.delayed(_getDuration(), () {});
        if (!reset) _streamController.add(_numbers);
      }
      _numbers[j + 1] = key;
      await Future.delayed(_getDuration(), () {});
      if (!reset) _streamController.add(_numbers);
    }
  }

  _bubbleSort() async {
    for (int i = 0; i < _numbers.length; i++) {
      for (int j = 0; j < _numbers.length - i - 1; j++) {
        if (_numbers[j] > _numbers[j + 1]) {
          int temp = _numbers[j];
          _numbers[j] = _numbers[j + 1];
          _numbers[j + 1] = temp;
        }
        await Future.delayed(_getDuration());
        if (!reset) _streamController.add(_numbers);
      }
    }
  }

  _mergeSort(int leftIndex, int rightIndex) async {
    Future<void> merge(int leftIndex, int middleIndex, int rightIndex) async {
      int leftSize = middleIndex - leftIndex + 1;
      int rightSize = rightIndex - middleIndex;

      List leftList = new List(leftSize);
      List rightList = new List(rightSize);

      for (int i = 0; i < leftSize; i++)
        leftList[i] = _numbers[leftIndex + i];

      for (int j = 0; j < rightSize; j++)
        rightList[j] = _numbers[middleIndex + j + 1];

      int i = 0,
          j = 0;
      int k = leftIndex;

      while (i < leftSize && j < rightSize) {
        if (leftList[i] <= rightList[j]) {
          _numbers[k] = leftList[i];
          i++;
        } else {
          _numbers[k] = rightList[j];
          j++;
        }
        await Future.delayed(_getDuration(), () {});

        if (!reset) _streamController.add(_numbers);

        k++;
      }

      while (i < leftSize) {
        _numbers[k] = leftList[i];
        i++;
        k++;

        await Future.delayed(_getDuration(), () {});

        if (!reset) _streamController.add(_numbers);
      }

      while (j < rightSize) {
        _numbers[k] = rightList[j];
        j++;
        k++;

        await Future.delayed(_getDuration(), () {});

        if (!reset) _streamController.add(_numbers);
      }
    }

    if (leftIndex < rightIndex) {
      int middleIndex = (rightIndex + leftIndex) ~/ 2;

      await _mergeSort(leftIndex, middleIndex);
      await _mergeSort(middleIndex + 1, rightIndex);

      await Future.delayed(_getDuration(), () {});

      if (!reset) _streamController.add(_numbers);

      await merge(leftIndex, middleIndex, rightIndex);
    }
  }

  cf(int a, int b) {
    if (a < b) {
      return -1;
    } else if (a > b) {
      return 1;
    } else {
      return 0;
    }
  }

  _quickSort(int leftIndex, int rightIndex) async {
    Future<int> _partition(int left, int right) async {
      int p = (left + (right - left) / 2).toInt();
      var temp = _numbers[p];
      _numbers[p] = _numbers[right];
      _numbers[right] = temp;

      await Future.delayed(_getDuration(), () {});

      if (!reset) _streamController.add(_numbers);

      int cursor = left;

      for (int i = left; i < right; i++) {
        if (cf(_numbers[i], _numbers[right]) <= 0) {
          var temp = _numbers[i];
          _numbers[i] = _numbers[cursor];
          _numbers[cursor] = temp;
          cursor++;

          await Future.delayed(_getDuration(), () {});

          if (!reset) _streamController.add(_numbers);
        }
      }
      temp = _numbers[right];
      _numbers[right] = _numbers[cursor];
      _numbers[cursor] = temp;

      await Future.delayed(_getDuration(), () {});

      if (!reset) _streamController.add(_numbers);

      return cursor;
    }

    if (leftIndex < rightIndex) {
      int p = await _partition(leftIndex, rightIndex);
      await _quickSort(leftIndex, p - 1);

      await _quickSort(p + 1, rightIndex);
    }
  }

  _heapSort() async {
    for (int i = _numbers.length ~/ 2; i >= 0; i--) {
      await heapify(_numbers, _numbers.length, i);
      if (!reset) _streamController.add(_numbers);
    }

    for (int i = _numbers.length - 1; i >= 0; i--) {
      int temp = _numbers[0];
      _numbers[0] = _numbers[i];
      _numbers[i] = temp;
      await heapify(_numbers, i, 0);

      if (!reset) _streamController.add(_numbers);
    }
  }

  heapify(List<int> arr, int n, int i) async {
    int largest = i;
    int l = 2 * i + 1;
    int r = 2 * i + 2;

    if (l < n && arr[l] > arr[largest]) largest = l;

    if (r < n && arr[r] > arr[largest]) largest = r;

    if (largest != i) {
      int temp = _numbers[i];
      _numbers[i] = _numbers[largest];
      _numbers[largest] = temp;
      heapify(arr, n, largest);
    }

    await Future.delayed(_getDuration());
  }
}
