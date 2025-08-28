<?php

namespace App\Http\Controllers;

use App\Models\FieldRecord;
use App\Models\SurveyResponseDetail;
use App\Models\Voter;
use App\Models\Question;
use App\Models\AnswerOption;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class FieldRecordController extends Controller
{
    public function index(Request $request)
    {
        // Get volunteer from middleware (set by VolunteerAuth middleware)
        $volunteer = $request->attributes->get('volunteer') ?? Auth::user();

        $records = FieldRecord::where('volunteer_id', $volunteer->id)
            ->with(['voter', 'surveyResponseDetails.question', 'surveyResponseDetails.answerOption'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'records' => $records->map(function ($record) {
                return [
                    'id' => $record->id,
                    'voter_name' => $record->voter->name,
                    'voter_village' => $record->voter->village,
                    'voter_rt' => $record->voter->rt,
                    'completion_status' => $record->completion_status,
                    'completion_percentage' => $record->completion_percentage,
                    'responded_at' => $record->responded_at->format('Y-m-d H:i:s'),
                    'photo_url' => $record->photo_path ? asset('storage/' . $record->photo_path) : null,
                ];
            })
        ]);
    }

    public function store(Request $request)
    {
        // Basic logging for production
        \Log::info('Survey submission received', [
            'voter_id' => $request->voter_id,
            'has_photo' => $request->hasFile('photo'),
            'response_count' => count($request->responses ?? [])
        ]);
        
        $request->validate([
            'voter_id' => 'required|exists:voters,id',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'notes' => 'nullable|string',
            'photo' => 'nullable|image|max:5120', // 5MB
            'responses' => 'required|array',
            'responses.*.question_id' => 'required|exists:questions,id',
            'responses.*.answer_option_id' => 'nullable|exists:answer_options,id',
            'responses.*.text_answer' => 'nullable|string',
        ]);

        // Get volunteer from middleware (set by VolunteerAuth middleware)
        $volunteer = $request->attributes->get('volunteer') ?? Auth::user();
        $voter = Voter::findOrFail($request->voter_id);

        // Check if voter already has record
        if (FieldRecord::where('voter_id', $voter->id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Data pemilih ini sudah pernah diinput'
            ], 400);
        }

        DB::beginTransaction();
        try {
            // Handle photo upload
            $photoPath = null;
            if ($request->hasFile('photo')) {
                $photoPath = $request->file('photo')->store('field_photos', 'public');
            }

            // Create field record
            $fieldRecord = FieldRecord::create([
                'volunteer_id' => $volunteer->id,
                'voter_id' => $voter->id,
                'latitude' => $request->latitude,
                'longitude' => $request->longitude,
                'responded_at' => now(),
                'completion_status' => 'complete',
                'total_questions' => count($request->responses),
                'answered_questions' => count($request->responses),
                'photo_path' => $photoPath,
                'notes' => $request->notes,
                'sync_status' => 'synced',
            ]);

            // Create response details
            foreach ($request->responses as $response) {
                $question = Question::find($response['question_id']);
                $answerOption = isset($response['answer_option_id']) 
                    ? AnswerOption::find($response['answer_option_id']) 
                    : null;

                SurveyResponseDetail::create([
                    'field_record_id' => $fieldRecord->id,
                    'question_id' => $response['question_id'],
                    'answer_option_id' => $response['answer_option_id'] ?? null,
                    'text_answer' => $response['text_answer'] ?? null,
                    'numeric_value' => $answerOption ? $answerOption->option_value : null,
                    'weight' => 1.00,
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil disimpan',
                'field_record_id' => $fieldRecord->id
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            
            // Delete uploaded photo if transaction failed
            if ($photoPath) {
                Storage::disk('public')->delete($photoPath);
            }

            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan data: ' . $e->getMessage()
            ], 500);
        }
    }

    public function show(Request $request, $id)
    {
        // Get volunteer from middleware (set by VolunteerAuth middleware)
        $volunteer = $request->attributes->get('volunteer') ?? Auth::user();
        $record = FieldRecord::where('id', $id)
            ->where('volunteer_id', $volunteer->id)
            ->with(['voter', 'surveyResponseDetails.question', 'surveyResponseDetails.answerOption'])
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'record' => [
                'id' => $record->id,
                'voter' => [
                    'id' => $record->voter->id,
                    'name' => $record->voter->name,
                    'age' => $record->voter->age,
                    'address' => $record->voter->address,
                    'village' => $record->voter->village,
                    'rt' => $record->voter->rt,
                ],
                'latitude' => $record->latitude,
                'longitude' => $record->longitude,
                'responded_at' => $record->responded_at->format('Y-m-d H:i:s'),
                'notes' => $record->notes,
                'photo_url' => $record->photo_path ? asset('storage/' . $record->photo_path) : null,
                'responses' => $record->surveyResponseDetails->map(function ($detail) {
                    return [
                        'question_id' => $detail->question_id,
                        'question_text' => $detail->question->question_text,
                        'answer_option_id' => $detail->answer_option_id,
                        'answer_text' => $detail->answerOption ? $detail->answerOption->option_text : null,
                        'text_answer' => $detail->text_answer,
                        'numeric_value' => $detail->numeric_value,
                    ];
                })
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'notes' => 'nullable|string',
            'photo' => 'nullable|image|max:5120',
            'responses' => 'required|array',
            'responses.*.question_id' => 'required|exists:questions,id',
            'responses.*.answer_option_id' => 'nullable|exists:answer_options,id',
            'responses.*.text_answer' => 'nullable|string',
        ]);

        // Get volunteer from middleware (set by VolunteerAuth middleware)
        $volunteer = $request->attributes->get('volunteer') ?? Auth::user();
        $fieldRecord = FieldRecord::where('id', $id)
            ->where('volunteer_id', $volunteer->id)
            ->firstOrFail();

        DB::beginTransaction();
        try {
            // Handle photo upload
            if ($request->hasFile('photo')) {
                // Delete old photo
                if ($fieldRecord->photo_path) {
                    Storage::disk('public')->delete($fieldRecord->photo_path);
                }
                $photoPath = $request->file('photo')->store('field_photos', 'public');
                $fieldRecord->photo_path = $photoPath;
            }

            // Update field record
            $fieldRecord->notes = $request->notes;
            $fieldRecord->save();

            // Delete existing response details
            $fieldRecord->surveyResponseDetails()->delete();

            // Create new response details
            foreach ($request->responses as $response) {
                $answerOption = isset($response['answer_option_id']) 
                    ? AnswerOption::find($response['answer_option_id']) 
                    : null;

                SurveyResponseDetail::create([
                    'field_record_id' => $fieldRecord->id,
                    'question_id' => $response['question_id'],
                    'answer_option_id' => $response['answer_option_id'] ?? null,
                    'text_answer' => $response['text_answer'] ?? null,
                    'numeric_value' => $answerOption ? $answerOption->option_value : null,
                    'weight' => 1.00,
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil diperbarui'
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui data: ' . $e->getMessage()
            ], 500);
        }
    }
}