using GridapMUMPS
using Documenter

DocMeta.setdocmeta!(GridapMUMPS, :DocTestSetup, :(using GridapMUMPS); recursive=true)

makedocs(;
    modules=[GridapMUMPS],
    authors="Martin Kosch <martin.kosch@gmail.com> and contributors",
    sitename="GridapMUMPS.jl",
    format=Documenter.HTML(;
        canonical="https://martinkosch.github.io/GridapMUMPS.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/martinkosch/GridapMUMPS.jl",
    devbranch="main",
)
