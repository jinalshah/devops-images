/* ==========================================================================
   DevOps Images – interactive widgets
   Each widget is a plain <div data-di-...> placeholder in the Markdown. The
   theme swaps pages without a full reload (navigation.instant), so widgets
   are (re)mounted on every page change via the theme's document$ observable.
   ========================================================================== */

(function () {
  "use strict";

  /* ---------- Shared data ------------------------------------------------ */

  var IMAGES = ["all-devops", "aws-devops", "gcp-devops"];

  var REGISTRIES = {
    ghcr: "ghcr.io/jinalshah/devops/images/",
    gitlab: "registry.gitlab.com/jinal-shah/devops/images/",
    dockerhub: "js01/"
  };

  // i = images the tool ships in: a = all-devops, w = aws-devops, g = gcp-devops
  var BASE = "awg";
  var TOOLS = [
    // Infrastructure as code
    { n: "Terraform", d: "Infrastructure as code (via tfswitch)", c: "iac", i: BASE, cmd: "terraform version" },
    { n: "tfswitch", d: "Switch Terraform versions", c: "iac", i: BASE, cmd: "tfswitch --latest" },
    { n: "Terragrunt", d: "DRY Terraform wrapper", c: "iac", i: BASE, cmd: "terragrunt --version" },
    { n: "TFLint", d: "Terraform linter", c: "iac", i: BASE, cmd: "tflint --version" },
    { n: "Packer", d: "Machine image builder", c: "iac", i: BASE, cmd: "packer version" },
    { n: "Ansible", d: "Configuration management", c: "iac", i: BASE, cmd: "ansible --version" },
    { n: "ansible-lint", d: "Ansible playbook linter", c: "iac", i: BASE, cmd: "ansible-lint --version" },
    // Kubernetes
    { n: "kubectl", d: "Kubernetes CLI (latest stable)", c: "k8s", i: BASE, cmd: "kubectl version --client" },
    { n: "Helm", d: "Kubernetes package manager", c: "k8s", i: BASE, cmd: "helm version" },
    { n: "k9s", d: "Kubernetes terminal UI", c: "k8s", i: BASE, cmd: "k9s version" },
    // Cloud
    { n: "AWS CLI v2", d: "Amazon Web Services CLI", c: "cloud", i: "aw", cmd: "aws --version" },
    { n: "Session Manager plugin", d: "SSM sessions without SSH", c: "cloud", i: "aw", cmd: "session-manager-plugin --version" },
    { n: "boto3", d: "AWS SDK for Python", c: "cloud", i: "aw", cmd: "python3 -c 'import boto3'" },
    { n: "cfn-lint", d: "CloudFormation linter", c: "cloud", i: "aw", cmd: "cfn-lint --version" },
    { n: "s3cmd", d: "S3 command-line client", c: "cloud", i: "aw", cmd: "s3cmd --version" },
    { n: "gcloud", d: "Google Cloud CLI (+ beta)", c: "cloud", i: "ag", cmd: "gcloud --version" },
    { n: "gsutil / bq", d: "Cloud Storage and BigQuery CLIs", c: "cloud", i: "ag", cmd: "gsutil version" },
    { n: "docker-credential-gcr", d: "Artifact / Container Registry auth", c: "cloud", i: "ag", cmd: "docker-credential-gcr version" },
    { n: "gke-gcloud-auth-plugin", d: "kubectl auth for GKE clusters", c: "cloud", i: "ag", cmd: "gke-gcloud-auth-plugin --version" },
    // AI assistants
    { n: "Claude Code", d: "Anthropic's coding agent", c: "ai", i: BASE, cmd: "claude --version" },
    { n: "Codex CLI", d: "OpenAI's coding agent", c: "ai", i: BASE, cmd: "codex --version" },
    { n: "Copilot CLI", d: "GitHub's coding agent", c: "ai", i: BASE, cmd: "copilot --version" },
    { n: "Antigravity CLI", d: "Google's coding agent (agy)", c: "ai", i: BASE, cmd: "agy --version" },
    // Security and quality
    { n: "Trivy", d: "Vulnerability and IaC scanner", c: "dev", i: BASE, cmd: "trivy --version" },
    { n: "pre-commit", d: "Git hook framework", c: "dev", i: BASE, cmd: "pre-commit --version" },
    // Developer tooling
    { n: "Python 3.14", d: "With pip", c: "dev", i: BASE, cmd: "python3 --version" },
    { n: "Node.js LTS", d: "With npm and npx", c: "dev", i: BASE, cmd: "node --version" },
    { n: "Git", d: "Version control", c: "dev", i: BASE, cmd: "git --version" },
    { n: "GitHub CLI", d: "gh for PRs, issues and Actions", c: "dev", i: BASE, cmd: "gh --version" },
    { n: "ghorg", d: "Clone a whole GitHub org", c: "dev", i: BASE, cmd: "ghorg version" },
    { n: "Task", d: "Taskfile runner (go-task)", c: "dev", i: BASE, cmd: "task --version" },
    { n: "Zensical", d: "Static site generator for docs", c: "dev", i: BASE, cmd: "zensical --version" },
    { n: "MkDocs Material", d: "Docs site generator", c: "dev", i: BASE, cmd: "mkdocs --version" },
    // Databases
    { n: "mongosh", d: "MongoDB 8.0 shell", c: "data", i: BASE, cmd: "mongosh --version" },
    { n: "psql", d: "PostgreSQL 17 client", c: "data", i: BASE, cmd: "psql --version" },
    { n: "mysql", d: "MySQL 8.4 client", c: "data", i: BASE, cmd: "mysql --version" },
    // Network and shell
    { n: "dig / nslookup", d: "DNS lookups (bind-utils)", c: "net", i: BASE, cmd: "dig -v" },
    { n: "nmap / ncat", d: "Port scanning and netcat", c: "net", i: BASE, cmd: "nmap --version" },
    { n: "curl / wget", d: "HTTP clients", c: "net", i: BASE, cmd: "curl --version" },
    { n: "lftp", d: "FTP / SFTP client", c: "net", i: BASE, cmd: "lftp --version" },
    { n: "telnet", d: "Raw TCP checks", c: "net", i: BASE, cmd: "which telnet" },
    { n: "jq", d: "JSON processor", c: "net", i: BASE, cmd: "jq --version" },
    { n: "Zsh + Oh My Zsh", d: "Default shell (also bash, fish)", c: "net", i: BASE, cmd: "zsh --version" }
  ];

  var CATEGORIES = {
    all: "Everything",
    iac: "Infrastructure as code",
    k8s: "Kubernetes",
    cloud: "Cloud CLIs",
    ai: "AI assistants",
    dev: "Dev & quality",
    data: "Databases",
    net: "Network & shell"
  };

  var MOUNTS = [
    { id: "project", label: "Project folder", arg: "-v \"$PWD\":/srv -w /srv", on: true },
    { id: "ssh", label: "SSH keys", arg: "-v ~/.ssh:/root/.ssh:ro", on: true },
    { id: "git", label: "Git config", arg: "-v ~/.gitconfig:/root/.gitconfig:ro", on: false },
    { id: "aws", label: "AWS credentials", arg: "-v ~/.aws:/root/.aws", on: true, only: "aws" },
    { id: "gcloud", label: "gcloud config", arg: "-v ~/.config/gcloud:/root/.config/gcloud", on: true, only: "gcp" },
    { id: "kube", label: "kubeconfig", arg: "-v ~/.kube:/root/.kube", on: false },
    { id: "claude", label: "Claude Code", arg: "-v ~/.claude:/root/.claude", on: false },
    { id: "codex", label: "Codex CLI", arg: "-v ~/.codex:/root/.codex", on: false },
    { id: "copilot", label: "Copilot CLI", arg: "-v ~/.copilot:/root/.copilot", on: false },
    { id: "agy", label: "Antigravity CLI", arg: "-v ~/.gemini:/root/.gemini", on: false }
  ];

  /* ---------- Helpers ---------------------------------------------------- */

  function el(tag, attrs, children) {
    var node = document.createElement(tag);
    Object.keys(attrs || {}).forEach(function (key) {
      if (key === "text") node.textContent = attrs[key];
      else if (key === "html") node.innerHTML = attrs[key];
      else node.setAttribute(key, attrs[key]);
    });
    (children || []).forEach(function (child) {
      if (child) node.appendChild(child);
    });
    return node;
  }

  function chip(label, pressed) {
    return el("button", { type: "button", class: "di-chip", "aria-pressed": pressed ? "true" : "false", text: label });
  }

  function commandBlock(text) {
    var pre = el("pre", { text: text });
    var button = el("button", { type: "button", class: "di-copy", text: "Copy" });
    button.addEventListener("click", function () {
      var done = function () {
        button.textContent = "Copied!";
        setTimeout(function () { button.textContent = "Copy"; }, 1500);
      };
      if (navigator.clipboard) navigator.clipboard.writeText(pre.textContent).then(done, function () {});
    });
    return el("div", { class: "di-command" }, [pre, button]);
  }

  function imageSupports(image, mount) {
    if (!mount.only) return true;
    if (image === "all-devops") return true;
    return image.indexOf(mount.only) === 0;
  }

  function runCommand(opts) {
    var lines = ["docker run -it"];
    lines.push(opts.persist ? "--name devops-work" : "--rm");
    MOUNTS.forEach(function (m) {
      if (opts.mounts[m.id] && imageSupports(opts.image, m)) lines.push(m.arg);
    });
    var ref = REGISTRIES[opts.registry || "ghcr"] + opts.image + ":" + (opts.tag || "latest");
    lines.push(ref + (opts.shell && opts.shell !== "zsh" ? " " + opts.shell : ""));
    return lines.join(" \\\n  ");
  }

  /* ---------- Widget: image picker -------------------------------------- */

  var PICKER_QUESTIONS = [
    { key: "cloud", q: "Which cloud do you work with?", a: [["aws", "AWS"], ["gcp", "Google Cloud"], ["both", "Both"], ["none", "Neither / not sure"]] },
    { key: "where", q: "Where will it run?", a: [["laptop", "My laptop"], ["ci", "CI/CD pipeline"], ["both", "Both"]] },
    { key: "size", q: "What matters more?", a: [["small", "Smallest download"], ["everything", "Every tool, just in case"]] }
  ];

  function pickImage(ans) {
    if (ans.cloud === "aws") return ans.size === "everything" ? "all-devops" : "aws-devops";
    if (ans.cloud === "gcp") return ans.size === "everything" ? "all-devops" : "gcp-devops";
    return "all-devops";
  }

  var PICKER_REASONS = {
    "all-devops": "Both cloud CLIs (AWS CLI v2 + Session Manager and gcloud) on top of the shared toolkit. The one-stop option for multi-cloud and platform teams.",
    "aws-devops": "AWS CLI v2, Session Manager plugin, boto3 and cfn-lint on top of the shared toolkit, without the Google Cloud SDK.",
    "gcp-devops": "The Google Cloud CLI (with beta components, docker-credential-gcr and the GKE auth plugin) on top of the shared toolkit, without the AWS tooling."
  };

  function mountPicker(root) {
    var answers = {};
    root.innerHTML = "";
    root.appendChild(el("h3", { text: "Find your image in three clicks" }));
    var result = el("div");

    PICKER_QUESTIONS.forEach(function (question) {
      var options = el("div", { class: "di-options", role: "group", "aria-label": question.q });
      question.a.forEach(function (pair) {
        var button = chip(pair[1], false);
        button.addEventListener("click", function () {
          answers[question.key] = pair[0];
          options.querySelectorAll(".di-chip").forEach(function (b) {
            b.setAttribute("aria-pressed", b === button ? "true" : "false");
          });
          render();
        });
        options.appendChild(button);
      });
      root.appendChild(el("div", { class: "di-question" }, [el("p", { text: question.q }), options]));
    });
    root.appendChild(result);

    function render() {
      result.innerHTML = "";
      if (Object.keys(answers).length < PICKER_QUESTIONS.length) return;
      var image = pickImage(answers);
      var mounts = { project: true, ssh: true, aws: true, gcloud: true };
      var command = runCommand({ image: image, mounts: mounts, persist: answers.where === "laptop" });
      if (answers.where !== "laptop") {
        command += "\n\n# In CI, pin a per-commit tag (or a @sha256 digest), for example:\n# " + REGISTRIES.ghcr + image + ":1.0.<short-sha>";
      }
      var box = el("div", { class: "di-result", "data-image": image }, [
        el("h4", { html: "Use <span class=\"di-pill di-pill--" + image.split("-")[0] + "\">" + image + "</span>" }),
        el("p", { text: PICKER_REASONS[image] }),
        commandBlock(command)
      ]);
      result.appendChild(box);
    }
  }

  /* ---------- Widget: docker run builder -------------------------------- */

  function mountBuilder(root) {
    var state = { image: "all-devops", registry: "ghcr", tag: "latest", shell: "zsh", persist: false, mounts: {} };
    MOUNTS.forEach(function (m) { state.mounts[m.id] = m.on; });

    root.innerHTML = "";
    root.appendChild(el("h3", { text: "Build your docker run command" }));

    function select(label, key, values) {
      var s = el("select", { "aria-label": label });
      values.forEach(function (v) {
        var o = el("option", { value: v[0], text: v[1] });
        if (state[key] === v[0]) o.selected = true;
        s.appendChild(o);
      });
      s.addEventListener("change", function () { state[key] = s.value; render(); });
      return el("div", { class: "di-field" }, [el("label", { text: label }), s]);
    }

    root.appendChild(select("Image", "image", IMAGES.map(function (i) { return [i, i]; })));
    root.appendChild(select("Registry", "registry", [["ghcr", "GitHub (ghcr.io)"], ["gitlab", "GitLab"], ["dockerhub", "Docker Hub"]]));
    root.appendChild(select("Shell", "shell", [["zsh", "zsh (default)"], ["bash", "bash"], ["fish", "fish"]]));

    var mountChips = el("div", { class: "di-options" });
    root.appendChild(el("div", { class: "di-question" }, [el("p", { text: "Mount into the container" }), mountChips]));

    var persistChip = chip("Keep the container after exit", false);
    persistChip.addEventListener("click", function () {
      state.persist = !state.persist;
      persistChip.setAttribute("aria-pressed", state.persist ? "true" : "false");
      render();
    });
    root.appendChild(el("div", { class: "di-options" }, [persistChip]));

    var out = el("div");
    root.appendChild(out);

    function render() {
      mountChips.innerHTML = "";
      MOUNTS.forEach(function (m) {
        if (!imageSupports(state.image, m)) return;
        var c = chip(m.label, state.mounts[m.id]);
        c.addEventListener("click", function () {
          state.mounts[m.id] = !state.mounts[m.id];
          render();
        });
        mountChips.appendChild(c);
      });
      out.innerHTML = "";
      out.appendChild(commandBlock(runCommand(state)));
    }
    render();
  }

  /* ---------- Widget: tool explorer ------------------------------------- */

  function mountTools(root) {
    var state = { q: "", cat: "all", image: "any" };
    root.innerHTML = "";
    root.appendChild(el("h3", { text: "Explore every tool" }));

    var search = el("input", { type: "search", placeholder: "Search tools, e.g. helm, sql, agent…", "aria-label": "Search tools" });
    search.addEventListener("input", function () { state.q = search.value.toLowerCase(); render(); });
    root.appendChild(el("div", { class: "di-field" }, [search]));

    function chipRow(label, key, entries) {
      var row = el("div", { class: "di-options", role: "group", "aria-label": label });
      entries.forEach(function (e) {
        var c = chip(e[1], state[key] === e[0]);
        c.addEventListener("click", function () {
          state[key] = e[0];
          row.querySelectorAll(".di-chip").forEach(function (b) { b.setAttribute("aria-pressed", b === c ? "true" : "false"); });
          render();
        });
        row.appendChild(c);
      });
      return el("div", { class: "di-question" }, [el("p", { text: label }), row]);
    }

    root.appendChild(chipRow("Image", "image", [["any", "Any image"], ["a", "all-devops"], ["w", "aws-devops"], ["g", "gcp-devops"]]));
    root.appendChild(chipRow("Category", "cat", Object.keys(CATEGORIES).map(function (k) { return [k, CATEGORIES[k]]; })));

    var count = el("div", { class: "di-count" });
    var grid = el("div", { class: "di-tools" });
    root.appendChild(count);
    root.appendChild(grid);

    function render() {
      grid.innerHTML = "";
      var shown = TOOLS.filter(function (t) {
        if (state.cat !== "all" && t.c !== state.cat) return false;
        if (state.image !== "any" && t.i.indexOf(state.image) === -1) return false;
        var hay = (t.n + " " + t.d + " " + t.cmd).toLowerCase();
        return !state.q || hay.indexOf(state.q) !== -1;
      });
      count.textContent = shown.length + " of " + TOOLS.length + " tools";
      shown.forEach(function (t) {
        var dots = el("div", { class: "di-dots" });
        if (t.i.indexOf("a") !== -1) dots.appendChild(el("b", { class: "all", text: "all" }));
        if (t.i.indexOf("w") !== -1) dots.appendChild(el("b", { class: "aws", text: "aws" }));
        if (t.i.indexOf("g") !== -1) dots.appendChild(el("b", { class: "gcp", text: "gcp" }));
        grid.appendChild(el("div", { class: "di-tool", "data-cat": t.c, title: "Check it: " + t.cmd }, [
          el("strong", { text: t.n }),
          el("small", { text: t.d }),
          dots
        ]));
      });
    }
    render();
  }

  /* ---------- Widget: animated terminal --------------------------------- */

  var TERMINAL_SCRIPT = [
    ["c", "docker run -it --rm ghcr.io/jinalshah/devops/images/all-devops"],
    ["o", "Welcome to all-devops on Rocky Linux 10"],
    ["c", "terraform version"],
    ["o", "Terraform v1.x (managed by tfswitch)"],
    ["c", "aws --version && gcloud --version | head -1"],
    ["o", "aws-cli/2.x  ·  Google Cloud SDK"],
    ["c", "claude --version && agy --version"],
    ["o", "Claude Code, Antigravity CLI: ready to pair"],
    ["c", "trivy config ."],
    ["o", "✔ No misconfigurations found"]
  ];

  function mountTerminal(root) {
    var body = el("pre", { class: "di-terminal__body" });
    root.innerHTML = "";
    root.appendChild(el("div", { class: "di-terminal__bar" }, [el("i"), el("i"), el("i"), el("span", { text: "zsh — devops-images" })]));
    root.appendChild(body);

    var reduce = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var line = 0;
    var ch = 0;
    var cursor = el("span", { class: "di-terminal__cursor" });

    function append(cls, text) {
      var span = el("span", { class: cls, text: text });
      body.insertBefore(span, cursor);
      return span;
    }

    body.appendChild(cursor);

    if (reduce) {
      TERMINAL_SCRIPT.forEach(function (entry) {
        if (entry[0] === "c") append("p", "❯ ");
        append(entry[0], entry[1] + "\n");
      });
      return;
    }

    var current = null;
    function tick() {
      if (!root.isConnected) return;
      if (line >= TERMINAL_SCRIPT.length) return;
      var entry = TERMINAL_SCRIPT[line];
      if (entry[0] === "o") {
        append("o", entry[1] + "\n");
        line += 1;
        setTimeout(tick, 450);
        return;
      }
      if (ch === 0) {
        append("p", "❯ ");
        current = append("c", "");
      }
      current.textContent += entry[1].charAt(ch);
      ch += 1;
      if (ch >= entry[1].length) {
        current.textContent += "\n";
        ch = 0;
        line += 1;
        setTimeout(tick, 350);
      } else {
        setTimeout(tick, 28);
      }
    }
    setTimeout(tick, 400);
  }

  /* ---------- Mount on every page load ---------------------------------- */

  function mountAll() {
    document.querySelectorAll("[data-di-picker]").forEach(mountPicker);
    document.querySelectorAll("[data-di-builder]").forEach(mountBuilder);
    document.querySelectorAll("[data-di-tools]").forEach(mountTools);
    document.querySelectorAll("[data-di-terminal]").forEach(mountTerminal);
  }

  if (window.document$ && typeof window.document$.subscribe === "function") {
    window.document$.subscribe(mountAll);
  } else {
    document.addEventListener("DOMContentLoaded", mountAll);
  }
})();
