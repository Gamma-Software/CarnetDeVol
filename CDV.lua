--------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------- Script written in LUA for Taranis by Valentin Rudloff -----------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- This script write the flight time into a file
-- You can now know how much time you spent in the air ! :D
-- written in 08/12/16 Rev 0





-------------------------------------------------------------
------------------------ LANGUAGE ---------------------------
-------------------------------------------------------------
local currentLanguage = "en"
local currentLanguage2 = "en"
local month1String = {}
local month2String = {}
local month3String = {}
local month4String = {}
local month5String = {}
local month6String = {}
local month7String = {}
local month8String = {}
local month9String = {}
local month10String = {}
local month11String = {}
local month12String = {}
local pickYear = {}
local pickMonth = {}
local pickDay = {}
local enterToContinue = {}
local enterToShow = {}
local exitToReset = {}
local noFlightTimeSaved = {}
local totalFlightTimeString = {}
local flightLogs = {}
local logToShow = {}
local logFrom = {}
local settingsTitle = {}
local armSwitchString = {}
local switchString = {}
local languageEnString = {}
local languageFrString = {}
local languageSettingString = {}
local firstSettingString = {}

month1String["en"] = "January"
month2String["en"] = "February"
month3String["en"] = "March"
month4String["en"] = "April"
month5String["en"] = "May"
month6String["en"] = "June"
month7String["en"] = "July"
month8String["en"] = "August"
month9String["en"] = "September"
month10String["en"] = "October"
month11String["en"] = "November"
month12String["en"]= "December"
pickYear["en"] = "Pick a year:"
pickMonth["en"] = "Pick a month:"
pickDay["en"]= "Pick a day:"
enterToContinue["en"] = "Enter ENT to continue"
enterToShow["en"] = "Enter ENT to show the log"
exitToReset["en"] = "Enter EXIT to reset choice"
noFlightTimeSaved["en"] = "No Flight Time Saved"
totalFlightTimeString["en"] = "Total Flight Time"
flightLogs["en"] = "Flight Logs"
logToShow["en"] = "Choose what log to show"
logFrom["en"] = " Logs from "
settingsTitle["en"] = "Settings"
armSwitchString["en"] = "Arm switch or logicalSwitch: "
switchString["en"] = "Switch"
languageEnString["en"] = "En"
languageFrString["en"] = "Fr"
languageSettingString["en"] = "Language: "
firstSettingString["en"] = "First, let's setup the app:"

month1String["fr"] = "Janvier"
month2String["fr"] = "Fevrier"
month3String["fr"] = "Mars"
month4String["fr"] = "Avril"
month5String["fr"] = "Mai"
month6String["fr"] = "Juin"
month7String["fr"] = "Juillet"
month8String["fr"] = "Aout"
month9String["fr"] = "Septembre"
month10String["fr"] = "Octobre"
month11String["fr"] = "Novembre"
month12String["fr"] = "Decembre"
pickYear["fr"] = "Choix de l'annee:"
pickMonth["fr"] = "Choix du mois:"
pickDay["fr"] = "Choix du jour:"
enterToContinue["fr"] = "ENT pour continuer"
enterToShow["fr"] = "ENT pour montrer le log"
exitToReset["fr"] = "EXIT pour recommencer"
noFlightTimeSaved["fr"] = "Pas de temps de vols"
totalFlightTimeString["fr"] = "Temps de vol total"
flightLogs["fr"] = "Historique des vols"
logToShow["fr"] = "Choix de l'Historique"
logFrom["fr"] = " historique du "
settingsTitle["fr"] = "Parametre"
armSwitchString["fr"] = "Inter d'Armement: "
switchString["fr"] = "Inter"
languageEnString["fr"] = "En"
languageFrString["fr"] = "Fr"
languageSettingString["fr"] = "Langue: "
firstSettingString["fr"] = "Commencons par parametrer l'app: "



-------------------------------------------------------------
------------------------ Variable ---------------------------
-------------------------------------------------------------
local totalFlightTime = 0
local currentTimeFlight = 0
local currentThrMean = 0
local currentWindow = 1
local currentFlightTimePage = 1
local saved = true
local armLogic
local reseted = false
local nameModel = model.getInfo().name

local startTicks
local alreadyReadTotalFlight = false
local alreadyReadFlight = false
local readTotalFlight = ""
local readFlight = {}
local flightTimes = {}
local thrMean = {}

--------------- Year/Month/Day selection Variable --------------------
local comboYearOptions
local comboMonthOptions
local comboDayOptions
local selectedYearOption = 0
local selectedMonthOption = 0
local selectedDayOption = 0
local inComboSelection = false
local activeComboField
local firstTime = true
local fieldMax
local fileNameFlightLogsToShow

--------------- Settings Variable --------------------
local editArm = false

local result = 0
local currentFieldSetup = 0
local currentLanguageSelected = 0


--------------- Source Variable --------------------
local armCommand = ""
local armCommandThreshold = 0
local thrCommand = getValue('thr')


-------------------------------------------------------------
------------------- Read / Write Logs -----------------------
-------------------------------------------------------------

-- Function used to write the total amount of flight time in a file
local function writeTotalFlightTime()
	local stringTotalFlightTime = ""

	-- First read current total flight time
	local totalFlight = io.open("CDV/DONT_MODIFY/TotalFlightTime/"..nameModel.."_totalFlightTime.txt", "r") -- open file in append mode
	-- If it doesn't exist
	if totalFlight == nil then
		local totalFlight = io.open("CDV/DONT_MODIFY/TotalFlightTime/"..nameModel.."_totalFlightTime.txt", "w") -- create and open file
		io.write(totalFlight, math.floor(totalFlightTime)) -- exemple: 1304 for 0h 21min 44sec
		io.close(totalFlight) -- Close the file
		return 0
	else --else we read the current total flight time
		while true do
			local data = io.read(totalFlight, 1)
			if #data == 0 then 
				break 
			end
			stringTotalFlightTime = stringTotalFlightTime .. data
		end
		io.close(totalFlight) -- Close the file
	end


	if tonumber(stringTotalFlightTime) ~= nil then
		local totalFlight3 = io.open("CDV/DONT_MODIFY/TotalFlightTime/"..nameModel.."_totalFlightTime.txt", "w") --open file in write mode
		io.write(totalFlight3, math.floor(currentTimeFlight + tonumber(stringTotalFlightTime))) -- exemple: 1304 for 0h 21min 44sec
		io.close(totalFlight3) -- Close the file
	end
end
-- Function used to read the total flight time
local function readTotalFlightTime()
	readTotalFlight = ""
	local data = ""

	-- First read current total flight time
	local file = io.open("CDV/DONT_MODIFY/TotalFlightTime/"..nameModel.."_totalFlightTime.txt", "r") -- open file in append mode
	-- If it doesn't exist
	if file ~= nil then
		while true do
			data = io.read(file, 1)
 			readTotalFlight = readTotalFlight..data
 			if #data == 0 then 
 				break 
 			end
		end
		io.close(file)
		lcd.drawTimer(1, 25,tonumber(readTotalFlight),TIMEHOUR + MIDSIZE)
	else
		file = io.open("CDV/DONT_MODIFY/TotalFlightTime/"..nameModel.."_totalFlightTime.txt", "w")
		readTotalFlight = 0
		io.write(file, readTotalFlight)
		io.close(file)
	end
	alreadyReadTotalFlight = true
end

-- Function used to write the file flight time
local function writeFlightTime()
	local currentFlightTimeH
	local currentFlightTimeM
	local tempFlightTime = currentTimeFlight


	----------------------------------------------
	----- Write Flight logs for viewing in Excel
	----------------------------------------------
	local datenow = getDateTime()
	local textToSave = datenow.year.."-"..datenow.mon.."-"..datenow.day.."_".. datenow.hour.."-"..datenow.min.."-"..datenow.sec..":  "

	local file = io.open("CDV/CarnetDeVol/"..nameModel.."_carnetDeVol.txt", "a") -- open file in append mode
	currentFlightTimeH = math.floor(tempFlightTime / 3600); -- get the hour
	tempFlightTime = tempFlightTime - currentFlightTimeH*3600 -- remove the hours
	textToSave = textToSave .. currentFlightTimeH .. "h "

	currentFlightTimeM = math.floor(tempFlightTime/60); -- get the minutes
	tempFlightTime = tempFlightTime - currentFlightTimeM*60 -- remove the minutes
	textToSave = textToSave .. currentFlightTimeM .. "min "

	textToSave = textToSave .. math.floor(tempFlightTime) .. "sec"

	textToSave = textToSave .. "\t\t/" .. math.floor(currentTimeFlight)

	io.write(file, textToSave.."/\n") -- exemple: 09-10-11_12-20-10:	0h 1min 24sec		/84/
	io.close(file)


	----------------------------------------------
	----- Write Year of flight logs
	----------------------------------------------
	local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_years.txt", "r") -- open file in read mode
	local haveToWrite = false
	local dataTemp
	if file ~= nil then
		while true do
			local data = io.read(file, 4)
			if #data == 0 then 
				if dataTemp ~= tostring(datenow.year) then
					io.close(file) --Close before write
					local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_years.txt", "a") -- open file in append mode
					io.write(file, datenow.year)
					io.close(file)
				end
				break --Get out of the while loop
			else
				dataTemp = data --get the previous year
			end
		end
	else
		local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_years.txt", "w") -- open file in write mode
		io.write(file, datenow.year) -- exemple: 2016
		io.close(file)
	end

	----------------------------------------------
	----- Write Month of flight logs
	----------------------------------------------
	local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_"..datenow.year.."_month.txt", "r") -- open file in read mode
	local haveToWrite = false
	local dataTemp
	if file ~= nil then
		while true do
			local data = io.read(file, 2)
			if #data == 0 then 
				if dataTemp ~= tostring(datenow.mon) then
					io.close(file) --Close before write
					local file = io.open("CDV/DontModify/Search/"..nameModel.."_"..datenow.year.."_month.txt", "a") -- open file in append mode
					io.write(file, datenow.mon)
					io.close(file)
				end
				break --Get out of the while loop
			else
				dataTemp = data --get the previous month
			end
		end
	else
		local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_"..datenow.year.."_month.txt", "w") -- open file in write mode
		io.write(file, datenow.mon) -- exemple: 10
		io.close(file)
	end

	----------------------------------------------
	----- Write day of flight logs
	----------------------------------------------
	local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_"..datenow.year.."_"..datenow.mon.."_day.txt", "r") -- open file in read mode
	local haveToWrite = false
	local dataTemp
	if file ~= nil then
		while true do
			local data = io.read(file, 2)
			if #data == 0 then 
				if dataTemp ~= tostring(datenow.day) then
					io.close(file) --Close before write
					local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_"..datenow.year.."_"..datenow.mon.."_day.txt", "a") -- open file in append mode
					io.write(file, datenow.day)
					io.close(file)
				end
				break --Get out of the while loop
			else
				dataTemp = data --get the previous day
			end
		end
	else
		local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_"..datenow.year.."_"..datenow.mon.."_day.txt", "w") -- open file in write mode
		io.write(file, datenow.day) -- exemple: 10
		io.close(file)
	end

	----------------------------------------------
	----- Write flight logs of the day
	----------------------------------------------
	local file = io.open("CDV/DONT_MODIFY/FlightLogsOfDay/"..nameModel.."_"..datenow.year.."_"..datenow.mon.."_"..datenow.day..".txt", "a") -- open file in append mode
	io.write(file, math.floor(currentTimeFlight).."/")
	io.close(file)

	local file = io.open("CDV/DONT_MODIFY/FlightLogsOfDay/thr_"..nameModel.."_"..datenow.year.."_"..datenow.mon.."_"..datenow.day..".txt", "a") -- open file in append mode
	io.write(file, math.floor(currentThrMean).."/")
	io.close(file)

	currentThrMean = 0
	currentTimeFlight = 0 --reset currentTimeOfFlight
end
-- Function used to read the flight time
local function readFlightTime(event, fileName)
	flightTimes = {}
	local inc = 0
	local tempData = ""
	local data = ""

	-- First read flight time
	local file = io.open("CDV/DONT_MODIFY/FlightLogsOfDay/"..fileName..".txt", "r") -- open file in append mode
	-- If it doesn't exist
	if file ~= nil then
		while true do
			data = io.read(file, 1) --To check if there is "/"
			if #data == 0 then break end
			if data == "/" then 
				flightTimes[inc] = tonumber(tempData)
				inc = inc + 1 
				tempData = ""
			else 
				tempData = tempData .. data  
			end
		end

		io.close(file)

	end


	thrMean = {}
	local inc = 0
	local tempData = ""
	local data = ""
	-- Second read mean throttle from the flight times
	local file = io.open("CDV/DONT_MODIFY/FlightLogsOfDay/thr_"..fileName..".txt", "r") -- open file in append mode
	-- If it doesn't exist
	if file ~= nil then
		while true do
			data = io.read(file, 1) --To check if there is "/"
			if #data == 0 then break end
			if data == "/" then 
				thrMean[inc] = tonumber(tempData)
				inc = inc + 1 
				tempData = ""
			else 
				tempData = tempData .. data  
			end
		end

		io.close(file)

		drawFlightTime(event)
	end


	alreadyReadFlight = true
end

local function isThereLogs()
	local tempFlightFile = io.open("CDV/CarnetDeVol/"..nameModel.."_carnetDeVol.txt", "r")
	if tempFlightFile == nil then
		return false
	else
		io.close(tempFlightFile)
		return true
	end
end

-------------------------------------------------------------
----------------- Read / Write Settings ---------------------
-------------------------------------------------------------
local function readSetting()
	local tempData = ""
	local inc = 0
	local data = ""

	local file = io.open("CDV/settings.txt", "r") -- open file in append mode
	-- If it exist
	if file ~= nil then
		while true do
			data = io.read(file, 1) --To check if there is "/"
			if data == "/" then
				if inc == 0 then
					armCommand = tempData
					tempData = ""
					data = ""
					inc = inc + 1
				elseif inc == 1 then
					if tempData == "up" then
						armCommandThreshold = 1024
					elseif tempData == "center" then
						armCommandThreshold = 0
					else
						armCommandThreshold = -1024
					end
					tempData = ""
					data = ""
					inc = inc + 1
				elseif inc == 2 then
					currentLanguage = tempData
					break
				end
			end
			tempData = tempData..data
		-- 	if data == "/" then
		-- 		if inc == 0 then
		-- 			armCommand = tempData
		-- 		elseif inc == 1 then
		-- 			if tempData == "up" then
		-- 				armCommandThreshold = 1024
		-- 			elseif tempData == "center" then
		-- 				armCommandThreshold = 0
		-- 			elseif tempData == "down" then
		-- 				armCommandThreshold = -1024
		-- 			else end

		-- 			local file2 = io.open("CDV/DONT_MODIFY/Settings/saved.txt", "r")
		-- 			if file2 == nil then
		-- 				setup = true
		-- 				break
		-- 			else
		-- 				io.close(file2)
		-- 			end
		-- 		else
		-- 			currentLanguage = data
		-- 		end
		-- 		tempData = ""
		-- 		inc = inc + 1
		-- 	else 
		-- 		tempData = tempData .. data  
		-- 	end
		end
		io.close(file)
	end
end

-------------------------------------------------------------
-------------------- Design Pages ---------------------------
-------------------------------------------------------------

--------------- Year/Month/Day selection --------------------

--Reset the data from the combo choice
local function resetComboChoice()
	firstTime = true
	activeComboField = 0
	alreadyReadFlight = false
	comboYearOptions = {} --Reset
	comboMonthOptions = {} --Reset
	comboDayOptions = {} --Reset
	flightTimes = {}
	fileNameFlightLogsToShow = nameModel.."_" --Reset Name of flight log to show
end
-- Get the month in number and return the full name of the month
local function getMonthName(monthNumber)
	local monthString = ""
	if monthNumber == 1 then
		monthString = month1String[currentLanguage]
	elseif monthNumber == 2 then
		monthString = month2String[currentLanguage]
	elseif monthNumber == 3 then
		monthString = month3String[currentLanguage]
	elseif monthNumber == 4 then
		monthString = month4String[currentLanguage]
	elseif monthNumber == 5 then
		monthString = month5String[currentLanguage]
	elseif monthNumber == 6 then
		monthString = month6String[currentLanguage]
	elseif monthNumber == 7 then
		monthString = month7String[currentLanguage]
	elseif monthNumber == 8 then
		monthString = month8String[currentLanguage]
	elseif monthNumber == 9 then
		monthString = month9String[currentLanguage]
	elseif monthNumber == 10 then
		monthString = month10String[currentLanguage]
	elseif monthNumber == 11 then
		monthString = month11String[currentLanguage]
	elseif monthNumber == 12 then
		monthString = month12String[currentLanguage]
	end
	return monthString
end
-- Get the month in full name and return the number of the month
local function getMonthNumber(monthName)
	local monthNumber = 0
	if monthName == month1String[currentLanguage] then
		monthNumber = 1
	elseif monthName == month2String[currentLanguage] then
		monthNumber = 2
	elseif monthName == month3String[currentLanguage] then
		monthNumber = 3
	elseif monthName == month4String[currentLanguage] then
		monthNumber = 4
	elseif monthName == month5String[currentLanguage] then
		monthNumber = 5
	elseif monthName == month6String[currentLanguage] then
		monthNumber = 6
	elseif monthName == month7String[currentLanguage] then
		monthNumber = 7
	elseif monthName == month8String[currentLanguage] then
		monthNumber = 8
	elseif monthName == month9String[currentLanguage] then
		monthNumber = 9
	elseif monthName == month10String[currentLanguage] then
		monthNumber = 10
	elseif monthName == month11String[currentLanguage] then
		monthNumber = 11
	elseif monthName == month12String[currentLanguage] then
		monthNumber = 12
	end
	return monthNumber
end

local function getYearForCombo()
	local yearCombo = {}
	local inc = 1
	local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_years.txt", "r") -- open file in read mode
	if file ~= nil then
		while true do
			local data = io.read(file, 4)
			if #data == 0 then break end
			yearCombo[inc] = data
			inc = inc + 1
		end
		io.close(file) --Close before write
	end
	return yearCombo
end
local function getMonthForCombo(year)
	local monthCombo = {}
	local inc = 1
	local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_"..year.."_month.txt", "r") -- open file in read mode
	if file ~= nil then
		while true do
			local data = io.read(file, 2)
			if #data == 0 then break end
			monthCombo[inc] = getMonthName(tonumber(data))
			inc = inc + 1
		end
		io.close(file) --Close before write
	end
	return monthCombo
end
local function getDayForCombo(year, month)
	local dayCombo = {}
	local inc = 1
	local file = io.open("CDV/DONT_MODIFY/Search/"..nameModel.."_"..year.."_"..getMonthNumber(month).."_day.txt", "r") -- open file in read mode
	if file ~= nil then
		while true do
			local data = io.read(file, 2)
			if #data == 0 then break end
			dayCombo[inc] = data
			inc = inc + 1
		end
		io.close(file) --Close before write
	end
	return dayCombo
end

local function fieldIncDec(event,value,max)
	if event==EVT_PLUS_FIRST then
		value=value+max
	elseif event==EVT_MINUS_FIRST then
		value=value+max+2
	end
	value=value%(max+1)
	return value
end
local function valueIncDec(event,value,min,max,step)
	if event==EVT_PLUS_FIRST or event==EVT_PLUS_REPT then
		if value<=max-step then
			value=value+step
		end
		if value == 25 then
			value = 51
		end
	elseif event==EVT_MINUS_FIRST or event==EVT_MINUS_REPT then
		if value>=min+step then
			value=value-step
		end
		if value == 50 then
			value = 24
		end
	end
	return value
end

local function drawCombo(event)
	if activeComboField == 0 then
		if tablelength(comboYearOptions) == 0 then
			comboYearOptions = getYearForCombo()
		else
			lcd.drawText(1, 10, pickYear[currentLanguage], 0)
			lcd.drawCombobox(lcd.getLastPos() + 8, 10, 100, comboYearOptions, selectedYearOption, INVERS)
			selectedYearOption = fieldIncDec(event, selectedYearOption, tablelength(comboYearOptions)-1)

			lcd.drawText(45, 45, enterToContinue[currentLanguage])
		end
	elseif activeComboField == 1 then
		if tablelength(comboMonthOptions) == 0 then
			comboMonthOptions = getMonthForCombo(comboYearOptions[selectedYearOption+1])
		else
			lcd.drawText(1, 10, pickYear[currentLanguage], 0)
			lcd.drawCombobox(lcd.getLastPos() + 8, 10, 100, comboYearOptions, selectedYearOption, INVERS)
			lcd.drawText(1, 22, pickMonth[currentLanguage], 0)
			lcd.drawCombobox(lcd.getLastPos() + 2, 21, 100, comboMonthOptions, selectedMonthOption, INVERS)
			selectedMonthOption = fieldIncDec(event, selectedMonthOption, tablelength(comboMonthOptions)-1)

			lcd.drawText(45, 45, enterToContinue[currentLanguage])
			lcd.drawText(35, 55, exitToReset[currentLanguage])
		end
	elseif activeComboField == 2 then
		if tablelength(comboDayOptions) == 0 then
			comboDayOptions = getDayForCombo(comboYearOptions[selectedYearOption+1], comboMonthOptions[selectedMonthOption+1])
		else
			lcd.drawText(1, 10, pickYear[currentLanguage], 0)
			lcd.drawCombobox(lcd.getLastPos() + 8, 10, 100, comboYearOptions, selectedYearOption, INVERS)
			lcd.drawText(1, 22, pickMonth[currentLanguage], 0)
			lcd.drawCombobox(lcd.getLastPos() + 2, 21, 100, comboMonthOptions, selectedMonthOption, INVERS)
			lcd.drawText(1, 34, pickDay[currentLanguage], 0)
			lcd.drawCombobox(lcd.getLastPos() + 14, 32, 100, comboDayOptions, selectedDayOption, INVERS)
			selectedDayOption = fieldIncDec(event, selectedDayOption, tablelength(comboDayOptions)-1)


			lcd.drawText(40, 45, enterToShow[currentLanguage], BLINK)
			lcd.drawText(35, 55, exitToReset[currentLanguage])
		end
	end


	-- Check event to change comboboxes
	if event == EVT_ENTER_BREAK and not firstTime then
		if activeComboField == 0 then
			fileNameFlightLogsToShow = fileNameFlightLogsToShow..comboYearOptions[selectedYearOption+1]
		elseif activeComboField == 1 then
			fileNameFlightLogsToShow = fileNameFlightLogsToShow.."_"..getMonthNumber(comboMonthOptions[selectedMonthOption+1])
		elseif activeComboField == 2 then
			fileNameFlightLogsToShow = fileNameFlightLogsToShow.."_"..comboDayOptions[selectedDayOption+1]
			readFlightTime(event, fileNameFlightLogsToShow) -- Show the logs
			activeComboField = -1 --reset
		end

		activeComboField = activeComboField + 1
	end
	if event == EVT_EXIT_BREAK then
		resetComboChoice()
	end

	firstTime = false
end
function drawFlightTime(event)
	local len = tablelength(flightTimes)
	local maxFlightLogsDisplayed = 4
	
	if len <= 0 then
		lcd.drawText(10, 25, noFlightTimeSaved[currentLanguage], MIDSIZE)
	else
		local maxFlightTimePage = math.ceil(len/maxFlightLogsDisplayed)

		if event == EVT_MINUS_BREAK or event==EVT_MINUS_REPT then
			currentFlightTimePage = currentFlightTimePage + 1 --we go down on the timeline
			if currentFlightTimePage >= maxFlightTimePage then --check if we cross the limits
				currentFlightTimePage = maxFlightTimePage
			end
		end
		if event == EVT_PLUS_BREAK or event==EVT_PLUS_REPT then
			currentFlightTimePage = currentFlightTimePage - 1 --we go up on the timeline
			if currentFlightTimePage < 1 then  --check if we cross the limits
				currentFlightTimePage = 1
			end
		end
		-- if there are more than 4 flight time saved
		local inc = 10
		if len > maxFlightLogsDisplayed then
			if currentFlightTimePage == maxFlightTimePage then
				for i = (currentFlightTimePage - 1)*maxFlightLogsDisplayed , len - 1 do
					lcd.drawTimer(1, inc+6, flightTimes[i], TIMEHOUR)
					inc = inc + 10
				end
			else
				for i = (currentFlightTimePage - 1)*maxFlightLogsDisplayed , (currentFlightTimePage)*maxFlightLogsDisplayed - 1 do
					lcd.drawTimer(1, inc+6, flightTimes[i], TIMEHOUR)
					inc = inc + 10
				end
			end
			-- Draw the indicator
			lcd.drawGauge(1, 10, 200, 5, currentFlightTimePage, maxFlightTimePage)
		else
			for i = 0, len-1 do
				lcd.drawTimer(1, inc, flightTimes[i], TIMEHOUR)
				inc = inc + 10
			end
		end

		
	end
end

local function designPageReadTotalFlightTime(event)
	lcd.drawScreenTitle(totalFlightTimeString[currentLanguage], 1, 2)

	lcd.drawPixmap(140, 10, "CDV/DONT_MODIFY/Images/timer.bmp")
	lcd.drawText(1, 10,totalFlightTimeString[currentLanguage]..": ", MIDSIZE)

	if not alreadyReadTotalFlight then 
		readTotalFlightTime() 
	else 
		lcd.drawTimer(50, 35,tonumber(readTotalFlight),TIMEHOUR + MIDSIZE) 
	end

end
local function designPageReadFlightTimes(event)
	if event == EVT_EXIT_BREAK then
		resetComboChoice()
	end

	if not isThereLogs() then
		lcd.drawScreenTitle(flightLogs[currentLanguage], 2, 2)
		lcd.drawText(10, 25, noFlightTimeSaved[currentLanguage], MIDSIZE)
	else
		if tablelength(flightTimes) == 0 then
			lcd.drawScreenTitle(logToShow[currentLanguage], 2, 2)
			drawCombo(event)
		else
			lcd.drawScreenTitle(tablelength(flightTimes)..logFrom[currentLanguage]..comboMonthOptions[selectedMonthOption+1].." "..comboDayOptions[selectedDayOption+1].." "..comboYearOptions[selectedYearOption+1], 2, 2)
			drawFlightTime(event)
			lcd.drawText(35, 55, exitToReset[currentLanguage])
		end
	end
end

-------------------------------------------------------------
---------------- Indispensable Function ---------------------
-------------------------------------------------------------
local function init()
	readSetting()

	fieldMax = 1
	selectedOption = 0
	activeComboField = 0
	selectedSize = 0

	resetComboChoice()
end


-- Function runs in background used to calculate the flight time
local function background()
	if getValue(armCommand) == armCommandThreshold then
		armLogic = true
		currentThrMean = (thrCommand + 1024)/20.48
	else
		armLogic = false
	end
	
	
	if not armLogic then --Disarm
		if not saved then
			totalFlightTime = totalFlightTime + currentTimeFlight
			reseted = false

			if totalFlightTime > 10 then -- If it's not an arm/disarm check
				writeTotalFlightTime()
				writeFlightTime()
				saved = true
			end
		end
	else --Arm
		if not reseted then
			saved = false
			reseted = true
			startTicks = getTime() / 100.0 -- reset timer
		end
		currentTimeFlight =  getTime() / 100.0 - startTicks --Calculate the current flight time 
		currentThrMean = (currentThrMean + (thrCommand + 1024)/20.48)/2 -- Calculate the current throttle mean
	end
end


-- this is an OpenTX stand-alone script that keeps track of the flight time
local function run(event)
	lcd.clear()

	--  ----------------------------------------------------
	--	  Switch pages
	--  ----------------------------------------------------
  	if event == EVT_MENU_BREAK then
  		currentWindow = currentWindow + 1

  		if currentWindow == 3 then
	    	alreadyReadTotalFlight = false
  			currentWindow = 1
  		end
  	end

  	if currentWindow == 1 then
		designPageReadTotalFlightTime(event) --Where the total time is displayed
  	elseif currentWindow == 2 then
  		designPageReadFlightTimes(event) --Where all flight times are displayed
  	end
end



function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


return { init=init , run=run , background=background}