# Ollama

Ollama allows you to run LLM models locally. 
It's kinda like "Docker for LLMs". I've successfully tried running it on
ec2 g5.xlarge instance with GPU and "Deep Learning Base OSS Nvidia Driver GPU AMI", it works pretty fast.

On 8-core cpu (t2.xlarge) it works significantly slower (couple of words per second), 
but it can still be used interactively, and it eats all of the CPUs (750% usage)

Install:

```shell
curl https://ollama.ai/install.sh | sh
```

Run (it will download llama3 8b, that's about 5gb):

llama3 8b has 8 billion parameters, it's actually a lighter version of the real deal
that has 70 billion parameters, I didn't dare to run it.
```shell
ollama run llama3
```

You can chat with it in the terminal.

It also starts http server, so you can curl with you model:

```shell
curl http://localhost:11434/api/generate -d '{
  "model": "llama3",
  "prompt": "Who are you?",
  "stream": false
}'
{"model":"llama3","created_at":"2024-06-08T15:16:15.333878793Z","response":"I am LLaMA, a large language model ..."}
```


Install python bindings for ollama
```shell
pip install ollama
```

Interact with the model:
```python
import ollama
response = ollama.chat(model="llama3", messages=[
  {"role": "user", "content": "Who was born in 1890 and has the same last name as author of 'Communist Manifesto'?"}
])
print(response["message"]["content"])
# the answer is totally wrong
'''The answer is Ernestine Friedmann, who was born in 1890. The author you're referring to is Karl Marx, who wrote "The Communist Manifesto" (originally titled "Manifesto of the Communist Party") along with Friedrich Engels. So, Ernestine Friedmann and Karl Marx share the same last name, although they were not related'''
```

We can also get embeddings from it:
```python
ollama.embeddings(model='llama3', prompt='who are you?')
```