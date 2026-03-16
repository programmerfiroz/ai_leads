// Background Script for AI Lead Scraper

chrome.runtime.onInstalled.addListener(() => {
    console.log("AI Lead Scraper Background Service Worker installed.");
    // Start sync manager on install
    startSyncManager();
});

// Sync Manager logic
let isSyncing = false;
async function startSyncManager() {
    console.log("[DEBUG] Sync Manager started.");
    chrome.alarms.create("syncData", { periodInMinutes: 0.2 }); // Run every 12 seconds as backup
}

// Trigger sync immediately when storage changes
chrome.storage.onChanged.addListener((changes, area) => {
    if (area === 'local' && changes.sync_queue) {
        console.log("[DEBUG] Storage changed, triggering immediate sync.");
        processSyncQueue();
    }
});

async function processSyncQueue() {
    if (isSyncing) return;
    isSyncing = true;
    
    try {
        let { sync_queue = [] } = await chrome.storage.local.get('sync_queue');
        if (sync_queue.length === 0) {
            isSyncing = false;
            return;
        }

        console.log(`[DEBUG] Sync Manager: Starting sync for ${sync_queue.length} leads.`);
        
        while (sync_queue.length > 0) {
            const lead = sync_queue[0];
            const res = await saveLeadToBackend(lead);
            
            if (res.success || res.status === 200 || res.status === 201) {
                // Success - remove from queue
                sync_queue.shift();
                await chrome.storage.local.set({ 'sync_queue': sync_queue });
                console.log(`[DEBUG] Sync Manager: Synced ${lead.business_name}. Remaining: ${sync_queue.length}`);
            } else if (res.status === 401) {
                console.warn("[DEBUG] Sync Manager: Auth failed (401), stopping sync.");
                break; // Stop and wait for user to re-auth
            } else {
                console.error(`[DEBUG] Sync Manager: Failed to sync ${lead.business_name} (Status: ${res.status}). Will retry later.`);
                // If it's a non-auth error (e.g. server down), we might want to stop for a bit
                break; 
            }
            
            // Re-read queue in case content script added more during sync
            const latestData = await chrome.storage.local.get('sync_queue');
            sync_queue = latestData.sync_queue || [];
        }
    } catch (e) {
        console.error("[DEBUG] Sync Manager Critical Error:", e);
    } finally {
        isSyncing = false;
    }
}

// Keep service worker alive while scraping is active
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log(`[DEBUG] Background message received: ${message.action}`, sender.tab?.id);
    
    if (message.action === "startScraping") {
        console.log("Scraping started in tab:", sender.tab?.id);
        chrome.alarms.create("keepAlive", { periodInMinutes: 0.1 });
    } else if (message.action === "stopScraping") {
        console.log("Scraping stopped in tab:", sender.tab?.id);
        chrome.alarms.clear("keepAlive");
    } else if (message.action === "crawlWebsite") {
        console.log(`[DEBUG] Crawling: ${message.url}`);
        crawlWebsite(message.url).then(data => {
            console.log(`[DEBUG] Crawl complete for: ${message.url}`);
            sendResponse(data);
        });
        return true; 
    } else if (message.action === "saveLead") {
        console.log(`[DEBUG] Saving lead: ${message.data?.business_name}`);
        saveLeadToBackend(message.data).then(res => {
            console.log(`[DEBUG] Save lead response for ${message.data?.business_name}:`, res.success ? "Success" : "Failed");
            sendResponse(res);
        });
        return true;
    } else if (message.action === "login") {
        handleAuthAction('login', message.data).then(sendResponse);
        return true;
    } else if (message.action === "register") {
        handleAuthAction('register', message.data).then(sendResponse);
        return true;
    } else if (message.action === "verifyAuth") {
        verifyAuth().then(sendResponse);
        return true;
    }
});

async function handleAuthAction(action, data) {
    try {
        const response = await fetch(`https://ai-leads.brainket.online/api/${action}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(data)
        });
        
        const result = await response.json();
        
        if (response.ok && result.access_token) {
            await chrome.storage.local.set({ 
                'access_token': result.access_token,
                'user': result.user 
            });
            return { success: true, user: result.user };
        } else {
            return { success: false, message: result.message || 'Auth failed', status: response.status };
        }
    } catch (e) {
        return { success: false, error: e.message };
    }
}

async function verifyAuth() {
    try {
        const { access_token } = await chrome.storage.local.get('access_token');
        if (!access_token) return { success: false };

        const response = await fetch('https://ai-leads.brainket.online/api/user', {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Authorization': `Bearer ${access_token}`
            }
        });

        if (response.ok) {
            const user = await response.json();
            await chrome.storage.local.set({ 'user': user });
            return { success: true, user };
        } else {
            if (response.status === 401) {
                await chrome.storage.local.clear();
            }
            return { success: false, status: response.status };
        }
    } catch (e) {
        return { success: false, error: e.message };
    }
}

async function crawlWebsite(url) {
    if (!url || url === 'N/A' || !url.startsWith('http')) return {};
    
    try {
        const response = await fetch(url, {
            method: 'GET',
            headers: { 'Accept': 'text/html' }
        });
        const html = await response.text();
        
        return {
            email: extractEmail(html),
            instagram: extractSocial(html, 'instagram.com'),
            facebook: extractSocial(html, 'facebook.com'),
            linkedin: extractSocial(html, 'linkedin.com'),
            twitter: extractSocial(html, 'twitter.com') || extractSocial(html, 'x.com'),
            youtube: extractSocial(html, 'youtube.com'),
        };
    } catch (error) {
        console.error(`Error crawling ${url}:`, error);
        return {};
    }
}

function extractEmail(text) {
    const emailRegex = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
    const matches = text.match(emailRegex);
    return matches ? matches[0] : null;
}

function extractSocial(text, platform) {
    // Improved regex to handle various URL formats and subdomains
    const regex = new RegExp(`https?:\/\/(?:[a-z0-9]+\\.)*${platform.replace('.', '\\.')}\/[a-zA-Z0-9._/\\-]+`, 'gi');
    const matches = text.match(regex);
    if (!matches) return null;
    
    // Clean up URLs to avoid trailing slashes or junk
    const url = matches[0].split(/[?#]/)[0]; // Remove query params
    return url.endsWith('/') ? url.slice(0, -1) : url;
}

async function saveLeadToBackend(data) {
    try {
        console.log(`[DEBUG] Attempting to save lead to backend: ${data?.business_name}`);
        const { access_token } = await chrome.storage.local.get('access_token');
        
        if (!access_token) {
            console.error("[DEBUG] No access token found in background storage!");
            return { success: false, error: "No access token" };
        }

        const headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': `Bearer ${access_token}`
        };
        
        const response = await fetch('https://ai-leads.brainket.online/api/leads', {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(data)
        });
        
        console.log(`[DEBUG] Backend Response Status: ${response.status}`);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error(`[DEBUG] Backend API Error (${response.status}):`, errorText);
            if (response.status === 401) {
                console.warn("[DEBUG] 401 Unauthorized - Clearing token.");
                await chrome.storage.local.clear();
            }
            return { success: false, status: response.status, error: errorText };
        }
        
        const result = await response.json();
        console.log("[DEBUG] Lead saved successfully:", result.business_name || result.id);
        return { success: true, data: result };
    } catch (e) {
        console.error("[DEBUG] Critical error in saveLeadToBackend:", e);
        return { success: false, error: e.message };
    }
}

chrome.alarms.onAlarm.addListener((alarm) => {
    if (alarm.name === "keepAlive") {
        console.log("Keep alive alarm triggered...");
    } else if (alarm.name === "syncData") {
        processSyncQueue();
    }
});

// Initialize on startup if not already
startSyncManager();
processSyncQueue();
