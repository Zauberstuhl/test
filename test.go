package main

import (
  "fmt"
  "log"
  "net/http"
  "time"

  "github.com/jpillora/overseer"
  "github.com/jpillora/overseer/fetcher"
)

//create another main() to run the overseer process
//and then convert your old main() into a 'prog(state)'
func main() {
  overseer.Run(overseer.Config{
    Program: prog,
    Address: ":3000",
    Fetcher: &fetcher.File{
      Path:      "/tmp/test",
      Interval: 1 * time.Second,
    },
  })
}

//prog(state) runs in a child process
func prog(state overseer.State) {
  log.Printf("app (%s) listening...", state.ID)
  http.Handle("/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "app (%s) says hello world\n", state.ID)
  }))
  http.Serve(state.Listener, nil)
}
