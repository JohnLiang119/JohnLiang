# 檔案編碼規範 (File Encoding Rule)

## 📌 核心要求
所有在 `C:\JohnLiang` 工作區及其底下所有子專案（如 `..Project/` 目錄下的所有專案）中新增、修改或產生的檔案，存檔時**必須一律使用 UTF-8 with BOM** 編碼格式。

## 🎯 重點適用副檔名
以下類型檔案必須嚴格確保具備 UTF-8 BOM（Byte Order Mark: `0xEF, 0xBB, 0xBF`）：
1. **腳本程式**：`*.ps1`, `*.bat`, `*.cmd`
2. **後端程式碼**：`*.cs`（C# 原始碼）
3. **文件與說明**：`*.md`, `CLAUDE.md`, `README.md`
4. **設定檔與資料**：`*.json`, `*.yaml`, `*.yml`, `*.xml`, `*.sql`

## 💡 規範目的與相容性
1. **Windows PowerShell 相容性**：防止 Windows 終端機在解析繁體中文字元時產生亂碼或 ParserError。
2. **舊版 .NET 編譯相容性**：相容 .NET 4.0 / Visual Studio 編譯環境對原始碼檔案之編碼識別。
3. **跨平台與跨電腦同步一致性**：確保在不同電腦間切換開發或使用 Git 同步時，中文字元註解與字串常數保持完整一致。
