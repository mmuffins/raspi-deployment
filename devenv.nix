{
  pkgs,
  lib,
  config,
  ...
}:
{
  languages.ansible.enable = true;

  packages = [
    pkgs.ansible-lint
    pkgs.docker-compose-language-service
    pkgs.hadolint # Dockerfiles linting
  ];

  # allowUnfree = true;

  enterShell = ''
    echo "Ansible deployment environment"
    ansible --version
  '';

  enterTest = ''
    echo 'test pihole'
    ansible pihole --inventory ./inventories/production -m ping
    ansible-playbook --inventory ./inventories/production pihole.yml --check --diff

    echo 'test unraid'
    ansible unraid --inventory ./inventories/production -m ping
    ansible-playbook --inventory ./inventories/production unraid.yml --check --diff
  '';
}
