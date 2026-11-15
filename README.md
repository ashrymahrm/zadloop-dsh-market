<p align="center">
  <img src="assets/logo.svg" width="96" alt="dsh-market logo">
</p>

# dsh-market for ZadLoop

English | العربية

**EN:** This repository is a byte-identical redistribution of the dsh-market plugin, pinned to `dshmarket@1.73.19` and verified working on ZadLoop (`@deepseek-ai/dsh` 0.2.2-rc.2, 2026-11-15). Everything in this page is about ZadLoop only. Written with AI assistance; the error and the fix are real and tested on an actual machine.

**AR:** المستودع ده نسخة مطابقة من بلجن سوق الإضافات، مثبت على نسخة مجربة وشغالة على ZadLoop. كل اللي في الصفحة دي عن ZadLoop بس. الشرح اتجمع بمساعدة AI، بس الخطأ والحل حقيقيين واتجربوا على جهاز فعلي.

## Install first: one command

**EN:** Type one line in your terminal. It finds ZadLoop's own Node runtime, puts ZadLoop's pnpm on the `PATH` first, and installs the market into the `web` profile. No app restart needed.

**AR:** اكتب سطر واحد في التيرمنال. السكريبت بيوصلك لـ Node بتاع ZadLoop، بيحط pnpm بتاع ZadLoop الأول في الـ `PATH`، وبيثبت السوق في البروفايل `web`. من غير ريستارت.

**Linux / macOS:**

```sh
curl -fsSL https://raw.githubusercontent.com/ashrymahrm/zadloop-dsh-market/master/tools/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/ashrymahrm/zadloop-dsh-market/master/tools/install.ps1 | iex
```

**EN:** When it finishes, open ZadLoop's Plugins page: the market is live.

**AR:** لما يخلص، افتح صفحة Plugins في ZadLoop: السوق شغال على طول.

Profile other than `web`? Export `ZL_PROFILE=<name>` first (`$env:ZL_PROFILE` on Windows). Custom locations: `ZL_RUNTIME`, `ZL_DSH_HOME`, `ZL_NODE`.

## لو التثبيت فشل عندك، الحل جاهز هنا / If the install fails, the fix is here

**AR:** الموضوع بدأ لما ضغطت Install على الإضافة. المهمة اتلغت بعد شوية برسالة إن `node_modules` معمولة بنسخة pnpm مختلفة، والاسترجاع التلقائي وقع بنفس الخطأ. في لوحة المهام ظهر عندي تلات عمليات ملغية ورا بعض.

السبب طلع بسيط. الجهاز عنده نسختين من pnpm: نسخة قديمة في `~/.local/bin`، ونسخة 11 جاية جوه ZadLoop نفسه. كل نسخة من pnpm بتخزن شغلها في مجلد اسمه فيه رقم نسختها، يعني `v10` و`v11` مش هيشاركوا نفس `node_modules`، ومفيش طريقة يخلص فيها الموضوع على النسخة الغلط. عشان كده الإصلاح اليدوي والإعادة التلقائية بيقعوا بنفس الخطأ.

الحل بقى مدمج في سكريبت التثبيت فوق: بيحط pnpm نسخة 11 بتاع ZadLoop الأول في الـ `PATH` قبل ما يثبّت، فالمشكلة بتتحل لوحدها. أنا لقيت النسخة 11 جاهزة جوه ملفات ZadLoop، عملت ليها symlink مكان القديمة ورجعت جربت، وعدى من أول مرة.

**EN:** The install fails when the pnpm first on your `PATH` is a different major than the one ZadLoop runs on. Each pnpm major writes its version into its store directory (`v10` vs `v11`), so two majors cannot share one `node_modules`, and rebuilds and the automatic rollback fail the same way. The install script above fixes this for you by putting ZadLoop's own pnpm first on the `PATH` before it installs anything.

## Waiting for agents to go idle

**AR:** لو ظهرك "Waiting for agents to go idle" بس من غير إيرور، فده مش مشكلة أصلاً. السوق بيستنى الجلسات تخلص قبل ما يعدّل ملفات البروفايل، وبيكمّل التثبيت أول ما تخلص. اقفل الجلسة واستنى شوية، أو دوس Run now لما مفيش جلسة شغالة.

**EN:** The market refuses profile changes while an agent session is mid-turn. The install queues and runs the moment sessions finish. Nothing to fix; close the session or press Run now when nothing is running.

## Manual install (Linux)

**EN:** Equivalent to the script, if you prefer to run it by hand: put ZadLoop's bundled pnpm first on the `PATH` (the part the script does for you), then add the plugin.

**AR:** نفس اللي بيعمله السكريبت لو بتحب بالإيد: خلي pnpm بتاع ZadLoop الأول في الـ `PATH` (دي الحتة اللي السكريبت بيعملها)، وبعدين ثبّت.

```sh
RUNTIME=/opt/ZadLoop/resources/app.asar.unpacked/runtime
DSH_HOME=~/.config/ZadLoop/harness \
PATH="/opt/ZadLoop/resources/primary-runtime/dependencies/pnpm/bin:$PATH" \
/opt/ZadLoop/resources/primary-runtime/dependencies/node/bin/node \
  --expose-internals --use-system-ca \
  --import file://$RUNTIME/lib/runtime.js \
  $RUNTIME/node_modules/@deepseek-ai/dsh/lib/bin.js \
  plugin --profile web add github:ashrymahrm/zadloop-dsh-market
```

If `pnpm` is missing from `pnpm/bin` on your install, make an executable one-line shim that runs `exec "$NODE" /opt/ZadLoop/resources/primary-runtime/dependencies/pnpm/bin/pnpm.cjs "$@"` and put its directory first on the `PATH`.

## No restart needed (HMR)

**EN:** ZadLoop runs the DeepSeek Harness HMR bundle by default: install and plugin switches hot-reload the running app in about a second, and the choice survives restarts.

**AR:** ZadLoop شغال بـ HMR افتراضيًا: التثبيت والتشغيل والإيقاف بيتطبقوا على التطبيق الشغال خلال ثانية تقريبًا، والاختيار باقي بعد الريستارت.

## Troubleshooting

**EN:**

- `pnpm` refuses a git-hosted build: add the key pnpm prints to `allowBuilds` in the profile's `pnpm-workspace.yaml`, then rerun. The market asks for this approval inside ZadLoop on its own.
- Stuck "Queued": one deferred change runs at a time. Dismiss finished notices in the Tasks panel and press Run now when no session is active.
- Windows/macOS scripts use the standard desktop layout and auto-detect the runtime; if a path differs on your machine, pass `ZL_RUNTIME` / `ZL_DSH_HOME`.

**AR:**

- pnpm رافض يبني من git: زود المفتاح اللي بيطلعه في رسالته تحت `allowBuilds` في `pnpm-workspace.yaml` جوه البروفايل، وبعدين حاول تاني. جوه ZadLoop السوق بيطلب الموافقة دي بنفسه.
- حاطط "Queued" ومش بيمشي: عملية واحدة مؤجلة بتشتغل في المرة. اقفل الاشعارات اللي خلصت من لوحة المهام ودوس Run now لما مفيش جلسة شغالة.
- سكريبتات ويندوز وماك بتستخدم الهيكل القياسي وبتكتشف الـ runtime لوحدها؛ لو المسار مختلف عندك، مرر `ZL_RUNTIME` / `ZL_DSH_HOME`.

## Provenance

**EN:** Upstream project: [dsh-market/dsh-market](https://github.com/dsh-market/dsh-market) (MIT). Plugin catalog: [awesome-dsh-plugin.com](https://awesome-dsh-plugin.com). Installing from GitHub bypasses the npm catalog lookup, so the market keeps working when a mirror is unreachable.

**AR:** المشروع الأصلي: [dsh-market/dsh-market](https://github.com/dsh-market/dsh-market) بترخيص MIT. كتالوج الإضافات: [awesome-dsh-plugin.com](https://awesome-dsh-plugin.com). التثبيت من GitHub بيتجاوز مسار الكتالوج في npm، فالسوق بيشتغل حتى لو المرايا واصلة.

## License

MIT · upstream [dshmarket.com](https://dshmarket.com)
