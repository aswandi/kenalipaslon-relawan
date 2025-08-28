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
          <div class="flex-1">
            <h1 class="text-xl font-bold">Detail Sensus</h1>
            <p class="text-primary-100 text-sm">Lihat dan edit hasil sensus</p>
          </div>
          <button 
            v-if="record && !isEditing"
            @click="startEdit"
            class="bg-primary-700 hover:bg-primary-800 px-4 py-2 rounded-lg text-sm transition-colors"
          >
            Edit
          </button>
        </div>
      </div>
    </header>

    <main class="max-w-4xl mx-auto px-4 py-6">
      <!-- Loading state -->
      <div v-if="isLoading" class="flex justify-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>

      <!-- Error state -->
      <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-2xl p-6 mb-6">
        <div class="flex items-center">
          <svg class="w-6 h-6 text-red-500 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <p class="text-red-600">{{ error }}</p>
        </div>
      </div>

      <!-- Record details -->
      <div v-else-if="record" class="space-y-6">
        <!-- Voter information -->
        <div class="bg-white rounded-2xl shadow-lg p-6 animate-fade-in">
          <h2 class="text-xl font-bold text-gray-800 mb-4">Data Pemilih</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <p class="text-sm font-medium text-gray-500">Nama Lengkap</p>
              <p class="text-lg font-semibold text-gray-800">{{ record.voter.name }}</p>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-500">Usia</p>
              <p class="text-lg font-semibold text-gray-800">{{ record.voter.age }} tahun</p>
            </div>
            <div class="md:col-span-2">
              <p class="text-sm font-medium text-gray-500">Alamat</p>
              <p class="text-gray-800">{{ record.voter.address }}</p>
              <p class="text-sm text-gray-500 mt-1">
                {{ record.voter.village }}, RT {{ record.voter.rt }}
              </p>
            </div>
          </div>
        </div>

        <!-- Sensus info -->
        <div class="bg-white rounded-2xl shadow-lg p-6 animate-fade-in">
          <h2 class="text-xl font-bold text-gray-800 mb-4">Informasi Sensus</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <p class="text-sm font-medium text-gray-500">Tanggal Sensus</p>
              <p class="text-lg font-semibold text-gray-800">{{ formatDate(record.responded_at) }}</p>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-500">Lokasi GPS</p>
              <p class="text-gray-800">
                {{ record.latitude && record.longitude ? 'Tersimpan' : 'Tidak tersedia' }}
              </p>
            </div>
          </div>
        </div>

        <!-- Edit form or display responses -->
        <form v-if="isEditing" @submit.prevent="handleUpdate" class="space-y-6">
          <!-- Questions with current responses -->
          <div v-for="(response, index) in editForm.responses" :key="response.question_id" class="bg-white rounded-2xl shadow-lg p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">
              {{ index + 1 }}. {{ response.question_text }}
            </h3>

            <!-- Multiple choice -->
            <div v-if="response.question_type === 'multiple_choice'" class="space-y-3">
              <label 
                v-for="option in getQuestionOptions(response.question_id)" 
                :key="option.id"
                class="flex items-start p-4 border border-gray-200 rounded-xl hover:bg-gray-50 cursor-pointer transition-colors"
                :class="{ 'ring-2 ring-primary-500 bg-primary-50': editForm.responses.find(r => r.question_id === response.question_id)?.answer_option_id === option.id }"
              >
                <input
                  v-model="editForm.responses.find(r => r.question_id === response.question_id).answer_option_id"
                  :value="option.id"
                  type="radio"
                  :name="`edit_question_${response.question_id}`"
                  class="mt-1 text-primary-600 focus:ring-primary-500"
                >
                <span class="ml-3 text-gray-800">{{ option.option_text }}</span>
              </label>
            </div>

            <!-- Text response -->
            <div v-else class="mt-4">
              <textarea
                v-model="editForm.responses.find(r => r.question_id === response.question_id).text_answer"
                rows="4"
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                :placeholder="response.question_text"
              ></textarea>
            </div>
          </div>

          <!-- Photo edit -->
          <div class="bg-white rounded-2xl shadow-lg p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">Foto Dokumentasi</h3>
            
            <!-- Current photo -->
            <div v-if="record.photo_url" class="mb-4">
              <img :src="record.photo_url" alt="Current photo" class="w-full max-w-md mx-auto rounded-lg shadow">
            </div>

            <!-- New photo preview -->
            <div v-if="photoPreview" class="mb-4">
              <p class="text-sm text-gray-500 mb-2">Foto baru:</p>
              <img :src="photoPreview" alt="New photo preview" class="w-full max-w-md mx-auto rounded-lg shadow">
              <button 
                @click="clearPhoto" 
                type="button"
                class="mt-2 text-red-600 hover:text-red-700 text-sm"
              >
                Hapus foto baru
              </button>
            </div>

            <!-- Photo input -->
            <input
              ref="photoInput"
              @change="handlePhotoChange"
              type="file"
              accept="image/*"
              capture="environment"
              class="hidden"
            >
            
            <button
              @click="$refs.photoInput.click()"
              type="button"
              class="flex items-center justify-center py-4 px-6 border-2 border-dashed border-gray-300 rounded-xl hover:border-primary-500 transition-colors w-full"
            >
              <svg class="w-6 h-6 text-gray-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
              {{ record.photo_url ? 'Ganti Foto' : 'Tambah Foto' }}
            </button>
          </div>

          <!-- Notes edit -->
          <div class="bg-white rounded-2xl shadow-lg p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">Catatan</h3>
            <textarea
              v-model="editForm.notes"
              rows="4"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="Catatan tambahan"
            ></textarea>
          </div>

          <!-- Action buttons -->
          <div class="flex space-x-4">
            <button
              type="submit"
              :disabled="isLoading"
              class="flex-1 bg-primary-600 hover:bg-primary-700 disabled:bg-gray-300 text-white font-semibold py-3 px-6 rounded-xl transition-colors"
            >
              <span v-if="isLoading">Menyimpan...</span>
              <span v-else>Simpan Perubahan</span>
            </button>
            <button
              @click="cancelEdit"
              type="button"
              class="flex-1 bg-gray-500 hover:bg-gray-600 text-white font-semibold py-3 px-6 rounded-xl transition-colors"
            >
              Batal
            </button>
          </div>
        </form>

        <!-- Display mode -->
        <div v-else class="space-y-6">
          <!-- Responses display -->
          <div v-for="(response, index) in record.responses" :key="response.question_id" class="bg-white rounded-2xl shadow-lg p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">
              {{ index + 1 }}. {{ response.question_text }}
            </h3>
            <div class="bg-gray-50 p-4 rounded-lg">
              <p class="text-gray-800 font-medium">
                {{ response.answer_text || response.text_answer || 'Tidak dijawab' }}
              </p>
            </div>
          </div>

          <!-- Photo display -->
          <div v-if="record.photo_url" class="bg-white rounded-2xl shadow-lg p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">Foto Dokumentasi</h3>
            <img :src="record.photo_url" alt="Sensus photo" class="w-full max-w-md mx-auto rounded-lg shadow">
          </div>

          <!-- Notes display -->
          <div v-if="record.notes" class="bg-white rounded-2xl shadow-lg p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">Catatan</h3>
            <div class="bg-gray-50 p-4 rounded-lg">
              <p class="text-gray-800">{{ record.notes }}</p>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'RecordDetails',
  data() {
    return {
      record: null,
      isEditing: false,
      editForm: {
        responses: [],
        notes: '',
        photo: null
      },
      photoPreview: null
    }
  },
  
  computed: {
    ...mapGetters('survey', ['questions', 'isLoading', 'error'])
  },
  
  async mounted() {
    const recordId = this.$route.params.recordId
    await this.loadRecord(recordId)
  },
  
  methods: {
    ...mapActions('survey', ['fetchFieldRecord', 'updateFieldRecord', 'fetchQuestions', 'clearError']),
    
    async loadRecord(recordId) {
      try {
        await this.fetchQuestions()
        this.record = await this.fetchFieldRecord(recordId)
      } catch (error) {
        console.error('Error loading record:', error)
      }
    },
    
    startEdit() {
      this.isEditing = true
      
      // Initialize edit form
      this.editForm.responses = this.record.responses.map(response => ({
        question_id: response.question_id,
        question_text: response.question_text,
        question_type: this.getQuestionType(response.question_id),
        answer_option_id: response.answer_option_id,
        text_answer: response.text_answer
      }))
      
      this.editForm.notes = this.record.notes || ''
      this.editForm.photo = null
      this.photoPreview = null
    },
    
    cancelEdit() {
      this.isEditing = false
      this.editForm = {
        responses: [],
        notes: '',
        photo: null
      }
      this.photoPreview = null
    },
    
    getQuestionType(questionId) {
      const question = this.questions.find(q => q.id === questionId)
      return question?.question_type || 'text'
    },
    
    getQuestionOptions(questionId) {
      const question = this.questions.find(q => q.id === questionId)
      return question?.answer_options || []
    },
    
    handlePhotoChange(event) {
      const file = event.target.files[0]
      if (file) {
        this.editForm.photo = file
        
        const reader = new FileReader()
        reader.onload = (e) => {
          this.photoPreview = e.target.result
        }
        reader.readAsDataURL(file)
      }
    },
    
    clearPhoto() {
      this.editForm.photo = null
      this.photoPreview = null
      this.$refs.photoInput.value = ''
    },
    
    async handleUpdate() {
      this.clearError()
      
      const surveyData = {
        responses: this.editForm.responses,
        notes: this.editForm.notes,
        photo: this.editForm.photo
      }
      
      try {
        await this.updateFieldRecord({
          recordId: this.record.id,
          surveyData
        })
        
        // Reload record to get updated data
        await this.loadRecord(this.record.id)
        this.isEditing = false
        
      } catch (error) {
        console.error('Error updating record:', error)
      }
    },
    
    formatDate(dateString) {
      const date = new Date(dateString)
      return new Intl.DateTimeFormat('id-ID', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      }).format(date)
    }
  }
}
</script>