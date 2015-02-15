part of life;

class ConfigurationException implements Exception {
	String _message;
	String get message => _message;

	ConfigurationException(String message) {
		_message = "Configuration Error: " + message;
	}
}

class Configuration {
	String _name, _defaultState;
	List<String> _states;
	SplayTreeMap<String, String> _stateColorMap;
	SplayTreeMap<String, List<Transition>> _stateTransitionMap;

	String get name => _name;
	String get defaultState => _defaultState;
	List<String> get states => _states;
	SplayTreeMap<String, String> get stateColorMap => _stateColorMap;
	SplayTreeMap<String, List<Transition>> get stateTransitionMap => _stateTransitionMap;

	Configuration(this._name, this._defaultState, this._states, this._stateColorMap, this._stateTransitionMap);

	Configuration.fromJson(String json) {
		Map config;

		try {
			config = JSON.decode(json);
		} on FormatException {
			throw new ConfigurationException("Invalid json formatting");
		}

		// Import name
		_name = config["name"] as String;
		if (_name == null)
			throw new ConfigurationException("Configuration must have a String property 'name'");

		// Import default state
		_defaultState = config["default"] as String;
		if (_defaultState == null)
			throw new ConfigurationException("Configuration must have a String property 'default'");

		List<Map> stateList = config["states"] as List<Map>;
		if (stateList == null)
			throw new ConfigurationException("Configurtion must have a List<Map> property 'states'");

		// Import states and colors
		_states = new List<String>();
		_stateColorMap = new SplayTreeMap<String, String>();
		for (Map state in stateList) {
			String stateName = state["name"] as String;
			if (stateName == null)
				throw new ConfigurationException("State must have a String property 'name'");

			if (_states.contains(stateName))
				throw new ConfigurationException("State name '" + stateName + "' is not unique");

			String color = state["color"] as String;
			if (color == null)
				throw new ConfigurationException("State must have a String property 'color'");

			_states.add(stateName);
			_stateColorMap[stateName] = color;
		}

		if (!_states.contains(_defaultState))
			throw new ConfigurationException("States must contain default state '" + _defaultState + "'");

		// Import transitions
		_stateTransitionMap = new SplayTreeMap<String, List<Transition>>();
		for (Map state in stateList) {
			String stateName = state["name"];

			List<Map> transitionList = state["transitions"] as List<Map>;
			if (transitionList == null)
				throw new ConfigurationException("State must have a List property 'transitions'");

			_stateTransitionMap[stateName] = new List<Transition>();
			for (Map transition in transitionList) {
				String conditionFormula = transition["condition"] as String;
				if (conditionFormula == null)
					throw new ConfigurationException("Transition must have a String property 'condition'");

				Condition condition = new Condition(conditionFormula);
				for (ConditionToken token in condition.tokens) {
					if (token.type == ConditionToken.STATE_TYPE && !_states.contains(token.text))
						throw new ConfigurationException("The condition '${conditionFormula}' references the non-existent state '${token.text}'");
				}

				Object next = transition["next"];
				if (next is String) {
					if (!_states.contains(next))
						throw new ConfigurationException("Invalid next state '" + next + "'");
					_stateTransitionMap[stateName].add(new Transition(condition, new ConstantNextStateGenerator(next)));
				} else if ((next is Map<String, num>) && (next.length > 0)) {
					SplayTreeMap<String, int> stateWeightMap = new SplayTreeMap<String, int>();
					int totalWeight = 0;
					for (String state in next.keys) {
						if (!_states.contains(state))
                        	throw new ConfigurationException("Invalid next state '" + state + "'");

						if (((next[state] % 1) != 0) || (next[state] <= 0))
							throw new ConfigurationException("Next state weights must be positive integers");

						stateWeightMap[state] = next[state];
						totalWeight += next[state];
					}
					_stateTransitionMap[stateName].add(new Transition(condition, new RandomNextStateGenerator(stateWeightMap, totalWeight)));
				} else {
					throw new ConfigurationException("Transition must have a String or Map<String, num> property 'next'");
				}
			}
		}
	}

	bool operator ==(Object obj) {
		Configuration other = obj as Configuration;
		if (other == null)
			return false;

		if (other._name != _name)
			return false;

		if (other.defaultState != _defaultState)
			return false;

		if (other._states.length != _states.length)
			return false;

		for (int i = 0; i < _states.length; i++) {
			if (other._states[i] != _states[i])
				return false;
		}

		if (other._stateColorMap.length != _stateColorMap.length)
			return false;

		for (String state in _stateColorMap.keys) {
			if (other._stateColorMap[state] != _stateColorMap[state])
				return false;
		}

		if (other._stateTransitionMap.length != _stateTransitionMap.length)
			return false;

		for (String state in _stateTransitionMap.keys) {
			if (other._stateTransitionMap[state].length != _stateTransitionMap[state].length)
				return false;

			for (int i = 0; i < _stateTransitionMap[state].length; i++) {
				if (_stateTransitionMap[state][i] != other._stateTransitionMap[state][i])
					return false;
			}
		}

		return true;
	}
}