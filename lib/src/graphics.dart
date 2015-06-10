part of life;

class Graphics {
	static const int CELL_SIZE = 4;
	static const int LINE_SIZE = 1;
	static const int PERIOD = CELL_SIZE + LINE_SIZE;

	int _rows, _cols, _width, _height;
	Map<String, String> _stateColorMap;
	String _defaultColor;

	int get rows => _rows;

	int get cols => _cols;

	int get width => _width;

	int get height => _height;

	Graphics(this._rows, this._cols, this._stateColorMap, this._defaultColor) {
		_width = (_cols * CELL_SIZE) + ((_cols + 1) * LINE_SIZE);
		_height = (_rows * CELL_SIZE) + ((_rows + 1) * LINE_SIZE);
	}

	int getRowFromCoord(int y) {
		if (y < 0 || y >= _height)
			return -1;

		return y ~/ PERIOD;
	}

	int getColFromCoord(int x) {
		if (x < 0 || x >= _width)
			return -1;

		return x ~/ PERIOD;
	}

	void drawGrid(CanvasRenderingContext2D context) {
		// Draw default color
		context.fillStyle = _defaultColor;
		context.fillRect(0, 0, _width, _height);

		// Draw grid lines
		for (num x = 0.5; x < _width; x += PERIOD) {
			context.moveTo(x, 0);
			context.lineTo(x, _height - 1);
		}
		for (num y = 0.5; y < _height; y += PERIOD) {
			context.moveTo(0, y);
			context.lineTo(_width - 1, y);
		}

		context.lineWidth = LINE_SIZE;
		context.strokeStyle = "black";
		context.stroke();
	}

	void drawCell(int row, int col, Grid grid, CanvasRenderingContext2D context) {
		int x = (col * PERIOD) + LINE_SIZE;
		int y = (row * PERIOD) + LINE_SIZE;

		context.fillStyle = _stateColorMap[grid.getState(row, col)];
		context.fillRect(x, y, CELL_SIZE, CELL_SIZE);
	}

	void drawCells(Grid grid, CanvasRenderingContext2D context) {
		context.clearRect(0, 0, _width, _height);

		String color;
		for (int row = 0, y = LINE_SIZE; row < _rows; row++, y += PERIOD) {
			for (int col = 0, x = LINE_SIZE; col < _cols; col++, x += PERIOD) {
				color = _stateColorMap[grid.getState(row, col)];
				if (color != _defaultColor) {
					context.fillStyle = color;
					context.fillRect(x, y, CELL_SIZE, CELL_SIZE);
				}
			}
		}
	}
}