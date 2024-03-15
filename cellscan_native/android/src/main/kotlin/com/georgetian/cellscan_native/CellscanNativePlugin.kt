package com.georgetian.cellscan_native

import android.annotation.TargetApi
import android.content.Context.LOCATION_SERVICE
import android.location.Location
import android.location.LocationManager
import android.location.LocationRequest
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import cz.mroczis.netmonster.core.INetMonster
import cz.mroczis.netmonster.core.factory.NetMonsterFactory
import cz.mroczis.netmonster.core.model.cell.ICell

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

import java.util.concurrent.Executor

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CellscanNativePlugin */
// @TargetApi(Build.VERSION_CODES.S)
class CellscanNativePlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private val gson = Gson()
  private lateinit var netMonster: INetMonster
//  private lateinit var locationManager: LocationManager
//  private lateinit var mainExecutor: Executor
//  private val locationRequest = LocationRequest
//    .Builder(0)
//    .setMaxUpdates(1)
//    .setQuality(LocationRequest.QUALITY_HIGH_ACCURACY)
//    .build()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cellscan_native")
    channel.setMethodCallHandler(this)
    netMonster = NetMonsterFactory.get(flutterPluginBinding.applicationContext)
    // mainExecutor = ContextCompat.getMainExecutor(flutterPluginBinding.applicationContext);
    // locationManager = flutterPluginBinding.applicationContext.getSystemService(LOCATION_SERVICE) as LocationManager
  }

  private fun postprocessCells(cells: List<ICell>): String {
    val type = object : TypeToken<List<MutableMap<String, Any>>>() {}.type
    val cellMaps = gson.fromJson<List<MutableMap<String, Any>>>(gson.toJson(cells), type)
    for (i in cells.indices) { // postprocessing on each cell
      val cellType = cells[i]::class.simpleName?.lowercase()
        ?.replace("cell", "") // Add cell type (GSM, LTE etc.)
      if (cellType != null) {
        cellMaps[i]["type"] = cellType
      }
      val connectionStatus = cells[i].connectionStatus::class.simpleName?.lowercase()?.replace("connection", "")
      if (connectionStatus != null) {
        cellMaps[i]["connectionStatus"] = connectionStatus
      }
    }
    return gson.toJson(cellMaps)
  }

//  private fun postprocessLocation(location: Location?): String {
//    if (location == null) {
//      return ""
//    }
//    val type = object : TypeToken<MutableMap<String, Any>>() {}.type
//    val locationMap = gson.fromJson<MutableMap<String, Any>>(gson.toJson(location), type)
//    // locationMap.remove("mExtras")
//
//    // remove leading 'm' in keys
//    val keys = locationMap.keys.toSet()
//    for (key in keys) {
//      locationMap[key.substring(1)] = locationMap.remove(key) as Any
//    }
//    return gson.toJson(locationMap)
//  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
//      "getLocation" -> {
//        try {
//          locationManager.getCurrentLocation(
//            LocationManager.GPS_PROVIDER,
//            locationRequest,
//            null,
//            mainExecutor,
//          ) { location -> result.success(postprocessLocation(location)) }
//        } catch (e: Exception) {
//          result.error(e.toString(), null, null)
//        }
//      }
      "getCells" -> netMonster.apply { result.success(postprocessCells(getCells())) }
      else -> result.notImplemented()
    }

  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
