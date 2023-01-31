# This file is just a way to automate this blog post:
#
#     https://devblogs.microsoft.com/cppblog/registries-bring-your-own-libraries-to-vcpkg/
#
# It will create and populate the necessary files using the template laid out
# in the article.

from argparse import ArgumentParser
from os import makedirs
from os import path
from pathlib import Path
from tempfile import TemporaryDirectory
import hashlib
import json
import subprocess
import urllib.request


def safeOpen(path, mode):
    ''' Open "path" for writing, creating any parent directories as needed.'''
    makedirs(path.parent, exist_ok=True)
    return open(path, mode)


def runWithResult(args):
  result = subprocess.run(args, stdout=subprocess.PIPE)
  return result.stdout.decode('utf-8').strip()


def errorIfExists(path, errors):
  if path.exists():
    errors.append(f'{path.name} already exists at {path.relative_to(Path.cwd())}')


def createPortFileCMake(filename, github_repo, ref, sha, branch):
  with safeOpen(filename, 'w') as out:
    out.write(f'''vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO {github_repo}
  REF {ref}
  SHA512 {sha}
  HEAD_REF 'main'
)

vcpkg_configure_cmake(
  SOURCE_PATH "${{SOURCE_PATH}}"
  PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE "${{CURRENT_PACKAGES_DIR}}/debug/include")

file(
  INSTALL "${{SOURCE_PATH}}/LICENSE"
  DESTINATION "${{CURRENT_PACKAGES_DIR}}/share/${{PORT}}"
  RENAME copyright)
''')


def createVcPkgJson(filename, portname, description, github_repo):
  with safeOpen(filename, 'w') as out:
    out.write(f'''{{
  "name": "{portname}",
  "version": "1.0.0",
  "description": "{description}",
  "homepage": "https://github.com/{github_repo}"
}}
''')


def createVersionJson(filename, gitTree):
  with safeOpen(filename, 'w') as out:
    out.write(f'''{{
  "versions": [
    {{
      "version": "1.0.0",
      "git-tree": "{gitTree}"
    }}
  ]
}}
''')


def generateSHA512(github_repo, commit_hash, github_token):
  url = f'https://github.com/{github_repo}/archive/{commit_hash}.tar.gz'
  headers = {'Authorization': f'Bearer {github_token}'}
  request = urllib.request.Request(url, None, headers)
  hash = hashlib.sha512()
  with urllib.request.urlopen(request) as response:
    hash.update(response.read())
  return hash.hexdigest()


def updateBaseline(filename, portname, baseline, portVersion):
  with safeOpen(filename, 'r') as file:
    try:
      jsonContents = json.load(file)
    except json.JSONDecodeError:
      jsonContents = {}
  
  default = jsonContents.setdefault('default', {})
  default[portname] = {'baseline': baseline, 'port-version': portVersion}

  with safeOpen(filename, 'w') as file:
    json.dump(jsonContents, file, indent=2)


def printSuccess(gitTree, repository, portname):
  print(f'''New port successful.
Update your project's vcpkg-configuration.json to look like the following:
{{
  "registries": [
    {{
      "kind": "git",
      "baseline": "{gitTree}",
      "repository": "{repository}",
      "packages": [
        ...
        "{portname}"
        ...
      ]
    }}
  ]
}}
''')


def createPort(registry, portname, commit_hash, github_repo, description, branch, github_token, force):
  print(f'Attempting to create port {portname}...')

  portFolder = registry/'ports'/portname
  portFileCMake = portFolder/'portfile.cmake'
  vcpkgJson = portFolder/'vcpkg.json'
  versionJson = registry/'versions'/f'{portname[0]}-'/f'{portname}.json'

  # Validate that the port doesn't already exist.
  if not force:
    errors = []
    errorIfExists(portFileCMake, errors)
    errorIfExists(vcpkgJson, errors)
    errorIfExists(versionJson, errors)
    if errors:
      return errors

  # Create and update port folder.

  sha512 = generateSHA512(github_repo, commit_hash, github_token)
  createPortFileCMake(portFileCMake, github_repo, commit_hash, sha512, branch)
  createVcPkgJson(vcpkgJson, portname, description, github_repo)

  # Prep the dummy commit.
  runWithResult(['git', 'add', f'ports/{portname}'])
  runWithResult(['git', 'commit', '-m', f'[{portname}] new port'])
  gitTree = runWithResult(['git', 'rev-parse', f'HEAD:ports/{portname}'])

  # Update the version information.
  createVersionJson(versionJson, gitTree)
  baselineJson = registry/'versions'/'baseline.json'
  updateBaseline(baselineJson, portname, '1.0.0', 0)

  # Finish off the commit.
  runWithResult(['git', 'add', 'versions'])
  runWithResult(['git', 'commit', '--amend', '--no-edit'])

  # Finally, display a helpful message.
  gitTree = runWithResult(['git', 'rev-parse', 'HEAD'])
  origin = runWithResult(['git', 'remote', 'get-url', 'origin'])

  if origin.startswith('error:'):
    repository = 'https://github.com/my-username/my-vcpkg-registry'
  elif origin.startswith('git@github.com:'):
    registryUsernameAndProject = origin[len('git@github.com:'):-len('.git')]
    repository = f'https://github.com/{registryUsernameAndProject}'
  else:
    repository = origin
  printSuccess(gitTree, repository, portname)


def parseArguments():
  usage = "usage: %prog [options] arg"
  parser = ArgumentParser(
    prog='%(prog)s',
    description=usage,
    epilog='')
  parser.add_argument(
      'action',
      choices=['create', 'update'],
      help='Whether to create or update a port')
  parser.add_argument(
      'portname',
      help='The name of the port to update or create')
  parser.add_argument(
      '--commit-hash',
      help='The hash to update to')
  parser.add_argument(
      '--github-repo',
      required=False,
      help='The github username and project of the port (e.g.: \'example/myproject\')')
  parser.add_argument(
      '--branch',
      required=False,
      default='main',
      help='A description of the port')
  parser.add_argument(
      '--description',
      required=False,
      help='A description of the port')
  parser.add_argument(
      '--force',
      action='store_true',
      required=False,
      help='Bypass errors that can be skipped')
  parser.add_argument(
      '--vcpkg-registry',
      required=False,
      default=Path.cwd(),
      help='Bypass errors that can be skipped')
  parser.add_argument(
      '--github-token',
      required=False,
      help='Bypass errors that can be skipped')

  args = parser.parse_args()
  # parser.print_help()
  return args


def main():
  args = parseArguments()
  if args.action == 'create':
    errors = createPort(
        args.vcpkg_registry,
        args.portname,
        args.commit_hash,
        args.github_repo,
        args.description,
        args.branch,
        args.github_token,
        args.force)
    if errors:
      print(f'The following {"error" if len(errors)==1 else "errors"} occured:')
      for error in errors:
        print(f' *\t{error}')
      print('Resolve these errors and retry.')

  # elif args.action == 'update':
  #   updatePort(args.portname, args.hash)


if __name__ == "__main__":
  main()
