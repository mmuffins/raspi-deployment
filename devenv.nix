{
  pkgs,
  lib,
  config,
  ...
}:
{
  env.GREET = "Ansible deployment environment";
  languages.ansible.enable = true;

  packages = [
    pkgs.ansible-lint
    pkgs.docker-compose-language-service
    pkgs.hadolint # Dockerfiles linting
  ];

  scripts = {
    deployunraid = {
      description = "Deploy the unraid playbook.";
      exec = ''
        ansible-playbook --inventory ./inventories/production unraid.yml
      '';
    };

    showhelp = {
      description = "Show help for the development environment";
      exec = ''
        bold='\n\e[1m%s\e[0m\n'

        printf "$bold" "Available tasks:"
        devenv tasks list

        printf "$bold" "Available scripts:"
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: value:
            "printf '%-12s %s\\n' ${lib.escapeShellArg name} ${lib.escapeShellArg value.description}"
          ) config.scripts
        )}
      '';
    };
  };

  enterShell = ''
    printf "$bold" "Tool versions:"
    ansible --version

    showhelp
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
