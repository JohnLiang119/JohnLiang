import asyncio
import os
import argparse
from urllib.parse import urlparse
from playwright.async_api import async_playwright, Route, Request, Response

async def download_book(url, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    print(f"[{url}] 開始處理，儲存至: {output_dir}")
    
    # 用來記錄已下載的圖片，防止重複
    downloaded_urls = set()
    img_counter = {"count": 1}
    
    async def handle_response(response: Response):
        # 我們只關心圖片
        if response.request.resource_type == "image":
            resp_url = response.url
            # 過濾特定格式，雲展網的內容圖通常是 files/large 或 files/mobile 中的 jpg/png，
            # 或者包含某些特徵的長網址
            if "files/large" in resp_url or "files/mobile" in resp_url or "shot.jpg" not in resp_url:
                # 排除一些介面圖標
                if "html5_templates" in resp_url or "common" in resp_url or "icon" in resp_url.lower():
                    return
                
                if resp_url not in downloaded_urls:
                    downloaded_urls.add(resp_url)
                    try:
                        body = await response.body()
                        if body:
                            # 儲存圖片
                            ext = resp_url.split('.')[-1].split('?')[0]
                            if len(ext) > 4: ext = "jpg" # 預設副檔名
                            
                            filename = f"{img_counter['count']}.{ext}"
                            filepath = os.path.join(output_dir, filename)
                            with open(filepath, "wb") as f:
                                f.write(body)
                            print(f"[{url}] 已下載圖片: {filename} (來源: {resp_url})")
                            img_counter['count'] += 1
                    except Exception as e:
                        print(f"無法讀取圖片 {resp_url}: {e}")

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False) # 先開啟 GUI 方便觀察
        context = await browser.new_context()
        page = await context.new_page()
        
        page.on("response", handle_response)
        
        print(f"[{url}] 載入網頁中...")
        await page.goto(url, wait_until="networkidle")
        
        print(f"[{url}] 網頁已載入，開始自動翻頁...")
        
        # 雲展網的翻頁通常可以按鍵盤右鍵 (ArrowRight) 或特定按鈕
        # 我們重複按下一頁，直到一定次數沒有新圖片
        consecutive_no_new_image = 0
        last_count = img_counter["count"]
        
        while consecutive_no_new_image < 3: # 連續 3 次按下一頁都沒新圖片則當作到底了
            await page.keyboard.press("ArrowRight")
            # 等待一下讓圖片載入
            await asyncio.sleep(2)
            
            current_count = img_counter["count"]
            if current_count == last_count:
                consecutive_no_new_image += 1
            else:
                consecutive_no_new_image = 0
                last_count = current_count
                
        print(f"[{url}] 翻頁結束，共下載 {img_counter['count'] - 1} 張圖片。")
        await browser.close()

async def main():
    parser = argparse.ArgumentParser(description="下載雲展網 (Yunzhan365) 電子書圖片")
    parser.add_argument("urls", nargs="+", help="雲展網電子書的 URL，可傳入多個")
    parser.add_argument("--outdir", default="downloads", help="下載的目標主資料夾")
    args = parser.parse_args()
    
    for url in args.urls:
        # 使用 URL 的一部分作為資料夾名稱
        parsed_url = urlparse(url)
        path_parts = [p for p in parsed_url.path.split('/') if p and p not in ('mobile', 'index.html')]
        book_id = "_".join(path_parts) if path_parts else "book"
        
        output_dir = os.path.join(args.outdir, book_id)
        await download_book(url, output_dir)

if __name__ == "__main__":
    asyncio.run(main())
