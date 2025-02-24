package main

import (
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/joho/godotenv"
	"golang.org/x/time/rate"
)

type ClientStats struct {
	SentRequests int
	StatusCounts map[int]int
}

func main() {
	rand.Seed(time.Now().UnixNano())

	err := godotenv.Load("../.env")
	if err != nil {
		fmt.Printf("Error loading .env file: %v\n", err)
		return
	}

	port := os.Getenv("PORT")
	if port == "" {
		fmt.Println("PORT is not set in env")
		return
	}

	clients := map[string]*ClientStats{
		"client1": {SentRequests: 0, StatusCounts: map[int]int{}},
		"client2": {SentRequests: 0, StatusCounts: map[int]int{}},
	}

	var wg sync.WaitGroup
	for name, stats := range clients {
		wg.Add(1)
		go sendRequests(name, stats, port, &wg)
	}

	wg.Add(1)
	go healthChecker(port, &wg)

	wg.Wait()

	printStats(clients)
}

func sendRequests(clientName string, stats *ClientStats, port string, wg *sync.WaitGroup) {
	defer wg.Done()

	clientLimiter := rate.NewLimiter(rate.Every(time.Second/5), 5)
	for i := 0; i < 100; i++ {
		if !clientLimiter.Allow() {
			fmt.Printf("Client %s: Rate limit exceeded\n", clientName)
			time.Sleep(200 * time.Millisecond)
			i--
			continue
		}
		sendRequest(clientName, stats, port)
		time.Sleep(100 * time.Millisecond)
	}

	fmt.Printf("Client %s finished sending requests\n", clientName)
}

func sendRequest(clientName string, stats *ClientStats, port string) {
	client := &http.Client{}
	req, _ := http.NewRequest("POST", fmt.Sprintf("http://localhost:%s/post", port), nil)
	req.Header.Set("Client-ID", clientName)

	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("Client %s: Error sending request: %v\n", clientName, err)
		return
	}
	defer resp.Body.Close()

	stats.SentRequests++
	stats.StatusCounts[resp.StatusCode]++

	fmt.Printf("Client %s: Received status %d\n", clientName, resp.StatusCode)
}

func healthChecker(port string, wg *sync.WaitGroup) {
	defer wg.Done()

	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	for range ticker.C {
		resp, err := http.Get(fmt.Sprintf("http://localhost:%s/health", port))
		if err != nil {
			fmt.Println("Health check failed:", err)
			continue
		}

		if resp.StatusCode == http.StatusOK {
			fmt.Println("Server is healthy")
		} else {
			fmt.Println("Server is not healthy")
		}
	}
}

func printStats(clients map[string]*ClientStats) {
	for name, stats := range clients {
		fmt.Printf("\nClient %s:\n", name)
		fmt.Printf("Sent Requests: %d\n", stats.SentRequests)
		fmt.Println("Status Breakdown:")
		for code, count := range stats.StatusCounts {
			fmt.Printf("  %d: %d\n", code, count)
		}
	}
}
