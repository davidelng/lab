# Local LLM Stack Setup

A Docker-based setup for running local LLMs with PostgreSQL vector storage on your laptop.

## Quick Start

### 1. Create Directory Structure
```bash
mkdir llm-stack
cd llm-stack

# Create subdirectories
mkdir -p init-scripts nginx/conf.d nginx/ssl \
         prometheus grafana/provisioning/datasources \
         grafana/provisioning/dashboards
```

### 2. Add Files
- Save the docker-compose.yml file
- Save the SQL init script to `init-scripts/01-init.sql`
- Save nginx.conf to `nginx/nginx.conf`
- Save llm-stack.conf to `nginx/conf.d/llm-stack.conf`
- Save prometheus.yml to `prometheus/prometheus.yml`
- Save prometheus datasource config to `grafana/provisioning/datasources/prometheus.yml`
- Save dashboard provider config to `grafana/provisioning/dashboards/default.yml`
- Save the .env template file as `.env`

### 3. Configure Environment
```bash
# Edit .env file with your values
nano .env

# Generate a secure secret key for WEBUI_SECRET_KEY
openssl rand -hex 32

# Important: Add .env to .gitignore if using git
echo ".env" >> .gitignore
```

### 4. Start the Stack
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 4. Pull a Model
```bash
# Pull a small, efficient model (recommended for older hardware)
docker exec -it llm-ollama ollama pull llama3.2:3b

# Or try phi3 (very efficient)
docker exec -it llm-ollama ollama pull phi3:mini

# List available models
docker exec -it llm-ollama ollama list
```

### 5. Access Services
All services are now accessible through Nginx reverse proxy:

**Via Nginx (recommended):**
- **Main Chat Interface**: http://localhost/
- **Ollama API**: http://localhost/ollama/
- **pgAdmin**: http://localhost/pgadmin/
- **Grafana**: http://localhost/grafana/ (default: admin / from .env)
- **Prometheus**: http://localhost/prometheus/
- **Health Check**: http://localhost/health

**Direct Access (if needed for debugging):**
- PostgreSQL: localhost:5432

**Custom domain (optional):**
Add to your `/etc/hosts` file:
```
127.0.0.1 llm.local
```
Then access via http://llm.local/chat

## Service Details

### Nginx Reverse Proxy
- **Port**: 80 (HTTP), 443 (HTTPS - requires SSL setup)
- Routes all services through clean URLs
- Handles WebSocket connections for chat
- Configured for LLM streaming responses
- Gzip compression enabled
- Security headers included

### PostgreSQL
- **User**: Configured in .env (POSTGRES_USER)
- **Password**: Configured in .env (POSTGRES_PASSWORD)
- **Database**: Configured in .env (POSTGRES_DB)
- **Port**: Configured in .env (POSTGRES_PORT)
- **Extension**: pgvector enabled
- Pre-created tables for embeddings, conversations, and knowledge base

### Ollama
- Stores models in `ollama_data` volume
- API available on port 11434
- Compatible with OpenAI API format

### Grafana + Prometheus Stack
- **Grafana**: Visualization and dashboards
- **Prometheus**: Metrics collection and storage
- **Node Exporter**: System metrics (CPU, RAM, disk, network)
- **cAdvisor**: Docker container metrics
- Pre-configured to monitor your entire LLM stack

**What you can monitor:**
- Container resource usage (CPU, memory per container)
- System resources (overall laptop health)
- Ollama response times and throughput
- PostgreSQL connections and query performance
- Network traffic between services

**Getting started with Grafana:**
1. Access http://localhost/grafana/
2. Login with credentials from .env file
3. Prometheus datasource is auto-configured
4. Import dashboards or create your own

### Open WebUI
- Modern chat interface
- Multi-model support
- Can store data in PostgreSQL or local volume

## Database Schema

### `embeddings`
Stores vector embeddings for RAG (Retrieval Augmented Generation)
- `content`: Original text
- `embedding`: Vector representation (384 dimensions)
- `metadata`: Flexible JSON storage

### `conversations`
Conversation history tracking
- Groups messages by `conversation_id`
- Tracks tokens and model used

### `knowledge_base`
Your personal knowledge repository
- Full-text and vector searchable
- Supports tagging and categorization

## Future Expansions

### Adding MCP Servers
Add to docker-compose.yml:
```yaml
  mcp-filesystem:
    build: ./mcp-servers/filesystem
    container_name: llm-mcp-fs
    volumes:
      - ./shared-data:/data
    networks:
      - llm-network
```

### Adding Monitoring (Grafana Stack)
```yaml
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
```

### Adding More Tools
- **Redis**: For caching and fast lookups
- **Minio**: S3-compatible object storage
- **Nginx**: Reverse proxy for all services
- **Jupyter**: For data analysis and model experimentation

## Useful Commands

```bash
# Stop everything
docker-compose down

# Stop and remove volumes (DELETES DATA!)
docker-compose down -v

# Rebuild a specific service
docker-compose up -d --build ollama

# Access Ollama CLI
docker exec -it llm-ollama ollama run llama3.2:3b

# Backup PostgreSQL
docker exec llm-postgres pg_dump -U llm_user llm_db > backup.sql

# Access PostgreSQL CLI
docker exec -it llm-postgres psql -U llm_user -d llm_db

# Check resource usage
docker stats
```

## Next Steps

1. Start with the basic chat in Open WebUI
2. Experiment with different models
3. Learn to query PostgreSQL for vector search
4. Build your first MCP server
5. Add monitoring with Grafana
6. Create custom tools for your specific needs

## Security Notes

This setup is for local network only

## SSL/HTTPS Setup (Optional)

To enable HTTPS:

1. **Generate self-signed certificate (for development):**
```bash
mkdir -p nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/CN=llm.local"
```

2. **Uncomment HTTPS server block** in `nginx/conf.d/llm-stack.conf`

3. **Restart Nginx:**
```bash
docker-compose restart nginx
```

4. **Access via HTTPS:**
- https://localhost/chat
- https://llm.local/chat (if using hosts file)

For production, use Let's Encrypt with Certbot instead of self-signed certificates.
