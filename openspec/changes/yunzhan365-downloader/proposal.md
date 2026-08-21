## Why

雲展網 (Yunzhan365) 等電子書平台會將書籍的圖片 URL 隱藏或加密，無法直接透過分析 HTML 來批次下載。我們需要一隻自動化爬蟲腳本，模擬真人在瀏覽器上的行為來翻頁，並攔截網路請求以獲取真正的圖片檔。這能解決手動下載的繁瑣問題。

## What Changes

- 新增一支 Python (搭配 Playwright 或 Selenium) 的爬蟲腳本。
- 腳本將能夠接收雲展網的網址，自動開啟瀏覽器，執行翻頁操作。
- 攔截瀏覽器的 Network 請求，辨識並下載每一頁的高畫質圖片。
- 支援批次處理多個網址。

## Capabilities

### New Capabilities
- `download`: 提供抓取雲展網圖片的功能與腳本參數設計。

### Modified Capabilities
- 無

## Impact

- 新增一個獨立的爬蟲專案/腳本 (例如 `scripts/yunzhan-downloader.py` 或類似的工具目錄)。
- 無影響現有的其他功能系統。
