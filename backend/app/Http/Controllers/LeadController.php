<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\Lead;
use App\Models\LeadStatusHistory;
use App\Exports\LeadsExport;
use Maatwebsite\Excel\Facades\Excel;
use Illuminate\Support\Facades\Http;

class LeadController extends Controller
{
    public function index(Request $request)
    {
        $query = Lead::where('user_id', auth()->id());

        if ($request->has('city')) {
            $query->where('city', 'like', '%' . $request->city . '%');
        }

        if ($request->has('category')) {
            $query->where('category', 'like', '%' . $request->category . '%');
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('search')) {
            $query->where('business_name', 'like', '%' . $request->search . '%');
        }

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'business_name' => 'required|string',
            'owner_name' => 'nullable|string',
            'phone' => 'nullable|string',
            'whatsapp' => 'nullable|string',
            'email' => 'nullable|string',
            'website' => 'nullable|string',
            'instagram' => 'nullable|string',
            'facebook' => 'nullable|string',
            'maps_link' => 'nullable|string',
            'address' => 'nullable|string',
            'city' => 'nullable|string',
            'category' => 'nullable|string',
            'status' => 'nullable|string',
            'linkedin' => 'nullable|string',
            'twitter' => 'nullable|string',
            'rating' => 'nullable|string',
            'reviews_count' => 'nullable|string',
            'opening_hours' => 'nullable|string',
        ]);

        // Check for duplicates by Maps Link (Scoped to User)
        if ($request->has('maps_link') && $request->maps_link) {
            $existingByMaps = Lead::where('user_id', auth()->id())
                                ->where('maps_link', $request->maps_link)
                                ->first();
            if ($existingByMaps) {
                return response()->json($existingByMaps, 200);
            }
        }

        // Check for duplicates by Phone Number (Scoped to User)
        if ($request->has('phone') && $request->phone) {
            $existingByPhone = Lead::where('user_id', auth()->id())
                                 ->where('phone', $request->phone)
                                 ->first();
            if ($existingByPhone) {
                return response()->json($existingByPhone, 200);
            }
        }

        $lead = new Lead($validatedData);
        $lead->user_id = auth()->id();
        $lead->save(); // Save immediately so it shows in the app
        
        // Generate AI Pitch in the background (or just after initial save)
        try {
            $aiService = new \App\Services\AIService();
            $lead->ai_pitch = $aiService->generatePitch($lead);
            $lead->save();
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("Pitch generation failed: " . $e->getMessage());
        }

        return response()->json($lead, 201);
    }

    public function show($id)
    {
        $lead = Lead::with('history')->findOrFail($id);
        return response()->json($lead);
    }

    public function updateStatus(Request $request)
    {
        $request->validate([
            'id' => 'required|exists:leads,id',
            'status' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $lead = Lead::findOrFail($request->id);
        $oldStatus = $lead->status;
        $lead->status = $request->status;
        $lead->save();

        LeadStatusHistory::create([
            'lead_id' => $lead->id,
            'status' => $request->status,
            'notes' => $request->notes ?? "Status changed from $oldStatus to {$request->status}",
        ]);

        return response()->json(['message' => 'Status updated successfully', 'lead' => $lead]);
    }

    public function destroy($id)
    {
        $lead = Lead::findOrFail($id);
        $lead->delete();

        return response()->json(['message' => 'Lead deleted successfully']);
    }

    public function scrapeLeads(Request $request)
    {
        $request->validate([
            'keyword' => 'required|string',
            'location' => 'required|string',
        ]);

        // Trigger the Node.js scraper in the background
        $keyword = escapeshellarg($request->keyword);
        $location = escapeshellarg($request->location);
        $token = escapeshellarg($request->bearerToken());
        $scraperPath = base_path('../scraper/index.js');
        
        // Use nohup and redirect output to run in background
        $command = "node $scraperPath $keyword $location $token > /dev/null 2>&1 &";
        exec($command);
        
        return response()->json([
            'message' => 'Scraping process initiated for ' . $request->keyword . ' in ' . $request->location,
            'status' => 'pending'
        ]);
    }

    public function export(Request $request)
    {
        $format = $request->get('format', 'xlsx');
        $filename = 'leads_' . now()->format('Y-m-d_H-i-s') . '.' . $format;
        
        return Excel::download(new LeadsExport, $filename);
    }

    public function dashboardStats()
    {
        $userId = auth()->id();
        return response()->json([
            'total' => Lead::where('user_id', $userId)->count(),
            'new' => Lead::where('user_id', $userId)->where('status', Lead::STATUS_NEW)->count(),
            'contacted' => Lead::where('user_id', $userId)->where('status', Lead::STATUS_CONTACTED)->count(),
            'converted' => Lead::where('user_id', $userId)->where('status', Lead::STATUS_CONVERTED)->count(),
        ]);
    }
    public function update(Request $request, $id)
    {
        $lead = Lead::findOrFail($id);
        
        $validatedData = $request->validate([
            'business_name' => 'required|string',
            'owner_name' => 'nullable|string',
            'phone' => 'nullable|string',
            'whatsapp' => 'nullable|string',
            'email' => 'nullable|string',
            'website' => 'nullable|string',
            'instagram' => 'nullable|string',
            'facebook' => 'nullable|string',
            'maps_link' => 'nullable|string',
            'address' => 'nullable|string',
            'city' => 'nullable|string',
            'category' => 'nullable|string',
            'status' => 'nullable|string',
            'linkedin' => 'nullable|string',
            'twitter' => 'nullable|string',
            'rating' => 'nullable|string',
            'reviews_count' => 'nullable|string',
            'opening_hours' => 'nullable|string',
        ]);

        $lead->update($validatedData);

        return response()->json($lead);
    }
}
