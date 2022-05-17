<!-- dx-header -->
# eggd_wisecondorX (DNAnexus Platform App)

## What does this app do?

Successfully calls CNVs for shallow WGS data (hopefully)

## What are typical use cases for this app?

This app may be executed as a standalone app.

## What data are required for this app to run?

This app requires BAMs and a reference npz file.

You can create the reference by running this app on samples (recommended: 50 samples at least) and by changing the flag `create_ref` to True. This will only create the reference.

## What does this app output?

This app outputs:

- Reference.npz
- other things that i don't know the name of yet

This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://documentation.dnanexus.com/.

#### This app was made by EMEE GLH