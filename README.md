# LlamaEdge-proxy

In this repo, we will provide instructions, configuration files, and testing scripts for running your own LlamaEdge API server in production. The server will support multiple concurrent inference workers distributed across

* A GPU with a large VRAM (e.g., an Nvidia Jetson 64GB device can run 6 concurrent workers for 7B models)
* Multiple GPUs on a server (e.g., a GPU server could have 4x H100 GPUs, supportng 30+ concurrent workers for 7B models) 
* Multiple physical servers

We will use the default [llama-api-server](https://github.com/second-state/LlamaEdge/tree/main/api-server) as example. The approach is to create an Nginx reverse proxy that load balances between `llama-api-server` workers. Each worker has an unqiue `ipaddr:port` combination.

* [Setup and stress testing instructions](nginx/README.md) for Nginx on Ubuntu 22.04
* [Bash script](scripts/) for stress testing

> LlamaEdge is an app development platform. While you can use our ready-made lightweight and portable API server, you will probably use the LlamaEdge to create your own "Assistants" APIs or apps that tie together multiple custom fine-tuned models, specialized multimodal models, document ingest algorithms, vector databases, search algorithms, prompt assembly algoithms, and external SaaS API calls for knowledge or actions. 
