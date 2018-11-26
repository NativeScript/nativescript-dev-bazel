"""Rules needed to run a nativescript build under Bazel

This file belongs somewhere else, not inside the project.
"""

def _static_binding_generator(ctx):
  srcdir = ctx.actions.declare_directory("java")

  sbg_deps_file = ctx.actions.declare_file("sbg-java-dependencies.txt")
  ctx.actions.write(output=sbg_deps_file, content="\n".join([
    f.path for f in ctx.files.deps if f.path.endswith(".jar")]))
  sbg_input_file = ctx.actions.declare_file("sbg-input-file.txt")
  # Note, the content of this file needs to be an absolute path, but Bazel bravely
  # resists non-portable actions. So the sbg.sh has a workaround.
  ctx.actions.write(output=sbg_input_file, content="/".join([ctx.label.package, ctx.attr.assets_dir]))
  sbg_output_file = ctx.actions.declare_file("sbg-output-file.txt")
  ctx.actions.write(output=sbg_output_file, content=srcdir.path)

  ctx.actions.run(
    inputs = ctx.files.jsparser + ctx.files.static_binding_generator + ctx.files._node + ctx.files._java + ctx.files.assets + ctx.files.deps + [sbg_deps_file, sbg_input_file, sbg_output_file],
    outputs = [srcdir],
    executable = ctx.executable._sbg,
    arguments = [
      ctx.file._node.dirname,
      ctx.file.jsparser.path,
      sbg_deps_file.path,
      sbg_input_file.path,
      sbg_output_file.path,
      ctx.executable._java.path,
      "-jar",
      ctx.executable.static_binding_generator.path,
    ],
  )

  ctx.actions.run(
    executable = ctx.executable._jar,
    inputs = [srcdir],
    outputs = [ctx.outputs.srcjar],
    arguments = ["-cf", ctx.outputs.srcjar.path, "-C", srcdir.path, "."],
  )

  return [DefaultInfo(files = depset([ctx.outputs.srcjar]))]

COMMON_ATTRS = {
      "_java": attr.label(
          cfg = "host",
          default = Label("@bazel_tools//tools/jdk:java"),
          executable = True,
      ),
      "_jar": attr.label(
          cfg = "host",
          default = Label("@bazel_tools//tools/jdk:jar"),
          executable = True,
      ),
      "deps": attr.label_list(allow_files = True),
}

static_binding_generator = rule(
    implementation = _static_binding_generator,
    attrs = dict(COMMON_ATTRS, **{
      "_sbg": attr.label(
          cfg = "host",
          default = Label("//platforms/android:sbg_sh"),
          executable = True,
      ),
      "_node": attr.label(
          cfg = "host",
          default = Label("@nodejs//:bin/node"), # FIXME: windows??
          executable = True,
          allow_single_file = True,
      ),
      "static_binding_generator": attr.label(
          allow_single_file = True,
          cfg = "host",
          executable = True,
          default = Label("@tns_android//:build-tools/static-binding-generator.jar")),
      "jsparser": attr.label(
          allow_single_file = True,
          default = Label("//platforms/android:modified_jsparser.js")),

      "assets": attr.label_list(allow_files = True),
      "assets_dir": attr.string(mandatory = True),
      "static_java": attr.label(default = Label("@tns_android//:static_binding_java")),
    }),
    outputs = {
      "srcjar": "%{name}.srcjar"
    }
)

def _android_metadata_generator(ctx):

    classes_dir = ctx.actions.declare_directory("classes-tmp")
    outdir = ctx.actions.declare_directory("app/src/main/assets/metadata")
    mdg_deps_file = ctx.actions.declare_file("mdg-java-dependencies.txt")
    ctx.actions.write(output=mdg_deps_file, content="\n".join([
        f.path for f in ctx.files.deps if f.path.endswith(".jar")
    ]))
    mdg_output_file = ctx.actions.declare_file("mdg-output-dir.txt")
    ctx.actions.write(output=mdg_output_file, content=outdir.path)

    ctx.actions.run(
        inputs = ctx.files._java + ctx.files._mdg + ctx.files.deps + ctx.files._android_metadata_generator + ctx.files._jar + [mdg_deps_file, mdg_output_file, ctx.file.resource_jar],
        outputs = [outdir, classes_dir],
        executable = ctx.executable._mdg,
        arguments = [
          ctx.executable._jar.path,
          ctx.file.resource_jar.path,
          classes_dir.path,
          mdg_deps_file.path,
          mdg_output_file.path,
          ctx.executable._java.path,
          "-jar",
          ctx.executable._android_metadata_generator.path,
        ],
    )
    return [DefaultInfo(files = depset([outdir]))]

android_metadata_generator = rule(
    implementation = _android_metadata_generator,
    attrs = dict(COMMON_ATTRS, **{
      # Should allow multiple resource jars
      "resource_jar": attr.label(allow_single_file = True),
      "_android_metadata_generator": attr.label(
          allow_single_file = True,
          cfg = "host",
          executable = True,
          default = Label("@tns_android//:build-tools/android-metadata-generator.jar")),
      "_mdg": attr.label(
          cfg = "host",
          default = Label("//platforms/android:mdg_sh"),
          executable = True,
      ),
    }),
)
