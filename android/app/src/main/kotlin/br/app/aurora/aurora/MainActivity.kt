package br.app.aurora.aurora

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

// FragmentActivity: exigido pelo local_auth (bloqueio com biometria).
class MainActivity : FlutterFragmentActivity() {
    private val principal = Handler(Looper.getMainLooper())

    // O Dart confirma que a tela do alarme abriu; sem isso, volta a esconder o app.
    private val recolher = Runnable { mostrarSobreBloqueio(false) }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Antes do super: a janela já nasce por cima do bloqueio.
        if (abertoPeloDespertador(intent)) liberarParaODespertador()
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (abertoPeloDespertador(intent)) liberarParaODespertador()
    }

    /// Aviso do despertador (flutter_local_notifications): ação SELECT_NOTIFICATION e payload
    /// "despertador:…" (lib/core/despertador.dart). Reabrir pelos recentes repete o intent
    /// antigo, por isso fica de fora.
    private fun abertoPeloDespertador(intent: Intent?): Boolean {
        if (intent == null || intent.action != "SELECT_NOTIFICATION") return false
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return false
        return intent.getStringExtra("payload")?.startsWith("despertador:") == true
    }

    private fun liberarParaODespertador() {
        mostrarSobreBloqueio(true)
        principal.removeCallbacks(recolher)
        principal.postDelayed(recolher, 30_000)
    }

    private fun mostrarSobreBloqueio(mostrar: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(mostrar)
            setTurnScreenOn(mostrar)
        } else {
            val bandeiras = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (mostrar) window.addFlags(bandeiras) else window.clearFlags(bandeiras)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Com bloqueio ligado, a tela não aparece nos recentes nem em capturas.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aurora/privacidade")
            .setMethodCallHandler { chamada, resultado ->
                when (chamada.method) {
                    "protegerTela" -> {
                        val bandeira = WindowManager.LayoutParams.FLAG_SECURE
                        if (chamada.arguments == true) window.addFlags(bandeira) else window.clearFlags(bandeira)
                        resultado.success(null)
                    }
                    else -> resultado.notImplemented()
                }
            }
        // Tela do alarme: "aberta" mantém por cima do bloqueio; "fechada" tira.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aurora/despertador")
            .setMethodCallHandler { chamada, resultado ->
                when (chamada.method) {
                    "aberta" -> {
                        principal.removeCallbacks(recolher)
                        resultado.success(null)
                    }
                    "fechada" -> {
                        principal.removeCallbacks(recolher)
                        mostrarSobreBloqueio(false)
                        resultado.success(null)
                    }
                    else -> resultado.notImplemented()
                }
            }
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
