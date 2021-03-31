const { Octokit } = require("@octokit/core");

module.exports = class RepoService {
  constructor({ token }) {
    this.octokit = new Octokit({
      auth: token,
    });
  }

  async getRepos() {
    const { data: repos } = await this.octokit.request(
      "GET /orgs/{org}/repos?per_page={limit}",
      {
        org: "edact",
        limit: 100,
      }
    );

    return repos.filter((r) => {
      return Object.values({
        isRelevant: r.name.includes("3t-"),
        notArchived: !r.archived,
        // branch: r.default_branch != "main",
        // size: r.size < 10,
      }).every((condition) => condition == true);
    });
  }

  async enforceRepoSettings(repo) {
    await this.octokit.request("PATCH /repos/{owner}/{repo}", {
      owner: repo.owner.login,
      repo: repo.name,
      has_issues: false,
      has_projects: false,
      has_wiki: false,
      allow_squash_merge: true,
      allow_merge_commit: false,
      allow_rebase_merge: false,
      delete_branch_on_merge: true,
      allow_auto_merge: true,
    });
  }

  async enableRepoDependabot(repo) {
    await this.octokit.request(
      "PUT /repos/{owner}/{repo}/vulnerability-alerts",
      {
        owner: repo.owner.login,
        repo: repo.name,
        mediaType: {
          previews: ["dorian"],
        },
      }
    );

    await this.octokit.request(
      "PUT /repos/{owner}/{repo}/automated-security-fixes",
      {
        owner: repo.owner.login,
        repo: repo.name,
        mediaType: {
          previews: ["london"],
        },
      }
    );
  }

  async enforceRepoBranchProtection(repo) {
    const { data: branch } = await this.octokit.request(
      "GET /repos/{owner}/{repo}/branches/{branch}",
      {
        owner: repo.owner.login,
        repo: repo.name,
        branch: repo.default_branch,
      }
    );

    await this.octokit.request(
      "PUT /repos/{owner}/{repo}/branches/{branch}/protection",
      {
        mediaType: {
          previews: ["luke-cage"],
        },
        owner: repo.owner.login,
        repo: repo.name,
        branch: repo.default_branch,
        required_status_checks: {
          strict: true,
          contexts: branch.protection
            ? branch.protection.required_status_checks.contexts
            : [],
        },
        enforce_admins: true,
        required_pull_request_reviews: {
          dismissal_restrictions: {},
          dismiss_stale_reviews: true,
          require_code_owner_reviews: false,
          required_approving_review_count: 1,
        },
        restrictions: null,
      }
    );
  }

  async rerunDependabotWorkflowRuns(repo) {
    const { data } = await this.octokit.request(
      "GET /repos/{owner}/{repo}/actions/runs",
      {
        owner: repo.owner.login,
        repo: repo.name,
      }
    );

    const runs = data.workflow_runs.filter(
      (run) =>
        run.head_commit.author.name === "dependabot[bot]" &&
        run.conclusion === "failure"
    );

    runs.map((run) =>
      this.octokit.request(
        "POST /repos/{owner}/{repo}/actions/runs/{run_id}/rerun",
        {
          owner: repo.owner.login,
          repo: repo.name,
          run_id: run.id,
        }
      )
    );
  }
};
