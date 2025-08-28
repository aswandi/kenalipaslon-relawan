<?php

namespace App\Http\Controllers;

use App\Models\Question;
use Illuminate\Http\Request;

class QuestionController extends Controller
{
    public function index()
    {
        $questions = Question::active()
            ->ordered()
            ->with(['answerOptions' => function ($query) {
                $query->where('is_active', true)->orderBy('order_number');
            }])
            ->get();

        return response()->json([
            'success' => true,
            'questions' => $questions->map(function ($question) {
                return [
                    'id' => $question->id,
                    'question_text' => $question->question_text,
                    'question_type' => $question->question_type,
                    'is_required' => $question->is_required,
                    'order_number' => $question->order_number,
                    'answer_options' => $question->answerOptions->map(function ($option) {
                        return [
                            'id' => $option->id,
                            'option_text' => $option->option_text,
                            'option_value' => $option->option_value,
                            'order_number' => $option->order_number,
                        ];
                    })
                ];
            })
        ]);
    }
}