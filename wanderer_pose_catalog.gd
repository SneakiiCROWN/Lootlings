extends RefCounted

# Compatibility facade; all actor geometry lives in WeaponFit.
const Fit = preload("res://weapon_fit_catalog.gd")
const BODY_RECT = Fit.BODY_RECT
const WEAPONS = Fit.GEOMETRY

static func sample(g, hurt: bool = false) -> Dictionary:
	return Fit.sample(g, hurt)

static func projectile_origin(g) -> Vector2:
	return Fit.projectile_origin(g)
