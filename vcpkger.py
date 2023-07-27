# This file is just a way to automate this blog post:
#
#     https://devblogs.microsoft.com/cppblog/registries-bring-your-own-libraries-to-vcpkg/
#
# It will create and populate the necessary files using the template laid out
# in the article.

from argparse import ArgumentParser
from pathlib import Path
from tempfile import TemporaryDirectory
import hashlib
import json
import os
import re
import subprocess
import urllib.request

################################################################################
# Utiltities
################################################################################

def safeOpen(path, mode):
    ''' Open `path` for writing, creating any parent directories as needed.'''
    os.makedirs(path.parent, exist_ok=True)
    return open(path, mode)


class jsonOpen:
  def __init__(self, filename):
    self.filename = filename
   
  def __enter__(self):
    try:
      with safeOpen(self.filename, 'r') as file:
        try:
          self.contents = json.load(file)
        except json.JSONDecodeError:
          self.contents = {}
    except FileNotFoundError:
      self.contents = {}
    return self.contents

  def __exit__(self, *args):
    with safeOpen(self.filename, 'w') as file:
      json.dump(self.contents, file, indent=2)



def runWithResult(args):
  result = subprocess.run(args, stdout=subprocess.PIPE)
  return result.stdout.decode('utf-8').strip()


def errorIfMisnamed(portname, errors):
  if portname != portname.lower():
    errors.append(f'{portname} must be lowercase (ex. {portname.lower()})')

def errorIfExists(path, errors):
  if path.exists():
    errors.append(f'{path.name} already exists at {path.relative_to(Path.cwd())}')


def errorIfDoesNotExists(path, errors):
  if not path.exists():
    errors.append(f'Expected file {path.name} at {path.relative_to(Path.cwd())}')


################################################################################
# VcPkg file content management
################################################################################


def createPortFileCMake(filename, github_repo, ref, sha, branch):
  with safeOpen(filename, 'w') as file:
    file.write(f'''vcpkg_from_github(
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


def updatePortFileCMake(filename, github_repo, commit_hash, sha512, branch):
  with safeOpen(filename, 'r') as file:
    contents = file.read()
  # Because there are no nested function calls in CMake script, we can easily
  # extract the call to vcpkg_from_github along with all of its arguments.
  vcpkg_from_github = re.search(r'vcpkg_from_github\([^)]*\)', contents).group(0)
  # Now update the arguments with the new values.
  updates = {
    'REF': commit_hash,
    'SHA512': sha512,
    'HEAD_REF': branch,
  }
  for key, value in updates.items():
    vcpkg_from_github = re.sub(
        f'(\\s){key} \\S*',
        f'\\1{key} {value}',
        vcpkg_from_github)
  # Place the updated call to vcpkg_from_github back in the script and write it
  # back out.
  contents = re.sub(r'vcpkg_from_github\([^)]*\)', vcpkg_from_github, contents)
  with safeOpen(filename, 'w') as file:
    file.write(contents)


def createVcPkgJson(filename, portname, version, description, github_repo):
  with safeOpen(filename, 'w') as file:
    file.write(f'''{{
  "name": "{portname}",
  "version": "{version}",
  "description": "{description}",
  "homepage": "https://github.com/{github_repo}"
}}
''')


def updateVcPkgJson(filename, version):
  with jsonOpen(filename) as jsonContents:
    if jsonContents['version-semver']:
      jsonContents['version-semver'] = version
    else:
      jsonContents['version'] = version

def updateVersionJson(filename, git_tree, version):
  with jsonOpen(filename) as jsonContents:
    versions = jsonContents.setdefault('versions', [])
    versions.append({'git-tree': git_tree, 'version': version})


def generateSHA512(github_repo, commit_hash, github_token):
  url = f'https://github.com/{github_repo}/archive/{commit_hash}.tar.gz'
  headers = {'Authorization': f'Bearer {github_token}'}
  request = urllib.request.Request(url, None, headers)
  hash = hashlib.sha512()
  with urllib.request.urlopen(request) as response:
    hash.update(response.read())
  return hash.hexdigest()


def updateBaseline(filename, portname, baseline, port_version):
  with jsonOpen(filename) as jsonContents:
    default = jsonContents.setdefault('default', {})
    default[portname] = {'baseline': baseline, 'port-version': port_version}


################################################################################
# Main flow
################################################################################

def printSuccess(portname):
  baseline = runWithResult(['git', 'rev-parse', 'HEAD'])
  origin = runWithResult(['git', 'remote', 'get-url', 'origin'])
  if origin.startswith('error:'):
    repository = 'https://github.com/my-username/my-vcpkg-registry'
  elif origin.startswith('git@github.com:'):
    registryUsernameAndProject = origin[len('git@github.com:'):-len('.git')]
    repository = f'https://github.com/{registryUsernameAndProject}'
  else:
    repository = origin
  print(f'''New port successful.
Update your project's vcpkg-configuration.json to look like the following:
{{
  "registries": [
    {{
      "kind": "git",
      "baseline": "{baseline}",
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


def createPort(*,
               registry_path,
               portname,
               commit_hash,
               github_repo,
               description,
               branch,
               version,
               github_token,
               force):
  print(f'Attempting to create port {portname}...')

  portFolder = registry_path/'ports'/portname
  portFileCMake = portFolder/'portfile.cmake'
  vcpkgJson = portFolder/'vcpkg.json'
  versionJson = registry_path/'versions'/f'{portname[0]}-'/f'{portname}.json'

  # Validate that the port doesn't already exist.
  if not force:
    errors = []
    errorIfMisnamed(portname, errors)
    errorIfExists(portFileCMake, errors)
    errorIfExists(vcpkgJson, errors)
    errorIfExists(versionJson, errors)
    if errors:
      return errors

  # Create and update port folder.
  sha512 = generateSHA512(github_repo, commit_hash, github_token)
  createPortFileCMake(portFileCMake, github_repo, commit_hash, sha512, branch)
  createVcPkgJson(vcpkgJson, portname, version, description, github_repo)

  # Prep the dummy commit.
  runWithResult(['git', 'add', f'ports/{portname}'])
  runWithResult(['git', 'commit', '-m', f'[{portname}] new port'])
  baseline = runWithResult(['git', 'rev-parse', f'HEAD:ports/{portname}'])

  # Update the version information.
  updateVersionJson(versionJson, baseline, version)
  baselineJson = registry_path/'versions'/'baseline.json'
  updateBaseline(baselineJson, portname, version, 0)

  # Finish off the commit.
  runWithResult(['git', 'add', 'versions'])
  runWithResult(['git', 'commit', '--amend', '--no-edit'])

  # Finally, display a helpful message.
  printSuccess(portname)


def updatePort(*,
               registry_path,
               portname,
               commit_hash,
               github_repo,
               branch,
               version,
               port_version,
               github_token,
               force):

  portFolder = registry_path/'ports'/portname
  portFileCMake = portFolder/'portfile.cmake'
  vcpkgJson = portFolder/'vcpkg.json'
  versionJson = registry_path/'versions'/f'{portname[0]}-'/f'{portname}.json'

  # Ensure files exist
  if not force:
    errors = []
    errorIfMisnamed(portname, errors)
    errorIfDoesNotExists(portFileCMake, errors)
    errorIfDoesNotExists(vcpkgJson, errors)
    errorIfDoesNotExists(versionJson, errors)
    if errors:
      return errors

  # Update port folder.
  sha512 = generateSHA512(github_repo, commit_hash, github_token)
  updatePortFileCMake(portFileCMake, github_repo, commit_hash, sha512, branch)
  updateVcPkgJson(vcpkgJson, version)

  # Prep the dummy commit.
  runWithResult(['git', 'add', f'ports/{portname}'])
  if int(port_version) > 0:
    port_version_message = f", port version {port_version}"
  else:
    port_version_message = ""
  runWithResult(['git', 'commit', '-m', f'[{portname}] Updated port to v{version}{port_version_message}'])
  baseline = runWithResult(['git', 'rev-parse', f'HEAD:ports/{portname}'])

  # Update the version information.
  updateVersionJson(versionJson, baseline, version)
  baselineJson = registry_path/'versions'/'baseline.json'
  updateBaseline(baselineJson, portname, version, port_version)

  # Finish off the commit.
  runWithResult(['git', 'add', 'versions'])
  runWithResult(['git', 'commit', '--amend', '--no-edit'])

  # Finally, display a helpful message.
  printSuccess(portname)

def printRegistries():
  baseline = runWithResult(['git', 'rev-parse', 'HEAD'])
  origin = runWithResult(['git', 'remote', 'get-url', 'origin'])
  if origin.startswith('error:'):
    repository = 'https://github.com/my-username/my-vcpkg-registry'
  elif origin.startswith('git@github.com:'):
    registryUsernameAndProject = origin[len('git@github.com:'):-len('.git')]
    repository = f'https://github.com/{registryUsernameAndProject}'
  else:
    repository = origin

  portnameList = []
  for entry in os.scandir('ports'):
    portnameList.append(f'"{entry.name}"')
  sep = ',\n        '
  portnames = sep.join(portnameList)

  print(f'''
{{
  "registries": [
    {{
      "kind": "git",
      "baseline": "{baseline}",
      "repository": "{repository}",
      "packages": [
        {portnames}
      ]
    }}
  ]
}}
''')



################################################################################
# Entry point
################################################################################


def parseArguments():
  usage = "usage: %prog [options] arg"
  parser = ArgumentParser(
    prog='%(prog)s',
    description=usage,
    epilog='')
  parser.add_argument(
      'action',
      choices=['create', 'update', 'list'],
      help='Whether to create or update a port')
  parser.add_argument(
      'portname',
      nargs='?',
      help='The name of the port to update or create')
  parser.add_argument(
      '--registry-path',
      required=False,
      default=Path.cwd(),
      help='Bypass errors that can be skipped')
  parser.add_argument(
      '--commit-hash',
      help='The hash to update to')
  parser.add_argument(
      '--github-repo',
      required=False,
      help='The github username and project of the port (e.g.: \'example/myproject\')')
  parser.add_argument(
      '--description',
      required=False,
      help='A description of the port')
  parser.add_argument(
      '--branch',
      required=False,
      default='main',
      help='A description of the port')
  parser.add_argument(
      '--version',
      required=False,
      default='1.0.0',
      help='A description of the port')
  parser.add_argument(
      '--port-version',
      required=False,
      default=0,
      type=int,
      help='A description of the port')
  parser.add_argument(
      '--github-token',
      required=False,
      help='Bypass errors that can be skipped')
  parser.add_argument(
      '--force',
      action='store_true',
      required=False,
      help='Bypass errors that can be skipped')

  args = parser.parse_args()
  # parser.print_help()
  return args


def main():
  args = parseArguments()
  if args.action == 'create':
    errors = createPort(
        registry_path = args.registry_path,
        portname =      args.portname,
        commit_hash =   args.commit_hash,
        github_repo =   args.github_repo,
        description =   args.description,
        branch =        args.branch,
        version =       args.version,
        github_token =  args.github_token,
        force =         args.force)
  elif args.action == 'update':
    errors = updatePort(
        registry_path = args.registry_path,
        portname =      args.portname,
        commit_hash =   args.commit_hash,
        github_repo =   args.github_repo,
        branch =        args.branch,
        version =       args.version,
        port_version =  args.port_version,
        github_token =  args.github_token,
        force =         args.force)
  elif args.action == 'list':
    errors = printRegistries()
  if errors:
    print(f'The following {"error" if len(errors)==1 else "errors"} occured:')
    for error in errors:
      print(f' *\t{error}')
    print('Resolve these errors and retry.')



if __name__ == "__main__":
  main()
