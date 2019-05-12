function abs(v) {return v < 0 ? -v : v}

{
	/a/
	correctRa = 212.338;
	correctDec = -13.060;
	print $1 " " abs($3-correctRa)+abs($4-correctDec)
}