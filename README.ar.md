<p align="center">
  <img src="assets/logo.svg" width="96" alt="dsh-market logo">
</p>

# Plugins Market for ZadLoop

[English](README.md) | العربية

المستودع ده نسخة مطابقة من بلجن سوق الإضافات، مثبت على نسخة مجربة وشغالة على ZadLoop (`@deepseek-ai/dsh` ‏0.2.2-rc.2، 2026-11-15). كل اللي في الصفحة دي عن ZadLoop بس. الشرح اتجمع بمساعدة AI، بس الخطأ والحل حقيقيين واتجربوا على جهاز فعلي.

## التثبيت الأول: سطر واحد

اكتب سطر واحد في التيرمنال. السكريبت بيوصلك لـ Node بتاع ZadLoop، بيحط pnpm بتاع ZadLoop الأول في الـ `PATH`، وبيثبت السوق في البروفايل `web`. من غير ريستارت.

**لينكس / ماك:**

```sh
curl -fsSL https://raw.githubusercontent.com/ashrymahrm/zadloop-dsh-market/master/tools/install.sh | bash
```

**ويندوز (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/ashrymahrm/zadloop-dsh-market/master/tools/install.ps1 | iex
```

لما يخلص، افتح صفحة Plugins في ZadLoop: السوق شغال على طول.

عندك بروفايل غير `web`؟ عرّف `ZL_PROFILE=<name>` الأول (وبدل `ZL_PROFILE` بـ `$env:ZL_PROFILE` في ويندوز). مسارات مخصصة: `ZL_RUNTIME`، `ZL_DSH_HOME`، `ZL_NODE`.

## لو التثبيت فشل، الحل جاهز هنا

الموضوع بدأ لما ضغطت Install على الإضافة. المهمة اتلغت بعد شوية برسالة إن `node_modules` معمولة بنسخة pnpm مختلفة، والاسترجاع التلقائي وقع بنفس الخطأ. في لوحة المهام ظهر عندي تلات عمليات ملغية ورا بعض.

السبب طلع بسيط. الجهاز عنده نسختين من pnpm: نسخة قديمة في `~/.local/bin`، ونسخة 11 جاية جوه ZadLoop نفسه. كل نسخة من pnpm بتخزن شغلها في مجلد اسمه فيه رقم نسختها، يعني `v10` و`v11` مش هيشاركوا نفس `node_modules`، ومفيش طريقة يخلص فيها الموضوع على النسخة الغلط. عشان كده الإصلاح اليدوي والإعادة التلقائية بيقعوا بنفس الخطأ.

الحل بقى مدمج في سكريبت التثبيت فوق: بيحط pnpm نسخة 11 بتاع ZadLoop الأول في الـ `PATH` قبل ما يثبّت، فالمشكلة بتتحل لوحدها. أنا لقيت النسخة 11 جاهزة جوه ملفات ZadLoop، عملت ليها symlink مكان القديمة ورجعت جربت، وعدى من أول مرة.

## Waiting for agents to go idle

لو ظهرلك "Waiting for agents to go idle" بس من غير إيرور، فده مش مشكلة أصلاً. السوق بيستنى الجلسات تخلص قبل ما يعدّل ملفات البروفايل، وبيكمّل التثبيت أول ما تخلص. اقفل الجلسة واستنى شوية، أو دوس Run now لما مفيش جلسة شغالة.

## التثبيت اليدوي (لينكس)

نفس اللي بيعمله السكريبت لو بتحب بإيدك: خلي pnpm بتاع ZadLoop الأول في الـ `PATH` (دي الحتة اللي السكريبت بيعملها)، وبعدين ثبت.

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

لو `pnpm` مش موجودة جوه `pnpm/bin` في نسختك، اعمل ملف تنفيذي سطر واحد فيه `exec "$NODE" /opt/ZadLoop/resources/primary-runtime/dependencies/pnpm/bin/pnpm.cjs "$@"` وحط مجلده الأول في الـ `PATH`.

## من غير ريستارت (HMR)

ZadLoop شغال بـ HMR افتراضيًا: التثبيت والتشغيل والإيقاف بيتطبقوا على التطبيق الشغال خلال ثانية تقريبًا، والاختيار باقي بعد الريستارت.

## حل المشاكل

- pnpm رافض يبني من git: زود المفتاح اللي بيطلعه في رسالته تحت `allowBuilds` في `pnpm-workspace.yaml` جوه البروفايل، وبعدين حاول تاني. جوه ZadLoop السوق بيطلب الموافقة دي بنفسه.
- حاطط "Queued" ومش بيمشي: عملية واحدة مؤجلة بتشتغل في المرة. اقفل الاشعارات اللي خلصت من لوحة المهام ودوس Run now لما مفيش جلسة شغالة.
- سكريبتات ويندوز وماك بتستخدم الهيكل القياسي وبتكتشف الـ runtime لوحدها؛ لو المسار مختلف عندك، مرر `ZL_RUNTIME` / `ZL_DSH_HOME`.

## المصدر

المشروع الأصلي: [dsh-market/dsh-market](https://github.com/dsh-market/dsh-market) بترخيص MIT. كتالوج الإضافات: [awesome-dsh-plugin.com](https://awesome-dsh-plugin.com). التثبيت من GitHub بيتجاوز مسار الكتالوج في npm، فالسوق بيشتغل حتى لو المرايا واصلة.

## الترخيص

MIT · المشروع الأصلي [dshmarket.com](https://dshmarket.com)
