# Omnimonitor
![CI](https://github.com/DB14823/COMP3000-DylanBennett/actions/workflows/ci.yml/badge.svg)  
**COMP3000 Computing Project — University of Plymouth, 2026–27**  
**Author:** Dylan Bennett  
**Supervisor:** Shaymaa Al-Juboori   
*Requires Xcode 27 / Swift 6.4*  
## Vision
For people living with type 1 diabetes to effectively manage their condition, they are required to manually calculate the correct dose of insulin to give themselves based on the carbohydrate content of whatever it is they are eating, as well as variables that are specific to each person. This is a heavy burden, as it is required for every meal, which is mentally demanding and prone to error.  
This iOS app aims to reduce the burden on those with type 1 diabetes by connecting to their insulin pump and glucose monitor, and forming a closed-loop system meaning that it automatically adjusts insulin delivery based on their glucose levels, within the safety limits manually set by the user. The app will also be used to manually administer an insulin dose, as well as recommending to the user the dose to give themselves at mealtimes. To do this, the user will take a photo of their meal, and using on-device computer vision and the built-in LiDAR depth sensor, the depth data can be used to calculate an estimate for the volume of food, which is more accurate than an estimate from a flat image. The custom machine learning model will then identify what food is in the photo using image classification. This is fed back into the app, which combines the identified food with the estimated volume, from which the app can calculate an estimate for carbohydrate content based on nutritional composition data. Once the app has this carbohydrate estimate, the user’s individual factors are then taken into account to provide them with their suggested dose which they can then manually adjust if needed, then approve.  
No insulin is given until the user approves it. Evaluations will be carried out to test the accuracy of carbohydrate estimates and whether insulin dosing stays safe when the estimates are not perfect.

> ⚠️ Research project. This software is not a medical device and is not approved for clinical use.
