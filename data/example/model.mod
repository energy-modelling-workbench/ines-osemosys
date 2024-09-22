# OSeMOSYS_2017_11_08
# OSeMOSYS_2017_11_08
#
# Open Source energy MOdeling SYStem
#
# Modified by Francesco Gardumi, Constantinos Taliotis, Igor Tatarewicz, Adrian Lefvert
# Main changes to previous version OSeMOSYS_2016_08_01
# Bug fixed in:
#		- Equation E1
# ============================================================================
#
#    Copyright [2010-2015] [OSeMOSYS Forum steering committee see: www.osemosys.org]
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# ============================================================================
#
																																																																																																																																																																																																							   
 
#  To run OSeMOSYS, enter the following line into your command prompt:
#
#  glpsol -m osemosys.txt -d datafile.txt -o results.txt
																																																																																																																																																																										  
#
#              			#########################################
######################			Model Definition				#############
#              			#########################################
#
###############
#    Sets     #
###############
#
set YEAR;
set TECHNOLOGY;
set TIMESLICE;
set FUEL;
set EMISSION;
set MODE_OF_OPERATION;
set REGION;
set SEASON;
set DAYTYPE;
set DAILYTIMEBRACKET;
set STORAGE;
#
#####################
#    Parameters     #
#####################
#
########			Global 						#############
#
param ResultsPath, symbolic default 'results';
param YearSplit{l in TIMESLICE, y in YEAR};

param DiscountRate{r in REGION};
param DiscountRateIdv{r in REGION, t in TECHNOLOGY}, default DiscountRate[r];

param DiscountFactor{r in REGION, y in YEAR} :=
	(1 + DiscountRate[r]) ^ (y - min{yy in YEAR} min(yy) + 0.0);
param DiscountFactorMid{r in REGION, y in YEAR} :=
	(1 + DiscountRate[r]) ^ (y - min{yy in YEAR} min(yy) + 0.5);

param OperationalLife{r in REGION, t in TECHNOLOGY};

param CapitalRecoveryFactor{r in REGION, t in TECHNOLOGY} :=
	(1 - (1 + DiscountRateIdv[r,t])^(-1))/(1 - (1 + DiscountRateIdv[r,t])^(-(OperationalLife[r,t])));
param PvAnnuity{r in REGION, t in TECHNOLOGY} :=
	(1 - (1 + DiscountRate[r])^(-(OperationalLife[r,t]))) * (1 + DiscountRate[r]) / DiscountRate[r];

param DiscountRateStorage{r in REGION, s in STORAGE};
param DiscountFactorStorage{r in REGION, s in STORAGE, y in YEAR} :=
	(1 + DiscountRateStorage[r, s]) ^ (y - min{yy in YEAR} min(yy) + 0.0);
param DiscountFactorMidStorage{r in REGION, s in STORAGE, y in YEAR} :=
	(1 + DiscountRateStorage[r, s]) ^ (y - min{yy in YEAR} min(yy) + 0.5);  
  
param DaySplit{lh in DAILYTIMEBRACKET, y in YEAR};
param Conversionls{l in TIMESLICE, ls in SEASON} binary;
param Conversionld{l in TIMESLICE, ld in DAYTYPE} binary;
param Conversionlh{l in TIMESLICE, lh in DAILYTIMEBRACKET} binary;
param DaysInDayType{ls in SEASON, ld in DAYTYPE, y in YEAR};
param TradeRoute {r in REGION, rr in REGION, f in FUEL, y in YEAR} binary;
param DepreciationMethod{r in REGION};

#
########			Demands 					#############
#
param SpecifiedAnnualDemand{r in REGION, f in FUEL, y in YEAR};
param SpecifiedDemandProfile{r in REGION, f in FUEL, l in TIMESLICE, y in YEAR};
param AccumulatedAnnualDemand{r in REGION, f in FUEL, y in YEAR};
#
#########			Performance					#############
#
param CapacityToActivityUnit{r in REGION, t in TECHNOLOGY};
param CapacityFactor{r in REGION, t in TECHNOLOGY, l in TIMESLICE, y in YEAR};
param AvailabilityFactor{r in REGION, t in TECHNOLOGY, y in YEAR};

param ResidualCapacity{r in REGION, t in TECHNOLOGY, y in YEAR};
param InputActivityRatio{r in REGION, t in TECHNOLOGY, f in FUEL, m in MODE_OF_OPERATION, y in YEAR};
param OutputActivityRatio{r in REGION, t in TECHNOLOGY, f in FUEL, m in MODE_OF_OPERATION, y in YEAR};
#
#########			Technology Costs			#############
#
param CapitalCost{r in REGION, t in TECHNOLOGY, y in YEAR};
param VariableCost{r in REGION, t in TECHNOLOGY, m in MODE_OF_OPERATION, y in YEAR};
param FixedCost{r in REGION, t in TECHNOLOGY, y in YEAR};
#
#########           		Storage                 		#############
#
param TechnologyToStorage{r in REGION, t in TECHNOLOGY, s in STORAGE, m in MODE_OF_OPERATION};
param TechnologyFromStorage{r in REGION, t in TECHNOLOGY, s in STORAGE, m in MODE_OF_OPERATION};
param StorageLevelStart{r in REGION, s in STORAGE};
param StorageMaxChargeRate{r in REGION, s in STORAGE};
param StorageMaxDischargeRate{r in REGION, s in STORAGE};
param MinStorageCharge{r in REGION, s in STORAGE, y in YEAR};
param OperationalLifeStorage{r in REGION, s in STORAGE};
param CapitalCostStorage{r in REGION, s in STORAGE, y in YEAR};
param ResidualStorageCapacity{r in REGION, s in STORAGE, y in YEAR};
#
#########			Capacity Constraints		#############
#
param CapacityOfOneTechnologyUnit{r in REGION, t in TECHNOLOGY, y in YEAR};
param TotalAnnualMaxCapacity{r in REGION, t in TECHNOLOGY, y in YEAR};
param TotalAnnualMinCapacity{r in REGION, t in TECHNOLOGY, y in YEAR};
#
#########			Investment Constraints		#############
#
param TotalAnnualMaxCapacityInvestment{r in REGION, t in TECHNOLOGY, y in YEAR};
param TotalAnnualMinCapacityInvestment{r in REGION, t in TECHNOLOGY, y in YEAR};
#
#########			Activity Constraints		#############
#
param TotalTechnologyAnnualActivityUpperLimit{r in REGION, t in TECHNOLOGY, y in YEAR};
param TotalTechnologyAnnualActivityLowerLimit{r in REGION, t in TECHNOLOGY, y in YEAR};
param TotalTechnologyModelPeriodActivityUpperLimit{r in REGION, t in TECHNOLOGY};
param TotalTechnologyModelPeriodActivityLowerLimit{r in REGION, t in TECHNOLOGY};
#
#########			Reserve Margin				#############
#
param ReserveMarginTagTechnology{r in REGION, t in TECHNOLOGY, y in YEAR} >= 0 <= 1;
param ReserveMarginTagFuel{r in REGION, f in FUEL, y in YEAR} binary;
param ReserveMargin{r in REGION, y in YEAR};
#
#########			RE Generation Target		#############
#
param RETagTechnology{r in REGION, t in TECHNOLOGY, y in YEAR} binary;
param RETagFuel{r in REGION, f in FUEL, y in YEAR} binary;
param REMinProductionTarget{r in REGION, y in YEAR};
#
#########			Emissions & Penalties		#############
#
param EmissionActivityRatio{r in REGION, t in TECHNOLOGY, e in EMISSION, m in MODE_OF_OPERATION, y in YEAR};
param EmissionsPenalty{r in REGION, e in EMISSION, y in YEAR};
param AnnualExogenousEmission{r in REGION, e in EMISSION, y in YEAR};
param AnnualEmissionLimit{r in REGION, e in EMISSION, y in YEAR};
param ModelPeriodExogenousEmission{r in REGION, e in EMISSION};
param ModelPeriodEmissionLimit{r in REGION, e in EMISSION};
#
																																																																															
##############
##
########################################################################
#   Check statements to carry out simple debugging in model parameters #
########################################################################

##### 'Capacity investment' check  #####
printf "Checking Max and Min capcity-investment bounds for r in REGION, t in TECHNOLOGY, y in YEAR \n";
#
check{r in REGION, t in TECHNOLOGY, y in YEAR:TotalAnnualMaxCapacityInvestment[r, t, y]<>-1 && TotalAnnualMinCapacityInvestment[r, t, y]<>0}: TotalAnnualMaxCapacityInvestment[r, t, y]>=TotalAnnualMinCapacityInvestment[r, t, y];
#
##### 'Annual Activity' check  #####
printf "Checking Annual activity limits for r in REGION, t in TECHNOLOGY, y in YEAR \n";
#
check{r in REGION, t in TECHNOLOGY, y in YEAR:TotalTechnologyAnnualActivityUpperLimit[r,t,y]<>-1 && TotalTechnologyAnnualActivityUpperLimit[r,t,y]<>0 && TotalTechnologyAnnualActivityLowerLimit[r,t,y]<>0}: TotalTechnologyAnnualActivityUpperLimit[r,t,y]>=TotalTechnologyAnnualActivityLowerLimit[r,t,y];
#
##### 'Capacity' check 1   #####
printf "Checking Residual and TotalAnnualMax Capacity for r in REGION, t in TECHNOLOGY, y in YEAR \n";
#
check{r in REGION, t in TECHNOLOGY, y in YEAR: TotalAnnualMaxCapacity[r,t,y]<>-1 && ResidualCapacity[r,t,y]<>0}: TotalAnnualMaxCapacity[r,t,y] >= ResidualCapacity[r,t,y];
#
##### 'Capacity' check 2   #####
printf "Checking Residual, Total annual maxcap and mincap investments for  all Region, Tech and Year \n";
#
check{r in REGION, t in TECHNOLOGY, y in YEAR:TotalAnnualMaxCapacity[r,t,y]<>-1 && ResidualCapacity[r,t,y]<>0}: TotalAnnualMaxCapacity[r,t,y]>= ResidualCapacity[r,t,y] + TotalAnnualMinCapacityInvestment[r,t,y];
#
#####  'Minimum Annual activity' check   #####
printf "Checking Annual production by technology bounds for r in REGION, t in TECHNOLOGY, y in YEAR \n";
#
check{r in REGION, t in TECHNOLOGY, y in YEAR:TotalAnnualMaxCapacity[r,t,y]<>0 && TotalAnnualMaxCapacity[r,t,y] <> -1 && TotalTechnologyAnnualActivityLowerLimit[r,t,y]<>0 && AvailabilityFactor[r,t,y]<>0 && CapacityToActivityUnit[r,t]<>0}: sum{l in TIMESLICE: CapacityFactor[r,t,l,y]<>0 && YearSplit[l,y]<>0}(CapacityFactor[r,t,l,y]*YearSplit[l,y])*TotalAnnualMaxCapacity[r,t,y]* AvailabilityFactor[r,t,y]*CapacityToActivityUnit[r,t] >= TotalTechnologyAnnualActivityLowerLimit[r,t,y];
#
#####    'Time Slice' check     #####
printf "Checking TimeSlices/YearSplits for y in YEAR \n";
#
check{y in YEAR}: sum{l in TIMESLICE} YearSplit[l,y] >= 0.9999;
check{y in YEAR}: sum{l in TIMESLICE} YearSplit[l,y] <= 1.0001;
#
#####   'Model period activity limit' check   #####
printf "Checking Model period activity bounds for r in REGION, t in TECHNOLOGY \n";
#
check{r in REGION, t in TECHNOLOGY: TotalTechnologyModelPeriodActivityLowerLimit[r,t]<>0}:TotalTechnologyModelPeriodActivityLowerLimit[r,t] >= sum{y in YEAR: TotalTechnologyAnnualActivityLowerLimit[r,t,y] <>0}TotalTechnologyAnnualActivityLowerLimit[r,t,y];

#
#
######################
#   Model Variables  #
######################
#
########			Demands 					#############
#
var pv_RateOfDemand{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR}>= 0;
var pv_Demand{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR}>= 0;
#
########     		Storage                 		#############
#
var RateOfStorageCharge{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR};
var RateOfStorageDischarge{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR};
var NetChargeWithinYear{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR};
var NetChargeWithinDay{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR};
var StorageLevelYearStart{r in REGION, s in STORAGE, y in YEAR} >=0;
var StorageLevelYearFinish{r in REGION, s in STORAGE, y in YEAR} >=0;
var StorageLevelSeasonStart{r in REGION, s in STORAGE, ls in SEASON, y in YEAR} >=0;
var StorageLevelDayTypeStart{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, y in YEAR} >=0;
var StorageLevelDayTypeFinish{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, y in YEAR} >=0;
var StorageLowerLimit{r in REGION, s in STORAGE, y in YEAR}>=0;
var StorageUpperLimit{r in REGION, s in STORAGE, y in YEAR} >=0;
																																																																																																																																																	  
var AccumulatedNewStorageCapacity{r in REGION, s in STORAGE, y in YEAR} >=0;
var NewStorageCapacity{r in REGION, s in STORAGE, y in YEAR} >=0;
																																																																																																																																																																												  
var CapitalInvestmentStorage{r in REGION, s in STORAGE, y in YEAR} >=0;
var DiscountedCapitalInvestmentStorage{r in REGION, s in STORAGE, y in YEAR} >=0;
var SalvageValueStorage{r in REGION, s in STORAGE, y in YEAR} >=0;
var DiscountedSalvageValueStorage{r in REGION, s in STORAGE, y in YEAR} >=0;
var TotalDiscountedStorageCost{r in REGION, s in STORAGE, y in YEAR} >=0;
#
#########		    Capacity Variables 			#############
#
var NumberOfNewTechnologyUnits{r in REGION, t in TECHNOLOGY, y in YEAR} >= 0,integer;
var NewCapacity{r in REGION, t in TECHNOLOGY, y in YEAR} >= 0;
var AccumulatedNewCapacity{r in REGION, t in TECHNOLOGY, y in YEAR} >= 0;
var TotalCapacityAnnual{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
#
#########		    Activity Variables 			#############
#
var RateOfActivity{r in REGION, l in TIMESLICE, t in TECHNOLOGY, m in MODE_OF_OPERATION, y in YEAR} >= 0;
var RateOfTotalActivity{r in REGION, t in TECHNOLOGY, l in TIMESLICE, y in YEAR} >= 0;
var TotalTechnologyAnnualActivity{r in REGION, t in TECHNOLOGY, y in YEAR} >= 0;
var TotalAnnualTechnologyActivityByMode{r in REGION, t in TECHNOLOGY, m in MODE_OF_OPERATION, y in YEAR}>=0;
var TotalTechnologyModelPeriodActivity{r in REGION, t in TECHNOLOGY};
var RateOfProductionByTechnologyByMode{r in REGION, l in TIMESLICE, t in TECHNOLOGY, m in MODE_OF_OPERATION, f in FUEL, y in YEAR}>= 0;
var RateOfProductionByTechnology{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR}>= 0;
var ProductionByTechnology{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR}>= 0;
var ProductionByTechnologyAnnual{r in REGION, t in TECHNOLOGY, f in FUEL, y in YEAR}>= 0;
var RateOfProduction{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR} >= 0;
var Production{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR} >= 0;
var RateOfUseByTechnologyByMode{r in REGION, l in TIMESLICE, t in TECHNOLOGY, m in MODE_OF_OPERATION, f in FUEL, y in YEAR}>= 0;
var RateOfUseByTechnology{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR} >= 0;
var UseByTechnologyAnnual{r in REGION, t in TECHNOLOGY, f in FUEL, y in YEAR}>= 0;
var RateOfUse{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR}>= 0;
var UseByTechnology{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR}>= 0;
var Use{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR}>= 0;
var Trade{r in REGION, rr in REGION, l in TIMESLICE, f in FUEL, y in YEAR};
var TradeAnnual{r in REGION, rr in REGION, f in FUEL, y in YEAR};
#
var ProductionAnnual{r in REGION, f in FUEL, y in YEAR}>= 0;
var UseAnnual{r in REGION, f in FUEL, y in YEAR}>= 0;
	   
 
	   
																																																																 
																																																																																																																																				  
																																																																																																	
																																																																																																																																																																			 
																																																																																																		 
																																																																																																																																																																																																																			  
																																																																																																																														  
																																																																																																																																										 
																																																																																																																																										   
																																																																																																													   
																																																																																								
																																																																																																																																																																										 
																																																																																																																																										 
																																																																																																	   
#
#########		    Costing Variables 			#############
#
var CapitalInvestment{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
var DiscountedCapitalInvestment{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
#
var SalvageValue{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
var DiscountedSalvageValue{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
var OperatingCost{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
 
																																																																										
																																																																																																		   
var DiscountedOperatingCost{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
																																																																																																					  
																																																																																																													   
#
var AnnualVariableOperatingCost{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
var AnnualFixedOperatingCost{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
#
var TotalDiscountedCostByTechnology{r in REGION, t in TECHNOLOGY, y in YEAR}>= 0;
var TotalDiscountedCost{r in REGION, y in YEAR}>= 0;
#
var ModelPeriodCostByRegion{r in REGION} >= 0;
#
#########			Reserve Margin				#############
 
#
var TotalCapacityInReserveMargin{r in REGION, y in YEAR}>= 0;
var DemandNeedingReserveMargin{r in REGION,l in TIMESLICE, y in YEAR}>= 0;
#
#########			RE Gen Target				#############
#
var TotalREProductionAnnual{r in REGION, y in YEAR};
var RETotalProductionOfTargetFuelAnnual{r in REGION, y in YEAR};
#
#########			Emissions					#############
#
var AnnualTechnologyEmissionByMode{r in REGION, t in TECHNOLOGY, e in EMISSION, m in MODE_OF_OPERATION, y in YEAR}>=0;
var AnnualTechnologyEmission{r in REGION, t in TECHNOLOGY, e in EMISSION, y in YEAR}>=0;
var AnnualTechnologyEmissionPenaltyByEmission{r in REGION, t in TECHNOLOGY, e in EMISSION, y in YEAR}>=0;
var AnnualTechnologyEmissionsPenalty{r in REGION, t in TECHNOLOGY, y in YEAR}>=0;
var DiscountedTechnologyEmissionsPenalty{r in REGION, t in TECHNOLOGY, y in YEAR}>=0;
var AnnualEmissions{r in REGION, e in EMISSION, y in YEAR}>=0;
var ModelPeriodEmissions{r in REGION, e in EMISSION}>=0;
	  
																																																																																																																														   
	   
																																																																															 
																																																																																																																																																																																		 
#
																																																																																																																																																																		   
																																																																																																																									
																																																																																																		   
######################
# Objective Function #
######################
#
minimize cost: sum{r in REGION, y in YEAR} TotalDiscountedCost[r,y];
					  
					  
 
																																																					  
	 
		 
			 
				 
																																																																																																												   
																																																							 
																																																																														   
																																																																																							   
																																																																																																																																					
																														 
																																																										  
#
#####################
# Constraints       #
#####################
#
s.t. EQ_SpecifiedDemand{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR:
						SpecifiedAnnualDemand[r,f,y] <> 0}:
	SpecifiedAnnualDemand[r,f,y] * SpecifiedDemandProfile[r,f,l,y] / YearSplit[l,y]
	=
	pv_RateOfDemand[r,l,f,y];
#
#########       	Capacity Adequacy A	     	#############
#
s.t. CAa1_TotalNewCapacity{r in REGION, t in TECHNOLOGY, y in YEAR}:
	AccumulatedNewCapacity[r,t,y]
	=
	sum{yy in YEAR: y-yy < OperationalLife[r,t] && y - yy >= 0} NewCapacity[r,t,yy];

s.t. CAa2_TotalAnnualCapacity{r in REGION, t in TECHNOLOGY, y in YEAR}:
	AccumulatedNewCapacity[r,t,y] + ResidualCapacity[r,t,y]
	=
	TotalCapacityAnnual[r,t,y];

s.t. CAa3_TotalActivityOfEachTechnology{r in REGION, t in TECHNOLOGY, l in TIMESLICE, y in YEAR}:
	sum{m in MODE_OF_OPERATION} RateOfActivity[r,l,t,m,y]
	=
	RateOfTotalActivity[r,t,l,y];

s.t. CAa4_Constraint_Capacity{r in REGION, l in TIMESLICE, t in TECHNOLOGY, y in YEAR}:
	RateOfTotalActivity[r,t,l,y]
	<=
	TotalCapacityAnnual[r,t,y] * CapacityFactor[r,t,l,y] * CapacityToActivityUnit[r,t];

s.t. CAa5_TotalNewCapacity{r in REGION, t in TECHNOLOGY, y in YEAR: CapacityOfOneTechnologyUnit[r,t,y]<>0}:
	CapacityOfOneTechnologyUnit[r,t,y] * NumberOfNewTechnologyUnits[r,t,y]
	=
	NewCapacity[r,t,y];

#
# Note that the PlannedMaintenance equation below ensures that all other technologies have a capacity great enough
# to at least meet the annual average.
#
#########       	Capacity Adequacy B		 	#############
#
s.t. CAb1_PlannedMaintenance{r in REGION, t in TECHNOLOGY, y in YEAR: AvailabilityFactor[r,t,y] < 1}:
	sum{l in TIMESLICE} RateOfTotalActivity[r,t,l,y] * YearSplit[l,y]
	<=
	sum{l in TIMESLICE} (TotalCapacityAnnual[r,t,y] * CapacityFactor[r,t,l,y] * YearSplit[l,y])
	* AvailabilityFactor[r,t,y] * CapacityToActivityUnit[r,t];

#
#########	        Energy Balance A    	 	#############
#
s.t. EBa1_RateOfFuelProduction1{
	r in REGION, l in TIMESLICE, f in FUEL, t in TECHNOLOGY, m in MODE_OF_OPERATION, y in YEAR:
	OutputActivityRatio[r,t,f,m,y] <> 0}:
	RateOfActivity[r,l,t,m,y] * OutputActivityRatio[r,t,f,m,y]
	=
	RateOfProductionByTechnologyByMode[r,l,t,m,f,y];

s.t. EBa2_RateOfFuelProduction2{r in REGION, l in TIMESLICE, f in FUEL, t in TECHNOLOGY, y in YEAR
								# : (sum{m in MODE_OF_OPERATION} OutputActivityRatio[r,t,f,m,y]) <> 0
								}:
	sum{m in MODE_OF_OPERATION: OutputActivityRatio[r,t,f,m,y] <> 0} RateOfProductionByTechnologyByMode[r,l,t,m,f,y]
	=
	RateOfProductionByTechnology[r,l,t,f,y];

s.t. EBa3_RateOfFuelProduction3{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR:
							    (sum{t in TECHNOLOGY, m in MODE_OF_OPERATION} OutputActivityRatio[r,t,f,m,y]) <> 0}:
	sum{t in TECHNOLOGY} RateOfProductionByTechnology[r,l,t,f,y]
	=
	RateOfProduction[r,l,f,y];

s.t. EBa4_RateOfFuelUse1{r in REGION, l in TIMESLICE, f in FUEL, t in TECHNOLOGY, m in MODE_OF_OPERATION, y in YEAR:
						 InputActivityRatio[r,t,f,m,y] <> 0}:
	RateOfActivity[r,l,t,m,y] * InputActivityRatio[r,t,f,m,y]
	=
	RateOfUseByTechnologyByMode[r,l,t,m,f,y];

s.t. EBa5_RateOfFuelUse2{r in REGION, l in TIMESLICE, f in FUEL, t in TECHNOLOGY, y in YEAR:
						 sum{m in MODE_OF_OPERATION} InputActivityRatio[r,t,f,m,y] <> 0}:
	sum{m in MODE_OF_OPERATION: InputActivityRatio[r,t,f,m,y] <> 0}
	RateOfUseByTechnologyByMode[r,l,t,m,f,y]
	=
	RateOfUseByTechnology[r,l,t,f,y];

s.t. EBa6_RateOfFuelUse3{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR:
						 sum{t in TECHNOLOGY, m in MODE_OF_OPERATION} InputActivityRatio[r,t,f,m,y] <> 0}:
	sum{t in TECHNOLOGY} RateOfUseByTechnology[r,l,t,f,y]
	=
	RateOfUse[r,l,f,y];

s.t. EBa7_EnergyBalanceEachTS1{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR:
							   (sum{t in TECHNOLOGY, m in MODE_OF_OPERATION} OutputActivityRatio[r,t,f,m,y]) <> 0}:
	RateOfProduction[r,l,f,y] * YearSplit[l,y]
	=
	Production[r,l,f,y];

s.t. EBa8_EnergyBalanceEachTS2{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR:
							   (sum{t in TECHNOLOGY, m in MODE_OF_OPERATION} InputActivityRatio[r,t,f,m,y]) <> 0}:
	RateOfUse[r,l,f,y] * YearSplit[l,y]
	=
	Use[r,l,f,y];

s.t. EBa9_EnergyBalanceEachTS3{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR:
							   SpecifiedAnnualDemand[r,f,y] <> 0}:
	pv_RateOfDemand[r,l,f,y] * YearSplit[l,y]
	=
	pv_Demand[r,l,f,y];

s.t. EBa10_EnergyBalanceEachTS4{r in REGION, rr in REGION, l in TIMESLICE, f in FUEL, y in YEAR:
								TradeRoute[r,rr,f,y] <> 0}:
	Trade[r,rr,l,f,y]
	=
	-Trade[rr,r,l,f,y];

s.t. EBa11_EnergyBalanceEachTS5{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR}:
	Production[r,l,f,y]
	>=
	pv_Demand[r,l,f,y] + Use[r,l,f,y] + sum{rr in REGION} Trade[r,rr,l,f,y] * TradeRoute[r,rr,f,y];

#
#########        	Energy Balance B		 	#############
#
s.t. EBb1_EnergyBalanceEachYear1{r in REGION, f in FUEL, y in YEAR}:
	sum{l in TIMESLICE} Production[r,l,f,y]
	=
	ProductionAnnual[r,f,y];

s.t. EBb2_EnergyBalanceEachYear2{r in REGION, f in FUEL, y in YEAR}:
	sum{l in TIMESLICE} Use[r,l,f,y]
	=
	UseAnnual[r,f,y];

s.t. EBb3_EnergyBalanceEachYear3{r in REGION, rr in REGION, f in FUEL, y in YEAR}:
	sum{l in TIMESLICE} Trade[r,rr,l,f,y]
	=
	TradeAnnual[r,rr,f,y];

s.t. EBb4_EnergyBalanceEachYear4{r in REGION, f in FUEL, y in YEAR}:
	ProductionAnnual[r,f,y]
	>=
	UseAnnual[r,f,y] + sum{rr in REGION} TradeAnnual[r,rr,f,y] * TradeRoute[r,rr,f,y] + AccumulatedAnnualDemand[r,f,y];

#
#########        	Accounting Technology Production/Use	#############
#
s.t. Acc1_FuelProductionByTechnology{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR}:
	RateOfProductionByTechnology[r,l,t,f,y] * YearSplit[l,y]
	=
	ProductionByTechnology[r,l,t,f,y];

s.t. Acc2_FuelUseByTechnology{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR}:
	RateOfUseByTechnology[r,l,t,f,y] * YearSplit[l,y]
	=
	UseByTechnology[r,l,t,f,y];

s.t. Acc3_AverageAnnualRateOfActivity{r in REGION, t in TECHNOLOGY, m in MODE_OF_OPERATION, y in YEAR}:
	sum{l in TIMESLICE} RateOfActivity[r,l,t,m,y]*YearSplit[l,y]
	=
	TotalAnnualTechnologyActivityByMode[r,t,m,y];

s.t. Acc4_ModelPeriodCostByRegion{r in REGION}:
	sum{y in YEAR}TotalDiscountedCost[r,y] = ModelPeriodCostByRegion[r];

#
#########        	Storage Equations			#############
#
s.t. S1_RateOfStorageCharge{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}:
	sum{t in TECHNOLOGY, m in MODE_OF_OPERATION, l in TIMESLICE: TechnologyToStorage[r,t,s,m] > 0}
	RateOfActivity[r,l,t,m,y] * TechnologyToStorage[r,t,s,m] * Conversionls[l,ls] * Conversionld[l,ld] * Conversionlh[l,lh]
	=
	RateOfStorageCharge[r,s,ls,ld,lh,y];

s.t. S2_RateOfStorageDischarge{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}:
	sum{t in TECHNOLOGY, m in MODE_OF_OPERATION, l in TIMESLICE: TechnologyFromStorage[r,t,s,m] > 0}
	RateOfActivity[r,l,t,m,y] * TechnologyFromStorage[r,t,s,m] * Conversionls[l,ls] * Conversionld[l,ld] * Conversionlh[l,lh]
	=
	RateOfStorageDischarge[r,s,ls,ld,lh,y];

s.t. S3_NetChargeWithinYear{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}:
	sum{l in TIMESLICE:Conversionls[l,ls]>0 && Conversionld[l,ld] > 0 && Conversionlh[l,lh] > 0}
	(RateOfStorageCharge[r,s,ls,ld,lh,y] - RateOfStorageDischarge[r,s,ls,ld,lh,y]) * YearSplit[l,y] *
	Conversionls[l,ls] * Conversionld[l,ld] * Conversionlh[l,lh]
	=
	NetChargeWithinYear[r,s,ls,ld,lh,y];

s.t. S4_NetChargeWithinDay{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}:
	(RateOfStorageCharge[r,s,ls,ld,lh,y] - RateOfStorageDischarge[r,s,ls,ld,lh,y]) * DaySplit[lh,y]
	=
	NetChargeWithinDay[r,s,ls,ld,lh,y];

s.t. S5_and_S6_StorageLevelYearStart{r in REGION, s in STORAGE, y in YEAR}:
	if y = min{yy in YEAR} min(yy)
	then StorageLevelStart[r,s]
	else StorageLevelYearStart[r,s,y-1] + sum{ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET}
	NetChargeWithinYear[r,s,ls,ld,lh,y-1]
	=
	StorageLevelYearStart[r,s,y];

s.t. S7_and_S8_StorageLevelYearFinish{r in REGION, s in STORAGE, y in YEAR}:
	if y < max{yy in YEAR} max(yy)
	then StorageLevelYearStart[r,s,y+1]
	else StorageLevelYearStart[r,s,y] + sum{ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET}
	NetChargeWithinYear[r,s,ls,ld,lh,y]
	=
	StorageLevelYearFinish[r,s,y];

s.t. S9_and_S10_StorageLevelSeasonStart{r in REGION, s in STORAGE, ls in SEASON, y in YEAR}:
	if ls = min{lsls in SEASON} min(lsls)
	then StorageLevelYearStart[r,s,y]
	else StorageLevelSeasonStart[r,s,ls-1,y] + sum{ld in DAYTYPE, lh in DAILYTIMEBRACKET}
	NetChargeWithinYear[r,s,ls-1,ld,lh,y]
	=
	StorageLevelSeasonStart[r,s,ls,y];

s.t. S11_and_S12_StorageLevelDayTypeStart{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, y in YEAR}:
	if ld = min{ldld in DAYTYPE} min(ldld)
	then StorageLevelSeasonStart[r,s,ls,y]
	else StorageLevelDayTypeStart[r,s,ls,ld-1,y] + sum{lh in DAILYTIMEBRACKET}
	NetChargeWithinDay[r,s,ls,ld-1,lh,y] * DaysInDayType[ls,ld-1,y]
	=
	StorageLevelDayTypeStart[r,s,ls,ld,y];

s.t. S13_and_S14_and_S15_StorageLevelDayTypeFinish{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, y in YEAR}:
	if ls = max{lsls in SEASON} max(lsls) && ld = max{ldld in DAYTYPE} max(ldld)
	then StorageLevelYearFinish[r,s,y]
	else if ld = max{ldld in DAYTYPE} max(ldld)
	then StorageLevelSeasonStart[r,s,ls+1,y]
	else StorageLevelDayTypeFinish[r,s,ls,ld+1,y] - sum{lh in DAILYTIMEBRACKET}
	NetChargeWithinDay[r,s,ls,ld+1,lh,y] * DaysInDayType[ls,ld+1,y]
	=
	StorageLevelDayTypeFinish[r,s,ls,ld,y];

#
##########		Storage Constraints				#############
#
s.t. SC1_LowerLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInFirstWeekConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}: 0 <= (StorageLevelDayTypeStart[r,s,ls,ld,y]+sum{lhlh in DAILYTIMEBRACKET:lh-lhlh>0} NetChargeWithinDay[r,s,ls,ld,lhlh,y])-StorageLowerLimit[r,s,y];
s.t. SC1_UpperLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInFirstWeekConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}: (StorageLevelDayTypeStart[r,s,ls,ld,y]+sum{lhlh in DAILYTIMEBRACKET:lh-lhlh>0} NetChargeWithinDay[r,s,ls,ld,lhlh,y])-StorageUpperLimit[r,s,y] <= 0;
s.t. SC2_LowerLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInFirstWeekConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}: 0 <= if ld > min{ldld in DAYTYPE} min(ldld) then (StorageLevelDayTypeStart[r,s,ls,ld,y]-sum{lhlh in DAILYTIMEBRACKET:lh-lhlh<0} NetChargeWithinDay[r,s,ls,ld-1,lhlh,y])-StorageLowerLimit[r,s,y];
s.t. SC2_UpperLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInFirstWeekConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}: if ld > min{ldld in DAYTYPE} min(ldld) then (StorageLevelDayTypeStart[r,s,ls,ld,y]-sum{lhlh in DAILYTIMEBRACKET:lh-lhlh<0} NetChargeWithinDay[r,s,ls,ld-1,lhlh,y])-StorageUpperLimit[r,s,y] <= 0;
s.t. SC3_LowerLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInLastWeekConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}:  0 <= (StorageLevelDayTypeFinish[r,s,ls,ld,y] - sum{lhlh in DAILYTIMEBRACKET:lh-lhlh<0} NetChargeWithinDay[r,s,ls,ld,lhlh,y])-StorageLowerLimit[r,s,y];
s.t. SC3_UpperLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInLastWeekConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}:  (StorageLevelDayTypeFinish[r,s,ls,ld,y] - sum{lhlh in DAILYTIMEBRACKET:lh-lhlh<0} NetChargeWithinDay[r,s,ls,ld,lhlh,y])-StorageUpperLimit[r,s,y] <= 0;
s.t. SC4_LowerLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInLastWeekConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}: 	0 <= if ld > min{ldld in DAYTYPE} min(ldld) then (StorageLevelDayTypeFinish[r,s,ls,ld-1,y]+sum{lhlh in DAILYTIMEBRACKET:lh-lhlh>0} NetChargeWithinDay[r,s,ls,ld,lhlh,y])-StorageLowerLimit[r,s,y];
s.t. SC4_UpperLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInLastWeekConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}: if ld > min{ldld in DAYTYPE} min(ldld) then (StorageLevelDayTypeFinish[r,s,ls,ld-1,y]+sum{lhlh in DAILYTIMEBRACKET:lh-lhlh>0} NetChargeWithinDay[r,s,ls,ld,lhlh,y])-StorageUpperLimit[r,s,y] <= 0;
s.t. SC5_MaxChargeConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}: RateOfStorageCharge[r,s,ls,ld,lh,y] <= StorageMaxChargeRate[r,s];
s.t. SC6_MaxDischargeConstraint{r in REGION, s in STORAGE, ls in SEASON, ld in DAYTYPE, lh in DAILYTIMEBRACKET, y in YEAR}: RateOfStorageDischarge[r,s,ls,ld,lh,y] <= StorageMaxDischargeRate[r,s];
#
#########		Storage Investments				#############
#
s.t. SI1_StorageUpperLimit{r in REGION, s in STORAGE, y in YEAR}: AccumulatedNewStorageCapacity[r,s,y]+ResidualStorageCapacity[r,s,y] = StorageUpperLimit[r,s,y];
s.t. SI2_StorageLowerLimit{r in REGION, s in STORAGE, y in YEAR}: MinStorageCharge[r,s,y]*StorageUpperLimit[r,s,y] = StorageLowerLimit[r,s,y];
s.t. SI3_TotalNewStorage{r in REGION, s in STORAGE, y in YEAR}: sum{yy in YEAR: y-yy < OperationalLifeStorage[r,s] && y-yy>=0} NewStorageCapacity[r,s,yy]=AccumulatedNewStorageCapacity[r,s,y];
s.t. SI4_UndiscountedCapitalInvestmentStorage{r in REGION, s in STORAGE, y in YEAR}: CapitalCostStorage[r,s,y] * NewStorageCapacity[r,s,y] = CapitalInvestmentStorage[r,s,y];
s.t. SI5_DiscountingCapitalInvestmentStorage{r in REGION, s in STORAGE, y in YEAR}: CapitalInvestmentStorage[r,s,y]/(DiscountFactorStorage[r,s,y]) = DiscountedCapitalInvestmentStorage[r,s,y];
s.t. SI6_SalvageValueStorageAtEndOfPeriod1{r in REGION, s in STORAGE, y in YEAR: (y+OperationalLifeStorage[r,s]-1) <= (max{yy in YEAR} max(yy))}: 0 = SalvageValueStorage[r,s,y];
s.t. SI7_SalvageValueStorageAtEndOfPeriod2{r in REGION, s in STORAGE, y in YEAR: (DepreciationMethod[r]=1 && (y+OperationalLifeStorage[r,s]-1) > (max{yy in YEAR} max(yy)) && DiscountRateStorage[r,s]=0) || (DepreciationMethod[r]=2 && (y+OperationalLifeStorage[r,s]-1) > (max{yy in YEAR} max(yy)))}: CapitalInvestmentStorage[r,s,y]*(1-(max{yy in YEAR} max(yy) - y+1)/OperationalLifeStorage[r,s]) = SalvageValueStorage[r,s,y];
s.t. SI8_SalvageValueStorageAtEndOfPeriod3{r in REGION, s in STORAGE, y in YEAR: DepreciationMethod[r]=1 && (y+OperationalLifeStorage[r,s]-1) > (max{yy in YEAR} max(yy)) && DiscountRateStorage[r,s]>0}: CapitalInvestmentStorage[r,s,y]*(1-(((1+DiscountRateStorage[r,s])^(max{yy in YEAR} max(yy) - y+1)-1)/((1+DiscountRateStorage[r,s])^OperationalLifeStorage[r,s]-1))) = SalvageValueStorage[r,s,y];
																																																											
																																																																																																																																																																																																																																																	  
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																					  
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																									
																																																																																																																																																																																																																																																																																																														   
s.t. SI9_SalvageValueStorageDiscountedToStartYear{r in REGION, s in STORAGE, y in YEAR}: SalvageValueStorage[r,s,y]/((1+DiscountRateStorage[r,s])^(max{yy in YEAR} max(yy)-min{yy in YEAR} min(yy)+1)) = DiscountedSalvageValueStorage[r,s,y];
s.t. SI10_TotalDiscountedCostByStorage{r in REGION, s in STORAGE, y in YEAR}: DiscountedCapitalInvestmentStorage[r,s,y]-DiscountedSalvageValueStorage[r,s,y] = TotalDiscountedStorageCost[r,s,y];
#
#########       	Capital Costs 		     	#############
#
s.t. CC1_UndiscountedCapitalInvestment{r in REGION, t in TECHNOLOGY, y in YEAR}: CapitalCost[r,t,y] * NewCapacity[r,t,y] * CapitalRecoveryFactor[r,t] * PvAnnuity[r,t] = CapitalInvestment[r,t,y];

s.t. CC2_DiscountingCapitalInvestment{r in REGION, t in TECHNOLOGY, y in YEAR}: CapitalInvestment[r,t,y]  / DiscountFactor[r,y] = DiscountedCapitalInvestment[r,t,y];


#
#########           Salvage Value            	#############
#
s.t. SV1_SalvageValueAtEndOfPeriod1{r in REGION, t in TECHNOLOGY, y in YEAR: DepreciationMethod[r]=1 && (y + OperationalLife[r,t]-1) > (max{yy in YEAR} max(yy)) && DiscountRate[r]>0}: SalvageValue[r,t,y] = CapitalCost[r,t,y] * NewCapacity[r,t,y] * CapitalRecoveryFactor[r,t] * PvAnnuity[r,t] *(1-(((1+DiscountRate[r])^(max{yy in YEAR} max(yy) - y+1)-1)/((1+DiscountRate[r])^OperationalLife[r,t]-1)));
s.t. SV2_SalvageValueAtEndOfPeriod2{r in REGION, t in TECHNOLOGY, y in YEAR: (DepreciationMethod[r]=1 && (y + OperationalLife[r,t]-1) > (max{yy in YEAR} max(yy)) && DiscountRate[r]=0) || (DepreciationMethod[r]=2 && (y + OperationalLife[r,t]-1) > (max{yy in YEAR} max(yy)))}: SalvageValue[r,t,y] = CapitalCost[r,t,y] * NewCapacity[r,t,y] * CapitalRecoveryFactor[r,t] * PvAnnuity[r,t] *(1-(max{yy in YEAR} max(yy) - y+1)/OperationalLife[r,t]);
s.t. SV3_SalvageValueAtEndOfPeriod3{r in REGION, t in TECHNOLOGY, y in YEAR: (y + OperationalLife[r,t]-1) <= (max{yy in YEAR} max(yy))}: SalvageValue[r,t,y] = 0;
s.t. SV4_SalvageValueDiscountedToStartYear{r in REGION, t in TECHNOLOGY, y in YEAR}: DiscountedSalvageValue[r,t,y] = SalvageValue[r,t,y]/((1+DiscountRate[r])^(1+max{yy in YEAR} max(yy)-min{yy in YEAR} min(yy)));
#
#########        	Operating Costs 		 	#############
#

s.t. OC1_OperatingCostsVariable{r in REGION, t in TECHNOLOGY, l in TIMESLICE, y in YEAR: sum{m in MODE_OF_OPERATION} VariableCost[r,t,m,y] <> 0}:
	sum{m in MODE_OF_OPERATION}
	TotalAnnualTechnologyActivityByMode[r,t,m,y] * VariableCost[r,t,m,y]
	=
	AnnualVariableOperatingCost[r,t,y];

s.t. OC2_OperatingCostsFixedAnnual{r in REGION, t in TECHNOLOGY, y in YEAR}:
	TotalCapacityAnnual[r,t,y]*FixedCost[r,t,y]
	=
	AnnualFixedOperatingCost[r,t,y];

s.t. OC3_OperatingCostsTotalAnnual{r in REGION, t in TECHNOLOGY, y in YEAR}:
	AnnualFixedOperatingCost[r,t,y] + AnnualVariableOperatingCost[r,t,y]
	=
	OperatingCost[r,t,y];

s.t. OC4_DiscountedOperatingCostsTotalAnnual{r in REGION, t in TECHNOLOGY, y in YEAR}:
	OperatingCost[r,t,y] / DiscountFactorMid[r, y]
	=
	DiscountedOperatingCost[r,t,y];
  
#
#########       	Total Discounted Costs	 	#############
#
s.t. TDC1_TotalDiscountedCostByTechnology{r in REGION, t in TECHNOLOGY, y in YEAR}: DiscountedOperatingCost[r,t,y]+DiscountedCapitalInvestment[r,t,y]+DiscountedTechnologyEmissionsPenalty[r,t,y]-DiscountedSalvageValue[r,t,y] = TotalDiscountedCostByTechnology[r,t,y];
s.t. TDC2_TotalDiscountedCost{r in REGION, y in YEAR}: sum{t in TECHNOLOGY} TotalDiscountedCostByTechnology[r,t,y]+sum{s in STORAGE} TotalDiscountedStorageCost[r,s,y] = TotalDiscountedCost[r,y];
																																																																													  
#
#########      		Total Capacity Constraints 	##############
#
s.t. TCC1_TotalAnnualMaxCapacityConstraint{r in REGION, t in TECHNOLOGY, y in YEAR: TotalAnnualMaxCapacity[r,t,y] <> -1}: TotalCapacityAnnual[r,t,y] <= TotalAnnualMaxCapacity[r,t,y];
 
																																																																																																																		 
 
																																																																																																																																																																																		  
s.t. TCC2_TotalAnnualMinCapacityConstraint{r in REGION, t in TECHNOLOGY, y in YEAR: TotalAnnualMinCapacity[r,t,y]>0}: TotalCapacityAnnual[r,t,y] >= TotalAnnualMinCapacity[r,t,y];
#
#########    		New Capacity Constraints  	##############
#
s.t. NCC1_TotalAnnualMaxNewCapacityConstraint{r in REGION, t in TECHNOLOGY, y in YEAR: TotalAnnualMaxCapacityInvestment[r,t,y] <> -1}: NewCapacity[r,t,y] <= TotalAnnualMaxCapacityInvestment[r,t,y];
 
																																																																														
 
s.t. NCC2_TotalAnnualMinNewCapacityConstraint{r in REGION, t in TECHNOLOGY, y in YEAR: TotalAnnualMinCapacityInvestment[r,t,y]>0}: NewCapacity[r,t,y] >= TotalAnnualMinCapacityInvestment[r,t,y];
#
#########   		Annual Activity Constraints	##############
																																																																														
																																																																																																																																																																																																																																																																																						  
 
																																																																																																													
 
																																																																																																												
																																																																																							  
																																																								 
																																																												 
	  
#
s.t. AAC1_TotalAnnualTechnologyActivity{r in REGION, t in TECHNOLOGY, y in YEAR}: sum{l in TIMESLICE} RateOfTotalActivity[r,t,l,y]*YearSplit[l,y] = TotalTechnologyAnnualActivity[r,t,y];
s.t. AAC2_TotalAnnualTechnologyActivityUpperLimit{r in REGION, t in TECHNOLOGY, y in YEAR: TotalTechnologyAnnualActivityUpperLimit[r,t,y] <> -1}: TotalTechnologyAnnualActivity[r,t,y] <= TotalTechnologyAnnualActivityUpperLimit[r,t,y] ;
s.t. AAC3_TotalAnnualTechnologyActivityLowerLimit{r in REGION, t in TECHNOLOGY, y in YEAR: TotalTechnologyAnnualActivityLowerLimit[r,t,y]>0}: TotalTechnologyAnnualActivity[r,t,y] >= TotalTechnologyAnnualActivityLowerLimit[r,t,y] ;
#
#########    		Total Activity Constraints 	##############
																																																											
																																																	 
#
s.t. TAC1_TotalModelHorizonTechnologyActivity{r in REGION, t in TECHNOLOGY}: sum{y in YEAR} TotalTechnologyAnnualActivity[r,t,y] = TotalTechnologyModelPeriodActivity[r,t];
s.t. TAC2_TotalModelHorizonTechnologyActivityUpperLimit{r in REGION, t in TECHNOLOGY: TotalTechnologyModelPeriodActivityUpperLimit[r,t]<>-1}: TotalTechnologyModelPeriodActivity[r,t] <= TotalTechnologyModelPeriodActivityUpperLimit[r,t] ;
s.t. TAC3_TotalModelHorizenTechnologyActivityLowerLimit{r in REGION, t in TECHNOLOGY: TotalTechnologyModelPeriodActivityLowerLimit[r,t]>0}: TotalTechnologyModelPeriodActivity[r,t] >= TotalTechnologyModelPeriodActivityLowerLimit[r,t] ;
#
#########   		Reserve Margin Constraint	############## NTS: Should change demand for production
																																																	 
																																																											
#
s.t. RM1_ReserveMargin_TechnologiesIncluded_In_Activity_Units{r in REGION, l in TIMESLICE, y in YEAR: ReserveMargin[r,y] > 0}:
	sum {t in TECHNOLOGY}
	TotalCapacityAnnual[r,t,y] * ReserveMarginTagTechnology[r,t,y] * CapacityToActivityUnit[r,t]
	=
	TotalCapacityInReserveMargin[r,y];

s.t. RM2_ReserveMargin_FuelsIncluded{r in REGION, l in TIMESLICE, y in YEAR: ReserveMargin[r,y] > 0}:
	sum {f in FUEL}
	RateOfProduction[r,l,f,y] * ReserveMarginTagFuel[r,f,y]
	=
	DemandNeedingReserveMargin[r,l,y];

s.t. RM3_ReserveMargin_Constraint{r in REGION, l in TIMESLICE, y in YEAR: ReserveMargin[r,y] > 0}:
	DemandNeedingReserveMargin[r,l,y] * ReserveMargin[r,y]
	<=
	TotalCapacityInReserveMargin[r,y];

#
#########   		RE Production Target		############## NTS: Should change demand for production
  

 
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																	
#
s.t. RE1_FuelProductionByTechnologyAnnual{r in REGION, t in TECHNOLOGY, f in FUEL, y in YEAR}: sum{l in TIMESLICE} ProductionByTechnology[r,l,t,f,y] = ProductionByTechnologyAnnual[r,t,f,y];
s.t. RE2_TechIncluded{r in REGION, y in YEAR}: sum{t in TECHNOLOGY, f in FUEL} ProductionByTechnologyAnnual[r,t,f,y]*RETagTechnology[r,t,y] = TotalREProductionAnnual[r,y];
s.t. RE3_FuelIncluded{r in REGION, y in YEAR}: sum{l in TIMESLICE, f in FUEL} RateOfProduction[r,l,f,y]*YearSplit[l,y]*RETagFuel[r,f,y] = RETotalProductionOfTargetFuelAnnual[r,y];
s.t. RE4_EnergyConstraint{r in REGION, y in YEAR}:REMinProductionTarget[r,y]*RETotalProductionOfTargetFuelAnnual[r,y] <= TotalREProductionAnnual[r,y];
s.t. RE5_FuelUseByTechnologyAnnual{r in REGION, t in TECHNOLOGY, f in FUEL, y in YEAR}: sum{l in TIMESLICE} RateOfUseByTechnology[r,l,t,f,y]*YearSplit[l,y] = UseByTechnologyAnnual[r,t,f,y];
#
#########   		Emissions Accounting		##############
																														 
																																																				 
 
																																																																																																																																																																																																																																																																																																																																																																																																											 
																																																																																																																																																																																																																																																																																																																																																																																									 
																																																																																																																																																																																																																																																																																																																																																																																																																																																					  
																																																																																																																																																																																																																																																																																																																																																																			 
																																																																																																																																																														 
																																																																																																						
																																																																																																	
	   
																																																																  
#
s.t. E1_AnnualEmissionProductionByMode{r in REGION, t in TECHNOLOGY, e in EMISSION, m in MODE_OF_OPERATION, y in YEAR:
									   EmissionActivityRatio[r,t,e,m,y] <> 0}:
	EmissionActivityRatio[r,t,e,m,y] * TotalAnnualTechnologyActivityByMode[r,t,m,y]
	=
	AnnualTechnologyEmissionByMode[r,t,e,m,y];

s.t. E2_AnnualEmissionProduction{r in REGION, t in TECHNOLOGY, e in EMISSION, y in YEAR}:
	sum{m in MODE_OF_OPERATION}
	AnnualTechnologyEmissionByMode[r,t,e,m,y]
	=
	AnnualTechnologyEmission[r,t,e,y];

s.t. E3_EmissionsPenaltyByTechAndEmission{r in REGION, t in TECHNOLOGY, e in EMISSION, y in YEAR: EmissionsPenalty[r,e,y] <> 0}:
	AnnualTechnologyEmission[r,t,e,y] * EmissionsPenalty[r,e,y]
	=
	AnnualTechnologyEmissionPenaltyByEmission[r,t,e,y];

s.t. E4_EmissionsPenaltyByTechnology{r in REGION, t in TECHNOLOGY, y in YEAR}:
	sum{e in EMISSION} AnnualTechnologyEmissionPenaltyByEmission[r,t,e,y]
	=
	AnnualTechnologyEmissionsPenalty[r,t,y];

s.t. E5_DiscountedEmissionsPenaltyByTechnology{r in REGION, t in TECHNOLOGY, y in YEAR}:
	AnnualTechnologyEmissionsPenalty[r,t,y] / DiscountFactorMid[r,y]
	=
	DiscountedTechnologyEmissionsPenalty[r,t,y];

s.t. E6_EmissionsAccounting1{r in REGION, e in EMISSION, y in YEAR}:
	sum{t in TECHNOLOGY}
	AnnualTechnologyEmission[r,t,e,y]
	=
	AnnualEmissions[r,e,y];

s.t. E7_EmissionsAccounting2{r in REGION, e in EMISSION}:
	sum{y in YEAR} AnnualEmissions[r,e,y]
	=
	ModelPeriodEmissions[r,e] - ModelPeriodExogenousEmission[r,e];

s.t. E8_AnnualEmissionsLimit{r in REGION, e in EMISSION, y in YEAR: AnnualEmissionLimit[r, e, y] <> -1}:
	AnnualEmissions[r,e,y] + AnnualExogenousEmission[r,e,y]
	<=
	AnnualEmissionLimit[r,e,y];

s.t. E9_ModelPeriodEmissionsLimit{r in REGION, e in EMISSION: ModelPeriodEmissionLimit[r, e] <> -1}:
	ModelPeriodEmissions[r,e]
	<=
	ModelPeriodEmissionLimit[r,e];
#
###########################################################################################
#
 
# Solve the problem
solve;
#
#########################################################################################################
#                                                                                                                                                                                                                #
#         Summary results tables below are printed to a comma-separated file called ResultsPath                #
#        For a full set of results please see "Results.txt"                                                                                                        #
#        If you don't want these printed, please comment-out or delete them.                                                                        #
#                                                                                                                                                                                                                #
#########################################################################################################
#
																																																																																																																																																																																																																				  
####        Summary results         ###
#
###                Total costs and emissions by region        ###
#
printf "\n" > ResultsPath & "/SelectedResults.csv";
printf "Summary" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION}         {printf ",%s", r >> ResultsPath & "/SelectedResults.csv";
                                        }
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Emissions" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION}         {
                                        for {e in EMISSION}         {
                                                                                        printf ",%s", e >> ResultsPath & "/SelectedResults.csv";
                                                                                        printf ",%g", sum{l in TIMESLICE, t in TECHNOLOGY, m in MODE_OF_OPERATION, y in YEAR: EmissionActivityRatio[r,t,e,m,y]<>0} EmissionActivityRatio[r,t,e,m,y]*RateOfActivity[r,l,t,m,y]*YearSplit[l,y] + ModelPeriodExogenousEmission[r,e] >> ResultsPath & "/SelectedResults.csv";
                                                                                        printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                                                        }
                                        }
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Cost" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION} {printf ",%g", sum{t in TECHNOLOGY, y in YEAR}(((((sum{yy in YEAR: y-yy < OperationalLife[r,t] && y-yy>=0} NewCapacity[r,t,yy])+ ResidualCapacity[r,t,y])*FixedCost[r,t,y] + sum{m in MODE_OF_OPERATION, l in TIMESLICE} RateOfActivity[r,l,t,m,y]*YearSplit[l,y]*VariableCost[r,t,m,y])/DiscountFactorMid[r,y] + DiscountedCapitalInvestment[r,t,y] + DiscountedTechnologyEmissionsPenalty[r,t,y]-DiscountedSalvageValue[r,t,y]) + sum{s in STORAGE} (CapitalCostStorage[r,s,y] * NewStorageCapacity[r,s,y]/DiscountFactor[r,y]-CapitalCostStorage[r,s,y] * NewStorageCapacity[r,s,y]/DiscountFactor[r,y])) >> ResultsPath & "/SelectedResults.csv";
}
printf "\n" >> ResultsPath & "/SelectedResults.csv";
#
###         Time Independent demand        ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "TID Demand" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
        for {r in REGION}{printf ",%s", r >> ResultsPath & "/SelectedResults.csv";}
        printf "\n" >> ResultsPath & "/SelectedResults.csv";
		printf "Fuel" >> ResultsPath & "/SelectedResults.csv";
		#printf "," >> ResultsPath & "/SelectedResults.csv";
        for {y in YEAR}{printf ",%g", y >> ResultsPath & "/SelectedResults.csv";}
		printf "\n" >> ResultsPath & "/SelectedResults.csv";
		for {r in REGION}{
							for {f in FUEL} {printf "%s,", f >> ResultsPath & "/SelectedResults.csv";
											#printf ",%s", f >> ResultsPath & "/SelectedResults.csv";
											for {y in YEAR}{
															#printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                            #printf "%g", y >> ResultsPath & "/SelectedResults.csv";
                                                            printf "%g,", AccumulatedAnnualDemand[r,f,y] >> ResultsPath & "/SelectedResults.csv";
                                                            #printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                            }
															printf "\n" >> ResultsPath & "/SelectedResults.csv";
											}
											#printf "\n" >> ResultsPath & "/SelectedResults.csv";
						}
#
###         Time Dependent demand        ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Time Dependent Demand (Energy Units)" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
		for {r in REGION}{printf ",%s", r >> ResultsPath & "/SelectedResults.csv";}
        printf "\n" >> ResultsPath & "/SelectedResults.csv";
		printf "Fuel" >> ResultsPath & "/SelectedResults.csv";
		printf ",Timeslice" >> ResultsPath & "/SelectedResults.csv";
        for {y in YEAR}{printf ",%g", y >> ResultsPath & "/SelectedResults.csv";}
		printf "\n" >> ResultsPath & "/SelectedResults.csv";
        for {r in REGION }{
							for {f in FUEL} {#printf "%s", f >> ResultsPath & "/SelectedResults.csv";
											 #printf "\n" >> ResultsPath & "/SelectedResults.csv";
											 for {l in TIMESLICE}{
																  printf "%s", f >> ResultsPath & "/SelectedResults.csv";
																  printf ",%s", l >> ResultsPath & "/SelectedResults.csv";
																						  for {y in YEAR}{printf ",%g", SpecifiedAnnualDemand[r,f,y]*SpecifiedDemandProfile[r,f,l,y] >> ResultsPath & "/SelectedResults.csv";
																										 }
																										  printf "\n" >> ResultsPath & "/SelectedResults.csv";
																 }
											}
							}
#
###         Time Dependent production ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Time Dependent Production (Energy Units) Test" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION}{printf ",%s", r >> ResultsPath & "/SelectedResults.csv";}
        printf "\n" >> ResultsPath & "/SelectedResults.csv";
		printf "Fuel" >> ResultsPath & "/SelectedResults.csv";
		printf ",Timeslice" >> ResultsPath & "/SelectedResults.csv";
        for {y in YEAR}{printf ",%g", y >> ResultsPath & "/SelectedResults.csv";}
		printf "\n" >> ResultsPath & "/SelectedResults.csv";
        for {r in REGION} {
							for {f in FUEL} {#printf "%s", f >> ResultsPath & "/SelectedResults.csv";
                                             #printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                             for {l in TIMESLICE}{
                                                                  printf "%s", f >> ResultsPath & "/SelectedResults.csv";
																  printf ",%s", l >> ResultsPath & "/SelectedResults.csv";
                                                                  for {y in YEAR }{
                                                                                   printf ",%g", sum{m in MODE_OF_OPERATION, t in TECHNOLOGY: OutputActivityRatio[r,t,f,m,y] <>0} RateOfActivity[r,l,t,m,y]*OutputActivityRatio[r,t,f,m,y]*YearSplit[l,y] >> ResultsPath & "/SelectedResults.csv";
                                                                                  }
                                                                                   printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                                 }
                                            }
                           }
#
####        Total Annual Capacity        ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "TotalAnnualCapacity (Capacity Units)" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Technology" >> ResultsPath & "/SelectedResults.csv";
for {y in YEAR} {printf ",%s", y >> ResultsPath & "/SelectedResults.csv";}
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION}        {
                for { t in TECHNOLOGY } {
                                                        printf "%s", t >> ResultsPath & "/SelectedResults.csv";
                                                        for { y in YEAR } {
                                                                                                        printf ",%g", ((sum{yy in YEAR: y-yy < OperationalLife[r,t] && y-yy>=0} NewCapacity[r,t,yy])+ ResidualCapacity[r,t,y]) >> ResultsPath & "/SelectedResults.csv";
                                                                                                        }
                                                        printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                        }
                                        }
#
####        New Annual Capacity        ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "NewCapacity (Capacity Units )" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Technology" >> ResultsPath & "/SelectedResults.csv";
for {y in YEAR}         {printf ",%s", y >> ResultsPath & "/SelectedResults.csv";}
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION}        {
                                        for { t in TECHNOLOGY }         {
                                                                                printf "%s", t >> ResultsPath & "/SelectedResults.csv";
                                                                                for { y in YEAR }         {
                                                                                                                                        printf ",%g", NewCapacity[r,t,y] >> ResultsPath & "/SelectedResults.csv";
                                                                                                                                        }
                                                                                printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                                                }
                                        }
#
### Annual Production ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Annual Production (Energy Units)" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION}{printf ",%s", r >> ResultsPath & "/SelectedResults.csv";}
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Technology" >> ResultsPath & "/SelectedResults.csv";
printf ",Fuel" >> ResultsPath & "/SelectedResults.csv";
for {y in YEAR}{printf",%g",y >> ResultsPath & "/SelectedResults.csv";}
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for{r in REGION}{
					for {t in TECHNOLOGY}{#printf "%s", t >> ResultsPath & "/SelectedResults.csv";
														  #printf "\n" >> ResultsPath & "/SelectedResults.csv";
														  for {f in FUEL }{
																			printf "%s", t >> ResultsPath & "/SelectedResults.csv";
																			printf ",%s", f >> ResultsPath & "/SelectedResults.csv";
																		    for {y in YEAR}{printf ",%g", sum{m in MODE_OF_OPERATION, l in TIMESLICE: OutputActivityRatio[r,t,f,m,y] <>0} RateOfActivity[r,l,t,m,y]*OutputActivityRatio[r,t,f,m,y] * YearSplit[l,y] >> ResultsPath & "/SelectedResults.csv";
																						   }
																						   printf "\n" >> ResultsPath & "/SelectedResults.csv";
																		  }
										 }
										 printf "\n" >> ResultsPath & "/SelectedResults.csv";
				}
#
### Annual Use ###
#
#printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Annual Use (Energy Units)" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION} {printf ",%s", r >> ResultsPath & "/SelectedResults.csv";
                                        printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                        printf "Technology" >> ResultsPath & "/SelectedResults.csv";
										printf ",Fuel" >> ResultsPath & "/SelectedResults.csv";
										#printf ",Timeslice" >> ResultsPath & "/SelectedResults.csv";
										for {y in YEAR}{printf",%g",y >> ResultsPath & "/SelectedResults.csv";}
										printf "\n" >> ResultsPath & "/SelectedResults.csv";
										for {t in TECHNOLOGY}{#printf "%s", t >> ResultsPath & "/SelectedResults.csv";
                                                              for {f in FUEL }{printf "%s", t >> ResultsPath & "/SelectedResults.csv";
																			   printf ",%s", f >> ResultsPath & "/SelectedResults.csv";
                                                                               for {y in YEAR}{printf ",%g", sum{m in MODE_OF_OPERATION, l in TIMESLICE: InputActivityRatio[r,t,f,m,y]<>0} RateOfActivity[r,l,t,m,y]*InputActivityRatio[r,t,f,m,y]*YearSplit[l,y] >> ResultsPath & "/SelectedResults.csv";
                                                                                              }
                                                                                              printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                                              }
																			  #printf "\n" >> ResultsPath & "/SelectedResults.csv";
															  }
				  }
#
###                Technology Production in each TS ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "ProductionByTechnology (Energy Units)" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION} {printf ",%s", r >> ResultsPath & "/SelectedResults.csv";
        printf "\n" >> ResultsPath & "/SelectedResults.csv";
		printf "Technology" >> ResultsPath & "/SelectedResults.csv";
		printf ",Fuel" >> ResultsPath & "/SelectedResults.csv";
		printf ",Timeslice" >> ResultsPath & "/SelectedResults.csv";
        for {y in YEAR}{printf ",%g", y >> ResultsPath & "/SelectedResults.csv";}
		printf "\n" >> ResultsPath & "/SelectedResults.csv";
        for {t in TECHNOLOGY} {#printf "%s", t >> ResultsPath & "/SelectedResults.csv";
                                        #printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                        for {f in FUEL } {
                                                #printf ",%s", f >> ResultsPath & "/SelectedResults.csv";
                                                for {l in TIMESLICE}{#printf ",%s", l >> ResultsPath & "/SelectedResults.csv";
														printf "%s", t >> ResultsPath & "/SelectedResults.csv";
														printf ",%s", f >> ResultsPath & "/SelectedResults.csv";
														printf ",%s", l >> ResultsPath & "/SelectedResults.csv";
                                                        for { y in YEAR} {
                                                                                printf ",%g", sum{m in MODE_OF_OPERATION: OutputActivityRatio[r,t,f,m,y] <>0} RateOfActivity[r,l,t,m,y]*OutputActivityRatio[r,t,f,m,y] * YearSplit[l,y] >> ResultsPath & "/SelectedResults.csv";
                                                                }
																printf "\n" >> ResultsPath & "/SelectedResults.csv";
																#printf "," >> ResultsPath & "/SelectedResults.csv";
                                                }
                                                #printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                        }
										#printf "\n" >> ResultsPath & "/SelectedResults.csv";
        }
}
#
###                Technology Use in each TS        ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Use By Technology (Energy Units)" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION} {printf ",%s", r >> ResultsPath & "/SelectedResults.csv";
        printf "\n" >> ResultsPath & "/SelectedResults.csv";
		printf "Technology" >> ResultsPath & "/SelectedResults.csv";
		printf ",Fuel" >> ResultsPath & "/SelectedResults.csv";
		printf ",Timeslice" >> ResultsPath & "/SelectedResults.csv";
        for {y in YEAR}{printf ",%g", y >> ResultsPath & "/SelectedResults.csv";}
		printf "\n" >> ResultsPath & "/SelectedResults.csv";
        for {t in TECHNOLOGY} {#printf "%s", t >> ResultsPath & "/SelectedResults.csv";
										#printf "," >> ResultsPath & "/SelectedResults.csv";
                                        #for {f in FUEL}{printf",%s",f >> ResultsPath & "/SelectedResults.csv";
                                                #for {y in YEAR}{
                                                        #printf ",%g", y >> ResultsPath & "/SelectedResults.csv";
                                                #}
                                        #}
                                        #printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                        for {f in FUEL} {
                                                #printf "%s", f >> ResultsPath & "/SelectedResults.csv";
                                                for {l in TIMESLICE}{#printf ",%s", l >> ResultsPath & "/SelectedResults.csv";
														printf "%s", t >> ResultsPath & "/SelectedResults.csv";
														printf ",%s", f >> ResultsPath & "/SelectedResults.csv";
														printf ",%s", l >> ResultsPath & "/SelectedResults.csv";
                                                        for { y in YEAR} {
                                                                                printf ",%g", sum{m in MODE_OF_OPERATION: InputActivityRatio[r,t,f,m,y]<>0} RateOfActivity[r,l,t,m,y]*InputActivityRatio[r,t,f,m,y] * YearSplit[l,y] >> ResultsPath & "/SelectedResults.csv";
                                                                }
																printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                }
												#printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                        }
										#printf "\n" >> ResultsPath & "/SelectedResults.csv";
        }
}
#
###                Total Annual Emissions        ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Annual Emissions (Emissions Units)" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
        for {r in REGION}{printf ",%s", r >> ResultsPath & "/SelectedResults.csv";
						printf "\n" >> ResultsPath & "/SelectedResults.csv";
						printf "," >> ResultsPath & "/SelectedResults.csv";
						for {y in YEAR} {printf ",%s", y >> ResultsPath & "/SelectedResults.csv";}
						printf "\n" >> ResultsPath & "/SelectedResults.csv";
						for {e in EMISSION}{printf ",%s", e >> ResultsPath & "/SelectedResults.csv";
											#printf "\n" >> ResultsPath & "/SelectedResults.csv";
											#printf "\n" >> ResultsPath & "/SelectedResults.csv";
											for {y in YEAR }{
															#printf "%g", y >> ResultsPath & "/SelectedResults.csv";
															printf ",%g", sum{l in TIMESLICE, t in TECHNOLOGY, m in MODE_OF_OPERATION: EmissionActivityRatio[r,t,e,m,y]<>0} EmissionActivityRatio[r,t,e,m,y]*RateOfActivity[r,l,t,m,y]*YearSplit[l,y] >> ResultsPath & "/SelectedResults.csv";
															#printf "\n" >> ResultsPath & "/SelectedResults.csv";
															}
															printf "\n" >> ResultsPath & "/SelectedResults.csv";
											}
							}
#
### Annual Emissions by Technology ###
#
printf "\n" >> ResultsPath & "/SelectedResults.csv";
printf "Annual Emissions by Technology (Emissions Units)" >> ResultsPath & "/SelectedResults.csv";
printf "\n" >> ResultsPath & "/SelectedResults.csv";
for {r in REGION} {printf ",%s", r >> ResultsPath & "/SelectedResults.csv";
                                        printf "\n" >> ResultsPath & "/SelectedResults.csv";
										printf "Technology" >> ResultsPath & "/SelectedResults.csv";
										printf ",Emission" >> ResultsPath & "/SelectedResults.csv";
										for {y in YEAR} {printf ",%s", y >> ResultsPath & "/SelectedResults.csv";}
										printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                        for {t in TECHNOLOGY}         {#printf "%s", t >> ResultsPath & "/SelectedResults.csv";
                                                                                        for {e in EMISSION}{
																									printf "%s", t >> ResultsPath & "/SelectedResults.csv";
																									printf",%s",e >> ResultsPath & "/SelectedResults.csv";
                                                                                                                        #}
                                                                                        #printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                                                        #for {e in EMISSION}         {
                                                                                                                                #printf "%g", y >> ResultsPath & "/SelectedResults.csv";
                                                                                                                                for {y in YEAR}{
                                                                                                                                                                printf ",%g", sum{l in TIMESLICE, m in MODE_OF_OPERATION: EmissionActivityRatio[r,t,e,m,y]<>0} EmissionActivityRatio[r,t,e,m,y]*RateOfActivity[r,l,t,m,y]*YearSplit[l,y] >> ResultsPath & "/SelectedResults.csv";
                                                                                                                                                                }
                                                                                                                                printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                                                                                                }
                                                printf "\n" >> ResultsPath & "/SelectedResults.csv";
                                                                                        }
                                        }


table AccumulatedNewCapacityResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		AccumulatedNewCapacity[r, t, y] > 0}

	OUT "CSV"
	ResultsPath & "/AccumulatedNewCapacity.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR, AccumulatedNewCapacity[r, t, y]~VALUE;
																																																															
			 

table AnnualEmissionsResults
	{r in REGION, e in EMISSION, y in YEAR:
		AnnualEmissions[r, e, y] > 0}

	OUT "CSV"
	ResultsPath & "/AnnualEmissions.csv" :
	r~REGION, e~EMISSION, y~YEAR, AnnualEmissions[r, e, y]~VALUE;
																																																			 
			 

table AnnualFixedOperatingCostResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		AnnualFixedOperatingCost[r, t, y] > 0}

																																																												 
																																																							 
	OUT "CSV"
	ResultsPath & "/AnnualFixedOperatingCost.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR, AnnualFixedOperatingCost[r, t, y]~VALUE;
		 
			 
																																																														  

table AnnualTechnologyEmissionResults
	{r in REGION, t in TECHNOLOGY, e in EMISSION, y in YEAR:
		AnnualTechnologyEmission[r, t, e, y] > 0}

	OUT "CSV"
	ResultsPath & "/AnnualTechnologyEmission.csv" :
	r~REGION, t~TECHNOLOGY, e~EMISSION, y~YEAR, AnnualTechnologyEmission[r, t, e, y]~VALUE;
																																																			 
			 

table AnnualTechnologyEmissionByModeResults
	{r in REGION, t in TECHNOLOGY, e in EMISSION, m in MODE_OF_OPERATION, y in YEAR:
		AnnualTechnologyEmissionByMode[r, t, e, m, y] > 0}
	OUT "CSV"
	ResultsPath & "/AnnualTechnologyEmissionByMode.csv" :
	r~REGION, t~TECHNOLOGY, e~EMISSION, m~MODE_OF_OPERATION, y~YEAR, AnnualTechnologyEmissionByMode[r, t, e, m, y]~VALUE;
																																																																																																																											 
			 

table AnnualVariableOperatingCostResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		AnnualVariableOperatingCost[r, t, y] > 0}

	OUT "CSV"
	ResultsPath & "/AnnualVariableOperatingCost.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR, AnnualVariableOperatingCost[r, t, y]~VALUE;
																																																																											  
			 

table CapitalInvestmentResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		CapitalInvestment[r, t, y] > 0}
	OUT "CSV"
	ResultsPath & "/CapitalInvestment.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR,
	CapitalInvestment[r, t, y]~VALUE;

table DemandResults
	{r in REGION, l in TIMESLICE, f in FUEL, y in YEAR:
		pv_Demand[r, l, f, y] > 0}
	OUT "CSV"
	ResultsPath & "/Demand.csv" :
	r~REGION, l~TIMESLICE, f~FUEL, y~YEAR,
	pv_Demand[r, l, f, y]~VALUE;

table DiscountedSalvageValueResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		DiscountedSalvageValue[r, t, y] > 0}
	OUT "CSV"
	ResultsPath & "/DiscountedSalvageValue.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR,
	DiscountedSalvageValue[r, t, y]~VALUE;

table DiscountedTechnologyEmissionsPenaltyResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		DiscountedTechnologyEmissionsPenalty[r, t, y] > 0}
	OUT "CSV"
	ResultsPath & "/DiscountedTechnologyEmissionsPenalty.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR,
	DiscountedTechnologyEmissionsPenalty[r, t, y]~VALUE;

table NewCapacityResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		NewCapacity[r, t, y] > 0}
	OUT "CSV"
	ResultsPath & "/NewCapacity.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR,
	NewCapacity[r, t, y]~VALUE;

table NewStorageCapacityResults
	{r in REGION, s in STORAGE, y in YEAR:
		NewStorageCapacity[r, s, y] > 0}
	OUT "CSV"
	ResultsPath & "/NewStorageCapacity.csv" :
	r~REGION, s~STORAGE, y~YEAR,
	NewStorageCapacity[r, s, y]~VALUE;

table NumberOfNewTechnologyUnitsResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		NumberOfNewTechnologyUnits[r, t, y] > 0}
	OUT "CSV"
	ResultsPath & "/NumberOfNewTechnologyUnits.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR,
	NumberOfNewTechnologyUnits[r, t, y]~VALUE;

table ProductionByTechnologyResults
	{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR:
		ProductionByTechnology[r, l, t, f, y] > 0}

	OUT "CSV"
	ResultsPath & "/ProductionByTechnology.csv" :
	r~REGION, l~TIMESLICE, t~TECHNOLOGY, f~FUEL, y~YEAR,
	ProductionByTechnology[r, l, t, f, y]~VALUE;
			 

table ProductionByTechnologyAnnualResults
	{r in REGION, t in TECHNOLOGY, f in FUEL, y in YEAR:
		ProductionByTechnologyAnnual[r, t, f, y] > 0}

	OUT "CSV"
	ResultsPath & "/ProductionByTechnologyAnnual.csv" :
	r~REGION, t~TECHNOLOGY, f~FUEL, y~YEAR,
	ProductionByTechnologyAnnual[r, t, f, y]~VALUE;
			 

table RateOfActivityResults
	{r in REGION, l in TIMESLICE, t in TECHNOLOGY, m in MODE_OF_OPERATION, y in YEAR:
		RateOfActivity[r, l, t, m, y] > 0}
	OUT "CSV"
	ResultsPath & "/RateOfActivity.csv" :
	r~REGION, l~TIMESLICE, t~TECHNOLOGY, m~MODE_OF_OPERATION, y~YEAR, RateOfActivity[r, l, t, m, y]~VALUE;
																																																			 

table RateOfProductionByTechnologyResults
	{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR:
		RateOfProductionByTechnology[r, l, t, f, y] > 0}

	OUT "CSV"
	ResultsPath & "/RateOfProductionByTechnology.csv" :
	r~REGION, l~TIMESLICE, t~TECHNOLOGY, f~FUEL, y~YEAR,
	RateOfProductionByTechnology[r, l, t, f, y]~VALUE;
			 

table RateOfProductionByTechnologyByModeResults
	{r in REGION, l in TIMESLICE, t in TECHNOLOGY, m in MODE_OF_OPERATION, f in FUEL, y in YEAR:
		RateOfProductionByTechnologyByMode[r, l, t, m, f, y] > 0}
	OUT "CSV"
	ResultsPath & "/RateOfProductionByTechnologyByMode.csv" :
	r~REGION, l~TIMESLICE, t~TECHNOLOGY, m~MODE_OF_OPERATION, f~FUEL, y~YEAR,
	RateOfProductionByTechnologyByMode[r, l, t, m, f, y]~VALUE;

table RateOfUseByTechnologyResults
	{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR:
		RateOfUseByTechnology[r, l, t, f, y] > 0}

	OUT "CSV"
	ResultsPath & "/RateOfUseByTechnology.csv" :
	r~REGION, l~TIMESLICE, t~TECHNOLOGY, f~FUEL, y~YEAR,
																																																			 
	RateOfUseByTechnology[r, l, t, f, y]~VALUE;

table RateOfUseByTechnologyByModeResults
	{r in REGION, l in TIMESLICE, t in TECHNOLOGY, m in MODE_OF_OPERATION, f in FUEL, y in YEAR:
		RateOfUseByTechnologyByMode[r, l, t, m, f, y] > 0}
	OUT "CSV"
	ResultsPath & "/RateOfUseByTechnologyByMode.csv" :
	r~REGION, l~TIMESLICE, t~TECHNOLOGY, m~MODE_OF_OPERATION, f~FUEL, y~YEAR,
	RateOfUseByTechnologyByMode[r, l, t, m, f, y]~VALUE;

table SalvageValueResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		SalvageValue[r, t, y] > 0}
	OUT "CSV"
	ResultsPath & "/SalvageValue.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR, SalvageValue[r, t, y]~VALUE;
																																																		  

table SalvageValueStorageResults
	{r in REGION, s in STORAGE, y in YEAR:
		SalvageValueStorage[r, s, y] > 0}
	OUT "CSV"
	ResultsPath & "/SalvageValueStorage.csv" :
	r~REGION, s~STORAGE, y~YEAR, SalvageValueStorage[r, s, y]~VALUE;
																																																	 
			 
																																																							 
																											
																																																															

																																																	 
																																																																																																														 
																																	   
																																																			 
			 

table TotalAnnualTechnologyActivityByModeResults
	{r in REGION, t in TECHNOLOGY, m in MODE_OF_OPERATION, y in YEAR:
		TotalAnnualTechnologyActivityByMode[r, t, m, y] > 0}

																														   
																																																							 
	OUT "CSV"
	ResultsPath & "/TotalAnnualTechnologyActivityByMode.csv" :
	r~REGION, t~TECHNOLOGY, m~MODE_OF_OPERATION, y~YEAR,
	TotalAnnualTechnologyActivityByMode[r, t, m, y]~VALUE;
			 
																																																							 

table TotalCapacityAnnualResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		TotalCapacityAnnual[r, t, y] > 0}
	OUT "CSV"
	ResultsPath & "/TotalCapacityAnnual.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR,
	TotalCapacityAnnual[r, t, y]~VALUE;

table TotalDiscountedCostResults
	{r in REGION, y in YEAR: TotalDiscountedCost[r, y] > 0}
	OUT "CSV"
	ResultsPath & "/TotalDiscountedCost.csv" :
	r~REGION, y~YEAR,
	TotalDiscountedCost[r, y]~VALUE;
		  
																																																			 
				  
																									   
																																																																															  
																																																																																																													   
																																																		 
																																																																																																																																																																										  
																																																																																								 
																																																		 
																																																			 

table TotalTechnologyAnnualActivityResults
	{r in REGION, t in TECHNOLOGY, y in YEAR:
		TotalTechnologyAnnualActivity[r, t, y] > 0}

																																																				 
	OUT "CSV"
	ResultsPath & "/TotalTechnologyAnnualActivity.csv" :
	r~REGION, t~TECHNOLOGY, y~YEAR,
	TotalTechnologyAnnualActivity[r, t, y]~VALUE;
			 

table TotalTechnologyModelPeriodActivityResults
	{r in REGION, t in TECHNOLOGY:
		TotalTechnologyModelPeriodActivity[r, t] > 0}

																																																																  
	OUT "CSV"
	ResultsPath & "/TotalTechnologyModelPeriodActivity.csv" :
	r~REGION, t~TECHNOLOGY,
	TotalTechnologyModelPeriodActivity[r, t]~VALUE;
			 

table TradeResults
	{r in REGION, rr in REGION, l in TIMESLICE, f in FUEL, y in YEAR:
		Trade[r, rr, l, f, y] <> 0}

	OUT "CSV"
	ResultsPath & "/Trade.csv" :
	r~REGION, rr~REGION, l~TIMESLICE, f~FUEL, y~YEAR, Trade[r, rr, l, f, y]~VALUE;
			 

table UseByTechnologyResults
	{r in REGION, l in TIMESLICE, t in TECHNOLOGY, f in FUEL, y in YEAR:
																											
		UseByTechnology[r, l, t, f, y] > 0}
																																			 
	OUT "CSV"
	ResultsPath & "/UseByTechnology.csv" :
	r~REGION, l~TIMESLICE, t~TECHNOLOGY, f~FUEL, y~YEAR, UseByTechnology[r, l, t, f, y]~VALUE;
			
			 
display RateOfActivity;
end;