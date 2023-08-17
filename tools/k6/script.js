import http from 'k6/http'

import {check, sleep} from 'k6'

// this function describe a client
// the client will fetch an url and sleep for 0.1 seconds
// and start over again
// so if you have 10 clients that sleep 0.1 seconds and test duration is 10 seconds
// then you'll have 1000 requests (1 client does 10rps, 10 clients do 100rps, => 1000 requests per 10 seconds)
export default function () {
    let res = http.get('http://localhost:8000/messages')
    check(res, {'success': (r) => r.status === 200})
    sleep(0.1)
}
