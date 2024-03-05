package cz.mroczis.netmonster.core.feature.merge

import cz.mroczis.netmonster.core.model.cell.CellLte
import cz.mroczis.netmonster.core.model.cell.CellNr
import cz.mroczis.netmonster.core.model.cell.ICell
import cz.mroczis.netmonster.core.model.connection.NoneConnection
import cz.mroczis.netmonster.core.model.connection.PrimaryConnection
import cz.mroczis.netmonster.core.model.connection.SecondaryConnection

/**
 * Merges data from new API represented by [CellSource.ALL_CELL_INFO] and
 * signal API represented by [CellSource.SIGNAL_STRENGTH]
 */
internal class CellSignalMerger {

    /**
     * Merge in this case adds cell from [signalApi] if [newApi] does not contain
     * NR cell that is bound to same the subscription id and is primary.
     */
    fun merge(newApi: List<ICell>, signalApi: List<CellNr>): List<ICell> {
        val nrCells = newApi.filterIsInstance(CellNr::class.java)
        val nonPresentNr = signalApi.filter { signalCell ->
            nrCells.find {
                it.subscriptionId == signalCell.subscriptionId && it.connectionStatus is PrimaryConnection
            } == null
        }

        return if (nonPresentNr.isEmpty()) {
            newApi
        } else {
            if (nrCells.size == 1 && signalApi.size == 1) {
                // Usually NR in NSA, signal source has correct signal, CellInfo source has PSC and ARFCN, must merge manually
                // HUAWEI CDY-NX9A
                val mergedCell = nrCells[0] mergeWith signalApi[0]
                newApi.toMutableList().apply {
                    remove(nrCells[0])
                    add(mergedCell)
                }
            } else if (nrCells.size > 1 && signalApi.size == 1) {
                // Multiple NR cells (two sims with working 5G), decide using subscription id
                val targetSub = signalApi[0].subscriptionId
                val sourceCell = nrCells.find { it.subscriptionId == targetSub }
                if (sourceCell != null) {
                    val mergedCell = sourceCell mergeWith signalApi[0]
                    newApi.toMutableList().apply {
                        remove(nrCells[0])
                        add(mergedCell)
                    }
                } else {
                    // No matching sub, pass everything
                    newApi.toMutableList().apply {
                        addAll(nonPresentNr)
                    }.toList()
                }
            } else {
                // Merge data from Signal API + add PLMN if possible
                newApi + nonPresentNr.map { nrCell ->
                    if (nrCell.network == null) {
                        val network = (newApi.find { it.subscriptionId == nrCell.subscriptionId && it is CellLte } as? CellLte)?.network
                        nrCell.copy(network = network)
                    } else {
                        nrCell
                    }
                }
            }
        }
    }


    private infix fun CellNr.mergeWith(other: CellNr): CellNr = copy(
        connectionStatus = connectionStatus.takeIf { it is PrimaryConnection }
            ?: other.connectionStatus.takeIf { it is PrimaryConnection }
            ?: connectionStatus.takeIf { it is SecondaryConnection }
            ?: other.connectionStatus.takeIf { it is SecondaryConnection } ?: NoneConnection(),
        nci = nci ?: other.nci,
        tac = tac ?: other.tac,
        pci = pci ?: other.pci,
        band = band ?: other.band,
        signal = signal.copy(
            csiRsrp = signal.csiRsrp minOr other.signal.csiRsrp,
            csiRsrq = signal.csiRsrq minOr other.signal.csiRsrq,
            csiSinr = signal.csiSinr minOr other.signal.csiSinr,
            ssRsrp = signal.ssRsrp minOr other.signal.ssRsrp,
            ssRsrq = signal.ssRsrq minOr other.signal.ssRsrq,
            ssSinr = signal.ssSinr minOr other.signal.ssSinr
        )
    )

    /**
     * Takes first not not null or min out of two
     */
    private infix fun Int?.minOr(other: Int?) =
        if (this != null && other != null) {
            kotlin.math.min(this, other)
        } else this ?: other
}