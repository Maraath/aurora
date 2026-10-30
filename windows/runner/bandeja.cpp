#include "bandeja.h"

#include <flutter/standard_method_codec.h>

#include "resource.h"

namespace {

constexpr UINT kCmdRestaurar = 1001;
constexpr UINT kCmdSair = 1002;

}  // namespace

Bandeja::Bandeja(flutter::BinaryMessenger* mensageiro, HWND janela)
    : janela_(janela) {
  canal_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      mensageiro, "aurora/bandeja",
      &flutter::StandardMethodCodec::GetInstance());
  canal_->SetMethodCallHandler([this](const auto& chamada, auto resultado) {
    const std::string& metodo = chamada.method_name();
    if (metodo == "restaurar") {
      RestaurarJanela();
      resultado->Success();
    } else if (metodo == "ocultar") {
      OcultarJanela();
      resultado->Success();
    } else if (metodo == "fecharParaBandeja") {
      if (const auto* ativo = std::get_if<bool>(chamada.arguments())) {
        DefinirFecharParaBandeja(*ativo);
      }
      resultado->Success(flutter::EncodableValue(fechar_para_bandeja_));
    } else if (metodo == "obterFecharParaBandeja") {
      resultado->Success(flutter::EncodableValue(fechar_para_bandeja_));
    } else {
      resultado->NotImplemented();
    }
  });

  Criar();
}

Bandeja::~Bandeja() {
  Destruir();
}

bool Bandeja::Criar() {
  if (janela_ == nullptr) return false;

  // Se já existia uma instância anterior (ex: Explorer reiniciou), remove antes.
  if (criada_) {
    Shell_NotifyIconW(NIM_DELETE, &nid_);
    criada_ = false;
  }

  ZeroMemory(&nid_, sizeof(nid_));
  nid_.cbSize = sizeof(NOTIFYICONDATAW);
  nid_.hWnd = janela_;
  nid_.uID = 1;
  nid_.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  nid_.uCallbackMessage = kMensagemBandeja;

  HINSTANCE hInst = GetModuleHandle(nullptr);
  nid_.hIcon = static_cast<HICON>(
      LoadImage(hInst, MAKEINTRESOURCE(IDI_APP_ICON), IMAGE_ICON,
                GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON),
                LR_DEFAULTCOLOR));
  if (nid_.hIcon == nullptr) {
    nid_.hIcon = LoadIcon(hInst, MAKEINTRESOURCE(IDI_APP_ICON));
  }

  wcsncpy_s(nid_.szTip, L"Aurora", _TRUNCATE);

  criada_ = Shell_NotifyIconW(NIM_ADD, &nid_) != FALSE;
  return criada_;
}

void Bandeja::Destruir() {
  if (criada_) {
    Shell_NotifyIconW(NIM_DELETE, &nid_);
    if (nid_.hIcon != nullptr) {
      DestroyIcon(nid_.hIcon);
      nid_.hIcon = nullptr;
    }
    criada_ = false;
  }
}

void Bandeja::AoEvento(WPARAM wparam, LPARAM lparam) {
  switch (LOWORD(lparam)) {
    case WM_LBUTTONUP:
    case WM_LBUTTONDBLCLK:
      RestaurarJanela();
      break;

    case WM_RBUTTONUP:
    case WM_CONTEXTMENU:
      MostrarMenuContexto();
      break;
  }
}

void Bandeja::RestaurarJanela() {
  if (janela_ == nullptr) return;

  if (!IsWindowVisible(janela_)) {
    ShowWindow(janela_, SW_SHOW);
  }
  if (IsIconic(janela_)) {
    ShowWindow(janela_, SW_RESTORE);
  }
  SetForegroundWindow(janela_);

  if (canal_) {
    canal_->InvokeMethod("restaurada", nullptr);
  }
}

void Bandeja::OcultarJanela() {
  if (janela_ == nullptr) return;

  ShowWindow(janela_, SW_HIDE);

  if (!aviso_mostrado_) {
    aviso_mostrado_ = true;
    MostrarAviso(
        L"Aurora continua em execução",
        L"O app fica na bandeja para continuar enviando seus lembretes e alertas.");
  }
}

void Bandeja::MostrarAviso(const std::wstring& titulo, const std::wstring& texto) {
  if (!criada_) return;

  NOTIFYICONDATAW aviso = nid_;
  aviso.uFlags |= NIF_INFO;
  wcsncpy_s(aviso.szInfoTitle, titulo.c_str(), _TRUNCATE);
  wcsncpy_s(aviso.szInfo, texto.c_str(), _TRUNCATE);
  aviso.dwInfoFlags = NIIF_INFO;
  Shell_NotifyIconW(NIM_MODIFY, &aviso);
}

void Bandeja::MostrarMenuContexto() {
  HMENU menu = CreatePopupMenu();
  if (!menu) return;

  InsertMenuW(menu, -1, MF_BYPOSITION | MF_STRING, kCmdRestaurar, L"Abrir Aurora");
  InsertMenuW(menu, -1, MF_BYPOSITION | MF_SEPARATOR, 0, nullptr);
  InsertMenuW(menu, -1, MF_BYPOSITION | MF_STRING, kCmdSair, L"Sair do Aurora");

  SetMenuDefaultItem(menu, kCmdRestaurar, FALSE);

  POINT ponto;
  GetCursorPos(&ponto);

  // Exigência da Win32 API para que o popup feche ao clicar fora
  SetForegroundWindow(janela_);

  UINT cmd = TrackPopupMenuEx(menu, TPM_RETURNCMD | TPM_RIGHTBUTTON | TPM_NONOTIFY,
                              ponto.x, ponto.y, janela_, nullptr);
  DestroyMenu(menu);

  if (cmd == kCmdRestaurar) {
    RestaurarJanela();
  } else if (cmd == kCmdSair) {
    PostMessage(janela_, WM_COMMAND, MAKEWPARAM(kCmdSair, 0), 0);
  }
}
