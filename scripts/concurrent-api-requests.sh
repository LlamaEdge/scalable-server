#!/bin/bash

run_worker () {
    while true; do
	current_time=$(date)
	printf "$current_time : " >> $3
        c="curl -X POST $1/v1/chat/completions -H 'accept: application/json' -H 'Content-Type: application/json' -d '$2' >> $3 2> /dev/null"
	eval $c
	printf "\n" >> $3
    done
}

prompts=("{\"messages\":[{\"role\":\"system\", \"content\": \"You are a high school science teacher. Explain concepts in very simple English.\"}, {\"role\":\"user\", \"content\": \"What is Mercury?\"}, {\"role\":\"assistant\", \"content\": \"Mercury is like a big rock that floats in the sky. Its too hot to touch and it spins really fast. Thats why we cant see it clearly. But sometimes we can see it in the sky at night when its not too bright. And thats Mercury!\"}, {\"role\":\"user\", \"content\": \"Hmm, I am thinking about the type that can be found in my home!\"}], \"model\":\"llama-2-chat\"}" "{\"messages\":[{\"role\":\"system\", \"content\": \"You are a helpful, respectful and honest assistant. Always answer as short as possible, while being safe.\"}, {\"role\":\"user\", \"content\": \"Where is the capital of Japan?\"}, {\"role\":\"assistant\", \"content\": \"The capital of Japan is Tokyo.\"}, {\"role\":\"user\", \"content\": \"Can you help me plan a trip there?\"}], \"model\":\"llama-2-chat\"}" "{\"messages\":[{\"role\":\"system\", \"content\": \"You are a helpful, respectful and honest assistant. Always answer as short as possible, while being safe.\"}, {\"role\":\"user\", \"content\": \"Please compare Wasm against Docker\"}], \"model\":\"llama-2-chat\"}" "{\"messages\":[{\"role\":\"system\", \"content\": \"You are a helpful, respectful and honest assistant. Always answer as short as possible, while being safe.\"}, {\"role\":\"user\", \"content\": \"Why are Nvidia GPUs so popular with the machine learning community?\"}], \"model\":\"llama-2-chat\"}")

for ((i=0; i<$2; i++)); do
    selected=$((i % 4))
    run_worker $1 "${prompts[$selected]}" run_worker_$i.log &
done
