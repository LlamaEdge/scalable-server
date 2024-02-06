# Creating a scalable LlamaEdge API server

[LlamaEdge](https://www.secondstate.io/LlamaEdge/) is an app development platform. Use it to create your own "Assistants" APIs or apps that tie together multiple custom fine-tuned models, specialized multimodal models, document ingest algorithms, vector databases, search algorithms, prompt assembly algoithms, and external SaaS API calls.

For simple use cases, it also provides an OpenAI compatible API server out of the box through the [llama-api-server](https://github.com/second-state/LlamaEdge/tree/main/api-server) project, which allows it to serve as [a backend in frameworks like LangChain](https://github.com/langchain-ai/langchain/pull/14787). The key benefit of LlamaEdge over other OpenAI compatible servers is its portability

* The same binary app runs on a variety of different CPU and GPU devices from server to edge. 
* The app can select from alternative inference frameworks (e.g., llama.cpp or MLX, plain CUDA or TensorRT) through runtime configuration, as opposed to code changes, to optimize the server performance for the specific use case. 
* The app itself is already sandboxed and ready for Kubernetes without the hassle of special containers, shims and binary builds.

LlamaEdge makes it possible to offer rich API services from a network of heterogeneous devices with a vaiety of CPUs, GPUs, NPUs, and OSes. In this repo, we will showcase how to run a scalable inference server with multiple LlamaEdge workers on the backend serving concurrent API users. We provide instructions, configuration files, and testing scripts for running your own LlamaEdge API server in production. The server will support multiple concurrent inference workers distributed across

* A GPU with a large VRAM (e.g., an Nvidia Jetson 64GB device can run 6 concurrent workers for 7B models)
* Multiple GPUs on a server (e.g., a GPU server could have 4x H100 GPUs, supportng 30+ concurrent workers for 7B models) 
* Multiple physical servers

We will use the default [llama-api-server](https://github.com/second-state/LlamaEdge/tree/main/api-server) as example. The approach is to create an Nginx reverse proxy that load balances between `llama-api-server` workers. Each worker has an unqiue `ipaddr:port` combination.

* [Setup and stress testing instructions](nginx/README.md) for Nginx on Ubuntu 22.04
* [Bash script](scripts/) for stress testing

## Benchmarks

| Provider      | Processor     | Inference RAM | LLM (llama2-chat) | Context length | LlamaEdge workers | Concurrent API clients | Prompt processing tokens / sec | Text generation tokens /s | 
| ------------- | ------------- | ------------- | ----------------- | -------------- | ----------------- | ---------------------- | ------------------------------ | ------------------------- |
| Azure NC4as T4 v3  | Nvidia Tesla T4  | 16GB | 7B Q5_k_m | 1024 | 2 | 4 | 152 | 17 |
| Jetson Orin 64GB  | Nvidia AGX  | 64GB | 7B Q5_k_m | 1024 | 10 | 20 | TBD | TBD |
| Jetson Orin 64GB  | Nvidia AGX  | 64GB | 13B Q5_k_m | 1024 | 6 | 12 | TBD | TBD |
| Macbook  | Apple M2  | 16GB | 7B Q5_k_m | 1024 | 2 | 4 | TBD | TBD |
| OpenBayes | Nvidia A100 | 80GB | 7B Q5_k_m | 1024 | 12 | 24 | TBD | TBD |
| OpenBayes | Nvidia A100 | 80GB | 13B Q5_k_m | 1024 | 6 | 12 | TBD | TBD |
| OpenBayes | Nvidia A6000 x4 | 192GB | 7B Q5_k_m | 1024 | 32 | 64 | TBD | TBD |
| OpenBayes | Nvidia A6000 x4 | 192GB | 13B Q5_k_m | 1024 | 16 | 32 | TBD | TBD |
| OpenBayes | Nvidia RTX 4090 x4 | 96GB | 7B Q5_k_m | 1024 | 16 | 32 | TBD | TBD |
| OpenBayes | Nvidia RTX 3090 x4 | 96GB | 7B Q5_k_m | 1024 | 16 | 32 | TBD | TBD |

