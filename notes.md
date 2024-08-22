# how to python

## Install Conda 

0. See if conda is already installed. 

```
conda --version
```

1. Download correct binary here: 
https://docs.anaconda.com/miniconda/

For Mac with M Chips:

```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
chmod +x Miniconda3-latest-MacOSX-arm64.sh 
./Miniconda3-latest-MacOSX-arm64.sh 
```

For Windows: 
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
```

## Make Environment for this Code

From `wildfire_disasters_lite` directory: 

```
conda env create -f wf.yml
conda activate wf
```

