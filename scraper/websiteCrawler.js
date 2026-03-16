const puppeteer = require('puppeteer');

async function crawlWebsite(url) {
    if (!url || url === 'N/A') return {};
    
    let browser;
    try {
        browser = await puppeteer.launch({ headless: true });
        const page = await browser.newPage();
        await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });
        
        const content = await page.content();
        
        const data = {
            email: extractEmail(content),
            instagram: extractSocial(content, 'instagram.com'),
            facebook: extractSocial(content, 'facebook.com'),
        };
        
        return data;
    } catch (error) {
        console.error(`Error crawling ${url}:`, error.message);
        return {};
    } finally {
        if (browser) await browser.close();
    }
}

function extractEmail(text) {
    const emailRegex = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
    const matches = text.match(emailRegex);
    return matches ? matches[0] : null;
}

function extractSocial(text, platform) {
    const regex = new RegExp(`https?:\/\/(www\\.)?${platform}\/[a-zA-Z0-9._-]+`, 'g');
    const matches = text.match(regex);
    return matches ? matches[0] : null;
}

module.exports = { crawlWebsite };
