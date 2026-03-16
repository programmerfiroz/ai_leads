const puppeteer = require('puppeteer');
const { crawlWebsite } = require('./websiteCrawler');
const { sendLeadToApi } = require('./apiClient');

async function scrapeGoogleMaps(keyword, location, token) {
    const searchQuery = `${keyword} in ${location}`;
    const url = `https://www.google.com/maps/search/${encodeURIComponent(searchQuery)}`;
    
    const browser = await puppeteer.launch({ headless: true }); // Changed to headless for testing environment
    const page = await browser.newPage();
    
    try {
        await page.goto(url, { waitUntil: 'networkidle2' });
        
        // Wait for results to load
        await page.waitForSelector('div[role="feed"]');
        
        // Scroll to load more results (simplified)
        for (let i = 0; i < 3; i++) {
            await page.evaluate(() => {
                const feed = document.querySelector('div[role="feed"]');
                if (feed) feed.scrollTop = feed.scrollHeight;
            });
            await new Promise(r => setTimeout(r, 2000));
        }
        
        const businessLinks = await page.evaluate(() => {
            const links = Array.from(document.querySelectorAll('a[href*="/maps/place/"]'));
            return links.map(link => link.href);
        });
        
        const uniqueLinks = [...new Set(businessLinks)];
        console.log(`Found ${uniqueLinks.length} potential businesses.`);
        
        for (const link of uniqueLinks) {
            try {
                const detailPage = await browser.newPage();
                await detailPage.goto(link, { waitUntil: 'networkidle2' });
                
                const details = await detailPage.evaluate(() => {
                    const getText = (selector) => document.querySelector(selector)?.innerText || 'N/A';
                    
                    return {
                        business_name: getText('h1'),
                        phone: getText('button[data-item-id*="phone:tel:"]'),
                        website: document.querySelector('a[data-item-id="authority"]')?.href || 'N/A',
                        address: getText('button[data-item-id="address"]'),
                        category: getText('button[data-item-id="address"] + div'), // Simplified category extraction
                        maps_link: window.location.href
                    };
                });
                
                console.log(`Scraped: ${details.business_name}`);
                
                // If website exists, crawl for socials
                if (details.website !== 'N/A') {
                    const socials = await crawlWebsite(details.website);
                    Object.assign(details, socials);
                }
                
                // Send to API
                await sendLeadToApi(details, token);
                
                await detailPage.close();
            } catch (err) {
                console.error(`Error scraping detail: ${link}`, err.message);
            }
        }
        
    } catch (error) {
        console.error('Error during scraping:', error.message);
    } finally {
        await browser.close();
    }
}

// Example usage
const keyword = process.argv[2] || 'software companies';
const location = process.argv[3] || 'Lucknow';
const token = process.argv[4];
scrapeGoogleMaps(keyword, location, token);
