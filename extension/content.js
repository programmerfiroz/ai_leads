// Google Maps Scraper Content Script

console.log("AI Leads loaded.");

let isScraping = false;
let currentLeads = [];
let currentUser = null;

async function checkAuth() {
    const data = await chrome.storage.local.get(['access_token', 'user']);
    if (!data.access_token) return false;

    // Proactively verify token with backend via background script
    return new Promise((resolve) => {
        chrome.runtime.sendMessage({ action: "verifyAuth" }, (res) => {
            if (res && res.success) {
                currentUser = res.user;
                resolve(true);
            } else {
                currentUser = null;
                resolve(false);
            }
        });
    });
}

// Side panel functions replacing old overlay logic
function createSidebar() {
    if (document.getElementById('ai-sidebar')) return;

    const sidebar = document.createElement('div');
    sidebar.id = 'ai-sidebar';
    sidebar.style.cssText = `
        position: fixed;
        top: 0;
        right: 0;
        width: 400px;
        height: 100vh;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(25px) saturate(200%);
        box-shadow: -10px 0 50px rgba(0,0,0,0.1);
        z-index: 2147483647;
        display: flex;
        flex-direction: column;
        font-family: 'Inter', -apple-system, sans-serif;
        border-left: 1px solid rgba(255, 255, 255, 0.3);
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        overflow: hidden;
    `;

    const header = document.createElement('div');
    header.style.cssText = `
        padding: 24px;
        background: white;
        border-bottom: 1px solid #f0f0f0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    `;

    const logoArea = document.createElement('div');
    logoArea.innerHTML = `
        <div style="font-size: 20px; font-weight: 850; color: #056E73; letter-spacing: -0.5px;">AI Leads</div>
        <div id="sidebar-user-info" style="font-size: 12px; color: #5f6368; margin-top: 4px;"></div>
    `;

    const closeBtn = document.createElement('button');
    closeBtn.innerHTML = '&#10005;';
    closeBtn.style.cssText = 'background: none; border: none; font-size: 20px; color: #999; cursor: pointer; padding: 5px;';
    closeBtn.onclick = () => {
        sidebar.style.transform = 'translateX(100%)';
        setTimeout(() => sidebar.remove(), 300);
    };

    const actionsArea = document.createElement('div');
    actionsArea.id = 'header-actions';
    actionsArea.style.cssText = 'display: flex; gap: 12px; align-items: center; margin-right: 15px;';
    
    header.appendChild(logoArea);
    header.appendChild(actionsArea);
    header.appendChild(closeBtn);
    sidebar.appendChild(header);

    const contentArea = document.createElement('div');
    contentArea.id = 'sidebar-content';
    contentArea.style.cssText = 'flex: 1; overflow-y: auto; padding: 24px; display: flex; flex-direction: column; gap: 20px;';
    sidebar.appendChild(contentArea);

    document.body.appendChild(sidebar);
    renderSidebar(true); // Initial with Splash
}

async function renderSidebar(isInitial = false) {
    const content = document.getElementById('sidebar-content');
    const userInfo = document.getElementById('sidebar-user-info');
    if (!content) return;
    
    // Only show Splash if initial open or specifically requested
    if (isInitial) {
        content.innerHTML = `
            <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; gap: 20px; animation: fadeIn 0.5s ease-in;">
                <div style="width: 50px; height: 50px; border: 3px solid #f3f3f3; border-top: 3px solid #056E73; border-radius: 50%; animation: spin 1s linear infinite;"></div>
                <div style="font-size: 14px; color: #666; font-weight: 500;">Securing Connection...</div>
            </div>
        `;
        await new Promise(r => setTimeout(r, 800));
    }

    const actions = document.getElementById('header-actions');
    if (actions) actions.innerHTML = '';

    const authenticated = await checkAuth();
    
    content.innerHTML = '';
    if (!authenticated) {
        userInfo.innerText = 'Guest Mode';
        renderAuthView(content);
    } else {
        const user = currentUser || {};
        userInfo.innerText = `${user.name || 'User'} • ${user.organization_name || 'Org'}`;
        
        // Prepare Header Actions
        if (actions) {
            actions.innerHTML = `
                <button id="header-stop" style="display: none; padding: 6px 12px; background: #ea4335; color: white; border: none; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">STOP</button>
                <button id="header-logout" style="padding: 6px; background: none; border: 1px solid #eee; color: #666; border-radius: 6px; font-size: 11px; font-weight: 500; cursor: pointer;">Logout</button>
            `;
            
            document.getElementById('header-logout').onclick = async () => {
                const confirmed = confirm("Logout from AI Leads?");
                if (!confirmed) return;
                await chrome.storage.local.clear();
                currentUser = null;
                renderSidebar();
            };

            document.getElementById('header-stop').onclick = () => {
                isScraping = false;
                const startBtn = document.getElementById('side-start');
                const stopBtnHeader = document.getElementById('header-stop');
                const status = document.getElementById('side-status');
                
                if (startBtn) startBtn.style.display = 'block';
                if (stopBtnHeader) stopBtnHeader.style.display = 'none';
                if (status) {
                    status.innerText = 'Stopped';
                    status.style.color = '#ea4335';
                }
            };
        }

        renderDashboardView(content);
    }
}

function renderAuthView(container) {
    container.innerHTML = `
        <div id="auth-view" style="display: flex; flex-direction: column; gap: 20px; height: 100%;">
            <div style="text-align: center; margin-bottom: 10px;">
                <h3 style="margin: 0; font-size: 18px; font-weight: 700;">Login</h3>
                <p style="font-size: 13px; color: #666; margin-top: 8px;">Connect to sync leads across all devices</p>
            </div>
            
            <div id="auth-form-container" style="display: flex; flex-direction: column; gap: 15px;">
                <input type="text" id="side-phone" placeholder="Phone Number" style="padding: 14px; border-radius: 12px; border: 1px solid #ddd; outline: none; transition: border-color 0.2s;">
                <input type="text" id="side-otp" placeholder="Enter 4-Digit OTP" style="padding: 14px; border-radius: 12px; border: 1px solid #ddd; outline: none; display: none;">
                <button id="side-auth-btn" style="padding: 16px; background: #056E73; color: white; border: none; border-radius: 12px; font-weight: 700; cursor: pointer; box-shadow: 0 4px 12px rgba(5,110,115,0.25);">Send OTP</button>
                <button id="side-back-btn" style="padding: 8px; background: none; border: none; color: #666; font-size: 12px; cursor: pointer; display: none;">Change Phone Number</button>
            </div>

            <div style="margin-top: auto; text-align: center; font-size: 13px; color: #666;">
                Use 1234 for OTP verification
            </div>
        </div>
    `;

    let step = 'phone';
    const authBtn = document.getElementById('side-auth-btn');
    const phoneInput = document.getElementById('side-phone');
    const otpInput = document.getElementById('side-otp');
    const backBtn = document.getElementById('side-back-btn');

    if (authBtn) {
        authBtn.onclick = async () => {
            if (step === 'phone') {
                if (phoneInput.value.length < 10) return alert('Valid phone needed');
                phoneInput.style.display = 'none';
                otpInput.style.display = 'block';
                if (backBtn) backBtn.style.display = 'block';
                authBtn.innerText = 'Login (Use 1234)';
                step = 'otp';
            } else {
                if (otpInput.value !== '1234') return alert('Invalid OTP');
                authBtn.innerText = 'Authenticating...';
                chrome.runtime.sendMessage({ action: "login", data: { phone: phoneInput.value, otp: otpInput.value } }, (res) => {
                    if (res.success) {
                        currentUser = res.user;
                        renderSidebar();
                    } else {
                        if (res.status === 404) {
                            alert("Profile not found. Redirecting to setup...");
                            renderRegisterView(container, phoneInput.value);
                        } else {
                            alert(res.message || "Login failed");
                        }
                    }
                });
            }
        };

        if (backBtn) {
            backBtn.onclick = () => {
                step = 'phone';
                phoneInput.style.display = 'block';
                otpInput.style.display = 'none';
                backBtn.style.display = 'none';
                authBtn.innerText = 'Send OTP';
            };
        }
    }

}

function renderRegisterView(container, prefilledPhone = '') {
    container.innerHTML = `
        <div style="display: flex; flex-direction: column; gap: 15px; animation: fadeIn 0.3s ease-in;">
            <div style="text-align: center; margin-bottom: 5px;">
                <h3 style="margin: 0; font-size: 20px; font-weight: 800; color: #056E73;">Profile Setup</h3>
                <p style="font-size: 12px; color: #666; margin-top: 5px;">Complete your business profile</p>
            </div>
            
            <div style="display: flex; flex-direction: column; gap: 12px;">
                <input id="r-name" placeholder="Full Name" style="padding: 14px; border-radius: 12px; border: 1px solid #ddd; font-size: 14px;">
                <input id="r-email" placeholder="Business Email" style="padding: 14px; border-radius: 12px; border: 1px solid #ddd; font-size: 14px;">
                <input id="r-org" placeholder="Company Name" style="padding: 14px; border-radius: 12px; border: 1px solid #ddd; font-size: 14px;">
                <input id="r-cat" placeholder="Category (e.g. IT, Gym, Bakery)" style="padding: 14px; border-radius: 12px; border: 1px solid #ddd; font-size: 14px;">
                
                <button id="r-btn" style="padding: 16px; background: #056E73; color: white; border: none; border-radius: 12px; font-weight: 700; cursor: pointer; margin-top: 10px; box-shadow: 0 4px 12px rgba(5,110,115,0.25);">Confirm Profile</button>
                
                <input type="hidden" id="r-phone" value="${prefilledPhone}">
                <button id="r-back" style="background:none; border:none; color:#666; font-size:12px; cursor:pointer; padding: 10px;">Back to Login</button>
            </div>
        </div>
    `;

    document.getElementById('r-btn').onclick = async () => {
        const btn = document.getElementById('r-btn');
        const originalText = btn.innerText;
        btn.innerText = 'Creating Profile...';
        btn.disabled = true;

        const data = {
            name: document.getElementById('r-name').value,
            email: document.getElementById('r-email').value,
            phone: document.getElementById('r-phone').value,
            organization_name: document.getElementById('r-org').value,
            business_category: document.getElementById('r-cat').value
        };

        if (!data.name || !data.email || !data.organization_name) {
            alert("Please fill all fields");
            btn.innerText = originalText;
            btn.disabled = false;
            return;
        }

        chrome.runtime.sendMessage({ action: "register", data }, (res) => {
            if (res.success) { 
                currentUser = res.user; 
                renderSidebar(); 
            } else { 
                alert(res.message); 
                btn.innerText = originalText;
                btn.disabled = false;
            }
        });
    };
    document.getElementById('r-back').onclick = () => renderAuthView(container);
}

function renderDashboardView(container) {
    const category = currentUser?.business_category || 'Agency';
    
    container.innerHTML = `
        <div style="display: flex; flex-direction: column; gap: 20px;">
            <!-- Scraper Controls -->
            <div style="background: #f8f9fa; padding: 20px; border-radius: 16px; border: 1px solid #eee;">
                <div style="font-weight: 700; margin-bottom: 15px; display: flex; justify-content: space-between;">
                    Scraper Controls
                    <span id="side-status" style="font-size: 11px; color: #666; font-weight: 400;">Ready</span>
                </div>
                <div style="display: flex; gap: 10px;">
                    <button id="side-start" style="flex: 1; padding: 12px; background: #34a853; color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer;">Start Scrape</button>
                </div>
            </div>

            <!-- Leads List -->
            <div style="flex: 1; display: flex; flex-direction: column; gap: 12px;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div style="font-weight: 700;">Recent Leads</div>
                    <span id="side-count" style="font-size: 12px; color: #056E73; background: #e6f1f1; padding: 2px 8px; border-radius: 20px;">0 leads</span>
                </div>
                <div id="side-leads-list" style="display: flex; flex-direction: column; gap: 8px;">
                    <div style="text-align: center; color: #999; font-size: 13px; padding: 40px 0;">No leads scraped yet</div>
                </div>
            </div>

            </div>
        </div>
    `;

    document.getElementById('side-start').onclick = () => {
        isScraping = true;
        const startBtn = document.getElementById('side-start');
        const stopBtnHeader = document.getElementById('header-stop');
        const status = document.getElementById('side-status');

        if (startBtn) startBtn.style.display = 'none';
        if (stopBtnHeader) stopBtnHeader.style.display = 'block';
        if (status) {
            status.innerText = 'Scraping...';
            status.style.color = '#34a853';
        }
        startScraping();
    };

    // Update list if there are leads
    if (currentLeads.length > 0) updateSidebarLeads();
}

async function updateSidebarLeads() {
    const list = document.getElementById('side-leads-list');
    const count = document.getElementById('side-count');
    if (!list) return;

    const { sync_queue = [] } = await chrome.storage.local.get('sync_queue');
    const pendingNames = new Set(sync_queue.map(l => l.business_name));

    count.innerText = `${currentLeads.length} leads`;
    list.innerHTML = currentLeads.slice(0, 10).map(lead => {
        const isPending = pendingNames.has(lead.business_name);
        return `
        <div style="padding: 12px; background: white; border-radius: 12px; border: 1px solid #eee; display: flex; justify-content: space-between; align-items: flex-start;">
            <div style="flex: 1; min-width: 0;">
                <div style="font-weight: 600; font-size: 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${lead.business_name}</div>
                <div style="font-size: 11px; color: #666; margin-top: 2px;">${lead.phone || 'No phone'}</div>
            </div>
            <div style="font-size: 10px; color: ${isPending ? '#f29900' : '#34a853'}; font-weight: 600; background: ${isPending ? '#fff7e6' : '#e6f4ea'}; padding: 2px 6px; border-radius: 4px; margin-left: 10px;">
                ${isPending ? 'Pending' : 'Synced'}
            </div>
        </div>
    `;}).join('') + (currentLeads.length > 10 ? '<div style="text-align: center; font-size: 11px; color: #666; margin-top: 5px;">View more in Mobile App</div>' : '');
}

// Refresh UI when background sync completes
chrome.storage.onChanged.addListener((changes, area) => {
    if (area === 'local' && changes.sync_queue) {
        updateSidebarLeads();
    }
});

const style = document.createElement('style');
style.innerHTML = `
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
`;
document.head.appendChild(style);

async function injectScrapeButton() {
    if (document.getElementById('ai-trigger')) return;
    
    // Create a small, elegant floating trigger button to open the sidebar
    const trigger = document.createElement('div');
    trigger.id = 'ai-trigger';
    trigger.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        width: 60px;
        height: 60px;
        background: #056E73;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        z-index: 2147483646;
        transition: transform 0.2s;
    `;
    trigger.innerHTML = `
        <svg width="24" height="24" viewBox="0 0 24 24" fill="white">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
        </svg>
    `;
    
    trigger.onclick = () => {
        const existing = document.getElementById('ai-sidebar');
        if (existing) {
            existing.style.transform = existing.style.transform === 'translateX(0px)' ? 'translateX(100%)' : 'translateX(0px)';
        } else {
            createSidebar();
        }
    };
    
    document.body.appendChild(trigger);
}

// Update the Lead syncing logic to refresh sidebar
function updateUIState() {
    renderSidebar(); // Refresh the sidebar views when state changes
}

// Side panel functions replacing old overlay logic
async function sendToApi(lead) {
    const rowId = updateSidebarLeads(); // Refresh list visual
    try {
        const response = await chrome.runtime.sendMessage({ 
            action: "saveLead", 
            data: lead 
        });
        updateSidebarLeads(); // Final update
        return response && response.success;
    } catch (e) {
        return false;
    }
}

// Helper to find text by icon/attribute in the current document context
function getByText(query, fallbackSelector = 'button, a, span, div') {
    const elements = Array.from(document.querySelectorAll(fallbackSelector)).filter(el => {
        const text = el.innerText || "";
        return text.length < 300 && text.includes(query);
    });
    
    elements.sort((a, b) => (a.innerText?.length || 0) - (b.innerText?.length || 0));
    
    const el = elements[0];
    return el?.innerText || el?.getAttribute('aria-label') || "";
}

async function scrapeDetailPanel() {
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    const name = document.querySelector('h1.DUwDvf')?.innerText || 
                 document.querySelector('h1.DUwDfb')?.innerText || 
                 document.querySelector('h1')?.innerText || 
                 document.querySelector('.fontHeadlineLarge')?.innerText || "";
    
    const category = document.querySelector('button.DkEaL')?.innerText || 
                     document.querySelector('.fontBodyMedium')?.innerText || 
                     getByText("category", "div") || "";
    
    let addressEl = document.querySelector('button[data-item-id="address"]') || 
                    document.querySelector('button[aria-label*="Address"]') ||
                    document.querySelector('div[aria-label*="Address"]');
                    
    let phoneEl = document.querySelector('button[data-item-id^="phone:tel:"]') || 
                  document.querySelector('button[aria-label*="Phone"]');
                  
    let websiteEl = document.querySelector('a[data-item-id="authority"]') || 
                    document.querySelector('a[aria-label*="Website"]');
    
    // Extraction for new rich details
    // Rating: try specific classes and aria-hidden span
    const ratingEl = document.querySelector('span.ceDRU') || 
                     document.querySelector('span.ceNzR') || 
                     document.querySelector('div.F7nice span[aria-hidden="true"]');
    
    // Reviews: try aria-label containing "reviews" or specific button classes
    const reviewsEl = document.querySelector('span[aria-label*="reviews"]') || 
                      document.querySelector('button[aria-label*="reviews"]') || 
                      document.querySelector('button.HHrUfc') || 
                      document.querySelector('span.F7kY9c');
    
    // Hours: try aria-label containing "Hours" or specific container classes
    const hoursEl = document.querySelector('div[role="button"][aria-label*="Hours"]') || 
                    document.querySelector('div[aria-label*="Hours"]') || 
                    document.querySelector('.tPP99.fontBodyMedium') ||
                    document.querySelector('div.OMl5r');

    let rating = ratingEl?.innerText || "";
    let reviews_count = reviewsEl?.innerText || reviewsEl?.getAttribute('aria-label') || "";
    let opening_hours = hoursEl?.getAttribute('aria-label') || hoursEl?.innerText || "";

    console.log(`[DEBUG] Scraped Raw - Rating: ${rating}, Reviews: ${reviews_count}, Hours: ${opening_hours}`);

    // Clean review count (often looks like "(120)" or "120 reviews")
    if (reviews_count) {
        reviews_count = reviews_count.replace(/[()]/g, '').replace(/reviews/gi, '').trim();
    }

    // Clean opening hours (Google often appends '·' or extra info)
    if (opening_hours.includes('⋅')) {
        opening_hours = opening_hours.split('⋅')[0].trim();
    } else if (opening_hours.includes('·')) {
        opening_hours = opening_hours.split('·')[0].trim();
    }
    
    let address = addressEl?.innerText || addressEl?.getAttribute('aria-label') || "";
    let phone = phoneEl?.innerText || phoneEl?.getAttribute('aria-label') || "";
    let website = websiteEl?.getAttribute('href') || websiteEl?.href || "";
    
    if (!phone) {
        const phoneText = getByText("Phone");
        if (phoneText) phone = phoneText.replace("Phone", "").replace(":", "").trim();
    }
    
    if (!address) {
        const addrText = getByText("Address");
        if (addrText) address = addrText.replace("Address", "").replace(":", "").trim();
    }

    // No risky fallback here to prevent false positives as per user feedback.
    // Rely exclusively on formal Website selectors.
    if (website && website.includes('google.com/maps')) {
        website = ""; 
    }

    // Categorize social links if they appear in the website field
    let instagram = "";
    let facebook = "";
    let linkedin = "";
    let twitter = "";
    let youtube = "";

    if (website) {
        const ws = website.toLowerCase();
        if (ws.includes('instagram.com')) {
            instagram = website;
            website = "";
        } else if (ws.includes('facebook.com') || ws.includes('fb.watch')) {
            facebook = website;
            website = "";
        } else if (ws.includes('linkedin.com')) {
            linkedin = website;
            website = "";
        } else if (ws.includes('twitter.com') || ws.includes('x.com')) {
            twitter = website;
            website = "";
        } else if (ws.includes('youtube.com') || ws.includes('youtu.be')) {
            youtube = website;
            website = "";
        }
    }
    
    const phoneMatch = phone.match(/(\+?\d[\d\s-]{8,}\d)/);
    phone = phoneMatch ? phoneMatch[0].replace(/[^0-9+]/g, '') : "";
    
    if (phone.length > 15 && !phone.startsWith('+')) {
        phone = phone.substring(0, 10);
    }

    const mapsLink = window.location.href;

    if (name && name.trim().length > 1) {
        return {
            business_name: name.trim(),
            category: category.trim(),
            address: address.trim(),
            phone: phone,
            website: website,
            instagram: instagram,
            facebook: facebook,
            linkedin: linkedin,
            twitter: twitter,
            youtube: youtube,
            maps_link: mapsLink,
            status: 'New',
            city: getCityFromSearch(),
            rating: rating,
            reviews_count: reviews_count,
            opening_hours: opening_hours
        };
    }
    return null;
}

function startScraping() {
    scrapeCurrentView();
}

async function scrapeCurrentView() {
    console.log("Auto-scrape started...");
    chrome.runtime.sendMessage({ action: "startScraping" });
    
    const leads = [];
    const seenNames = new Set();
    
    try {
        const feed = document.querySelector('div[role="feed"]') || document.querySelector('.m67q60-ixlo7c-AS7zUe');
        
        if (!feed) {
            if (window.location.href.includes('/maps/place/')) {
                const lead = await scrapeDetailPanel();
                if (lead) {
                    await sendToApi(lead);
                    updateSidebarLeads();
                    return [lead];
                }
            }
            alert("Google Maps results list not found. Make sure results are visible on the left.");
            return [];
        }

        let lastLeadsCount = -1;
        let scrollAttempts = 0;

        while (isScraping && (leads.length > lastLeadsCount || scrollAttempts < 4)) {
            lastLeadsCount = leads.length;
            
            const items = Array.from(document.querySelectorAll('a[href*="/maps/place/"]'))
                               .filter(a => a.offsetHeight > 0);
            
            for (const item of items) {
                if (!isScraping) break;

                const listName = item.getAttribute('aria-label') || item.innerText || "";
                if (!listName || seenNames.has(listName)) continue;
                
                seenNames.add(listName);

                item.scrollIntoView({ behavior: 'auto', block: 'center' });
                await new Promise(resolve => setTimeout(resolve, 500));
                
                item.click();
                
                await new Promise(resolve => setTimeout(resolve, 3500));

                const lead = await scrapeDetailPanel();
                if (lead) {
                    console.log(`[DEBUG] Final Lead Object:`, lead);
                    if (lead.website && lead.website !== 'N/A') {
                        console.log(`[DEBUG] Requesting website crawl for: ${lead.website}`);
                        try {
                            const extraData = await chrome.runtime.sendMessage({ 
                                action: "crawlWebsite", 
                                url: lead.website 
                            });
                            if (extraData) {
                                console.log(`[DEBUG] Received crawl data:`, extraData);
                                Object.assign(lead, extraData);
                            }
                        } catch (crawlErr) {
                            console.error(`[DEBUG] Crawl messaging failed for ${lead.website}:`, crawlErr);
                        }
                    }
                    
                    currentLeads.push(lead);
                    updateSidebarLeads();
                    
                    // Push to Sync Queue in storage for background processing
                    try {
                        console.log(`[DEBUG] Adding to Sync Queue: ${lead.business_name}`);
                        const { sync_queue = [] } = await chrome.storage.local.get('sync_queue');
                        sync_queue.push(lead);
                        await chrome.storage.local.set({ 'sync_queue': sync_queue });
                        console.log(`[DEBUG] Sync Queue size: ${sync_queue.length}`);
                    } catch (e) {
                        console.error(`[DEBUG] Failed to add to Sync Queue:`, e);
                    }
                }
            } // for loop end
            
            if (!isScraping) break;

            feed.scrollTop += 1000;
            await new Promise(resolve => setTimeout(resolve, 1000));
            feed.scrollTop = feed.scrollHeight;
            await new Promise(resolve => setTimeout(resolve, 2500));
            
            if (currentLeads.length === lastLeadsCount) {
                scrollAttempts++;
            } else {
                scrollAttempts = 0;
            }

            if (currentLeads.length > 500) break;
        } // while loop end
    } catch (e) {
        console.error("Scraping error:", e);
    } finally {
        isScraping = false;
        updateUIState();
        chrome.runtime.sendMessage({ action: "stopScraping" });
    }

    return leads;
}

function getCityFromSearch() {
    const searchInput = document.getElementById('searchboxinput');
    if (searchInput) {
        const value = searchInput.value.toLowerCase().trim();
        if (value.includes('in ')) {
            return value.split('in ').pop().trim();
        }
        // Fallback: If no "in", take the last word if it's potentially a city
        const words = value.split(' ');
        if (words.length > 1) {
            return words[words.length - 1];
        }
    }
    return "";
}

// sendToApi removed - now handled by background.js for better tab-switching reliability


setInterval(injectScrapeButton, 2000);
