import '../lib/life.dart';
import 'graphics.dart';
import 'dart:async';
import 'dart:html';
import 'package:core_elements/core_collapse.dart';
import 'package:core_elements/core_menu.dart';
import 'package:paper_elements/paper_action_dialog.dart';
import 'package:paper_elements/paper_button.dart';
import 'package:paper_elements/paper_radio_group.dart';
import 'package:paper_elements/paper_toast.dart';
import 'package:polymer/polymer.dart';

const Duration SLOW = const Duration(milliseconds: 250);
const Duration NORMAL = const Duration(milliseconds: 100);
const Duration FAST = const Duration(milliseconds: 0);

const String DEFAULT_CONFIGURATION = "configurations/conway.json";

@CustomTag('life-app')
class LifeApp extends PolymerElement {

	CanvasElement backgroundCanvas, foregroundCanvas;
	PaperRadioGroup speedRadioGroup;
	PaperButton playButton, stepButton, clearButton;
	CoreMenu stateMenu, patternMenu;
	Element importDropzone;
	PaperToast alertToast;
	PaperActionDialog stateFixDialog, configureDialog;

	@observable List<String> invalidStates = toObservable([]);
	@observable List<String> validStates = toObservable(["Something", "else"]);

	Configuration config;
	Graphics graphics;
	Grid grid;
	Timer advanceTimer;

	@observable bool playing = false;
	@observable int generation = 0;
	@observable String configurationName = "";
	@observable List<String> states = toObservable([]);
	int _lastClickedRow = -1, _lastClickedCol = -1;

	LifeApp.created() : super.created();

	@override
	void attached() {
		super.attached();

		backgroundCanvas = shadowRoot.querySelector("#grid_background");
		foregroundCanvas = shadowRoot.querySelector("#grid_foreground");
		speedRadioGroup = shadowRoot.querySelector("#speed_radio_group");
		playButton = shadowRoot.querySelector("#play_button");
		stepButton = shadowRoot.querySelector("#step_button");
		clearButton = shadowRoot.querySelector("#clear_button");
		stateMenu = shadowRoot.querySelector("#state_menu");
		patternMenu = shadowRoot.querySelector("#pattern_menu");
		importDropzone = shadowRoot.querySelector('#import_drop');
		alertToast = shadowRoot.querySelector("#alert_toast");
		stateFixDialog = shadowRoot.querySelector("#state_fix_dialog");

		_addKeyHandlers();
		_addClickHandlers();
		_addDropHandlers();

		shadowRoot.querySelector("#play_header").onClick.listen((
			_) => (shadowRoot.querySelector("#play_collapse") as CoreCollapse).toggle());
		shadowRoot.querySelector("#click_header").onClick.listen((
			_) => (shadowRoot.querySelector("#click_collapse") as CoreCollapse).toggle());
		shadowRoot.querySelector("#import_header").onClick.listen((
			_) => (shadowRoot.querySelector("#import_collapse") as CoreCollapse).toggle());

		HttpRequest.getString(DEFAULT_CONFIGURATION).then(importConfiguration,
		onError: (_) => alert("Import Error"));
	}

	void importConfiguration(String json) {
		if (playing)
			_stopPlaying();

		try {
			config = new Configuration.fromJson(json);
			generation = 0;
			configurationName = config.name;
			states
				..clear()
				..addAll(config.states);

			initialize();
			alert("Configuration successfully imported!");
		} on ConfigurationException catch (e) {
			alert(e.message);
		}
	}

	void initialize() {
		grid = new Grid(100, 100, config.defaultState);
		graphics = new Graphics(100, 100, config.stateColorMap,
		config.stateColorMap[config.defaultState]);

		shadowRoot.querySelector("#grid_container").style
			..minWidth = (graphics.width.toString() + "px")
			..maxWidth = (graphics.width.toString() + "px")
			..minHeight = (graphics.height.toString() + "px")
			..maxHeight = (graphics.height.toString() + "px");

		backgroundCanvas
			..width = graphics.width
			..height = graphics.height;

		foregroundCanvas
			..width = graphics.width
			..height = graphics.height;

		graphics.drawGrid(backgroundCanvas.context2D);
		graphics.drawCells(grid, foregroundCanvas.context2D);
	}

	void alert(String message) {
		alertToast.text = message;
		alertToast.show();
	}

	/**
	 * Key Handlers
	 */
	void _addKeyHandlers() {
		window.onKeyUp.listen((KeyboardEvent e) {
			switch (e.keyCode) {
				case KeyCode.ENTER:
					_playClickHandler(null);
					break;
				case KeyCode.SPACE:
					if (!playing)
						_stepClickHandler(null);
					break;
				case KeyCode.CTRL:
					stateFixDialog.toggle();
					break;
			}
		});
	}

	/**
	 * Click Handlers
	 */
	void _addClickHandlers() {
		foregroundCanvas.onMouseDown.listen(_canvasMouseDownHandler);
		playButton.onClick.listen(_playClickHandler);
		stepButton.onClick.listen(_stepClickHandler);
		clearButton.onClick.listen(_clearClickHandler);
	}

	void _playClickHandler(MouseEvent e) {
		if (playing)
			_stopPlaying();
		else
			_startPlaying();
	}

	void _stepClickHandler(MouseEvent e) {
		_advance();
	}

	void _clearClickHandler(MouseEvent e) {
		grid.clear();
		generation = 0;
		graphics.drawCells(grid, foregroundCanvas.context2D);
	}

	void _startPlaying() {
		playing = true;
		_advance();
		playButton.text = "Pause";
	}

	void _stopPlaying() {
		playing = false;
		_stopTimer();
		playButton.text = "Play";
	}

	void _startTimer() {
		if (advanceTimer != null)
			advanceTimer.cancel();

		String speed = speedRadioGroup.selected;
		switch (speed) {
			case "Fast":
				advanceTimer = new Timer(FAST, _advance);
				break;
			case "Slow":
				advanceTimer = new Timer(SLOW, _advance);
				break;
			default:
				advanceTimer = new Timer(NORMAL, _advance);
		}
	}

	void _stopTimer() {
		if (advanceTimer != null) {
			advanceTimer.cancel();
			advanceTimer = null;
		}
	}

	void _advance() {
		generation = grid.advance(config.stateTransitionMap);
		graphics.drawCells(grid, foregroundCanvas.context2D);

		if (playing)
			_startTimer();
	}

	void _canvasMouseDownHandler(MouseEvent e) {
		_click(e);

		StreamSubscription mouseMoveStream = foregroundCanvas.onMouseMove.listen((MouseEvent evt) {
			_click(evt);
		});

		foregroundCanvas.onMouseUp.listen((_) {
			mouseMoveStream.cancel();
			_lastClickedRow = -1;
			_lastClickedCol = -1;
		});

		foregroundCanvas.onMouseOut.listen((_) {
			mouseMoveStream.cancel();
			_lastClickedRow = -1;
			_lastClickedCol = -1;
		});
	}

	void _click(MouseEvent e) {
		Rectangle rect = foregroundCanvas.getBoundingClientRect();
		num canvasX = e.client.x - rect.left;
		num canvasY = e.client.y - rect.top;
		int row = graphics.getRowFromCoord(canvasY.floor());
		int col = graphics.getColFromCoord(canvasX.floor());

		if (row >= 0 && col >= 0 && (row != _lastClickedRow || col != _lastClickedCol)) {
			String state = e.shiftKey ? config.defaultState : (stateMenu.selected as String);
			if (state != null) {
				grid.setState(row, col, state);
				graphics.drawCell(row, col, grid, foregroundCanvas.context2D);
			}
		}

		_lastClickedRow = row;
		_lastClickedCol = col;
	}

	/**
	 * Drop Handlers
	 */
	void _addDropHandlers() {
		importDropzone.onDragOver.listen(_dragOverHandler);
		importDropzone.onDragEnter.listen((e) => importDropzone.classes.add('hover'));
		importDropzone.onDragLeave.listen((e) => importDropzone.classes.remove('hover'));
		importDropzone.onDrop.listen(_dropHandler);
	}

	void _dragOverHandler(MouseEvent event) {
		event.stopPropagation();
		event.preventDefault();
		event.dataTransfer.dropEffect = 'copy';
	}

	void _dropHandler(MouseEvent event) {
		event.stopPropagation();
		event.preventDefault();
		importDropzone.classes.remove('hover');

		if (event.dataTransfer.files.length != 1)
			alert("Import Error: Only one file may be imported at a time");

		File file = event.dataTransfer.files[0];
		if (!file.name.endsWith(".json"))
			alert("Import Error: Only json files may be imported");

		FileReader reader = new FileReader();
		reader.onError.listen((_) => alert("Import Error: Could not read file"));
		reader.onLoadEnd.listen((ProgressEvent e) {
			String json = reader.result as String;
			if (json == null)
				alert("Import Error: Could not read file");

			importConfiguration(json);
		});

		reader.readAsText(file);
	}
}