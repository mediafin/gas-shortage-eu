# gas-shortage-eu

This repo contains the data analysis for all data concerning the gas industry.

## Data sources:

### Gas storage levels
The European gas storage levels can be found on the [website of GIE Aggregated Gas Story Inventory](https://agsi.gie.eu/#/). We use their API to collect their data in R and node.

### Gas price
[Intercontinental Exchange® (ICE)](https://www.theice.com/products/27996665/Dutch-TTF-Gas-Futures/data?marketId=5350859&span=3) has the Dutch TTF Gas Futures index we use to show the price for natural gas. This index should be updated every month since it indicates the price for gas for a specific month.

### Gas pipelines infrastructure
The [SciGRID_gas project](https://www.gas.scigrid.de/downloads.html) has developed a European gas transportation network model with geojsons we can use to visualize on a map.

### Physical flow of natural gas
There are several sources to use if you want to show the flow of natural gas in Europe.

For gas flowing through pipelines **from Russia to Europe** a good source is [Gazprom](https://www.gazprom.com/investors/disclosure/actual-supplies/). The actual gas supplies can be scraped from their website.

For gas flowing through pipelines **from Russia through Ukraine** a good source is the [Ukrainian gas grid operator](https://tsoua.com/en/transparency/test-transparency-platform/). They have an API to collect the data behind the Power BI platform.

### Gas dependency
On the [website of BP](https://www.bp.com/en/global/corporate/energy-economics/statistical-review-of-world-energy/downloads.html) you can download an excel with the dependency for every European country.
