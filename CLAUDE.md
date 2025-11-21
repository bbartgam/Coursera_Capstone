# CLAUDE.md - AI Assistant Guide for Coursera_Capstone

## Project Overview

This repository contains the capstone project for the IBM Data Scientist Professional Certificate program on Coursera. The project demonstrates practical data science skills applied to a real-world problem: finding the optimal neighborhood for apartment hunting in Western Washington.

**Project Status**: Completed academic project
**Primary Language**: Python (Jupyter Notebooks)
**Domain**: Data Science, Geospatial Analysis, Location Intelligence

## Business Problem

The capstone project addresses the question: "Where should I move to maintain my lifestyle while reducing commute times?"

The solution analyzes neighborhoods in Western Washington to find areas that:
1. Have similar amenities to the current neighborhood (coffee shops, parks, grocery stores, etc.)
2. Reduce commute times to both work (Kent, WA) and school (Seattle, WA)
3. Are visualized on an interactive map for decision-making

## Repository Structure

```
Coursera_Capstone/
├── final.ipynb                              # MAIN PROJECT - Apartment hunting analysis
├── CourseraCapstone.ipynb                   # Simple "Hello World" test notebook
├── SegandClusterpart1.ipynb                 # Course exercise - Toronto neighborhoods (basic)
├── SegandClusterpart1 (1).ipynb            # Course exercise - Toronto neighborhoods (iteration 1)
├── SegandClusterpart1 (2).ipynb            # Course exercise - Toronto neighborhoods (iteration 2)
├── SegandClusterpart1 (3).ipynb            # Course exercise - Toronto neighborhoods (full analysis)
├── appartment_hunt_4_ A_New_Hope.ipynb     # Alternative/draft apartment hunting notebook
├── python_code.py                           # Simple test script (contains syntax error)
├── Coursera.docx                            # Final report (Word format)
├── Coursera.pdf                             # Final report (PDF format)
├── Coursera.pptx                            # Presentation slides
└── README.md                                # Basic project description
```

### File Descriptions

#### Primary Files

- **`final.ipynb`**: The main capstone project notebook containing:
  - Complete apartment hunting workflow
  - Foursquare API integration for venue discovery
  - Bing Maps API integration for route/distance calculations
  - Geospatial analysis using geopy
  - K-means clustering (planned, may not be fully implemented)
  - Folium map visualization with interactive popups
  - Data analysis on 134 zip codes narrowed to 25 candidates

#### Course Exercises

- **`SegandClusterpart1*.ipynb`**: Progressive iterations of a course assignment
  - Web scraping Toronto postal codes from Wikipedia
  - Neighborhood segmentation and clustering
  - The `(3)` version is the most complete implementation

#### Supporting Files

- **`appartment_hunt_4_ A_New_Hope.ipynb`**: Early draft or alternative approach to apartment hunting
- **`python_code.py`**: Simple test script with basic imports (has syntax error on line 3)
- **`Coursera.{docx,pdf,pptx}`**: Final deliverables for course submission

## Technical Stack

### Core Libraries

```python
import numpy as np              # Numerical computing
import pandas as pd             # Data manipulation and analysis
import json                     # JSON data handling
import requests                 # HTTP requests for APIs
import matplotlib.pyplot as plt # Plotting and visualization
import matplotlib.cm as cm      # Colormaps
import matplotlib.colors        # Color utilities
```

### Geospatial Libraries

```python
from geopy.geocoders import Nominatim  # Geocoding (address to lat/long)
import geopy.distance                   # Distance calculations
import folium                           # Interactive map visualization
```

### Machine Learning

```python
from sklearn.cluster import KMeans  # K-means clustering algorithm
```

### Web Scraping

```python
from bs4 import BeautifulSoup       # HTML/XML parsing
import urllib.request               # URL fetching
```

### Installation

The notebooks use conda and pip for package management:

```bash
# Geopy installation (used in notebooks)
conda install -c conda-forge geopy --yes

# Folium installation
pip install folium

# BeautifulSoup installation
pip install beautifulsoup4

# Other dependencies (typically pre-installed in Jupyter environments)
# numpy, pandas, matplotlib, scikit-learn, requests
```

## API Integration

### ⚠️ CRITICAL SECURITY ISSUE

**The notebooks contain hardcoded API credentials that should NOT be committed to version control.**

#### Foursquare API

Located in: `final.ipynb`

```python
# THESE CREDENTIALS ARE EXPOSED IN THE CODE
CLIENT_ID = 'FD35ZLLUHS5JQBQBK0FDBZXI2ADUFCR02IOU51JMUXIUHDNL'
CLIENT_SECRET = '5WMJDA1OQP4XS0Q1NT5L0MBD32ELTSL32505WWPTTC53GV5O'
VERSION = '20200101'
LIMIT = 100
```

**Usage**: Fetches venue information (restaurants, coffee shops, parks, etc.) for neighborhoods

**API Endpoint Pattern**:
```
https://api.foursquare.com/v2/venues/explore?client_id={}&client_secret={}&ll={},{}&v={}&limit={}
```

#### Bing Maps API

Located in: `final.ipynb`

```python
# THIS CREDENTIAL IS EXPOSED IN THE CODE
bingkey = 'AtIG73fsNaAkmjh6G6-RGJJ4TtGEFva81aF6bOHrfjWzA4HvmRL2OBITa_udr65s'
```

**Usage**: Calculates drive times and distances between locations

**API Endpoint Pattern**:
```
https://dev.virtualearth.net/REST/v1/Routes/DistanceMatrix?origins={}&destinations={}&travelMode={}&key={}
```

### Recommendations for AI Assistants

When working with this code:

1. **NEVER commit new API keys to the repository**
2. **Suggest using environment variables** for credentials:
   ```python
   import os
   CLIENT_ID = os.getenv('FOURSQUARE_CLIENT_ID')
   CLIENT_SECRET = os.getenv('FOURSQUARE_CLIENT_SECRET')
   BING_KEY = os.getenv('BING_MAPS_API_KEY')
   ```
3. **Recommend creating a `.gitignore`** to exclude credential files
4. **Warn users** that existing credentials may be compromised

## Data Workflow

### Main Analysis Pipeline (final.ipynb)

1. **Define Locations**
   - Home: 98059 (Renton/Newcastle area)
   - Work: 21218 76th Ave S, Kent, WA 98032
   - School: 4105 George Washington Lane NE, Seattle, WA 98105
   - Uses Nominatim geocoder for lat/long conversion

2. **Calculate Distance Threshold**
   - Measures distance between work and school: ~17.4 miles
   - Sets search radius: 21.76 miles (17.4 × 1.25)

3. **Load Candidate Zip Codes**
   - Reads from `/resources/labs/fina/zipss.csv`
   - Geocodes all zip codes in Western Washington
   - Filters to valid coordinates (134 zip codes)

4. **Filter by Geographic Distance**
   - Calculates geodesic distance from work and school to each zip code
   - Filters to areas within acceptable commute distance
   - Reduces to 53 potential neighborhoods

5. **Calculate Drive Times (Bing Maps API)**
   - Driving time to work (threshold: < 45 minutes)
   - Transit time to school (threshold: < 45 minutes)
   - Filters to 25 viable neighborhoods

6. **Analyze Neighborhood Amenities (Foursquare API)**
   - Fetches top 100 venues for current neighborhood
   - Creates "model" based on desired venue types:
     - Coffee Shop, Mexican Restaurant, Grocery Store
     - Brewery, Pet Store, Café, Bakery
     - Supermarket, Trail, Park, Gastropub
   - Queries Foursquare for each candidate neighborhood
   - Filters neighborhoods matching the model criteria

7. **Visualization**
   - Creates Folium map centered on candidate areas
   - Adds CircleMarker for each viable neighborhood
   - Popup shows: City, drive time to work, transit time to school

### Result

From 134 zip codes → 25 neighborhoods meeting all criteria
- Bellevue areas (98004, 98008, 98009, etc.)
- Seattle neighborhoods (98102, 98103, 98104, etc.)
- Other areas (Kenmore, Renton, Lynnwood, Kent)

## Code Patterns and Conventions

### Naming Conventions

- **Variables**: snake_case (e.g., `nearby_venues`, `travel_time`)
- **DataFrames**: descriptive names (e.g., `potential`, `df_wa`, `adding_times`)
- **Constants**: UPPERCASE (e.g., `CLIENT_ID`, `VERSION`, `LIMIT`)

### Common Patterns

#### 1. API Request Pattern

```python
url = 'https://api.example.com/endpoint?param1={}&param2={}'.format(value1, value2)
results = requests.get(url).json()
data = results['response']['key']
```

#### 2. DataFrame Building with Iteration

```python
result_df = pd.DataFrame()
result_df['column'] = ''

for i in range(len(source_df)):
    # ... calculations ...
    result_df = result_df.append({'column': value}, ignore_index=True)

# Merge back to original
source_df = pd.merge(source_df, result_df, left_index=True, right_index=True)
```

#### 3. Data Filtering

```python
# Filter by boolean condition
df = df.loc[(df['column'] > threshold)]

# Remove rows with specific values
df = df[~df['column'].isin(['unwanted_value'])]

# Reset index after filtering
df = df.reset_index()
df = df.drop(['index'], axis=1)
```

#### 4. JSON Normalization from APIs

```python
venues = results['response']['groups'][0]['items']
nearby_venues = pd.json_normalize(venues)

filtered_columns = ['venue.name', 'venue.categories', 'venue.location.lat']
dataframe_filtered = nearby_venues.loc[:, filtered_columns]
```

## Known Issues

### 1. Syntax Error in python_code.py

**Location**: `python_code.py:3`

```python
print ('hello capstone course")  # Mismatched quotes
```

**Fix**: Should be `print('hello capstone course')`

### 2. Hardcoded API Credentials

**Severity**: HIGH - Security vulnerability

**Files**: `final.ipynb`, multiple cells

**Issue**: API keys committed to public repository

**Recommendation**:
- Rotate compromised keys
- Use environment variables
- Add `.env` to `.gitignore`

### 3. Deprecated API Calls

**pandas.io.json.json_normalize** is deprecated

**Current**: `from pandas.io.json import json_normalize`

**Recommended**: `from pandas import json_normalize` (pandas >= 1.0)

### 4. Inefficient DataFrame Appending

Multiple loops use `.append()` in iterations, which is inefficient for large datasets.

**Current Pattern**:
```python
for i in range(len(df)):
    result = result.append({'col': value}, ignore_index=True)
```

**Better Pattern**:
```python
results = []
for i in range(len(df)):
    results.append({'col': value})
result = pd.DataFrame(results)
```

### 5. File Path Dependency

**Location**: `final.ipynb`, cell 7

```python
path = '/resources/labs/fina/zipss.csv'
```

**Issue**: Hardcoded absolute path may not exist in all environments

**Recommendation**: Use relative paths or check file existence

## Development Workflow

### For AI Assistants: How to Work with This Code

#### When Asked to Modify Analysis

1. **Start with `final.ipynb`** - This is the main project
2. **Check data availability** - The CSV file path may need updating
3. **API credentials** - Verify keys are valid or use test data
4. **Run cells sequentially** - Later cells depend on variables from earlier cells
5. **Expect long runtimes** - API calls to Foursquare/Bing for 25+ locations take time

#### When Asked to Improve Code

**Priorities**:
1. Security: Remove hardcoded credentials
2. Efficiency: Replace DataFrame.append() loops with list comprehensions
3. Error handling: Add try/except for API calls
4. Documentation: Add markdown cells explaining each step
5. Modularity: Extract repeated code into functions

#### When Asked About Results

**Key insights**:
- Analysis identified 25 viable neighborhoods from 134 candidates
- Bellevue and Seattle dominate results
- Commute times range from 11-43 minutes (well within 45-minute threshold)
- Method successfully balanced amenity matching with commute reduction

## Git Workflow

### Branch Strategy

This repository uses feature branches for development:
- Current branch: `claude/claude-md-mi9husl8lq4gz7rk-01MjdLj9TWg7satWPEJQeWMy`
- Branches follow pattern: `claude/claude-md-{session-id}`

### Commit Guidelines

When making changes:

```bash
# Check status
git status

# Stage changes
git add <files>

# Commit with descriptive message
git commit -m "Brief description of changes"

# Push to remote (use -u for new branches)
git push -u origin <branch-name>
```

### Important Git Notes

- Always develop on the designated Claude branch
- Push must use the exact branch name (starts with 'claude/', ends with session ID)
- Network failures should retry with exponential backoff (2s, 4s, 8s, 16s)
- Never force push without explicit permission

## Testing and Validation

### How to Verify the Analysis

Since this is data science work, "testing" means validating results:

1. **Check data shapes**: Verify DataFrame dimensions match expected counts
2. **Validate coordinates**: Ensure lat/long are within Washington state bounds
   - Latitude: ~45.5 to 49.0
   - Longitude: ~-124.8 to -116.9
3. **API response validation**: Check for empty responses or errors
4. **Distance calculations**: Spot-check using Google Maps
5. **Visual inspection**: Review Folium map output for sensibility

### Example Validation Commands

```python
# Check DataFrame shape
print(potential.shape)  # Should be (25, 10) in final analysis

# Validate coordinates
assert potential['Lat'].between(45.5, 49.0).all()
assert potential['Long'].between(-124.8, -116.9).all()

# Check for missing data
assert not potential.isnull().any().any()

# Validate travel times
assert (potential['T_work'] < 45).all()
assert (potential['T_school'] < 45).all()
```

## Common Questions for AI Assistants

### Q: Can I run this code?

**A**: Partially. You'll need:
- Valid Foursquare API credentials (free tier available)
- Valid Bing Maps API key (free tier available)
- The zip code CSV file (`/resources/labs/fina/zipss.csv`)
- Or modify to work with different data sources

### Q: How do I adapt this for a different city?

**A**: Modify these variables:
1. `postalcode` (home location)
2. `Work` address
3. `School` address
4. `zipss.csv` data source (or generate list of zip codes)
5. `list1` tuple (desired amenities to match)

### Q: Why are there multiple SegandClusterpart1 files?

**A**: These are iterations of a course assignment. The student saved multiple versions:
- Base version: Simple scraping exercise
- (1) and (2): Intermediate iterations
- (3): Full analysis with clustering

This is common in learning environments where students iterate on assignments.

### Q: What's the purpose of `appartment_hunt_4_ A_New_Hope.ipynb`?

**A**: It appears to be an early draft or alternative approach to the main capstone. It contains similar markdown describing the business problem but minimal code. The name suggests it's the 4th iteration (Star Wars reference).

### Q: Should I clean up the duplicate files?

**A**: For a production repo, yes. For an academic archive, keep them as evidence of the learning process. If cleaning up, create a `drafts/` or `archive/` directory.

## Project Context and Learning Objectives

This capstone demonstrates proficiency in:

1. **API Integration**: Working with external data sources (Foursquare, Bing Maps)
2. **Geospatial Analysis**: Geocoding, distance calculations, coordinate systems
3. **Data Wrangling**: Filtering, merging, transforming data with pandas
4. **Web Scraping**: Extracting data from Wikipedia (in SegandCluster exercises)
5. **Clustering**: K-means for neighborhood segmentation (Toronto exercises)
6. **Visualization**: Creating interactive maps with Folium
7. **Problem Solving**: Applying data science to real-world decision-making

## Additional Resources

### Documentation Links

- [Foursquare Places API](https://location.foursquare.com/developer/)
- [Bing Maps Distance Matrix API](https://docs.microsoft.com/en-us/bingmaps/rest-services/routes/calculate-a-distance-matrix)
- [Geopy Documentation](https://geopy.readthedocs.io/)
- [Folium Documentation](https://python-visualization.github.io/folium/)
- [Scikit-learn KMeans](https://scikit-learn.org/stable/modules/generated/sklearn.cluster.KMeans.html)

### Related Coursera Course

- IBM Data Science Professional Certificate
- Applied Data Science Capstone (Course 9/9)

## Summary for AI Assistants

**When working with this repository, remember:**

1. This is a COMPLETED academic project - respect the original work
2. Security: Never commit API credentials
3. Main file: `final.ipynb` contains the core analysis
4. Data dependencies: May need to provide CSV file or modify data sources
5. Runtime: API calls make this slow; be patient
6. Purpose: Demonstrates practical data science skills, not production code
7. Code quality: Typical of learning projects; optimization opportunities exist
8. Documentation: This CLAUDE.md file should be your primary reference

**Key takeaway**: This project successfully applies data science techniques to solve a real-world problem (apartment hunting) using geospatial data, external APIs, and visualization tools.
