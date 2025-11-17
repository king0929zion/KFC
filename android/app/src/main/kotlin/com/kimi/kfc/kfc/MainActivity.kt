package com.kimi.kfc.kfc

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform

class MainActivity : FlutterActivity() {
    private val CHANNEL = "kfc.python.bridge"
    private var pythonBridge: Any? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    try {
                        initializePython()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", "Failed to initialize Python: ${e.message}", null)
                    }
                }
                "sendMessage" -> {
                    val message = call.argument<String>("message")
                    if (message != null) {
                        try {
                            val response = sendMessageToPython(message)
                            result.success(response)
                        } catch (e: Exception) {
                            result.error("SEND_ERROR", "Failed to send message: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Message is null", null)
                    }
                }
                "executeTool" -> {
                    val toolType = call.argument<String>("toolType")
                    val params = call.argument<String>("params")
                    if (toolType != null && params != null) {
                        try {
                            val response = executeToolInPython(toolType, params)
                            result.success(response)
                        } catch (e: Exception) {
                            result.error("TOOL_ERROR", "Failed to execute tool: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Tool type or params is null", null)
                    }
                }
                "getHistory" -> {
                    try {
                        val history = getHistoryFromPython()
                        result.success(history)
                    } catch (e: Exception) {
                        result.error("HISTORY_ERROR", "Failed to get history: ${e.message}", null)
                    }
                }
                "getContextHistory" -> {
                    try {
                        val history = getContextHistoryFromPython()
                        result.success(history)
                    } catch (e: Exception) {
                        result.error("HISTORY_ERROR", "Failed to get context history: ${e.message}", null)
                    }
                }
                "compactContext" -> {
                    try {
                        val response = compactContextInPython()
                        result.success(response)
                    } catch (e: Exception) {
                        result.error("COMPACT_ERROR", "Failed to compact context: ${e.message}", null)
                    }
                }
                "getStatus" -> {
                    try {
                        val status = getStatusFromPython()
                        result.success(status)
                    } catch (e: Exception) {
                        result.error("STATUS_ERROR", "Failed to get status: ${e.message}", null)
                    }
                }
                "clearHistory" -> {
                    try {
                        val response = clearHistoryInPython()
                        result.success(response)
                    } catch (e: Exception) {
                        result.error("CLEAR_ERROR", "Failed to clear history: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializePython() {
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(context))
        }
        
        val py = Python.getInstance()
        val module = py.getModule("kimi_bridge")
        pythonBridge = module
    }

    private fun sendMessageToPython(message: String): String {
        if (pythonBridge == null) {
            initializePython()
        }
        
        val py = Python.getInstance()
        val module = py.getModule("kimi_bridge")
        val result = module.callAttr("send_message", message)
        return result.toString()
    }

    private fun executeToolInPython(toolType: String, paramsJson: String): String {
        if (pythonBridge == null) {
            initializePython()
        }
        
        val py = Python.getInstance()
        val module = py.getModule("kimi_bridge")
        val result = module.callAttr("execute_tool", toolType, paramsJson)
        return result.toString()
    }

    private fun getHistoryFromPython(): String {
        if (pythonBridge == null) {
            initializePython()
        }
        
        val py = Python.getInstance()
        val module = py.getModule("kimi_bridge")
        val result = module.callAttr("get_history")
        return result.toString()
    }

    private fun clearHistoryInPython(): String {
        if (pythonBridge == null) {
            initializePython()
        }
        
        val py = Python.getInstance()
        val module = py.getModule("kimi_bridge")
        val result = module.callAttr("clear_history")
        return result.toString()
    }

    private fun getContextHistoryFromPython(): String {
        if (pythonBridge == null) {
            initializePython()
        }
        
        val py = Python.getInstance()
        val module = py.getModule("kimi_bridge")
        val result = module.callAttr("get_context_history")
        return result.toString()
    }

    private fun compactContextInPython(): String {
        if (pythonBridge == null) {
            initializePython()
        }
        
        val py = Python.getInstance()
        val module = py.getModule("kimi_bridge")
        val result = module.callAttr("compact_context")
        return result.toString()
    }

    private fun getStatusFromPython(): String {
        if (pythonBridge == null) {
            initializePython()
        }
        
        val py = Python.getInstance()
        val module = py.getModule("kimi_bridge")
        val result = module.callAttr("get_status")
        return result.toString()
    }
}
