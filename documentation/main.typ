#set page("a4", margin: 0.5in)
#set text(size: 11pt, font: "New Computer Modern")
// #set text(size: 11pt, font: "TeX Gyre Schola")
// #set text(size: 11pt)
#show link: it => {
  if (type(it.dest) == str) {
    set text(blue)
    it
  } else { it }
}
#set figure(gap: 1em)

#set footnote(numbering: "*")

#align(center)[
  #set text(size: 18pt)
  `smoothmanifold.asy` \ #v(0pt)
  Diagrams in higher mathematics with Asymptote\
  #set text(size: 15pt)
  Roman Maksimovich
  #v(1fr)
  #image("./resources/logo.svg")
  #v(1fr)
]
#pagebreak()

#set heading(numbering: none)
= Abstract

This document contains the full description and user manual to the `smoothmanifold` Asymptote module, home page https://github.com/thornoar/smoothmanifold.

#outline()

#set heading(numbering: "1.")
= Introduction

== Rationale

In higher mathematics, diagrams often take the form of "blobs" (representing sets) placed on the plane, connected with paths or arrows. This is particularly true for set theory and topology, but other more advanced fields inherit this style. In differential geometry, one draws spheres, tori, and other surfaces in place of these "blobs". In category theory, commutative diagrams are commonplace, where the "blobs" are replaced by symbols. Here are a couple of examples, all drawn with `smoothmanifold`:

#[
  #show: it => columns(3, gutter: 0%, it)
  #figure(
    image("./resources/injection.svg"),
    caption: [An illustration of\ non-injectivity (set theory)]
  )
  #colbreak()
  #figure(
    image("./resources/baire-category-theorem.svg"),
    caption: [The proof of the Baire category theorem (topology)]
  )
  #colbreak()
  #figure(
    image("./resources/tangent.svg"),
    caption: [Tangent space at a point on a surface (diff. geometry)]
  )
]
