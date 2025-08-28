<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Volunteer;
use Symfony\Component\HttpFoundation\Response;

class VolunteerAuth
{
    public function handle(Request $request, Closure $next): Response
    {
        // Minimal logging for production
        if (app()->environment('local')) {
            \Log::info('VolunteerAuth middleware triggered', [
                'url' => $request->url(),
                'method' => $request->method(),
                'session_volunteer_id' => session('volunteer_id')
            ]);
        }
        
        // First check session-based auth
        $volunteerId = session('volunteer_id');
        $volunteer = null;
        
        if ($volunteerId) {
            $volunteer = Volunteer::find($volunteerId);
        }
        
        // Fallback to Auth guard
        if (!$volunteer && Auth::check()) {
            $authUser = Auth::user();
            if ($authUser instanceof Volunteer) {
                $volunteer = $authUser;
            }
        }

        if (!$volunteer) {
            return response()->json([
                'success' => false,
                'message' => 'Silakan login terlebih dahulu untuk mengakses halaman ini'
            ], 401);
        }

        if (!$volunteer->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak aktif'
            ], 403);
        }

        // Store volunteer in request for use in controllers
        $request->attributes->set('volunteer', $volunteer);

        return $next($request);
    }
}