const core = require("@actions/core");
// const github = require("@actions/github");
const RepoService = require('./repoService');

/*
Ideen:
 - prüfen, ob für einzelne Repos Secrets gesetzt sind
 - Workflow-Dispatch für alle Repos ermöglichen
 - prüfen, ob der default_branch === main ist
 - prüfen, ob es leere Repos gibt
*/

try {
  (async () => {
    const repoService = new RepoService({
      token: core.getInput("api-token"),
    });

    const repos = await repoService.getRepos();

    console.log(">>", repos.length, "Repos");

    await Promise.all([
      // TODO: enable once auto merging can be configured
      // ...repos.map((r) => repoService.enforceRepoSettings(r)),
      ...repos.map((r) => repoService.enforceRepoBranchProtection(r)),
      ...repos.map((r) => repoService.enableRepoDependabot(r)),
      ...repos.map((r) => repoService.rerunDependabotWorkflowRuns(r)),
    ]);
  })();
} catch (err) {
  console.error(err);
}
