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
            <h1 class="text-xl font-bold">Cari Pemilih</h1>
            <p class="text-primary-100 text-sm">Ketik minimal 3 huruf untuk mencari</p>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-4xl mx-auto px-4 py-6">
      <!-- Search input -->
      <div class="bg-white rounded-2xl shadow-lg p-6 mb-6 animate-fade-in">
        <div class="relative">
          <input
            v-model="searchQuery"
            @input="handleSearch"
            type="text"
            placeholder="Masukkan nama pemilih..."
            class="w-full pl-12 pr-4 py-4 text-lg border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
          >
          <div class="absolute inset-y-0 left-0 pl-4 flex items-center">
            <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
            </svg>
          </div>
        </div>
        
        <!-- Search hint -->
        <p v-if="searchQuery.length < 3 && searchQuery.length > 0" class="text-sm text-gray-500 mt-2">
          Masukkan minimal 3 huruf untuk mencari
        </p>
      </div>

      <!-- Loading state -->
      <div v-if="isLoading" class="flex justify-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>

      <!-- No results -->
      <div v-else-if="searchQuery.length >= 3 && voters.length === 0" class="text-center py-8 animate-fade-in">
        <svg class="w-16 h-16 mx-auto mb-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
        </svg>
        <p class="text-gray-500">Tidak ada data pemilih ditemukan</p>
        <p class="text-sm text-gray-400 mt-2">
          Pastikan nama yang dicari berada di wilayah tugas Anda
        </p>
      </div>

      <!-- Results -->
      <div v-else-if="voters.length > 0" class="space-y-4">
        <div
          v-for="voter in voters"
          :key="voter.id"
          @click="voter.clickable && selectVoter(voter)"
          :class="{
            'opacity-50 cursor-not-allowed': !voter.clickable,
            'hover:shadow-lg cursor-pointer': voter.clickable,
            'transform hover:scale-105': voter.clickable
          }"
          class="bg-white rounded-2xl shadow-lg p-6 transition-all duration-200 animate-slide-up"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <div class="flex items-center mb-2">
                <h3 class="text-lg font-bold text-gray-800 mr-3">{{ voter.name }}</h3>
                <span 
                  v-if="voter.has_record"
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
                >
                  Sudah Sensus
                </span>
              </div>
              
              <div class="space-y-1 text-sm text-gray-600">
                <div class="flex items-center">
                  <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                  </svg>
                  <span>{{ voter.age }} tahun ({{ voter.gender === 'L' ? 'Laki-laki' : 'Perempuan' }})</span>
                </div>
                
                <div class="flex items-center">
                  <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                  </svg>
                  <span>{{ voter.village }}, RT {{ voter.rt }}/{{ voter.rw }}</span>
                </div>
                
                <div class="flex items-center">
                  <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-4m-5 0H9m0 0H5m4 0v-5a1 1 0 011-1h4a1 1 0 011 1v5M7 7h.01M7 10h.01M7 13h.01m8-6h.01m0 3h.01m0 3h.01"></path>
                  </svg>
                  <span>TPS {{ voter.tps }}</span>
                </div>
                
                <p class="mt-2 text-xs text-gray-500">{{ voter.address }}</p>
              </div>
            </div>

            <!-- Status indicator -->
            <div class="ml-4">
              <div v-if="voter.clickable" class="bg-primary-100 text-primary-600 rounded-full p-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                </svg>
              </div>
              <div v-else class="bg-gray-100 text-gray-400 rounded-full p-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
              </div>
            </div>
          </div>

          <!-- Not clickable overlay -->
          <div v-if="!voter.clickable" class="absolute inset-0 bg-gray-200 bg-opacity-50 rounded-2xl flex items-center justify-center">
            <div class="bg-white px-4 py-2 rounded-lg shadow">
              <p class="text-sm font-medium text-gray-700">Data sudah diinput</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Initial state -->
      <div v-else class="text-center py-16 animate-fade-in">
        <svg class="w-20 h-20 mx-auto mb-6 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
        </svg>
        <h3 class="text-xl font-semibold text-gray-700 mb-2">Mulai Pencarian</h3>
        <p class="text-gray-500">Ketik nama pemilih di kolom pencarian untuk memulai</p>
      </div>
    </main>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'VoterSearch',
  data() {
    return {
      searchQuery: '',
      debounceTimer: null
    }
  },
  
  computed: {
    ...mapGetters('survey', ['voters', 'isLoading', 'error'])
  },
  
  methods: {
    ...mapActions('survey', ['searchVoters', 'clearVoters', 'clearError']),
    
    handleSearch() {
      // Clear previous timer
      if (this.debounceTimer) {
        clearTimeout(this.debounceTimer)
      }
      
      // Clear error
      this.clearError()
      
      // If less than 3 characters, clear results
      if (this.searchQuery.length < 3) {
        this.clearVoters()
        return
      }
      
      // Debounce search
      this.debounceTimer = setTimeout(() => {
        this.searchVoters(this.searchQuery)
      }, 300)
    },
    
    selectVoter(voter) {
      if (voter.clickable) {
        this.$router.push({ 
          name: 'SurveyForm', 
          params: { voterId: voter.id } 
        })
      }
    }
  },
  
  beforeUnmount() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }
}
</script>