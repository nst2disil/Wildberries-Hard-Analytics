package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/joho/godotenv"

	"golang.org/x/time/rate"
)

var (
	port          string
	serverLimiter = rate.NewLimiter(rate.Every(time.Second/5), 5)
	serverStats   = map[string]map[int]int{"total": {}, "client1": {}, "client2": {}}
	mu            sync.Mutex
)

func init() {
	err := godotenv.Load("../.env")
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	port = os.Getenv("PORT")
	if port == "" {
		log.Fatal("PORT is not set in env")
	}

	for _, client := range []string{"total", "client1", "client2"} {
		serverStats[client] = make(map[int]int)
	}
}

func handlePost(w http.ResponseWriter, r *http.Request) {
	clientID := r.Header.Get("Client-ID")
	if clientID == "" {
		http.Error(w, "Missing Client-ID header", http.StatusBadRequest)
		return
	}

	if !serverLimiter.Allow() {
		http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
		return
	}

	time.Sleep(100 * time.Millisecond)

	status := getRandomStatus()
	mu.Lock()
	defer mu.Unlock()

	serverStats["total"][status]++
	if _, exists := serverStats[clientID]; !exists {
		serverStats[clientID] = make(map[int]int)
	}
	serverStats[clientID][status]++

	w.WriteHeader(status)
	fmt.Fprintf(w, "Status: %d\n", status)
}

func getRandomStatus() int {
	r := rand.Intn(100)
	if r < 70 {
		return http.StatusOK
	} else if r < 90 {
		return http.StatusAccepted
	} else if r < 95 {
		return http.StatusBadRequest
	}
	return http.StatusInternalServerError
}

func handleGet(w http.ResponseWriter, r *http.Request) {
	mu.Lock()
	defer mu.Unlock()

	jsonData, err := json.Marshal(serverStats)
	if err != nil {
		http.Error(w, "Error encoding JSON", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonData)
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "Server is up and running")
}

func main() {
	http.HandleFunc("/post", handlePost)
	http.HandleFunc("/get-stats", handleGet)
	http.HandleFunc("/health", healthCheck)

	log.Printf("Starting server on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
