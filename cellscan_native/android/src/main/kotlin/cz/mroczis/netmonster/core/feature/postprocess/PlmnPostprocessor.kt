package cz.mroczis.netmonster.core.feature.postprocess

import cz.mroczis.netmonster.core.SubscriptionId
import cz.mroczis.netmonster.core.db.BandTableGsm
import cz.mroczis.netmonster.core.db.BandTableLte
import cz.mroczis.netmonster.core.model.Network
import cz.mroczis.netmonster.core.model.cell.*
import cz.mroczis.netmonster.core.model.connection.IConnection

/**
 * Attempts to assign valid PLMN ([Network]) to cells which do not have valid value.
 */
class PlmnPostprocessor : ICellPostprocessor {

    private val plmnExtractor = PlmnExtractor()

    override fun postprocess(list: List<ICell>): List<ICell> {
        val plmns: Map<NetworkGeneration, List<PlmnNetwork>> = list
            .mapNotNull { it.let(plmnExtractor) }
            .distinct()
            .groupBy { it.generation }

        val plmnStacker = PlmnStacker(plmns)
        return list.map { it.let(plmnStacker) }
    }

    /**
     * Extracts data required to assign PLMN to cells that to not have valid PLMN
     */
    private class PlmnExtractor : ICellProcessor<PlmnNetwork?> {
        override fun processCdma(cell: CellCdma): PlmnNetwork? = null

        override fun processGsm(cell: CellGsm) = cell.network?.let {
            PlmnNetwork(
                subscriptionId = cell.subscriptionId,
                network = it,
                generation = NetworkGeneration.GSM,
                connection = cell.connectionStatus,
                channelNumber = null,
                areaCode = cell.lac
            )
        }

        override fun processWcdma(cell: CellWcdma) = cell.network?.let {
            PlmnNetwork(
                subscriptionId = cell.subscriptionId,
                network = it,
                generation = NetworkGeneration.WCDMA,
                connection = cell.connectionStatus,
                channelNumber = cell.band?.channelNumber
            )
        }

        override fun processLte(cell: CellLte) = cell.network?.let {
            PlmnNetwork(
                subscriptionId = cell.subscriptionId,
                network = it,
                generation = NetworkGeneration.LTE,
                connection = cell.connectionStatus,
                channelNumber = cell.band?.channelNumber
            )
        }

        override fun processTdscdma(cell: CellTdscdma) = cell.network?.let {
            PlmnNetwork(
                subscriptionId = cell.subscriptionId,
                network = it,
                generation = NetworkGeneration.TDSCDMA,
                connection = cell.connectionStatus,
                channelNumber = cell.band?.channelNumber
            )
        }

        override fun processNr(cell: CellNr) = cell.network?.let {
            PlmnNetwork(
                subscriptionId = cell.subscriptionId,
                network = it,
                generation = NetworkGeneration.NR,
                connection = cell.connectionStatus,
                channelNumber = cell.band?.channelNumber
            )
        }
    }

    /**
     * Assigns PLMN to [ICell] from its [dictionary].
     * Processing differs for each [NetworkGeneration].
     *  - CDMA is not supported
     *  - For WCDMA, LTE, NR and TDSCDMA copies PLMN of serving cell or takes
     *  PLMN of cell that has same channel number
     *  - For GSM takes PLMN of serving cell only if there are no other serving cells
     *  (in dual SIM phones neighbours of both SIMs usually appear). In second case we take look
     *  on LAC that can sometimes help (when it equals, we also grab that PLMN)
     */
    private class PlmnStacker(
        private val dictionary: Map<NetworkGeneration, List<PlmnNetwork>>
    ) : ICellProcessor<ICell> {

        override fun processCdma(cell: CellCdma) = cell

        override fun processGsm(cell: CellGsm) = dictionary[NetworkGeneration.GSM]?.let { plmns ->
            val subscriptionPlmns = plmns.filter { it.subscriptionId == cell.subscriptionId }
            if (subscriptionPlmns.size == 1) {
                val network = subscriptionPlmns[0].network
                cell.copy(
                    network = network,
                    band = cell.band?.let { BandTableGsm.map(it.arfcn, mcc = network.mcc) }
                )
            } else {
                val lacPlmn = subscriptionPlmns.firstOrNull { it.areaCode == cell.lac }
                if (lacPlmn != null && lacPlmn.network != cell.network) {
                    cell.copy(
                        network = lacPlmn.network,
                        band = cell.band?.let { BandTableGsm.map(it.arfcn, mcc = lacPlmn.network.mcc) }
                    )
                } else {
                    cell
                }
            }
        } ?: getFirstPlmnIfOnly(cell) { network ->
            cell.copy(
                network = network,
                band = cell.band?.let { BandTableGsm.map(it.arfcn, mcc = network.mcc) }
            )
        }

        override fun processLte(cell: CellLte) =
            findByChannel(
                gen = NetworkGeneration.LTE,
                subscriptionId = cell.subscriptionId,
                channel = cell.band?.channelNumber,
                // Fixes channel number for select carriers
                onInterceptChannel = { candidate, channel -> BandTableLte.getFixedEarfcn(channel, candidate.network.mcc) }
            )?.let {
                cell.copy(network = it, band = cell.band?.channelNumber?.let { earfcn -> BandTableLte.map(earfcn, it.mcc) })
            } ?: getFirstPlmnIfOnly(cell) { cell.copy(network = it) }

        override fun processNr(cell: CellNr) =
            findByChannel(NetworkGeneration.NR, cell.subscriptionId, cell.band?.channelNumber)?.let {
                cell.copy(network = it)
            } ?: getFirstPlmnIfOnly(cell, allowSubscriptionOverride = NetworkGeneration.LTE) { cell.copy(network = it) }

        override fun processTdscdma(cell: CellTdscdma) =
            findByChannel(NetworkGeneration.TDSCDMA, cell.subscriptionId, cell.band?.channelNumber)?.let {
                cell.copy(network = it)
            } ?: getFirstPlmnIfOnly(cell) { cell.copy(network = it) }

        override fun processWcdma(cell: CellWcdma) =
            findByChannel(NetworkGeneration.WCDMA, cell.subscriptionId, cell.band?.channelNumber)?.let {
                cell.copy(network = it)
            } ?: getFirstPlmnIfOnly(cell) { cell.copy(network = it) }

        /**
         * Searches for a PLMN using primarily network generation (2G, 3G, ...)
         * If there are multiple candidates for given network generation (e.g. Dual SIM, both connected to 4G) then channel number
         * is used to find correct PLMN.
         *
         * Some adjustments of [channel] might be needed if it's bound to [PlmnNetwork]. For example some devices
         * report incorrect EARFCN and it needs to be fixed
         */
        private fun findByChannel(
            gen: NetworkGeneration,
            subscriptionId: SubscriptionId,
            channel: Int?,
            // Default impl = keep channel that was passed assuming it's correct
            onInterceptChannel: (PlmnNetwork, Int) -> Int? = { _, channel -> channel },
        ): Network? =
            dictionary[gen]?.let { plmns ->
                val subscriptionPlmns = plmns.filter { it.subscriptionId == subscriptionId }
                if (subscriptionPlmns.size == 1) {
                    subscriptionPlmns[0].network
                } else if (channel != null) {
                    subscriptionPlmns.find { it.channelNumber == onInterceptChannel(it, channel) }?.network
                } else {
                    null
                }
            }

        /**
         * Takes 1st PLMN if it's the only one in [dictionary].
         * If there are multiple matching entries and there's unique combination "subscription id + network generation" then PLMN of serving cell is returned
         * (common case is that in NR NSA PLMN of LTE cell gets assigned to a NSA cell)
         */
        private fun getFirstPlmnIfOnly(
            cell: ICell,
            allowSubscriptionOverride: NetworkGeneration? = null,
            callback: (Network) -> ICell
        ): ICell =
            if (dictionary.size == 1 && dictionary.values.first().size == 1) {
                callback.invoke(dictionary.values.first()[0].network)
            } else if (allowSubscriptionOverride != null && dictionary[allowSubscriptionOverride] != null) {
                val subEntries = dictionary[allowSubscriptionOverride]!!.filter { it.subscriptionId == cell.subscriptionId }
                if (subEntries.size == 1) {
                    callback.invoke(subEntries[0].network)
                } else {
                    cell
                }
            } else {
                cell
            }
    }

    /**
     * Internal data structure that holds all attributes we need to assign PLMN properly
     */
    private data class PlmnNetwork(
        val subscriptionId: Int,
        val network: Network,
        val generation: NetworkGeneration,
        val connection: IConnection,
        val channelNumber: Int? = null,
        val areaCode: Int? = null
    )

    /**
     * Network generations supported by this algorithm
     */
    private enum class NetworkGeneration {
        GSM, LTE, NR, TDSCDMA, WCDMA
    }
}