# 🛠️ Contributor Guide 

Thanks for contributing to helm-charts-interactive-services! This guide outlines key conventions and practices to follow when contributing to the charts.

---


## 📝 PR naming

Use the following format when naming your pull requests:  
[chart-name] Short description of what the PR does


## Chart versioning

Every time you modify a chart, bump its version in the `Chart.yaml` file.
This ensures proper versioning and keeps deployment flows smooth and consistent.


## Library chart workflow

If you plan to make changes to the **library chart** (shared base chart), please make two distincts PR:

1. **First PR:** update the library chart only.
2. **Second PR:** make your modifications to other charts and update the dependent charts that rely on the library.

> ⚠️ This separation is required due to the structure of our CI/CD pipelines. Changes to the library chart must be processed first to avoid pipeline errors.

## 💡 Tips and tricks

You can run `pre-commit` hooks to help ensure a smoother integration. These hooks will automatically run a series of checks before you commit your changes.

```
pre-commit install
pre-commit run
```


## ⚙️ Auto-Generated Charts

Some charts are automatically generated, so there is no need to modify them. 

The 'children charts' are built from
- vscode-python
- vscode-pyspark
- jupyter-python
- jupyter-pyspark
- rstudio
- rstudio-sparkr  

Hence, only the above charts should be edited. 

Do not edit children charts directly, your modification could be erased in later releases.  

You can refer to [a diagram to see the link between the charts](https://github.com/InseeFrLab/helm-charts-interactive-services/blob/main/utils/charts-inheritance.yaml) or [consult the code](https://github.com/InseeFrLab/helm-charts-interactive-services/blob/main/utils/generate-children-charts.py).


## 🚀 You're Ready!

Feel free to fork the repo, create a feature branch, and submit your pull request.  
If you're unsure about something, open an issue or start a discussion first — we’re happy to help!


Thank you for contributing to the repo ☺️
