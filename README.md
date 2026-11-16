# GenAI Surveys in Europe

A list of surveys on artificial intelligence run in Europe, kept by DG EMPL and DG ECFIN. Built with [Quarto](https://quarto.org).

Each survey page is a source link, a short table (who / when / where / sample / question / adoption) and one or two figures with the main result. The overview page plots AI adoption by workers and by firms over time, one dot per survey.

## Structure

```
_quarto.yml               site configuration and sidebar (one section per year)
index.qmd                 overview page
surveys/<year>/*.qmd      one page per survey; the YAML header fills the table
surveys/_template.qmd     template for a new entry
country-evidence.qmd      single-country surveys, one section per country
company-surveys.qmd       surveys run by private companies, one section per company
figures/make_figures.py   data and code for all charts (writes figures/*.svg)
filters/survey-card.lua   builds the link and table from the YAML header
styles.css                fonts, colours, table
docs/                     rendered site (serve this folder with GitHub Pages)
```

## Adding a survey

1. Copy `surveys/_template.qmd` to `surveys/<year>/<short-name>.qmd` and fill in the header. Keep `title` short: it is the label in the left menu.
2. If the survey measures AI adoption, fill in `month`, `adoption-individuals` / `adoption-workers` / `adoption-firms` and `coverage` in the header: the overview time series picks them up.
3. Add the numbers for its chart to `FIGURES` in `figures/make_figures.py` and run `python figures/make_figures.py`.
4. If the year is new, add a section for it in `_quarto.yml`.
5. Run `quarto render`.

A question in quotation marks is verbatim from the questionnaire or report; without quotation marks it is a summary.
