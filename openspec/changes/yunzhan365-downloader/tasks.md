## 1. 環境設定與套件初始化

- [x] 1.1 建立 Python 專案目錄與虛擬環境 (如果尚未建立)
- [x] 1.2 安裝必要套件：`pip install playwright requests`
- [x] 1.3 執行 `playwright install chromium` 以下載瀏覽器核心

## 2. 核心爬蟲實作

- [x] 2.1 建立 `yunzhan_downloader.py` 腳本檔案。
- [x] 2.2 實作 Playwright 初始化邏輯，自動開啟目標 URL。
- [x] 2.3 實作 Network Interception (`page.on('response', ...)` )，過濾並下載副檔名為 jpg/png 且屬於內容圖片的請求。
- [x] 2.4 實作自動翻頁機制 (利用 `page.keyboard.press("ArrowRight")` 或是點擊下一頁按鈕)，並加入適當的延遲等待新圖片載入。

## 3. 下載與儲存邏輯

- [x] 3.1 根據書本標題或 URL，動態建立存放圖片的資料夾。
- [x] 3.2 確保圖片檔名依序命名 (1.jpg, 2.jpg ...)，或直接提取原始網址的檔名。
- [x] 3.3 偵測翻頁到底 (如連翻幾頁都沒有新請求) 的終止條件。

## 4. 批次處理與測試

- [x] 4.1 支援接收命令列引數傳遞多個 URL，依序執行下載任務。
- [x] 4.2 實際執行測試以確認那三本電子書均能成功下載。
