# Auditor

The Auditor is a toolbox based on the awesome [GrumPHP](https://github.com/phpro/grumphp) utility
which allows to run several code quality tools parallel.

Currently, the Auditor supports the following code quality tools:

- [Deptrac](https://github.com/qossmic/deptrac)
- [Phan](https://github.com/phan/phan)
- [PHP CS Fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer)
- [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- [PHP Mess Detector](https://github.com/phpmd/phpmd)
- [PHP Magic Number Detector](https://github.com/povils/phpmnd)
- [PHPStan](https://github.com/phpstan/phpstan)
- [Psalm](https://github.com/vimeo/psalm)

## Usage

To use the Auditor tool container just run the following command in directory with
your `grumphp.yml`:

```
docker run -it --rm -v $PWD:/app --workdir /app nbgrp/auditor:latest
```

It passes your current working directory (`$PWD`) into the Auditor's container and execute
`grumphp run` for all files from this directory with applying settings from `grumphp.yml`.

When using the Auditor with GitHub Actions, you may need to specify the working directory (that
contains `grumphp.yml`) inside a repository. To do this, you can use the `with.working_dir` step
parameter:

```yaml
- name: Audit
  uses: docker://nbgrp/auditor:latest
  with:
    working_dir: inner_directory_with_grumphp_config
```
