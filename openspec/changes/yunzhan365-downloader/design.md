## Context

目前雲展網的圖片網址被混淆與加密 (見 proposal.md)，我們需要建立自動化工具。因為我們需要模擬真實瀏覽器環境執行前端 JS 以獲得解密後的圖片，我們需要使用 Browser Automation 工具。

## Goals / Non-Goals

**Goals:**
- 寫一隻能夠打開給定 URL 並能擷取其圖片檔的腳本。
- 自動化翻頁以觸發所有圖片的載入。

**Non-Goals:**
- 不打算逆向工程破解其混淆的 JS (因為維護成本過高，他們只要一改版就失效)。
- 不開發 GUI 介面，以 Command Line (CLI) 為主。

## Decisions

**技術選型：Python + Playwright**
- **Rationale**: Playwright 在攔截 Network Request 上比 Selenium 更加直觀與穩定。且 Python 容易撰寫與維護。
- **Alternatives Considered**: 
  - Selenium：也可以做到，但在處理非同步 Network 攔截時較為繁瑣。
  - Puppeteer (Node.js)：由於專案慣用語系，加上 Python 生態系在處理資料抓取上更為豐富，故選擇 Python + Playwright。

**圖片攔截機制**
- 在 Playwright 中註冊 `page.on("response", ...)` 事件，過濾 Content-Type 為 image 的請求。
- 當 URL 包含特定模式 (例如 `files/large` 或 `files/mobile` 等特徵，或直接過濾所有載入的大圖) 時，將 Response Body 直接存為檔案。
- 自動點擊「下一頁」按鈕或模擬滑動手勢，直到偵測無新圖片載入為止。

## Risks / Trade-offs

- **Risk**: 翻頁速度過快導致圖片未載入完整就被略過。
  - **Mitigation**: 每次翻頁後加入明確的 Wait 或檢查機制 (例如等待特定的 Request 完成，或固定休眠 2 秒)。
- **Risk**: 雲展網若偵測到無頭瀏覽器 (Headless Browser) 可能會阻擋存取。
  - **Mitigation**: 使用 undetected_chromedriver (若用 Selenium) 或在 Playwright 中隱藏 headless 特徵，初期先使用非 headless 模式 (有頭模式) 進行開發與抓取。
