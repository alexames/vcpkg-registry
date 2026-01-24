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



def runWithResult(args, check=True):
  result = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  if check and result.returncode != 0:
    cmd = ' '.join(args)
    stderr = result.stderr.decode('utf-8').strip()
    raise RuntimeError(f'Command failed: {cmd}\n{stderr}')
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


def createPortFileCMake(filename, github_repo, ref, sha, branch, portname):
  with safeOpen(filename, 'w') as file:
    file.write(f'''vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO {github_repo}
  REF {ref}
  SHA512 {sha}
  HEAD_REF {branch}
)

vcpkg_cmake_configure(
  SOURCE_PATH "${{SOURCE_PATH}}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/{portname})

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


def createVcPkgJson(filename, portname, version, description, github_repo, port_version=0):
  port_version_line = f'\n  "port-version": {port_version},' if port_version > 0 else ''
  with safeOpen(filename, 'w') as file:
    file.write(f'''{{
  "name": "{portname}",
  "version": "{version}",
  "description": "{description}",
  "homepage": "https://github.com/{github_repo}",{port_version_line}
  "dependencies": [
    {{
      "name": "vcpkg-cmake",
      "host": true
    }},
    {{
      "name": "vcpkg-cmake-config",
      "host": true
    }}
  ]
}}
''')


def updateVcPkgJson(filename, version, port_version=0):
  with jsonOpen(filename) as jsonContents:
    if 'version-semver' in jsonContents:
      jsonContents['version-semver'] = version
    else:
      jsonContents['version'] = version
    # Update or remove port-version as needed
    if port_version > 0:
      jsonContents['port-version'] = port_version
    elif 'port-version' in jsonContents:
      del jsonContents['port-version']


def usesSemver(filename):
  '''Check if a vcpkg.json file uses version-semver.'''
  try:
    with open(filename, 'r') as file:
      contents = json.load(file)
      return 'version-semver' in contents
  except (FileNotFoundError, json.JSONDecodeError):
    return False

def updateVersionJson(filename, git_tree, version, port_version=0, use_semver=False):
  with jsonOpen(filename) as jsonContents:
    versions = jsonContents.setdefault('versions', [])
    version_key = 'version-semver' if use_semver else 'version'
    entry = {'git-tree': git_tree, version_key: version}
    if port_version > 0:
      entry['port-version'] = port_version
    versions.insert(0, entry)


def getNextPortVersion(versionJson, version):
  '''Find the highest port-version for a given version and return the next one.

  If no entries exist for this version, returns 0.
  If entries exist, returns the highest port-version + 1.
  '''
  try:
    with open(versionJson, 'r') as file:
      contents = json.load(file)
  except (FileNotFoundError, json.JSONDecodeError):
    return 0

  versions = contents.get('versions', [])
  max_port_version = -1

  for entry in versions:
    # Check both 'version' and 'version-semver' keys
    entry_version = entry.get('version') or entry.get('version-semver')
    if entry_version == version:
      port_version = entry.get('port-version', 0)
      max_port_version = max(max_port_version, port_version)

  # If we found matching versions, return the next port version
  # If no matches found (max_port_version == -1), this is a new version, return 0
  return max_port_version + 1 if max_port_version >= 0 else 0


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
  origin = runWithResult(['git', 'remote', 'get-url', 'origin'], check=False)
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
  createPortFileCMake(portFileCMake, github_repo, commit_hash, sha512, branch, portname)
  createVcPkgJson(vcpkgJson, portname, version, description, github_repo)

  input("Check port file and make any necessary edits.")

  # Prep the dummy commit.
  runWithResult(['git', 'add', f'ports/{portname}'])
  runWithResult(['git', 'commit', '-m', f'[{portname}] New port'])
  baseline = runWithResult(['git', 'rev-parse', f'HEAD:ports/{portname}'])

  # Update the version information.
  updateVersionJson(versionJson, baseline, version, port_version=0, use_semver=usesSemver(vcpkgJson))
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
               description,
               branch,
               version,
               github_token,
               force):

  portFolder = registry_path/'ports'/portname
  portFileCMake = portFolder/'portfile.cmake'
  vcpkgJson = portFolder/'vcpkg.json'
  versionJson = registry_path/'versions'/f'{portname[0]}-'/f'{portname}.json'

  # Ensure required files exist (portfile.cmake and vcpkg.json are optional - will be regenerated if missing)
  if not force:
    errors = []
    errorIfMisnamed(portname, errors)
    errorIfDoesNotExists(versionJson, errors)
    if errors:
      return errors

  # Derive the port version from existing entries
  port_version = getNextPortVersion(versionJson, version)
  print(f'Derived port version: {port_version}')

  # Update port folder.
  sha512 = generateSHA512(github_repo, commit_hash, github_token)
  if portFileCMake.exists():
    updatePortFileCMake(portFileCMake, github_repo, commit_hash, sha512, branch)
  else:
    createPortFileCMake(portFileCMake, github_repo, commit_hash, sha512, branch, portname)
  if vcpkgJson.exists():
    updateVcPkgJson(vcpkgJson, version, port_version)
  else:
    createVcPkgJson(vcpkgJson, portname, version, description or 'None', github_repo, port_version)

  input("Check port file and make any necessary edits.")

  # Prep the dummy commit.
  runWithResult(['git', 'add', f'ports/{portname}'])
  if int(port_version) > 0:
    port_version_message = f", port version {port_version}"
  else:
    port_version_message = ""
  runWithResult(['git', 'commit', '-m', f'[{portname}] Updated port to version {version}{port_version_message}'])
  baseline = runWithResult(['git', 'rev-parse', f'HEAD:ports/{portname}'])

  # Update the version information.
  updateVersionJson(versionJson, baseline, version, port_version=port_version, use_semver=usesSemver(vcpkgJson))
  baselineJson = registry_path/'versions'/'baseline.json'
  updateBaseline(baselineJson, portname, version, port_version)

  # Finish off the commit.
  runWithResult(['git', 'add', 'versions'])
  runWithResult(['git', 'commit', '--amend', '--no-edit'])

  # Finally, display a helpful message.
  printSuccess(portname)

def printRegistries():
  baseline = runWithResult(['git', 'rev-parse', 'HEAD'])
  origin = runWithResult(['git', 'remote', 'get-url', 'origin'], check=False)
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
  return None  # No errors



################################################################################
# Entry point
################################################################################


def getCommitHash(repo):
  return runWithResult(['git', '-C', repo, 'rev-parse', 'HEAD'])

def getCurrentBranch(repo):
  return runWithResult(['git', '-C', repo, 'rev-parse', '--abbrev-ref', 'HEAD'])

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
      type=Path,
      help='Path to the vcpkg registry (default: current directory)')
  parser.add_argument(
      '--commit-hash',
      required=False,
      help='The hash to update to')
  parser.add_argument(
      '--local-repo',
      required=False,
      help='The local repo to get the hash and branch from')
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
      help='The git branch to track (default: main)')
  parser.add_argument(
      '--version',
      required=False,
      default='1.0.0',
      help='The version of the port (default: 1.0.0)')
  parser.add_argument(
      '--github-token',
      required=False,
      help='GitHub token for API authentication')
  parser.add_argument(
      '--force',
      action='store_true',
      required=False,
      help='Bypass validation errors and force the operation')

  args = parser.parse_args()
  # parser.print_help()
  return args


def main():
  args = parseArguments()

  # Validate required arguments for create/update actions
  if args.action in ('create', 'update'):
    missing = []
    if not args.portname:
      missing.append('--portname (or positional argument)')
    if not args.github_repo:
      missing.append('--github-repo')
    if not args.commit_hash and not args.local_repo:
      missing.append('--commit-hash or --local-repo')
    if args.action == 'create' and not args.description:
      missing.append('--description')
    if missing:
      print(f'Missing required arguments for {args.action}: {", ".join(missing)}')
      return

  commit_hash = args.commit_hash or getCommitHash(args.local_repo)
  branch = args.commit_hash or getCurrentBranch(args.local_repo)
  if args.action == 'create':
    errors = createPort(
        registry_path = args.registry_path,
        portname =      args.portname,
        commit_hash =   commit_hash,
        github_repo =   args.github_repo,
        description =   args.description,
        branch =        branch,
        version =       args.version,
        github_token =  args.github_token,
        force =         args.force)
  elif args.action == 'update':
    errors = updatePort(
        registry_path = args.registry_path,
        portname =      args.portname,
        commit_hash =   commit_hash,
        github_repo =   args.github_repo,
        description =   args.description,
        branch =        branch,
        version =       args.version,
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
