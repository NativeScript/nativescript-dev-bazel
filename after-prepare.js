const path = require('path');

module.exports = function ($logger, $fs, hookArgs) {
	const projectData = hookArgs.projectData;
	const projectDir = projectData.projectDir;
	const bazelFilesService = new BazelFilesService($fs, $logger);
	bazelFilesService.setupBazelFiles(projectDir);
}

class BazelFilesService {
	constructor($fs, $logger) {
		this.$fs = $fs;
		this.$logger = $logger;
		this.originalBazelFilesDir = path.join(__dirname, "bazel-files");
	}

	setupBazelFiles(projectDir) {
		const pathToProjectWorkspace = path.join(projectDir, "WORKSPACE");
		const originalWorkspaceFile = path.join(this.originalBazelFilesDir, "WORKSPACE");
		this.ensureCorrectBazelFileExist(pathToProjectWorkspace, originalWorkspaceFile);

		const platformsDirPath = path.join(projectDir, "platforms");
		const pathToPlatformsBuildFile = path.join(platformsDirPath, "BUILD");
		const originalPlatformsBuildFile = path.join(this.originalBazelFilesDir, "BUILD_platforms_dir");
		this.ensureCorrectBazelFileExist(pathToPlatformsBuildFile, originalPlatformsBuildFile);

		const androidPath = path.join(platformsDirPath, "android");

		const pathToAndroidBuildFile = path.join(androidPath, "BUILD.bazel");
		const originalAndroidBuildFile = path.join(this.originalBazelFilesDir, "BUILD_android_dir");
		this.ensureCorrectBazelFileExist(pathToAndroidBuildFile, originalAndroidBuildFile);

		const pathToNativeScriptBazelFile = path.join(androidPath, "nativescript.bzl");
		const originalNativeScriptBazelFile = path.join(this.originalBazelFilesDir, "nativescript.bzl");
		this.ensureCorrectBazelFileExist(pathToNativeScriptBazelFile, originalNativeScriptBazelFile);

		const pathToMdgFile = path.join(androidPath, "mdg.sh");
		const originalMdgFile = path.join(this.originalBazelFilesDir, "mdg.sh");
		this.ensureCorrectBazelFileExist(pathToMdgFile, originalMdgFile);

		const pathToSbgFile = path.join(androidPath, "sbg.sh");
		const originalSbgFile = path.join(this.originalBazelFilesDir, "sbg.sh");
		this.ensureCorrectBazelFileExist(pathToSbgFile, originalSbgFile);
	}

	ensureCorrectBazelFileExist(bazelFileExpectedLocationPath, baseBazelFile) {
		const expectedContent = this.getBaseBazelFileContent(baseBazelFile);
		
		if (this.$fs.exists(bazelFileExpectedLocationPath)) {
			const content = this.$fs.readText(bazelFileExpectedLocationPath);
	
			if (content !== expectedContent) {
				this.$logger.warn(`Files ${bazelFileExpectedLocationPath} and ${baseBazelFile} differ. Bazel build may not work as expected.`);
			}
		} else {
			this.$fs.writeFile(bazelFileExpectedLocationPath, expectedContent);
			if (path.extname(bazelFileExpectedLocationPath) === ".sh") {
				this.$fs.chmod(bazelFileExpectedLocationPath, "500");
			}
		}
	}

	getBaseBazelFileContent(baseBazelFile) {
		const fileName = path.basename(baseBazelFile);
		let content = this.$fs.readText(baseBazelFile);
		if (fileName === "WORKSPACE") {
			content = content.replace(/__ANDROID_HOME__/g, process.env.ANDROID_HOME);
		}

		return content;
	}
}