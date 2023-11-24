build.builder:
	docker build -t centos-rpm-builder .

run.builder: build.builder
	docker run -v ./executables:/opt/executables -it centos-rpm-builder /bin/bash
