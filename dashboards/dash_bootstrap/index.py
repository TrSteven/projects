"""
This app creates a responsive sidebar layout with dash-bootstrap-components and
some custom css with media queries.

When the screen is small, the sidebar moved to the top of the page, and the
links get hidden in a collapse element. We use a callback to toggle the
collapse when on a small screen, and the custom CSS to hide the toggle, and
force the collapse to stay open when the screen is large.

dcc.Location is used to track the current location. There are two callbacks,
one uses the current location to render the appropriate page content, the other
uses the current location to toggle the "active" properties of the navigation
links.

For more details on building multi-page Dash applications, check out the Dash
documentation: https://dash.plot.ly/urls
"""

# https://github.com/facultyai/dash-bootstrap-components/tree/master/examples/multi-page-apps/responsive-sidebar

import dash_bootstrap_components as dbc
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output, State

import importlib
import glob

from app import app

# Get all the file names of the apps in the apps folder
apps_names = [x.replace('apps\\', '').replace('.py', '') for x in glob.glob("apps/*.py")]
apps_names.remove('__init__')

# Import the apps in the apps folder
apps_modules = [importlib.import_module('apps.' + x) for x in apps_names]

# Create pages for navigation
pages = [x.replace('_', ' ').title() for x in apps_names]
number_of_pages = len(pages)

pages_url = ['/' + x.replace(' ', '-').lower() for x in pages]
pages_url_id =  [x.replace(' ', '-').lower() + '-link' for x in pages]

# we use the Row and Col components to construct the sidebar header
# it consists of a title, and a toggle, the latter is hidden on large screens
sidebar_header = dbc.Row(
    [
        dbc.Col(html.H2("Dashboard Example", className="display-5")),
        dbc.Col(
            html.Button(
                # use the Bootstrap navbar-toggler classes to style the toggle
                html.Span(className="navbar-toggler-icon"),
                className="navbar-toggler",
                # the navbar-toggler classes don't set color, so we do it here
                style={
                    "color": "rgba(0,0,0,.5)",
                    "border-color": "rgba(0,0,0,.1)",
                },
                id="toggle",
            ),
            # the column containing the toggle will be only as wide as the
            # toggle, resulting in the toggle being right aligned
            width="auto",
            # vertically align the toggle in the center
            align="center",
        ),
    ]
)

sidebar = html.Div(
    [
        sidebar_header,
        # we wrap the horizontal rule and short blurb in a div that can be
        # hidden on a small screen
        html.Div(
            [
                html.Hr(),
                html.P(
                    "An dashboard with a sidebar created with Bootstrap components"
                    "links.",
                    className="lead",
                ),
            ],
            id="blurb",
        ),
        # use the Collapse component to animate hiding / revealing links
        dbc.Collapse(
            dbc.Nav(
                [dbc.NavLink(pages[x], href=pages_url[x], id=pages_url_id[x]) 
                 for x in range(number_of_pages)
                ],
                vertical=True,
                pills=True,
            ),
            id="collapse",
        ),
    ],
    id="sidebar",
)

content = html.Div(id="page-content")

app.layout = html.Div([dcc.Location(id="url"), sidebar, content])
app.title = 'My dashboard'

# this callback uses the current pathname to set the active state of the
# corresponding nav link to true, allowing users to tell see page they are on
@app.callback(
    [Output(x, "active") for x in pages_url_id],
    [Input("url", "pathname")],
)
def toggle_active_links(pathname):
    if pathname == "/":
        # Treat page 1 as the homepage / index
        return True, False, False
    return [pathname == pages_url[x] for x in pages_url]


@app.callback(Output("page-content", "children"), [Input("url", "pathname")])
def render_page_content(pathname):
    # Treat page 1 as the homepage / index
    if pathname == '/':
        return apps_modules[0].layout
    elif any([pathname == x for x in pages_url]):
        return apps_modules[pages_url.index(pathname)].layout
    # If the user tries to reach a different page, return a 404 message
    return dbc.Jumbotron(
        [
            html.H1("404: Not found", className="text-danger"),
            html.Hr(),
            html.P(f"The pathname {pathname} was not recognised..."),
        ]
    )


@app.callback(
    Output("collapse", "is_open"),
    [Input("toggle", "n_clicks")],
    [State("collapse", "is_open")],
)
def toggle_collapse(n, is_open):
    if n:
        return not is_open
    return is_open

# http://127.0.0.1:8888/
if __name__ == "__main__":
    app.run_server(port=8888, debug=False, dev_tools_hot_reload=False)
