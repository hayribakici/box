# box

Pandoc lua-filter that creates a box around some text.

## Run 

Run this filter e.g. with `pandoc sample.md --lua-filter=box.lua --output=sample.pdf`.

## Usage

The simplest usage would be to wrap three colons `:::` with the `{.box}` attribute around some text. `box` creates a box around it with the default border and fill color of `tcolorbox` (see [sample.pdf](https://github.com/hayribakici/box/blob/main/sample.pdf)).

```markdown
:::{.box}

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy
eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam
voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet
clita kasd gubergren.

:::
```

Resulting in

<img src="https://github.com/hayribakici/box/assets/3295340/71f1b8c1-dbfb-4e21-aeae-5a54468910ce" width="300px" />

### Admonition

It is also possible to use predefined boxes aka. admonitions. All you need to do is to call the classes `.important`, `.info`, `.danger`, `.warning` and `.plain` (see [sample_types.md](https://github.com/hayribakici/box/blob/main/sample_types.pdf)). 

<img src="https://github.com/hayribakici/box/assets/3295340/21b49977-36c7-4fa8-b957-7703ab018df6" width="300px" />

### Customizing

You can add titles and define fill and border colors with

```markdown
:::{.box fillcolor="#ababab" bordercolor="#000000"}
> Your title as a blockquote followed by an empty line

Your regular markdown content here such as

Here is some **Text** that you can *display* inside a Box!
You can also add your favorite markdown commands such as

> a nice blockquote

Maybe a table?!

| Here | Here|
|------|----:|
|Here  | and here |

And some bullet points

- Some
- important
- bullet
- points

and enumerations

1. first
2. second
3. third

> The last line as a blockquote results in adding a lower part of the box.

:::
```

<img width="300" src="https://github.com/hayribakici/box/assets/3295340/03b9b880-d60d-4104-aa38-ccbe0a713e39" />

This pandoc filter is basically wrapping a `tcolorbox` around the text in markdown and provides the options:

- the title set by the first blockquote paragraph (see below on [Caveats](#caveats) when you only want to put a quote inside the box)
- a lower part set by the last blockquote
- **fillcolor**: the background color of the box. Supports `HTML` (`#...`) and [latex `xcolor`](https://en.wikibooks.org/wiki/LaTeX/Colors) colors
- **bordercolor**: the framecolor of the box. Supports `HTML` (`#...`) and latex `xcolor` colors

## Caveats

1. So far the display of images are not supported. Latex throws an error message

  ```terminal
  ! LaTeX Error: Not in outer par mode.

  See the LaTeX manual or LaTeX Companion for explanation.
  Type  H <return>  for immediate help.
   ...                                              
                                                  
  l.108 \centering
  ```

  Any help here is appreciated.

2. The `tcolorbox` package provides much more options than this filter. If you think that this filter should have more options, any PR redarding this issue is welcome.

## Important information

1. If you have your own `header-includes` file, you need to additionally import `tcolorbox` with `\usepackage{tcolorbox}`.
2. If you only want to put a quote `>` into a box consider adding an empty title and empty bottom quote like this:

```markdown
:::{.box}
>

> I think therefore I am

>
:::
```

Resulting in this:

<img src="https://github.com/hayribakici/box/assets/3295340/2d646810-b750-44ce-ac17-873217f05d40" width="300px" />

## Future ideas

- allow identification with `crossref` 

