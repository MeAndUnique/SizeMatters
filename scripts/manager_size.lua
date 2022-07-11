--
-- Please see the license.txt file included with this distribution for
-- attribution and copyright information.
--

local getValueOriginal;

local tSizeChangedHandlers = {};
local tSpaceChangedHandlers = {};
local tReachChangedHandlers = {};

local bShouldSwap;
local sDeleted;

function onInit()
	getValueOriginal = DB.getValue;
	DB.getValue = getDBValue;

	DB.addHandler(CombatManager.CT_COMBATANT_PATH .. ".currentsize", "onUpdate", onCurrentSizeChanged);
	DB.addHandler(CombatManager.CT_COMBATANT_PATH .. ".currentspace", "onUpdate", onCurrentSpaceChanged);
	DB.addHandler(CombatManager.CT_COMBATANT_PATH .. ".currentreach", "onUpdate", onCurrentReachChanged);
	DB.addHandler(CombatManager.CT_COMBATANT_PATH .. ".currentsize", "onDelete", onCurrentDeleted);
	DB.addHandler(CombatManager.CT_COMBATANT_PATH .. ".currentspace", "onDelete", onCurrentDeleted);
	DB.addHandler(CombatManager.CT_COMBATANT_PATH .. ".currentreach", "onDelete", onCurrentDeleted);
	DB.addHandler(CombatManager.CT_COMBATANT_PATH, "onChildDeleted", onChildDeleted);

	if Session.IsHost then
		DB.addHandler(CombatManager.CT_COMBATANT_PATH .. ".effects", "onChildUpdate", onCombatantEffectUpdated);
	end
end

function getDBValue(vFirst, vSecond, ...)
	if bShouldSwap then
		if vSecond == "size" then
			local nodeCT = ActorManager.getCTNode(vFirst)
			local vCurrent = getValueOriginal(nodeCT, "currentsize");
			if vCurrent then
				return vCurrent;
			end
		elseif vSecond == "space" then
			local vCurrent = getValueOriginal(vFirst, "currentspace");
			if vCurrent then
				return vCurrent;
			end
		elseif vSecond == "reach" then
			local vCurrent = getValueOriginal(vFirst, "currentreach");
			if vCurrent then
				return vCurrent;
			end
		end
	end
	return getValueOriginal(vFirst, vSecond, unpack(arg));
end

function addSizeChangedHandler(fHandler)
	tSizeChangedHandlers[fHandler] = true;
end

function removeSizeChangedHandler(fHandler)
	tSizeChangedHandlers[fHandler] = nil;
end

function invokeSizeChangedHandlers(nodeCombatant)
	for fHandler in pairs(tSizeChangedHandlers) do
		fHandler(nodeCombatant);
	end
end

function addSpaceChangedHandler(fHandler)
	tSpaceChangedHandlers[fHandler] = true;
end

function removeSpaceChangedHandler(fHandler)
	tSpaceChangedHandlers[fHandler] = nil;
end

function invokeSpaceChangedHandlers(nodeCombatant)
	for fHandler in pairs(tSpaceChangedHandlers) do
		fHandler(nodeCombatant);
	end
end

function addReachChangedHandler(fHandler)
	tReachChangedHandlers[fHandler] = true;
end

function removeReachChangedHandler(fHandler)
	tReachChangedHandlers[fHandler] = nil;
end

function invokeReachChangedHandlers(nodeCombatant)
	for fHandler in pairs(tReachChangedHandlers) do
		fHandler(nodeCombatant);
	end
end

function getDefaultSize()
	-- Assume that the ruleset has a defined medium size.
	local tSize = getSizeTable();
	if tSize and tSize["medium"] then
		return tSize["medium"];
	end
end

function getSizeTable()
	return DataCommon.creaturesize;
end

function onCurrentSizeChanged(nodeCurrent)
	invokeSizeChangedHandlers(nodeCurrent.getParent());
end

function onCurrentSpaceChanged(nodeCurrent)
	invokeSpaceChangedHandlers(nodeCurrent.getParent());
end

function onCurrentReachChanged(nodeCurrent)
	invokeReachChangedHandlers(nodeCurrent.getParent());
end

function onCurrentDeleted(nodeCurrent)
	sDeleted = nodeCurrent.getName();
end

function onChildDeleted(nodeCombatant)
	if sDeleted == "currentsize" then
		invokeSizeChangedHandlers(nodeCombatant);
	elseif sDeleted == "currentspace" then
		invokeSpaceChangedHandlers(nodeCombatant);
	elseif sDeleted == "currentreach" then
		invokeReachChangedHandlers(nodeCombatant);
	end
	sDeleted =nil;
end

function onCombatantEffectUpdated(nodeEffectList)
	local nodeCombatant = nodeEffectList.getParent();
	calculateSpace(nodeCombatant);
	calculateReach(nodeCombatant);
end

function calculateSize(nodeCombatant)
	local tSize = getSizeTable();
	if not tSize then
		return;
	end

	local nDefaultSize = getDefaultSize();
	if not nDefaultSize then
		return;
	end

	local aSizeEffects = EffectManager.getEffectsByType(nodeCombatant, "SIZE");
	local nMod = 0;
	local sBaseSize = DB.getValue(nodeCombatant, "size", ""):lower();
	local sCurrentSize = DB.getValue(nodeCombatant, "currentsize", sBaseSize);
	local sSize = sBaseSize;
	for _,rEffect in ipairs(aSizeEffects) do
		for _,sRemainder in ipairs(rEffect.remainder) do
			sSize = sRemainder; -- last in wins
		end
		nMod = nMod + rEffect.mod;
	end
	local nSize = tSize[sSize] or tSize[sBaseSize] or nDefaultSize;
	nSize = nSize + nMod;

	local nMin = 1000;
	local nMax = -1000;
	for _,nMappedSize in pairs(tSize) do
		if nMappedSize < nMin then
			nMin = nMappedSize;
		end
		if nMax < nMappedSize then
			nMax = nMappedSize;
		end
	end
	nSize = math.max(nMin, math.min(nSize, nMax));

	if nSize ~= tSize[sCurrentSize] then
		if nSize == tSize[sBaseSize] then
			DB.deleteChild(nodeCombatant, "currentsize");
		else
			DB.setValue(nodeCombatant, "currentsize", "string", getSizeName(nSize));
		end
	end
	return nSize;
end

function calculateSpace(nodeCombatant)
	local nDU = GameSystem.getDistanceUnitsPerGrid();
	local nBaseSpace = DB.getValue(nodeCombatant, "space", nDU);
	local nCurrentSpace = DB.getValue(nodeCombatant, "currentspace", nBaseSpace);
	local nSpace = nBaseSpace;

	local nSize = calculateSize(nodeCombatant);
	if nSize then
		local nSizeSpace = getSpaceFromSize(nSize, nDU);
		if nSizeSpace then
			nSpace = nSizeSpace;
		end
	end

	local aSpaceEffects = EffectManager.getEffectsByType(nodeCombatant, "SPACE");
	for _,rEffect in ipairs(aSpaceEffects) do
		if rEffect.mod ~= 0 then
			nSpace = rEffect.mod;
		end
	end

	local aAddSpaceEffects = EffectManager.getEffectsByType(nodeCombatant, "ADDSPACE");
	for _,rEffect in ipairs(aAddSpaceEffects) do
		nSpace = nSpace + rEffect.mod;
	end

	if nSpace ~= nCurrentSpace then
		if nSpace == nBaseSpace then
			DB.deleteChild(nodeCombatant, "currentspace");
		else
			DB.setValue(nodeCombatant, "currentspace", "number", nSpace);
		end
		return true;
	end
end

function calculateReach(nodeCombatant)
	local nDU = GameSystem.getDistanceUnitsPerGrid();
	local nBaseReach = DB.getValue(nodeCombatant, "reach", nDU);
	local nCurrentReach = DB.getValue(nodeCombatant, "currentreach", nBaseReach);
	local nReach = nBaseReach;

	local aReachEffects = EffectManager.getEffectsByType(nodeCombatant, "REACH");
	for _,rEffect in ipairs(aReachEffects) do
		if rEffect.mod ~= 0 then
			nReach = rEffect.mod;
		end
	end

	local aAddReachEffects = EffectManager.getEffectsByType(nodeCombatant, "ADDREACH");
	for _,rEffect in ipairs(aAddReachEffects) do
		nReach = nReach + rEffect.mod;
	end

	if nReach ~= nCurrentReach then
		if nReach == nBaseReach then
			DB.deleteChild(nodeCombatant, "currentreach");
		else
			DB.setValue(nodeCombatant, "currentreach", "number", nReach);
		end
		return true;
	end
end

function getSizeName(nSize)
	for sName,nMappedSize in pairs(getSizeTable()) do
		if (sName:len() > 1) and (nMappedSize == nSize) then
			return sName;
		end
	end
end

function getSpaceFromSize(nSize, nDU)
	-- Scale by increments over default.
	local nDefaultSize = getDefaultSize();
	if nDefaultSize then
		return nDU * math.max(1, nSize + 1 - nDefaultSize);
	end
end

function swapSpaceReach()
	bShouldSwap = true;
end

function resetSpaceReach()
	bShouldSwap = false;
end

function swapSize()
	bShouldSwap = true;
end

function resetSize()
	bShouldSwap = false;
end