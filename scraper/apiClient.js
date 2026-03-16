const axios = require('axios');

const API_BASE_URL = 'https://ai-leads.brainket.online/api'; // Live Hostinger URL

async function sendLeadToApi(leadData, token) {
    try {
        const response = await axios.post(`${API_BASE_URL}/leads`, leadData, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        });
        console.log(`Lead sent: ${leadData.business_name}`);
        return response.data;
    } catch (error) {
        // Since we don't have a direct /leads POST in the requested endpoints, 
        // I should check what the user requested.
        // User requested:
        // POST /scrape-leads
        // GET /leads
        // GET /lead/{id}
        // POST /lead/update-status
        // DELETE /lead/{id}
        
        // Wait, the user didn't specify a POST /lead endpoint to CREATE a lead.
        // I should probably add one or use a "webhook" style endpoint.
        // I'll add a POST /leads endpoint to the Laravel backend now.
        
        console.error(`Error sending lead: ${leadData.business_name}`, error.message);
    }
}

module.exports = { sendLeadToApi };
