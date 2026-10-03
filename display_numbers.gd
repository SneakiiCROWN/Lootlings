extends RefCounted

# Compact totals for narrow headers. Costs and transaction details stay exact.
static func compact(value: int) -> String:
	var magnitude := absf(float(value))
	if magnitude < 10000: return str(value)
	var divisor := 1000.0
	var suffix := "K"
	for unit in [[1000000000000.0,"T"],[1000000000.0,"B"],[1000000.0,"M"]]:
		if magnitude >= float(unit[0]): divisor = float(unit[0]); suffix = str(unit[1]); break
	var scaled := floorf(magnitude/divisor*10)/10
	return ("-" if value < 0 else "") + ("%.0f" % scaled if is_equal_approx(scaled,floorf(scaled)) else "%.1f" % scaled) + suffix
