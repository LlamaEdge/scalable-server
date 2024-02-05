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

run_worker $1 '{"messages":[{"role":"system", "content": "You are a high school science teacher. Explain concepts in very simple English."}, {"role":"user", "content": "What is Mercury?"}, {"role":"assistant", "content": "Mercury is like a big rock that floats in the sky. Its too hot to touch and it spins really fast. Thats why we cant see it clearly. But sometimes we can see it in the sky at night when its not too bright. And thats Mercury!"}, {"role":"user", "content": "Hmm, I am thinking about the type that can be found in my home!"}], "model":"llama-2-chat"}' run_worker_1.log &

if [ $2 -gt 1 ]; then
    run_worker $1 '{"messages":[{"role":"system", "content": "You are a helpful, respectful and honest assistant. Always answer as short as possible, while being safe."}, {"role":"user", "content": "Where is the capital of Japan?"}, {"role":"assistant", "content": "The capital of Japan is Tokyo."}, {"role":"user", "content": "Can you help me plan a trip there?"}], "model":"llama-2-chat"}' run_worker_2.log &
fi

if [ $2 -gt 2 ]; then
    run_worker $1 '{"messages":[{"role":"system", "content": "You are a helpful, respectful and honest assistant. Always answer as short as possible, while being safe."}, {"role":"user", "content": "Please write a hello world in Rust and show how to use cargo to build it"}], "model":"llama-2-chat"}' run_worker_3.log &
fi

if [ $2 -gt 3 ]; then
    run_worker $1 '{"messages":[{"role":"system", "content": "You are a helpful, respectful and honest assistant. Always answer as short as possible, while being safe."}, {"role":"user", "content": "Please compare Wasm against Docker"}], "model":"llama-2-chat"}' run_worker_4.log &
fi

if [ $2 -gt 4 ]; then
    run_worker $1 '{"messages":[{"role":"system", "content": "You are a helpful, respectful and honest assistant. Always answer as short as possible, while being safe."}, {"role":"user", "content": "Why are Nvidia GPUs so popular with the machine learning community?"}], "model":"llama-2-chat"}' run_worker_5.log &
fi

