<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-primary-600 text-white shadow-lg">
      <div class="max-w-4xl mx-auto px-4 py-4">
        <div class="flex items-center">
          <button 
            @click="$router.back()"
            class="mr-4 p-2 hover:bg-primary-700 rounded-lg transition-colors"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
            </svg>
          </button>
          <div>
            <h1 class="text-xl font-bold">Sensus Pemilih</h1>
            <p class="text-primary-100 text-sm">Lengkapi data dan pertanyaan</p>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-4xl mx-auto px-4 py-6">
      <!-- Loading state -->
      <div v-if="isLoading && !selectedVoter" class="flex justify-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>

      <!-- Error state -->
      <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-2xl p-6 mb-6 animate-fade-in">
        <div class="flex items-center">
          <svg class="w-6 h-6 text-red-500 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <p class="text-red-600">{{ error }}</p>
        </div>
      </div>

      <!-- Main form -->
      <div v-else-if="selectedVoter" class="space-y-6">
        <!-- Voter information -->
        <div class="bg-white rounded-2xl shadow-lg p-6 animate-fade-in">
          <h2 class="text-xl font-bold text-gray-800 mb-4">Data Pemilih</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <p class="text-sm font-medium text-gray-500">Nama Lengkap</p>
              <p class="text-lg font-semibold text-gray-800">{{ selectedVoter.name }}</p>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-500">Usia</p>
              <p class="text-lg font-semibold text-gray-800">{{ selectedVoter.age }} tahun</p>
            </div>
            <div class="md:col-span-2">
              <p class="text-sm font-medium text-gray-500">Alamat</p>
              <p class="text-gray-800">{{ selectedVoter.address }}</p>
              <p class="text-sm text-gray-500 mt-1">
                {{ selectedVoter.village }}, RT {{ selectedVoter.rt }}/{{ selectedVoter.rw }}, TPS {{ selectedVoter.tps }}
              </p>
            </div>
          </div>
        </div>

        <!-- Sensus form -->
        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Questions -->
          <div v-for="(question, index) in visibleQuestions" :key="question.id" class="bg-white rounded-2xl shadow-lg p-6 animate-slide-up">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">
              {{ index + 1 }}. {{ question.question_text }}
              <span v-if="question.is_required" class="text-red-500">*</span>
            </h3>

            <!-- Multiple choice -->
            <div v-if="question.question_type === 'multiple_choice'" class="space-y-3">
              <label 
                v-for="option in question.answer_options" 
                :key="option.id"
                class="flex items-start p-4 border border-gray-200 rounded-xl hover:bg-gray-50 cursor-pointer transition-colors"
                :class="{ 'ring-2 ring-primary-500 bg-primary-50': form.responses[question.id]?.answer_option_id === option.id }"
              >
                <input
                  :checked="form.responses[question.id]?.answer_option_id === option.id"
                  :value="option.id"
                  type="radio"
                  :name="`question_${question.id}`"
                  class="mt-1 text-primary-600 focus:ring-primary-500"
                  :required="question.is_required"
                  @change="updateResponse(question.id, 'answer_option_id', option.id)"
                >
                <span class="ml-3 text-gray-800">{{ option.option_text }}</span>
              </label>
            </div>

            <!-- Text input -->
            <div v-else-if="question.question_type === 'text'" class="mt-4">
              <textarea
                :value="form.responses[question.id]?.text_answer || ''"
                rows="4"
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                :placeholder="`Jawab pertanyaan: ${question.question_text}`"
                :required="question.is_required"
                @input="updateResponse(question.id, 'text_answer', $event.target.value)"
              ></textarea>
            </div>
          </div>

          <!-- Photo upload -->
          <div class="bg-white rounded-2xl shadow-lg p-6 animate-slide-up">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">Foto Dokumentasi</h3>
            
            <!-- Photo preview -->
            <div v-if="photoPreview" class="mb-4">
              <img :src="photoPreview" alt="Preview" class="w-full max-w-md mx-auto rounded-lg shadow">
              <button 
                @click="clearPhoto" 
                type="button"
                class="mt-2 text-red-600 hover:text-red-700 text-sm"
              >
                Hapus foto
              </button>
            </div>

            <!-- Photo input -->
            <div class="space-y-4">
              <input
                ref="photoInput"
                @change="handlePhotoChange"
                type="file"
                accept="image/*"
                capture="environment"
                class="hidden"
              >
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <button
                  @click="$refs.photoInput.click()"
                  type="button"
                  class="flex items-center justify-center py-4 px-6 border-2 border-dashed border-gray-300 rounded-xl hover:border-primary-500 transition-colors"
                >
                  <svg class="w-6 h-6 text-gray-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
                  </svg>
                  Ambil Foto
                </button>
                
                <button
                  @click="$refs.photoInput.click()"
                  type="button"
                  class="flex items-center justify-center py-4 px-6 border-2 border-dashed border-gray-300 rounded-xl hover:border-primary-500 transition-colors"
                >
                  <svg class="w-6 h-6 text-gray-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                  </svg>
                  Upload Foto
                </button>
              </div>
            </div>
          </div>

          <!-- Notes -->
          <div class="bg-white rounded-2xl shadow-lg p-6 animate-slide-up">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">Catatan Tambahan</h3>
            <textarea
              v-model="form.notes"
              rows="4"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="Catatan atau keterangan tambahan (opsional)"
            ></textarea>
          </div>

          <!-- Submit button -->
          <div class="bg-white rounded-2xl shadow-lg p-6 animate-slide-up">
            <button
              type="submit"
              :disabled="isLoading || !isFormValid"
              class="w-full bg-primary-600 hover:bg-primary-700 disabled:bg-gray-300 text-white font-semibold py-4 px-6 rounded-xl text-lg transition-colors"
            >
              <div v-if="isLoading" class="flex items-center justify-center">
                <svg class="animate-spin -ml-1 mr-3 h-6 w-6 text-white" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Menyimpan...
              </div>
              <span v-else>KIRIM DATA</span>
            </button>
            
            <p class="text-xs text-gray-500 text-center mt-2">
              Data akan disimpan dengan koordinat GPS otomatis
            </p>
          </div>
        </form>
      </div>
    </main>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'SurveyForm',
  data() {
    return {
      form: {
        responses: {},
        photo: null,
        notes: '',
        latitude: null,
        longitude: null
      },
      photoPreview: null,
      isGettingLocation: false
    }
  },
  
  computed: {
    ...mapGetters('survey', ['selectedVoter', 'questions', 'isLoading', 'error']),
    
    visibleQuestions() {
      if (!this.questions || this.questions.length === 0) {
        return []
      }
      
      // Always show questions 1 and 2
      const baseQuestions = this.questions.filter(q => q.order_number <= 2)
      
      // Check answer for question 2 (conditional question)
      const question2Response = this.form.responses[2] // question with id=2
      if (!question2Response?.answer_option_id) {
        return baseQuestions
      }
      
      // Based on question 2 answer, show conditional question
      let conditionalQuestion = null
      
      // If answer is "Ya" (id: 5) -> show question 3
      if (question2Response.answer_option_id === 5) {
        conditionalQuestion = this.questions.find(q => q.order_number === 3)
      }
      // If answer is "Tidak" (id: 6) -> show question 4  
      else if (question2Response.answer_option_id === 6) {
        conditionalQuestion = this.questions.find(q => q.order_number === 4)
      }
      // If answer is "Ragu-ragu" (id: 7) -> show question 5
      else if (question2Response.answer_option_id === 7) {
        conditionalQuestion = this.questions.find(q => q.order_number === 5)
      }
      
      // Return base questions + conditional question if exists
      return conditionalQuestion 
        ? [...baseQuestions, conditionalQuestion]
        : baseQuestions
    },
    
    isFormValid() {
      // Check if all required visible questions are answered
      return this.visibleQuestions.every(question => {
        if (!question.is_required) return true
        
        const response = this.form.responses[question.id]
        if (!response) return false
        
        if (question.question_type === 'multiple_choice') {
          return !!response.answer_option_id
        } else if (question.question_type === 'text') {
          return !!response.text_answer?.trim()
        }
        
        return true
      })
    }
  },
  
  async mounted() {
    const voterId = this.$route.params.voterId
    
    try {
      // Fetch voter and questions
      await Promise.all([
        this.fetchVoter(voterId),
        this.fetchQuestions()
      ])
      
      // Initialize form responses
      this.initializeForm()
      
      // Get GPS location
      this.getCurrentLocation()
      
    } catch (error) {
      console.error('Error loading survey form:', error)
    }
  },
  
  methods: {
    ...mapActions('survey', ['fetchVoter', 'fetchQuestions', 'submitSurvey', 'clearError']),
    
    initializeForm() {
      // Initialize response objects for each question
      this.questions.forEach(question => {
        if (!this.form.responses[question.id]) {
          this.form.responses[question.id] = {
            question_id: question.id,
            answer_option_id: null,
            text_answer: ''
          }
        }
      })
    },
    
    updateResponse(questionId, field, value) {
      // Ensure the response object exists
      if (!this.form.responses[questionId]) {
        this.form.responses[questionId] = {
          question_id: questionId,
          answer_option_id: null,
          text_answer: ''
        }
      }
      // Update the specific field
      this.form.responses[questionId][field] = value
      
      // If this is question 2 (conditional question), clear conditional responses
      if (questionId === 2 && field === 'answer_option_id') {
        // Clear responses for questions 3, 4, and 5 since they're conditional
        [3, 4, 5].forEach(qId => {
          if (this.form.responses[qId]) {
            this.form.responses[qId] = {
              question_id: qId,
              answer_option_id: null,
              text_answer: ''
            }
          }
        })
      }
    },
    
    handlePhotoChange(event) {
      const file = event.target.files[0]
      if (file) {
        this.form.photo = file
        
        // Create preview
        const reader = new FileReader()
        reader.onload = (e) => {
          this.photoPreview = e.target.result
        }
        reader.readAsDataURL(file)
      }
    },
    
    clearPhoto() {
      this.form.photo = null
      this.photoPreview = null
      this.$refs.photoInput.value = ''
    },
    
    async getCurrentLocation() {
      if (!navigator.geolocation) {
        console.warn('Geolocation not supported')
        return
      }
      
      this.isGettingLocation = true
      
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.form.latitude = position.coords.latitude
          this.form.longitude = position.coords.longitude
          this.isGettingLocation = false
        },
        (error) => {
          console.warn('Error getting location:', error)
          this.isGettingLocation = false
        },
        {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 300000
        }
      )
    },
    
    async handleSubmit() {
      this.clearError()
      
      // Prepare responses array - only include responses from visible questions
      const visibleQuestionIds = this.visibleQuestions.map(q => q.id)
      const responses = Object.values(this.form.responses).filter(response => {
        return visibleQuestionIds.includes(response.question_id) && 
               (response.answer_option_id || response.text_answer?.trim())
      })
      
      const surveyData = {
        voter_id: this.selectedVoter.id,
        responses,
        photo: this.form.photo,
        notes: this.form.notes,
        latitude: this.form.latitude,
        longitude: this.form.longitude
      }
      
      try {
        await this.submitSurvey(surveyData)
        
        // Success - redirect to dashboard
        this.$router.push({ 
          name: 'Dashboard',
          query: { success: 'Data survey berhasil disimpan!' }
        })
        
      } catch (error) {
        console.error('Error submitting survey:', error)
        // Error is handled by store
      }
    }
  }
}
</script>