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
}
