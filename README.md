# gas-shortage-eu

This repo contains the data analysis for all data concerning the gas industry.

## Data sources:

### Gas storage levels
https://agsi.gie.eu/#/

The European gas storage levels can be found on the website of GIE Aggregated Gas Story Inventory. We use their API to collect their data in R and node.

### Gas pipelines infrastructure
https://www.gas.scigrid.de/downloads.html

The SciGRID_gas project has developed a European gas transportation network model with geojsons we can use to visualize on a map.

### Physical flow of natural gas

There are several sources to use if you want to show the flow of natural gas in Europe.

For gas flowing through pipelines from Russia to Europe a good source is Gazprom:
https://www.gazprom.com/investors/disclosure/actual-supplies/

The actual gas supplies can be scraped from their website.

For gas flowing through pipelines through Ukraine a good source is the Ukrainian gas grid operator:
https://tsoua.com/en/transparency/test-transparency-platform/

They have an API to collect the data behind the Power BI platform.
