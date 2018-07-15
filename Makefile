RESEARCH_DIR = $(HOME)/research
DOCKERFILE_DIR = $(RESEARCH_DIR)/docker
DOCKERHUB_USR = atbell013
IMAGE = $(DOCKERHUB_USR)/mylab
REIKI_SRC_DIR = $(RESEARCH_DIR)/reikiset
REIKI_TAR_DIR = /root/home/reikiset
RES_SRC_DIR = $(RESEARCH_DIR)/results
RES_TAR_DIR = /root/home/results
N4J_SRC_DIR = $(RESEARCH_DIR)/neo4j
N4J_TAR_DIR = /var/lib/neo4j

build:
	docker build -t $(IMAGE) ${DOCKERFILE_DIR}

push:
	docker push $(IMAGE)

run:
	docker run -p 7474:7474 -p 7687:7687 -p 8888:8888 -p 6006:6006 -v $(REIKI_SRC_DIR):$(REIKI_TAR_DIR) -v $(RES_SRC_DIR):$(RES_TAR_DIR) -v$(N4J_SRC_DIR):$(N4J_TAR_DIR) -it $(IMAGE) /bin/bash
