package cz.mroczis.netmonster.core.db

import cz.mroczis.netmonster.core.db.model.BandEntity
import cz.mroczis.netmonster.core.db.model.IBandEntity
import cz.mroczis.netmonster.core.model.band.BandLte

/**
 * [3GPP 36.101](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=2411)
 */
object BandTableLte {

    internal val BAND_NUMBER_RANGE = 1..88

    private val bands = arrayOf(
        BandEntity(0..599, "2100", 1),
        BandEntity(600..1199, "1900", 2),
        BandEntity(1_200..1_949, "1800", 3),
        BandEntity(1_950..2_399, "AWS", 4),
        BandEntity(2_400..2_649, "850", 5),
        BandEntity(2_650..2_749, "900", 6),
        BandEntity(2_750..3_449, "2600", 7),
        BandEntity(3_450..3_799, "900", 8),
        BandEntity(3_800..4_149, "1800", 9),
        BandEntity(4_150..4_749, "AWS", 10),
        BandEntity(4_750..5_009, "1500", 11),
        BandEntity(5_010..5_179, "700", 12),
        BandEntity(5_180..5_279, "700", 13),
        BandEntity(5_280..5_729, "700", 14),
        BandEntity(5_730..5_849, "700", 17),
        BandEntity(5_850..5_999, "800", 18),
        BandEntity(6_000..6_149, "800", 19),
        BandEntity(6_150..6_449, "800", 20),
        BandEntity(6_450..6_599, "1500", 21),
        BandEntity(6_600..7_499, "3500", 22),
        BandEntity(7_500..7_699, "2000", 23),
        BandEntity(7_700..8_039, "1600", 24),
        BandEntity(8_040..8_689, "1900", 25),
        BandEntity(8_690..9_039, "850", 26),
        BandEntity(9_040..9_209, "800", 27),
        BandEntity(9_210..9_659, "700", 28),
        BandEntity(9_660..9_769, "700", 29),
        BandEntity(9_770..9_869, "2300", 30),
        BandEntity(9_870..9_919, "450", 31),
        BandEntity(9_920..10_359, "1500", 32),

        // TDD start
        BandEntity(36_000..36_199, "1900", 33),
        BandEntity(36_200..36_349, "2000", 34),
        BandEntity(36_350..36_949, "PCS", 35),
        BandEntity(36_950..37_549, "PCS", 36),
        BandEntity(37_550..37_749, "PCS", 37),
        BandEntity(37_750..38_249, "2600", 38),
        BandEntity(38_250..38_649, "1900", 39),
        BandEntity(38_650..39_649, "2300", 40),
        BandEntity(39_650..41_589, "2500", 41),
        BandEntity(41_590..43_589, "3500", 42),
        BandEntity(43_590..45_589, "3700", 43),
        BandEntity(45_590..46_589, "700", 44),
        BandEntity(46_590..46_789, "1500", 45),
        BandEntity(46_790..54_539, "5200", 46),
        BandEntity(54_540..55_239, "5900", 47),
        BandEntity(55_240..56_739, "3600", 48),
        BandEntity(56_740..58_239, "3600", 49),
        BandEntity(58_240..59_089, "1500", 50),
        BandEntity(59_090..59_139, "1500", 51),
        BandEntity(59_140..60_139, "3300", 52),
        BandEntity(60_140..60_254, "2500", 53),
        // TDD end

        BandEntity(65_536..66_435, "2100", 65),
        BandEntity(66_436..67_335, "AWS", 66),
        BandEntity(67_336..67_535, "700", 67),
        BandEntity(67_536..67_835, "700", 68),
        BandEntity(67_836..68_335, "2500", 69),
        BandEntity(68_336..68_585, "AWS", 70),
        BandEntity(68_586..68_935, "600", 71),
        BandEntity(68_936..68_985, "450", 72),
        BandEntity(68_986..69_035, "450", 73),
        BandEntity(69_036..69_465, "L", 74),
        BandEntity(69_466..70_315, "1500", 75),
        BandEntity(70_316..70_365, "1500", 76),
        BandEntity(70_366..70_545, "700", 85),
        BandEntity(70_546..70_595, "410", 87),
        BandEntity(70_596..70_645, "410", 88),
        BandEntity(70_646..70_655, "700", 103),
    )

    /**
     * Some devices report max EARFCN as 2^16, however max possible value is higher.
     * Returned values are equal to remainder after division by 2^16.
     * Example: 1275 (b3) in Canada eventually equals to 66811 = 1275 + 2^16 (b66)
     * This map contains mapping of MCC to ranges that are 100 % invalid and 2^16 should be added to an EARFCN.
     *
     * For ranges explanation have a look at: https://github.com/mroczis/netmonster-core/issues/59#issuecomment-1374842154
     */
    private val integerOverflowFix = mapOf(
        "228" to listOf(1_950..1_999, 3_930..4_779), // Switzerland, b67 (non-overlapping part with b3) + b75
        "302" to listOf(1_200..1_799), // Canada, b66 (non-overlapping part with b2)
        "310" to listOf(1_200..1_799, 3_050..3_399), // USA, b66 (non-overlapping part with b2) + b71
        "311" to listOf(1_200..1_799, 3_050..3_399), // USA, b66 (non-overlapping part with b2) + b71
        "466" to listOf(900..1_199), // Taiwan, b66 (non-overlapping part with b3)
        "730" to listOf(900..1_799), // Chile, b66
    )

    internal fun getFixedEarfcn(earfcn: Int, mcc: String?) =
        if (mcc != null && integerOverflowFix[mcc]?.any { range -> earfcn in range } == true) {
            earfcn + 65536
        } else {
            earfcn
        }

    internal fun get(earfcn: Int): IBandEntity? =
        bands.firstOrNull { it.channelRange.contains(earfcn) }

    internal fun getByNumber(number: Int): IBandEntity? =
        bands.firstOrNull { it.number == number }


    /**
     * Attempts to find current band information depending on [earfcn].
     * If no such band is found then result [BandLte] will contain only [BandLte.downlinkEarfcn].
     */
    fun map(earfcn: Int, mcc: String? = null): BandLte {
        val fixedEarfcn = getFixedEarfcn(earfcn, mcc)
        val raw = get(fixedEarfcn)
        return BandLte(
            downlinkEarfcn = fixedEarfcn,
            number = raw?.number,
            name = raw?.name
        )
    }

    private data class CountryOverride(
        val range: IntRange,
        val addition: Int,
    )

}