<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\VoterController;
use App\Http\Controllers\QuestionController;
use App\Http\Controllers\FieldRecordController;

// Authentication routes - need web middleware for sessions
Route::middleware('web')->group(function () {
    // CSRF cookie endpoint (similar to Sanctum)
    Route::get('/sanctum/csrf-cookie', function () {
        return response()->json(['message' => 'CSRF cookie set']);
    });
    
    Route::post('/api/login', [AuthController::class, 'login']);
    Route::post('/api/logout', [AuthController::class, 'logout']);
    Route::get('/api/me', [AuthController::class, 'me']);
    
});

// Protected API routes
Route::middleware(['web', 'volunteer.auth'])->group(function () {
    // Voters
    Route::get('/api/voters/search', [VoterController::class, 'search']);
    Route::get('/api/voters/{id}', [VoterController::class, 'show']);
    
    // Questions
    Route::get('/api/questions', [QuestionController::class, 'index']);
    
    // Field records
    Route::get('/api/field-records', [FieldRecordController::class, 'index']);
    Route::post('/api/field-records', [FieldRecordController::class, 'store']);
    Route::get('/api/field-records/{id}', [FieldRecordController::class, 'show']);
    Route::put('/api/field-records/{id}', [FieldRecordController::class, 'update']);
});

// SPA Routes - catch all routes for Vue Router
Route::get('/{any}', function () {
    return view('app');
})->where('any', '.*');
