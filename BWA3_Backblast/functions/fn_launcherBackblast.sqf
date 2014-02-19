/*
BWA3 function, by commy2
this code is property of the ArmA 3 Bundeswehr modification
ask us nicely at http://www.bwmod.de/ if you want to re-use any of this script
we don't support changed code based on this work
*/

_unit = _this select 0;
_firer = _this select 1;
_distance = _this select 2;
_weapon = _this select 3;

if (vehicle _unit != _unit) exitWith {};

_backblastAngle = getNumber (configFile >> "CfgWeapons" >> _weapon >> "BWA3_Backblast_Angle") / 2;
_backblastRange = getNumber (configFile >> "CfgWeapons" >> _weapon >> "BWA3_Backblast_Range");
_backblastDamage = getNumber (configFile >> "CfgWeapons" >> _weapon >> "BWA3_Backblast_Damage") * 2;

_position = eyePos _firer;
_direction = _firer weaponDirection currentWeapon _firer;

if (_unit == _firer) then {
	_direction set [0, (_position select 0) - (_direction select 0) * _backblastRange];
	_direction set [1, (_position select 1) - (_direction select 1) * _backblastRange];
	_direction set [2, (_position select 2) + (_direction select 2) * _backblastRange];
	_line = [_position, _direction];

	_hitSelf = false;
	{
		if (_x isKindOf "Static" || {_x isKindOf "AllVehicles"}) then {
			_hitSelf = true;
		};
	} forEach lineIntersectsWith _line;

	if (terrainIntersectASL _line) then {
		_hitSelf = true;
	};

	if (_hitSelf) then {
		_damage = _backblastDamage / 2;
		[_damage * 100] call BIS_fnc_bloodEffect;
		_unit setDamage (damage _unit + _damage);
	};
} else {
	_direction set [0, (_position select 0) - (_direction select 0)];
	_direction set [1, (_position select 1) - (_direction select 1)];
	_direction set [2, (_position select 2) + (_direction select 2)];

	_azimuth = (_direction select 0) atan2 (_direction select 1);
	_inclination = asin (_direction select 2);

	_relativePosition = eyePos _unit;
	_relativeDirection = [
		(_relativePosition select 0) - (_position select 0),
		(_relativePosition select 1) - (_position select 1),
		(_relativePosition select 2) - (_position select 2)
	];

	_relativeAzimuth = (_relativeDirection select 0) atan2 (_relativeDirection select 1);
	_relativeInclination = asin (_relativeDirection select 2);

	_distance = _position distance _relativePosition;
	_angle = abs (_relativeAzimuth - _azimuth) + abs (_relativeInclination - _inclination);
	_line = [_position, _relativePosition];

	if (_distance < _backblastRange && {_angle < _backblastAngle} && {!lineIntersects _line} && {!terrainIntersectASL _line}) then {
		_alpha = sqrt (1 - _difference / _backblastAngle);
		_beta = sqrt (1 - _distance / _backblastRange);

		_damage = _backblastDamage * 2 * _alpha * _beta;
		if (_unit == player) then {[_damage * 100] call BIS_fnc_bloodEffect};
		_unit setDamage (damage _unit + _damage);
	};
};
