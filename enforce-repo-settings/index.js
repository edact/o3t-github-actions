const core = require("@actions/core");
const github = require("@actions/github");
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
      ...repos.map(async (r) => repoService.enforceRepoSettings(r)),
      ...repos.map(async (r) => repoService.enforceRepoBranchProtection(r)),
      ...repos.map(async (r) => repoService.enableRepoDependabot(r)),
    ]);
  })();
} catch (err) {
  console.error(err);
}
