<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LeadController;

use App\Http\Controllers\AuthController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'me']);
    Route::get('/leads', [LeadController::class, 'index']);
    Route::post('/leads', [LeadController::class, 'store']);
    Route::get('/lead/{id}', [LeadController::class, 'show']);
    Route::post('/lead/update-status', [LeadController::class, 'updateStatus']);
    Route::put('/lead/{id}', [LeadController::class, 'update']);
    Route::delete('/lead/{id}', [LeadController::class, 'destroy']);
    Route::post('/scrape-leads', [LeadController::class, 'scrapeLeads']);
    Route::get('/export-leads', [LeadController::class, 'export']);
    Route::get('/dashboard-stats', [LeadController::class, 'dashboardStats']);
});
