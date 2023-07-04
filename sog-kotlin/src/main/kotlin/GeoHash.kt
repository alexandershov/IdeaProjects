fun checkGeoHash() {
    // this prints "gbsuv", that is correct: https://www.movable-type.co.uk/scripts/geohash.html
    println("geohash = ${getGeoHash(48.669, -4.329, 5)}")
}

/*
The idea behind geohash is this:
* We split earth into 4 quadrants
  This split can be encoded in 2 bits (from top-left clockwise 01, 11, 10, 00)
  We find the quadrant that (latitude, longitude) is in
  Then we split quadrant found in the previous step. Encoding rules are the same.
  We append bits to the resulting string.

  We stop when we got the precision we want.
  Resulting binary string is encoded in base32 encoding.

  So if geohashes of two locations have a long common prefix, then the locations are close.
  If we're not lucky then two very close locations can have completely different geohashes.

 */

// TODO: implement the reverse operation: geohash -> (latitudeRange, longitudeRange)
fun getGeoHash(latitude: Double, longitude: Double, precision: Int): String {
    val symbols = "0123456789bcdefghjkmnpqrstuvwxyz"
    val bits = mutableListOf<Char>()
    var latitudeRange = -90.0..90.0
    var longitudeRange = -180.0..180.0
    while ((bits.size + 2) / 5 <= precision) {
        val (latitudeBit, newLatitudeRange) = getBitAndPart(latitude, latitudeRange)
        val (longitudeBit, newLongitudeRange) = getBitAndPart(longitude, longitudeRange)
        bits.add(longitudeBit)
        bits.add(latitudeBit)

        latitudeRange = newLatitudeRange
        longitudeRange = newLongitudeRange
    }
    val geoHash = mutableListOf<Char>()
    for (code in bits.windowed(5, 5)) {
        val index = code.joinToString("").toInt(2)
        geoHash.add(symbols[index])
    }
    return geoHash.joinToString("")
}

private fun higherPart(range: ClosedRange<Double>): ClosedFloatingPointRange<Double> {
    val middle = (range.start + range.endInclusive) / 2
    return middle..range.endInclusive
}

private fun lowerPart(range: ClosedRange<Double>): ClosedFloatingPointRange<Double> {
    val middle = (range.start + range.endInclusive) / 2
    return range.start..middle
}

private fun getBitAndPart(value: Double, range: ClosedRange<Double>): Pair<Char, ClosedFloatingPointRange<Double>> {
    val higherPart = higherPart(range)
    return if (value in higherPart(range)) {
        Pair('1', higherPart)
    } else {
        Pair('0', lowerPart(range))
    }
}