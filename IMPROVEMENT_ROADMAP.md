# Improvement Roadmap: from 65 to a stronger mark

How the report was graded, what cost you marks, and exactly what to change.
Fixes are ordered by impact. The first one matters most.

The module marks three things:

| Criterion | Max | What they reward |
|-----------|-----|------------------|
| Awareness of subject | 35 | Context, correct use of methods, referencing |
| Content and communication | 50 | Accuracy, structure, clarity, notation, bibliography |
| Understanding | 15 | Insight, a cohesive argument |

---

## Priority 1: Fix the central calculation (biggest mark swing)

**The problem.** Your headline answer (~£968, "close to £1,000, so realistic")
does not reconcile with your own inputs.

With your stated numbers, mean log-return `mu = -0.034` over an expected
`E[N] ≈ 22` years, the expected value of `log S` should be:

```
E[log S] = log(1000) + 22.23 × (-0.034) = 6.908 - 0.756 = 6.15
```

That gives an expected inheritance near **£480**, not £968. Your reported
`E[log S] = 6.875` is almost exactly `log(1000) + (-0.034)`, which is what you
get if the simulation added **one** year's return instead of summing **N** of
them. Your reported variance (0.0038) is also far too small for the same
reason. The Monte Carlo loop almost certainly summed a single `X_i` rather than
`N` of them.

**Why it costs marks.** This sits under "accuracy of mathematical content" (the
single largest sub-criterion). An examiner who spots it discounts the whole
conclusion.

**The fix.** Sum `N` returns per simulation, then cross-check against the
closed form. The corrected script in `R/markov_inheritance.R` does both:

```
E[log S]   = log S0 + E[N]·mu
Var[log S] = E[N]·sigma^2 + Var[N]·mu^2
```

If the Monte Carlo and the formula agree, you can state the result with
confidence. Re-interpret honestly: losing roughly half over ~22 years on a
single declining stock is a reasonable finding, and saying so shows insight.

**Also fix the two different final numbers.** The body says £967.97 and the
conclusion says £968.74. Pick one, derived one way.

---

## Priority 2: Present the parameter estimation cleanly

**The problem.** The report says: *"I could not figure out how to solve these
equations, so I switched the method."* Honest, but it reads as a dead end and
loses credibility.

**The fix.** Don't narrate the failed attempt. Present the method that worked as
the chosen method, with the reasoning. Two clean options:

1. **Log-linear Gompertz fit (recommended, simplest).** The Gompertz hazard is
   `mu(t) = b·exp(eta·t)`, so `log(mortality rate)` is a straight line in age.
   A single linear regression gives both parameters. This is what the new script
   does, and it is easy to defend in writing.
2. **Maximum likelihood**, kept but written up properly: state the likelihood,
   the starting values, and that `optim()` converged. Show the fitted curve over
   the data.

Either way, include the **fitted-vs-observed mortality chart** so the reader can
see the fit is good.

**Reconcile your symbols.** The text reports `h = 0.0016, b = 0.5341` while the
code uses `b` and `eta`. Use one consistent naming throughout.

---

## Priority 3: Clean mathematical notation

**The problem.** The equations rendered as garbled symbols in the PDF, and
notation is inconsistent (`X_i`, `µ`, `Q`, `alpha` all appear in different
forms). Notation is an explicit sub-criterion.

**The fix.**

- Write the maths in a system that renders cleanly (LaTeX, or Word's equation
  editor). On GitHub, use LaTeX math blocks in markdown.
- Define every symbol once, the first time it appears: `S0`, `S_i`, `X_i`, `N`,
  `mu`, `sigma`, `b`, `eta`.
- State the Gompertz survival and hazard functions explicitly, and the Normal
  density, rather than referring to them in prose.

---

## Priority 4: Tighten structure and exposition

**The problem.** Long unbroken paragraphs; the literature review lists generic
textbook properties of each distribution rather than arguing toward a choice.

**The fix.**

- Use clear sections: Introduction, Modelling N, Modelling returns, Simulation,
  Results, Discussion, Conclusion, References.
- In the literature review, lead with the decision criterion (does the hazard
  rate match human mortality?) then judge each distribution against it. That
  shows reasoning, not recall.
- Replace the claim that Weibull is "for single causes of death" (not quite
  right) with the accurate point: Weibull can model rising hazards but Gompertz
  is the established demographic/actuarial standard for adult human mortality.
- Add one or two sentences of professional context (pensions, annuities, life
  insurance pricing all use exactly this machinery). That directly targets the
  "wider professional context" the marks reward.

---

## Priority 5: Strengthen the analysis and the discussion

Small additions that demonstrate understanding (the 15-mark criterion):

- **Report uncertainty, not just a point estimate.** Give a 90% interval for the
  inheritance, e.g. "£X to £Y", from the simulated distribution.
- **Validate the lifespan model.** Note that the modelled life expectancy at 60
  matches the life table (~22 years). One sentence, big credibility gain.
- **Check Monte Carlo stability.** State that 100,000 runs were used and that
  results are stable across seeds, or show how the estimate settles as runs
  increase.
- **State assumptions and their effect.** i.i.d. Normal returns understate tail
  risk; no dividends; single stock means no diversification. Saying what would
  change the answer is exactly the "insight" examiners look for.

---

## Priority 6: Referencing polish (low effort, easy marks)

- The Lenart reference is dated 2011 in text and 2012 in the list. Make it
  consistent.
- Use one citation style throughout (Harvard looks intended). Cite the ONS data
  set, the Gompertz source, and any formula you use.
- Cite a source for the method of percentiles and for the Gompertz survival
  function so the formulae are attributable.

---

## Quick-win checklist

- [ ] Sum N returns in the Monte Carlo; cross-check with the closed form
- [ ] One consistent final inheritance figure
- [ ] Remove the "could not solve it" narration; present the working method
- [ ] Consistent parameter names (`b`, `eta`, `mu`, `sigma`)
- [ ] Clean, defined notation that renders properly
- [ ] Fitted-vs-observed mortality chart included
- [ ] Section headings and shorter paragraphs
- [ ] Add a 90% interval and a model-validation sentence
- [ ] Fix the Lenart date and unify the reference style

---

## Making it GitHub-friendly (already scaffolded for you)

This folder now contains:

- **README.md** - the front page recruiters and markers see first: problem,
  method, how to run, results.
- **R/markov_inheritance.R** - one clean script that runs end to end with a
  single command, replacing the original (which referenced undefined variables,
  read a mis-named file, and mixed two methods).
- **data/uk_life_table.csv** - the mortality data in a tidy, documented form.
- **.gitignore** - keeps `.DS_Store`, `.RData` and the copyrighted course PDFs
  out of the public repo.
- **LICENSE** - MIT, so others know they can use the code.

Recommended final tidy-up before pushing:

1. Move your written report into `report/` (PDF is fine; a markdown version is
   better for GitHub because it renders inline).
2. **Do not commit** the assignment brief, the 177-page module notes, or the
   marking scheme. They are course copyright and add nothing to your profile.
   The `.gitignore` already excludes them.
3. Rename the repo something descriptive, e.g. `markov-inheritance-model`.
4. In your GitHub profile README, link to it under a "Projects" heading with one
   line: what it does and the headline result.
