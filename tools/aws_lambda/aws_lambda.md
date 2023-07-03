## AWS Lambda

AWS Lambda can execute functions.
You are not aware of VMs, containers, or whatever tech is underneath. 
You just execute functions.

Let's create a lambda function in nodejs.
Go to AWS console, type "Lambda" in Search. Press "Create function".
Use hello-world blueprint.

The function will look something like that:
```js
console.log('Loading function');

exports.handler = async (event, context) => {
    //console.log('Received event:', JSON.stringify(event, null, 2));
    console.log('value1 =', event.key1);
    console.log('value2 =', event.key2);
    console.log('value3 =', event.key3);
    return event.key1;  // Echo back the first key value
    // throw new Error('Something went wrong');
};
```

Then manually create an event in the AWS interface and press "Test".


Lambda will be executed.
You can look at logs
```
Test Event Name
MyEvent

Response
"value1"

Function Logs
2023-07-03T09:35:38.878Z	undefined	INFO	Loading function
START RequestId: 4cb3d9d9-fb96-4a1e-a777-0ea434c478ca Version: $LATEST
2023-07-03T09:35:38.883Z	4cb3d9d9-fb96-4a1e-a777-0ea434c478ca	INFO	value1 = value1
2023-07-03T09:35:38.883Z	4cb3d9d9-fb96-4a1e-a777-0ea434c478ca	INFO	value2 = value2
2023-07-03T09:35:38.883Z	4cb3d9d9-fb96-4a1e-a777-0ea434c478ca	INFO	value3 = value3
END RequestId: 4cb3d9d9-fb96-4a1e-a777-0ea434c478ca
REPORT RequestId: 4cb3d9d9-fb96-4a1e-a777-0ea434c478ca	Duration: 13.80 ms	Billed Duration: 14 ms	Memory Size: 128 MB	Max Memory Used: 57 MB	Init Duration: 177.39 ms

Request ID
4cb3d9d9-fb96-4a1e-a777-0ea434c478ca
```

Lambda can react to the events from AWS services: s3/api gateway/dynamodb/etc