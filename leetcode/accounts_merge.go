package leetcode

/*
21:44 started reading
21:47 started thinking
21:51 just do dfs
21:51 started writing
22:14 started checking
22:20 checked
22:23 bunch of go-related errors
22:24 TLE, updated frontier after continue
22:25 wrong answer
22:41 wrong bfs, set visited in the wrong time


*/

import "sort"

type Emails = []string

func accountsMerge(accounts [][]string) [][]string {
	graph := buildGraph(accounts)
	nameByEmail := buildNameByEmail(accounts)
	visited := map[string]bool{}
	frontier := buildEmails(nameByEmail)
	result := [][]string{}
	for len(frontier) > 0 {
		email := frontier[0]
		frontier = frontier[1:len(frontier)]
		if visited[email] {
			continue
		}
		name := nameByEmail[email]
		emails := bfs(email, graph, visited)
		account := []string{name}
		sort.Strings(emails)
		account = append(account, emails...)
		result = append(result, account)
	}
	return result
}

func buildGraph(accounts [][]string) map[string]Emails {
	graph := map[string]Emails{}
	for _, acc := range accounts {
		emails := acc[1:len(acc)]
		for i, email := range emails {
			if i-1 >= 0 {
				graph[email] = append(graph[email], emails[i-1])
			}
			if i+1 < len(emails) {
				graph[email] = append(graph[email], emails[i+1])
			}
		}
	}
	return graph
}

func buildNameByEmail(accounts [][]string) map[string]string {
	nameByEmail := map[string]string{}
	for _, acc := range accounts {
		name := acc[0]
		for _, email := range acc[1:len(acc)] {
			nameByEmail[email] = name
		}
	}
	return nameByEmail
}

func buildEmails(nameByEmail map[string]string) Emails {
	emails := Emails{}
	for email, _ := range nameByEmail {
		emails = append(emails, email)
	}
	return emails
}

func convertToResult(emailsByName map[string]Emails) [][]string {
	result := [][]string{}
	for name, emails := range emailsByName {
		sort.Strings(emails)
		account := []string{name}
		account = append(account, emails...)
		result = append(result, account)
	}
	return result
}

func bfs(email string, graph map[string]Emails, visited map[string]bool) Emails {
	emails := Emails{}
	frontier := []string{email}
	for len(frontier) > 0 {
		email := frontier[0]
		frontier = frontier[1:len(frontier)]
		if visited[email] {
			continue
		}
		visited[email] = true
		emails = append(emails, email)
		for _, neighbor := range graph[email] {
			if !visited[neighbor] {
				frontier = append(frontier, neighbor)
			}
		}
	}
	return emails
}
