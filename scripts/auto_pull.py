import yaml
import subprocess
from collections import Counter
from pathlib import Path


def execute_commands(commands):
    for task in ["clone", "setup"]:
        print(commands[task])
        subprocess.run(commands[task], shell=True)


if __name__ == '__main__':
    source_dir = Path(__file__).parent
    with (source_dir/"target_repos.yaml").open() as f:
        setting_file = yaml.load(f, Loader=yaml.Loader)
    print(setting_file)
    commands_dict = {}
    starting_points = []
    edges = set()
    enter_degree_count = Counter()

    for i, (repo_name, repo_setting) in enumerate(setting_file["repos"].items()):
        commands_dict[repo_name] = {
            "clone": "git clone -b {branch} https://github.com/{repo} {directory}/{repo_name}".format(
                repo=repo_setting["repo"],
                directory=str(source_dir),
                branch=repo_setting["branch"],
                repo_name=repo_name
            ),
            "setup": "pip install {repo_name}".format(
                repo_name=repo_name
            )
        }
        depending_repos = repo_setting.get("depends_on", None)
        if depending_repos is None:
            starting_points.append(repo_name)
        else:
            to_repo = repo_name
            for from_repo in depending_repos:
                edges.add((from_repo, to_repo))
                enter_degree_count[to_repo] += 1

    # リポジトリセットアップタスクを依存関係によってトポロジカルソート
    reserved_commands = []
    while len(starting_points) > 0:
        from_repo = starting_points.pop()
        reserved_commands.append(commands_dict[from_repo])
        for f, t in list(edges):
            if f == from_repo:
                edges.remove((f, t))
                enter_degree_count[t] -= 1
                if enter_degree_count[t] == 0:
                    starting_points.append(t)

    if len(edges) > 0:
        err_message = "Invalid dependency."
        err_message += ", ".join(str(e) for e in edges)
        raise ValueError(err_message)

    for commands in reserved_commands:
        execute_commands(commands)
