<?php

namespace App\Http\Controllers;

use App\Models\Voter;
use App\Models\FieldRecord;
use App\Models\VolunteerAssignment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class VoterController extends Controller
{
    public function search(Request $request)
    {
        $request->validate([
            'query' => 'required|string|min:3',
        ]);

        // Get volunteer from middleware (set by VolunteerAuth middleware)
        $volunteer = $request->attributes->get('volunteer') ?? Auth::user();
        $query = $request->input('query');

        // Get volunteer assignments
        $assignments = VolunteerAssignment::where('volunteer_id', $volunteer->id)
            ->where('is_active', true)
            ->get();

        if ($assignments->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki area tugas yang aktif'
            ], 400);
        }

        // Build query for voters in assigned areas
        $votersQuery = Voter::query();
        
        foreach ($assignments as $assignment) {
            $votersQuery->orWhere(function ($q) use ($assignment) {
                $q->where('district', $assignment->district)
                  ->where('village', $assignment->village)
                  ->where('rt', $assignment->rt);
                
                // Add RW filter if specified in assignment
                if (!is_null($assignment->rw)) {
                    $q->where('rw', $assignment->rw);
                }
            });
        }

        $voters = $votersQuery
            ->where('name', 'LIKE', '%' . $query . '%')
            ->with('fieldRecords')
            ->limit(20)
            ->get();

        $result = $voters->map(function ($voter) {
            $hasRecord = $voter->fieldRecords->isNotEmpty();
            
            return [
                'id' => $voter->id,
                'name' => $voter->name,
                'age' => $voter->age,
                'address' => $voter->address,
                'village' => $voter->village,
                'rt' => $voter->rt,
                'rw' => $voter->rw,
                'tps' => $voter->tps,
                'gender' => $voter->gender,
                'has_record' => $hasRecord,
                'clickable' => !$hasRecord
            ];
        });

        return response()->json([
            'success' => true,
            'voters' => $result
        ]);
    }

    public function show(Request $request, $id)
    {
        // Get volunteer from middleware (set by VolunteerAuth middleware)
        $volunteer = $request->attributes->get('volunteer') ?? Auth::user();
        $voter = Voter::findOrFail($id);

        // Check if voter is in volunteer's assigned area
        $hasAssignment = VolunteerAssignment::where('volunteer_id', $volunteer->id)
            ->where('district', $voter->district)
            ->where('village', $voter->village)
            ->where('rt', $voter->rt)
            ->where('is_active', true)
            ->where(function ($q) use ($voter) {
                // If assignment has specific RW, voter must match
                // If assignment RW is null, accept any RW
                $q->whereNull('rw')
                  ->orWhere('rw', $voter->rw);
            })
            ->exists();

        if (!$hasAssignment) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke data pemilih ini'
            ], 403);
        }

        // Check if voter already has record
        $existingRecord = FieldRecord::where('voter_id', $voter->id)->first();

        return response()->json([
            'success' => true,
            'voter' => [
                'id' => $voter->id,
                'name' => $voter->name,
                'age' => $voter->age,
                'address' => $voter->address,
                'village' => $voter->village,
                'rt' => $voter->rt,
                'rw' => $voter->rw,
                'tps' => $voter->tps,
                'gender' => $voter->gender,
                'place_of_birth' => $voter->place_of_birth,
                'date_of_birth' => $voter->date_of_birth->format('Y-m-d'),
            ],
            'has_existing_record' => $existingRecord !== null,
            'existing_record_id' => $existingRecord?->id
        ]);
    }
}