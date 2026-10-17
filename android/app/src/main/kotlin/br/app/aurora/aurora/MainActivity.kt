package br.app.aurora.aurora

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Atualização automática: o Dart baixa o APK e pede aqui para abrir o instalador.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aurora/atualizacao")
            .setMethodCallHandler { chamada, resultado ->
                when (chamada.method) {
                    // Arquiteturas do aparelho, da preferida para a última (escolhe o APK certo).
                    "abis" -> resultado.success(Build.SUPPORTED_ABIS.toList())
                    "podeInstalar" -> resultado.success(
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
                            packageManager.canRequestPackageInstalls()
                    )
                    "pedirPermissao" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                Uri.parse("package:$packageName")
                            )
                        )
                        resultado.success(null)
                    }
                    "instalar" -> {
                        val arquivo = File(chamada.argument<String>("caminho")!!)
                        val uri = FileProvider.getUriForFile(this, "$packageName.atualizacoes", arquivo)
                        startActivity(
                            Intent(Intent.ACTION_VIEW)
                                .setDataAndType(uri, "application/vnd.android.package-archive")
                                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                        resultado.success(null)
                    }
                    else -> resultado.notImplemented()
                }
            }
    }
}
