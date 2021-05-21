packer:
	packer init .
	packer build .

gcr:
	gcloud auth login
	gcloud services enable containerregistry.googleapis.com
	gcloud auth configure-docker

inspec:
	gem install bundler
	bundle install

build:
	docker build -t policy-as-code:latest .

push: build
	docker tag policy-as-code:latest gcr.io/${CLOUDSDK_CORE_PROJECT}/policy-as-code
	docker push gcr.io/${CLOUDSDK_CORE_PROJECT}/policy-as-code