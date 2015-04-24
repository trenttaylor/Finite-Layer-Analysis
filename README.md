# finite-layer-analysis

## Introduction
This codebase contains a script to run a finite layer analysis on a prestressed concrete beam. Concrete strenths are determined at discrete layers and are then summed into the total compressive force. The prestress force is also calcuated and then using statics the beam's capacity and curvature can be obtained.

## Instructions
### Running The Code
1. Copy or Clone the Repository
2. Navigate to `.\finite-layer-analysis\` in the Matlab browser to set as the current folder or add `.\finite-layer-analysis\` to your path
3. Open `FiniteLayerAnalysis.m`
4. Check the `Input Parameters` section (lines 18-29) and verify they are the correct parameters
5. Execute the code
6. Type a section name. If you've used the section before it will load the section geometry and properties from last time.
6. Input the cross section according to the prompts
7. Input the prestressing steel according to the prompts
  * The script will remember this cross section by saving it as `<your section>.mat`. This allows you to reuse the section.
8. Input a "0" for the reinforced steel layers. This feature hasn't been implemented yet
9. Watch the calculations take place and then review the results 
11. Type `close all` at the command window and it will close all of the Matlab figures. There can be lots of them.

### Modifying the code
Just a little background on the code. 
* All units are inches and pounds.
* The top is referenced at zero and then positive values continue down for most calculations.
* The Kent and Park concrete model is used for concrete compressive strength
* Power formula is used for tendon stress

### Changes to This Repository
1. Fork the repository (try [GitHub for Windows](https://windows.github.com/), it's pretty simple)
2. Make the changes
3. Send me a pull request and I will make the changes
Other instructions on how to change a GitHub repository are available, here's a basic one: https://guides.github.com/introduction/flow/
