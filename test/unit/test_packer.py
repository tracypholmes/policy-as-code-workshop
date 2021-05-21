import hcl2
import pytest


@pytest.fixture
def image_config():
    with open('docker.pkr.hcl', 'r') as file:
        return hcl2.load(file)



# Tests the container source image for Ubuntu
# It's ok if your function is a little longer so
# someone can understand your intent!
def test_container_source_image_for_ubuntu_base(image_config):
    base_image = image_config['source'][0]['docker']['pac']['image'][0]
    assert base_image == 'ubuntu'


# Tests that fake-service uses a specific version.
# Good to include if you want to be declarative about
# potentially patched images!
def test_shell_provisioner_for_fake_service_version(image_config):
    fake_service_version = image_config['build'][0]['provisioner'][0]['shell']['environment_vars'][0][0]
    assert '0.21.0' in fake_service_version
