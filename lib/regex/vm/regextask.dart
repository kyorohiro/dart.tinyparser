part of hetimaregex;

class RegexTask {
  int _nextCommandLocation = 0;
  heti.TinyParser _parseHelperWithTargetSource = null;
  int get nextCommandLocation => _nextCommandLocation;

  List<List<int>> _memory = [];
  List<int> _currentMemoryTargetId = [];
  int _nextMemoryId = 0;

  RegexTask.clone(RegexTask task, [int commandPos = -1]) {
    if (commandPos != -1) {
      this._nextCommandLocation = commandPos;
    } else {
      this._nextCommandLocation = task._nextCommandLocation;
    }
    this._parseHelperWithTargetSource = task._parseHelperWithTargetSource.toClone();
    {
      //deep copy
      this._memory = [];
      for(List<int> v in task._memory) {
        this._memory.add(new List.from(v));
      }
    }
    this._currentMemoryTargetId = new List.from(task._currentMemoryTargetId);
    this._nextMemoryId = task._nextMemoryId;
  }

  RegexTask.fromCommnadPos(int commandPos, heti.TinyParser parser) {
    _nextCommandLocation = commandPos;
    _parseHelperWithTargetSource = parser.toClone();
  }

  void tryAddMemory(List<int> matchedData) {
    if (_currentMemoryTargetId.length > 0) {
      for (int i in _currentMemoryTargetId) {
        _memory[i].addAll(matchedData);
      }
    }
  }

  Future<List<int>> executeNextCommand(RegexVM vm) async {
    if (_nextCommandLocation >= vm._commands.length) {
      throw "";
    }
    RegexCommand c = vm._commands[_nextCommandLocation];
    return await c.check(vm, _parseHelperWithTargetSource);
  }

  Future<List<List<int>>> lookingAt(RegexVM vm) async {
    do {
      try {
        List<int> matchedData = await executeNextCommand(vm);
        tryAddMemory(matchedData);
      } catch(e) {
        if (e is MatchCommandNotification) {
          return _memory;
        } else {
          throw e;
        }
      }
    } while(true);
  }
}
