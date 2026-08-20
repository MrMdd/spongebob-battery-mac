# 🧽 SpongeBob Battery - macOS Menu Bar App

macOS 13+ için modern SwiftUI `MenuBarExtra`, IOKit pil bildirimleri ve `SMAppService` (Launch at Login) kullanılarak geliştirilmiş menü çubuğu uygulaması.

---

## 🚀 Özellikler

1. **Sıfır CPU / Pil Tüketimi (Event-Driven):**
   - Polling/Timer kullanılmaz.
   - macOS `IOKit` (`IOPSNotificationCreateRunLoopSource`) ile pil seviyesi değiştiğinde işletim sistemi uygulamayı tetikler.
2. **Dinamik Süngerbob İkonları:**
   - 10 farklı pil seviyesi aralığına göre 10 renkli ikon (`1.png` - `10.png`).
   - `.renderingMode(.original)` ile renkler korunur.
   - Menü çubuğuna uygun 22x22 point boyutlandırma.
3. **Dinamik Sözler & Bilgiler:**
   - Pil > %20: *"I don't need it"*
   - Pil %11 - %20: *"I actually need it."*
   - Pil <= %10: *"I NEED IT!"*
   - Anlık pil yüzdesi gösterimi (Örn: `Battery: 45%`).
4. **Dock İkonu Yok (Saf Menu Bar Agent):**
   - `Info.plist` içinde `LSUIElement = true` ayarlandı.
5. **Girişte Otomatik Başlatma (Launch at Login):**
   - macOS 13+ modern `SMAppService.mainApp` ile açılıp kapatılabilir Toggle.
6. **Çıkış Butonu:**
   - `NSApplication.shared.terminate(nil)` ile tam kapatma.

---

## 🛠️ Windows'tan macOS `.app` Çıktısı Alma (GitHub Actions ile)

1. Bu projeyi bir GitHub reposuna yükleyin (Public repo'larda macOS runner tamamen ücretsizdir).
2. GitHub reposunda **Actions** sekmesine gidin.
3. Otomatik olarak çalışan `Build macOS Menu Bar App` işi tamamlandığında **Artifacts** bölümünden `SpongeBobBattery-macOS.zip` dosyasını indirin.
4. Bu zip'i Mac kullanan arkadaşınıza gönderin.

> **Mac'te İlk Açılış Notu:**  
> Apple Geliştirici Sertifikası olmadan (ad-hoc) derlendiği için macOS ilk açılışta "Geliştirici doğrulanamadı" diyebilir. Arkadaşınız Terminal'de şu komutu çalıştırabilir veya `Sağ Tık > Aç` diyebilir:  
> ```bash
> xattr -cr /Applications/SpongeBobBattery.app
> ```
