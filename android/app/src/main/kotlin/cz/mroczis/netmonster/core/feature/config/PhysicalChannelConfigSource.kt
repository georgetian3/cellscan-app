package cz.mroczis.netmonster.core.feature.config

import android.os.Build
import android.telephony.TelephonyManager
import cz.mroczis.netmonster.core.SubscriptionId
import cz.mroczis.netmonster.core.cache.TelephonyCache
import cz.mroczis.netmonster.core.feature.config.PhysicalChannelConfigSource.PhysicalChannelListener
import cz.mroczis.netmonster.core.model.config.PhysicalChannelConfig
import cz.mroczis.netmonster.core.util.SingleEventPhoneStateListener

/**
 * Fetches [PhysicalChannelConfig] from [PhysicalChannelListener]. Those data are currently not publicly
 * accessible however, some phones fill them (Pixel 3 XL, OnePlus 6T, Xiaomi Mi 9T).
 *
 * Data are obtained from system on each request, no caching is involved here hence it might take a
 * few milliseconds.
 */
class PhysicalChannelConfigSource {

    companion object {
        // Copied from SDK, this field is currently hidden
        const val LISTEN_PHYSICAL_CHANNEL_CONFIGURATION = 0x00100000
    }

    /**
     * Registers [PhysicalChannelListener] and awaits for data. After 500 milliseconds time outs if
     * nothing is delivered.
     */
    fun get(telephonyManager: TelephonyManager, subId: SubscriptionId): List<PhysicalChannelConfig> =
        if (Build.VERSION.SDK_INT in Build.VERSION_CODES.P..Build.VERSION_CODES.Q) {
            TelephonyCache.getOrUpdate(subId, TelephonyCache.Event.PHYSICAL_CHANNEL) {
                telephonyManager.requestPhoneStateUpdate<List<PhysicalChannelConfig>> { onData ->
                    PhysicalChannelListener(subId, onData)
                }
            } ?: emptyList()
        } else {
            emptyList()
        }


    /**
     * Kotlin friendly PhoneStateListener
     */
    private class PhysicalChannelListener(
        subId: SubscriptionId?,
        private val physicalChannelCallback: UpdateResult<PhysicalChannelListener, List<PhysicalChannelConfig>>,
    ) : SingleEventPhoneStateListener(LISTEN_PHYSICAL_CHANNEL_CONFIGURATION, subId) {

        override fun onPhysicalChannelConfigurationChanged(configs: List<Any?>) {
            val mapped = configs
                .mapNotNull { it.toString() }
                .map { PhysicalChannelConfig.fromString(it) }

            physicalChannelCallback.invoke(this, mapped)
        }
    }
}