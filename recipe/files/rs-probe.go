// rs-probe: the HEALTHCHECK helper of ReadyStack's slim runtime images, which carry no curl.
//
//	rs-probe URL         exit 0 when GET URL answers 2xx or 3xx (redirects not followed), 1 otherwise
//	rs-probe -body URL   the same, and print the response body
//	rs-probe -code URL   print the HTTP status code; exit 0 on any response, 1 (printing 000) on none
//	  -k                 do not verify the server's TLS certificate (curl -k)
//	  -cert F -key F     present this client certificate and key (curl --cert F --key F)
//	rs-probe -tcp HOST:PORT
//	                     send standard input to HOST:PORT, print what it answers within 2 s, exit 0 once connected
//	                     (curl telnet://HOST:PORT, as a protocol check of a server that does not speak HTTP)
//
// The verdicts of `curl -fsS -o /dev/null URL`, `curl -fsS URL` and `curl -s -o /dev/null -w '%{http_code}' URL`.
// Standard library only, built with CGO_ENABLED=0 by the kit's pinned Go toolchain: no library, no package.
package main

import (
	"crypto/tls"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"time"
)

func usage() {
	fmt.Fprintln(os.Stderr, "usage: rs-probe [-k] [-cert FILE -key FILE] [-body|-code] http(s)://host:port/path\n"+
		"       rs-probe -tcp host:port < request")
	os.Exit(2)
}

func main() {
	var mode, url, cert, key, tcpAddr string
	insecure := false
	args := os.Args[1:]
	for i := 0; i < len(args); i++ {
		a := args[i]
		switch {
		case a == "-body" || a == "-code":
			mode = a
		case a == "-k":
			insecure = true
		case (a == "-cert" || a == "-key" || a == "-tcp") && i+1 < len(args):
			i++
			switch a {
			case "-cert":
				cert = args[i]
			case "-key":
				key = args[i]
			default:
				tcpAddr = args[i]
			}
		case url == "" && a != "" && a[0] != '-':
			url = a
		default:
			usage()
		}
	}
	if tcpAddr != "" {
		if url != "" || mode != "" {
			usage()
		}
		tcpProbe(tcpAddr)
		return
	}
	if url == "" || (cert == "") != (key == "") {
		usage()
	}
	cfg := &tls.Config{InsecureSkipVerify: insecure}
	if cert != "" {
		pair, err := tls.LoadX509KeyPair(cert, key)
		if err != nil {
			fmt.Fprintln(os.Stderr, "rs-probe:", err)
			os.Exit(1)
		}
		cfg.Certificates = []tls.Certificate{pair}
	}
	c := &http.Client{
		Timeout:       10 * time.Second,
		Transport:     &http.Transport{Proxy: http.ProxyFromEnvironment, TLSClientConfig: cfg},
		CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse },
	}
	r, err := c.Get(url)
	if err != nil {
		if mode == "-code" {
			fmt.Print("000")
		}
		fmt.Fprintln(os.Stderr, "rs-probe:", err)
		os.Exit(1)
	}
	if mode == "-body" {
		io.Copy(os.Stdout, r.Body)
	}
	r.Body.Close()
	if mode == "-code" {
		fmt.Print(r.StatusCode)
		os.Exit(0)
	}
	if r.StatusCode >= 200 && r.StatusCode < 400 {
		os.Exit(0)
	}
	fmt.Fprintln(os.Stderr, "rs-probe: HTTP", r.StatusCode)
	os.Exit(1)
}

func tcpProbe(addr string) {
	in, _ := io.ReadAll(os.Stdin)
	conn, err := net.DialTimeout("tcp", addr, 5*time.Second)
	if err != nil {
		fmt.Fprintln(os.Stderr, "rs-probe:", err)
		os.Exit(1)
	}
	defer conn.Close()
	conn.Write(in)
	conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	io.Copy(os.Stdout, conn)
}
