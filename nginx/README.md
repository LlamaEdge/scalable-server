# Install on Ubuntu 22.04

See more details [here](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-22-04)

```
sudo apt install nginx
```

# Start 4 WasmEdge workers

Install WasmEdge.

```
curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- --plugin wasi_nn-ggml
```

Download an LLM.

```
curl -LO https://huggingface.co/second-state/Llama-2-7B-Chat-GGUF/resolve/main/Llama-2-7b-chat-hf-Q5_K_M.gguf
```

Download the API server.

```
curl -LO https://github.com/second-state/LlamaEdge/releases/latest/download/llama-api-server.wasm
curl -LO https://github.com/second-state/chatbot-ui/releases/latest/download/chatbot-ui.tar.gz
tar xzf chatbot-ui.tar.gz
rm chatbot-ui.tar.gz
```

Start the API servers. Each of these is an OpenAI compatible API server. We just start them on different hosts and ports.

```
# worker server #1
nohup wasmedge --dir .:. --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf llama-api-server.wasm --prompt-template llama-2-chat --model-name Llama-2-7b-chat-hf --ctx-size 1024 --socket-addr 127.0.0.1:8080 --log-prompts --log-stat &

# worker server #2
nohup wasmedge --dir .:. --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf llama-api-server.wasm --prompt-template llama-2-chat --model-name Llama-2-7b-chat-hf --ctx-size 1024 --socket-addr 127.0.0.1:8081 --log-prompts --log-stat &

# worker server #3
nohup wasmedge --dir .:. --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf llama-api-server.wasm --prompt-template llama-2-chat --model-name Llama-2-7b-chat-hf --ctx-size 1024 --socket-addr 127.0.0.1:8082 --log-prompts --log-stat &

# worker server #4
nohup wasmedge --dir .:. --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf llama-api-server.wasm --prompt-template llama-2-chat --model-name Llama-2-7b-chat-hf --ctx-size 1024 --socket-addr 127.0.0.1:8083 --log-prompts --log-stat &
```

# Configure the load balancer

Update the NGINX config file for a reverse proxy.

```
sudo vi /etc/nginx/nginx.conf
```

Here is what the file looks like. The load balancer sends at most one connection per upstream worker. Hence there are max 4 concurrent connections.


```
... ...

http {
        ... ...
        ##
        # Virtual Host Configs
        ##
        # include /etc/nginx/conf.d/*.conf;
        # include /etc/nginx/sites-enabled/*;

        upstream llama_api_servers {
            least_conn;
            server 127.0.0.1:8080;
            server 127.0.0.1:8081;
            server 127.0.0.1:8082;
            server 127.0.0.1:8083;
        }

        limit_conn_zone $server_name zone=servers:10m;

        server {
            listen 80;
            server_name localhost;
            limit_conn servers 4;
            location / {
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_pass http://llama_api_servers;
            }
        }
}
```

# Start the load balancer

```
sudo systemctl restart nginx
```

# Start ngrok

```
nohup ngrok http 80 &
```

Go to the ngrok console, and find out the public URL. In this case, it as follows.

```
https://c1b5-13-68-146-155.ngrok-free.app
```

# Test the API server

```
curl -X POST https://c1b5-13-68-146-155.ngrok-free.app/v1/chat/completions -H 'accept: application/json' -H 'Content-Type: application/json' -d '{"messages":[{"role":"system", "content": "You are a high school science teacher. Explain concepts in very simple English."}, {"role":"user", "content": "What is Mercury?"}, {"role":"assistant", "content": "Mercury is like a big rock that floats in the sky. Its too hot to touch and it spins really fast. Thats why we cant see it clearly. But sometimes we can see it in the sky at night when its not too bright. And thats Mercury!"}, {"role":"user", "content": "Hmm, I am thinking about the type that can be found in my home!"}], "model":"llama-2-chat"}'
```

Response is as follows.

```
{
  "id": "6d036a50-40cd-4de3-a119-68960c9561be",
  "object": "chat.completion",
  "created": 1707200177,
  "model": "llama-2-chat",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Ah, I see! Mercury is actually a planet in our solar system, and it's the closest one to the sun. It's a small, rocky world that orbits around the sun every 88 Earth days. That means it moves really fast compared to us, and it can be hard to see with the naked eye because it's so far away. But don't worry, you can still learn more about Mercury and its interesting features!\n\nHere are some fun facts about Mercury:\n\n1. Mercury is the smallest planet in our solar system, with a diameter of only about 4,879 kilometers (3,031 miles). That's less than half the size of Earth!\n2. Mercury is also the closest planet to the sun, with an average distance of about 58 million kilometers (36 million miles). That means it gets really hot on Mercury, with temperatures reaching up"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 125,
    "completion_tokens": 205,
    "total_tokens": 330
  }
}
```

# Start a stress test

The following script starts 4 concurrent threads for continous requests. It should max out the server. Any additional request would result in a 503 error.

```
cd ../scripts
./concurrent-api-requests.sh 'https://094f-13-68-146-155.ngrok-free.app' 4
```

