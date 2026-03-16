<?php

namespace App\Services;

class AIService
{
    public function generatePitch($lead)
    {
        $businessName = $lead->business_name;
        $category = $lead->category ?? 'business';
        $city = $lead->city ?? 'your local area';
        $hasWebsite = !empty($lead->website);
        $hasPhone = !empty($lead->phone);
        $email = $lead->email ?? '';
        $instagram = $lead->instagram ?? '';
        $facebook = $lead->facebook ?? '';
        $linkedin = $lead->linkedin ?? '';
        $twitter = $lead->twitter ?? '';

        $apiKey = env('OPENAI_API_KEY');

        if (!$apiKey) {
            return $this->generateStaticFallback($lead);
        }

        try {
            $prompt = "Analyze this business lead and generate a professional sales pitch.\n";
            $prompt .= "Business Name: $businessName\n";
            $prompt .= "Category: $category\n";
            $prompt .= "City: $city\n";
            $website = $lead->website;
            if ($website && (str_contains($website, 'instagram.com') || str_contains($website, 'facebook.com') || str_contains($website, 'linkedin.com') || str_contains($website, 'twitter.com') || str_contains($website, 'x.com') || str_contains($website, 'youtube.com'))) {
                $website = null;
            }
            $prompt .= "Website: " . ($website ?: 'None') . "\n";
            $prompt .= "Phone: " . ($hasPhone ? $lead->phone : 'None') . "\n";
            $prompt .= "Email: " . ($email ?: 'None') . "\n";
            $prompt .= "Instagram: " . ($instagram ?: 'None') . "\n";
            $prompt .= "Facebook: " . ($facebook ?: 'None') . "\n";
            $prompt .= "LinkedIn: " . ($linkedin ?: 'None') . "\n";
            $prompt .= "Twitter/X: " . ($twitter ?: 'None') . "\n";
            $prompt .= "YouTube: " . ($lead->youtube ?? 'None') . "\n\n";
            $prompt .= "Return the output in two sections:\n";
            $prompt .= "### 📊 Business Analysis\n(List 2-3 specific gaps or opportunities based on the data provided)\n\n";
            $prompt .= "### 💡 Suggested Pitch\n(A 2-3 sentence personalized sales pitch to help them grow their business)\n";
            $prompt .= "Keep it concise and professional.";

            $response = \Illuminate\Support\Facades\Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
                'Content-Type' => 'application/json',
            ])->post('https://api.openai.com/v1/chat/completions', [
                'model' => 'gpt-3.5-turbo',
                'messages' => [
                    ['role' => 'system', 'content' => 'You are a professional sales consultant.'],
                    ['role' => 'user', 'content' => $prompt],
                ],
                'temperature' => 0.7,
            ]);

            if ($response->successful()) {
                return $response->json()['choices'][0]['message']['content'];
            }
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("OpenAI Error: " . $e->getMessage());
        }

        return $this->generateStaticFallback($lead);
    }

    private function generateStaticFallback($lead)
    {
        $businessName = $lead->business_name;
        $category = $lead->category ?? 'business';
        $city = $lead->city ?? 'your local area';
        $hasWebsite = !empty($lead->website);

        $analysis = "### 📊 Business Analysis for $businessName\n\n";
        if (!$hasWebsite) {
            $analysis .= "❌ **Digital Gap**: No website found. High risk of losing customers to competitors.\n";
        } else {
            $analysis .= "✅ **Online Presence**: Website detected. Opportunity for optimization.\n";
        }
        $analysis .= "📍 **Market Position**: $category in $city.\n\n";

        $analysis .= "### 💡 Suggested Pitch\n";
        $analysis .= "Hi $businessName team, I noticed your profile in $city. ";
        if (!$hasWebsite) {
            $analysis .= "I specialize in building fast websites for $category businesses. Can we talk?";
        } else {
            $analysis .= "I saw your website and have ideas to increase your bookings. Can we talk?";
        }

        return $analysis;
    }
}
