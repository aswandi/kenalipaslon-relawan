<?php

namespace App\Http\Controllers;

use App\Models\Volunteer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'password' => 'required|string',
        ]);

        $volunteer = Volunteer::where('phone_number', $request->phone_number)
            ->where('is_active', true)
            ->first();

        // Debug logging
        \Log::info('Login attempt', [
            'phone_number' => $request->phone_number,
            'volunteer_found' => $volunteer ? 'yes' : 'no',
            'password_match' => $volunteer && $request->password === $volunteer->getAuthPassword() ? 'yes' : 'no'
        ]);

        if (!$volunteer) {
            throw ValidationException::withMessages([
                'phone_number' => ['Nomor telepon tidak ditemukan.'],
            ]);
        }

        if ($request->password !== $volunteer->getAuthPassword()) {
            throw ValidationException::withMessages([
                'phone_number' => ['Password tidak sesuai.'],
            ]);
        }

        // Store volunteer ID in session instead of using Auth guard
        session(['volunteer_id' => $volunteer->id]);
        session()->save(); // Force save session immediately
        
        // Also try the Auth guard as backup
        Auth::guard('web')->login($volunteer);

        // Debug logging after login
        \Log::info('Login successful', [
            'session_id' => session()->getId(),
            'session_volunteer_id' => session('volunteer_id'),
            'auth_authenticated' => Auth::guard('web')->check(),
            'auth_user_id' => Auth::guard('web')->id(),
            'session_regenerated' => true
        ]);
        
        // Verify session was actually saved to database
        $dbSession = \DB::table('sessions')->where('id', session()->getId())->first();
        \Log::info('Session verification', [
            'db_session_exists' => !!$dbSession,
            'db_session_volunteer_id' => $dbSession ? (unserialize(base64_decode($dbSession->payload))['volunteer_id'] ?? 'not_found') : 'no_session'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'volunteer' => [
                'id' => $volunteer->id,
                'full_name' => $volunteer->full_name,
                'phone_number' => $volunteer->phone_number,
                'role' => $volunteer->role,
            ]
        ]);
    }

    public function logout(Request $request)
    {
        // Clear session-based auth
        session()->forget('volunteer_id');
        
        // Also logout from Auth guard
        Auth::guard('web')->logout();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ]);
    }

    public function me(Request $request)
    {
        // First check session-based auth
        $volunteerId = session('volunteer_id');
        $volunteer = null;
        
        if ($volunteerId) {
            $volunteer = Volunteer::find($volunteerId);
        }
        
        // Fallback to Auth guard
        if (!$volunteer) {
            $volunteer = Auth::guard('web')->user();
        }

        // Debug logging
        \Log::info('Auth check', [
            'session_id' => session()->getId(),
            'session_volunteer_id' => session('volunteer_id'),
            'auth_authenticated' => Auth::guard('web')->check(),
            'auth_user_id' => Auth::guard('web')->id(),
            'found_volunteer' => $volunteer ? $volunteer->id : 'none'
        ]);

        if (!$volunteer) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        return response()->json([
            'success' => true,
            'volunteer' => [
                'id' => $volunteer->id,
                'full_name' => $volunteer->full_name,
                'phone_number' => $volunteer->phone_number,
                'role' => $volunteer->role,
            ]
        ]);
    }
}