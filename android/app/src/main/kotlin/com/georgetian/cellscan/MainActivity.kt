package com.georgetian.cellscan

import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.location.LocationRequest
import android.os.Build
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import cz.mroczis.netmonster.core.factory.NetMonsterFactory
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import cz.mroczis.netmonster.core.INetMonster
import cz.mroczis.netmonster.core.model.cell.ICell

class MainActivity: FlutterActivity() {
  private val channel = "com.georgetian.cellscan/cell_info"
  private val gson = Gson()
  private lateinit var netMonster: INetMonster
  private lateinit var locationManager: LocationManager
  @RequiresApi(Build.VERSION_CODES.S)
  private val locationRequest = LocationRequest
    .Builder(0)
    .setMaxUpdates(1)
    .setQuality(LocationRequest.QUALITY_HIGH_ACCURACY)
    .build()


  private fun postprocessCells(cells: List<ICell>): String {
    val type = object : TypeToken<List<MutableMap<String, Any>>>() {}.type
    val cellMaps = gson.fromJson<List<MutableMap<String, Any>>>(gson.toJson(cells), type)
    for (i in cells.indices) { // postprocessing on each cell
      val cellType = cells[i]::class.simpleName?.lowercase()
        ?.replace("cell", "") // Add cell type (GSM, LTE etc.)
      if (cellType != null) {
        cellMaps[i]["type"] = cellType
      }
      val connectionStatus = cells[i].connectionStatus::class.simpleName
      if (connectionStatus != null) {
        cellMaps[i]["connectionStatus"] = connectionStatus
      }
    }
    return gson.toJson(cellMaps)
  }

  private fun postprocessLocation(location: Location?): String {
    if (location == null) {
      return ""
    }
    val type = object : TypeToken<MutableMap<String, Any>>() {}.type
    val locationMap = gson.fromJson<MutableMap<String, Any>>(gson.toJson(location), type)
    locationMap.remove("mExtras")

    return gson.toJson(locationMap)
  }

  private fun requestPermissions() {
    if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED
    ) {
      // Permission is already granted.
      Toast.makeText(this, "already ok", Toast.LENGTH_SHORT).show()
    } else {
      Toast.makeText(this, "prompting", Toast.LENGTH_SHORT).show()
      // Permission is not granted.
      ActivityCompat.requestPermissions(this,
        arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE), 1)
    }

  }

  @RequiresApi(Build.VERSION_CODES.S)
  @SuppressLint("MissingPermission")
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    netMonster = NetMonsterFactory.get(this)
    locationManager = getSystemService(LOCATION_SERVICE) as LocationManager

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
      try {
        when (call.method) {
          "location" -> locationManager.getCurrentLocation(
            LocationManager.GPS_PROVIDER,
            locationRequest,
            null,
            mainExecutor
          ) { location -> result.success(postprocessLocation(location)) }
          "cells" -> netMonster.apply { result.success(postprocessCells(getCells())) }
          "permissions" -> {
            requestPermissions()
            result.success("")
          }
          else -> result.notImplemented()
        }
      } catch (e: Exception) {
        result.error(e.toString(), null, null)
      }
    }

  }
}