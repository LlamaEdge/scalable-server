# Scalable LlamaEdge API server

[LlamaEdge](https://www.secondstate.io/LlamaEdge/) is an app development platform. Use it to create your own `Assistants` APIs or apps that tie together multiple custom fine-tuned models, specialized multimodal models, document ingest algorithms, vector databases, search algorithms, prompt assembly algoithms, and external SaaS API calls. The LlamaEdge apps are **portable even across GPUs** -- you can develop and test your app on a Macbook and deploy it on an Nvidia device. 

> To learn more about how to create your own LLM inference apps using Rust and LlamaEdge, [check out our examples](https://github.com/second-state/WasmEdge-WASINN-examples/tree/master/wasmedge-ggml).

For simple use cases, it also provides an OpenAI compatible API server out of the box through the [llama-api-server](https://github.com/second-state/LlamaEdge/tree/main/api-server) project, which allows it to serve as [a backend in frameworks like LangChain](https://github.com/langchain-ai/langchain/pull/14787). The key benefits of LlamaEdge over other OpenAI compatible servers are easy deployment and management.

* *Lightweight and simple.* There is no complex Python dependenices. The total package with all dependencies is less than 30MB, as opposed to 5GB for a PyTorch container.
* *Easy to setup.* A simple installer for a variety of different CPU and GPU devices from server to edge. 
* *Selection of backends.* The server can switch between inference frameworks (e.g., llama.cpp or MLX, plain CUDA or TensorRT) through *runtime configuration* to optimize performance for the specific use case. 
* *Cloud-native orchestration.* The server itself is already sandboxed and ready for Kubernetes without the hassle of special containers, shims and binary builds.

LlamaEdge makes it possible to offer rich API services from a network of heterogeneous devices with a vaiety of CPUs, GPUs, NPUs, and OSes. In this repo, we will showcase how to run a scalable inference server with multiple LlamaEdge workers on the backend serving concurrent API users. We provide instructions, configuration files, and testing scripts for running your own LlamaEdge API server in production. The server will support multiple concurrent inference workers distributed across

* A GPU with a large VRAM (e.g., an Nvidia Jetson 64GB device can run 10 concurrent workers for 7B models)
* Multiple GPUs on a server (e.g., a GPU server could have 4x H100 GPUs, supportng 50+ concurrent workers for 7B models) 
* Multiple physical servers

We will use the default [llama-api-server](https://github.com/second-state/LlamaEdge/tree/main/api-server) as example. The approach is to create an Nginx reverse proxy that load balances between `llama-api-server` workers. Each worker has an unqiue `ipaddr:port` combination.

* [Setup and stress testing instructions](nginx/README.md) for Nginx on Ubuntu 22.04
* [Bash script](scripts/) for stress testing

## Benchmarks

All models are `llama2-chat` with `Q5_K_M` quantization.

* pp - Prompt processing tokens / sec for each worker at max concurrency
* tg - Text generation tokens / sec for each worker at max concurrency
* Throughput - Max text generation tokens /sec for a single worker

| Provider      | Processor     | RAM | LLM | LlamaEdge workers | Concurrent API clients | pp | tg | Throughput |
| ------------- | ------------- | --- | --- | ----------------- | ---------------------- | -- | -- | ---------- |
| Azure NC4as T4 v3  | Nvidia Tesla T4  | 16GB | 7B | 2 | 4 | 152 | 17 | 34 |
| AWS g5.xlarge  | Nvidia A10G  | 24GB | 7B | 4 | 8 | ... | 17 | 71 |
| OpenBayes | Nvidia RTX 4090 | 24GB | 7B | 4 | 8 | 667 | 32 | 129 |
| OpenBayes | Nvidia RTX 4090 | 24GB | 13B | 2 | 4 | 666 | 31 | 76 |
| Jetson Orin 64GB  | Nvidia AGX  | 64GB | 7B | 10 | 20 | ... | ... | ... |
| Jetson Orin 64GB  | Nvidia AGX  | 64GB | 13B | 6 | 12 | ... | ... | ... |
| Macbook  | Apple M2  | 16GB | 7B | 2 | 4 | ... | ... | ... |
| Macbook  | Apple M2  | 32GB | 7B | 6 | 12 | ... | ... | ... |
| Macbook  | Apple M2  | 32GB | 13B | 3 | 6 | ... | ... | ... |
| Macbook  | Apple M3  | 64GB | 7B | 10 | 20 | ... | ... | ... |
| Macbook  | Apple M3  | 64GB | 13B | 6 | 12 | ... | ... | ... |
| OpenBayes | Nvidia A100 | 80GB | 7B | 12 | 24 | ... | ... | ... |
| OpenBayes | Nvidia A100 | 80GB | 13B | 6 | 12 | ... | ... | ... |
| OpenBayes | Nvidia A6000 x4 | 192GB | 7B | 32 | 64 | ... | ... | ... |
| OpenBayes | Nvidia A6000 x4 | 192GB | 13B | 16 | 32 | ... | ... | ... |
| OpenBayes | Nvidia RTX 4090 x4 | 96GB | 7B | 16 | 32 | ... | ... | ... |
| OpenBayes | Nvidia RTX 3090 x4 | 96GB | 7B | 16 | 32 | ... | ... | ... |

