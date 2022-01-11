-- 
-- Please see the license.txt file included with this distribution for 
-- attribution and copyright information.
--

local tSizeChangedHandlers = {};

function onInit()
	DB.addHandler(CombatManager.CT_COMBATANT_PATH .. ".effects", "onChildUpdate", onCombatantEffectUpdated);
end

function addSizeChangedHandler(fHandler)
	tSizeChangedHandlers[fHandler] = true;
end

function removeSizeChangedHandler(fHandler)
	tSizeChangedHandlers[fHandler] = nil;
end

function invokeSizeChangedHandlers()
	for fHandler in pairs(tSizeChangedHandlers) do
		fHandler();
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

function onCombatantEffectUpdated(nodeEffectList)
	local nodeCombatant = nodeEffectList.getParent();
	local tokenCombatant = CombatManager.getTokenFromCT(nodeCombatant);
	local bChanged = calculateSpace(nodeCombatant);
	bChanged = calculateReach(nodeCombatant) or bChanged;

	if bChanged then
		if tokenCombatant then
			TokenManager.updateSizeHelper(tokenCombatant, nodeCombatant);
			if (OptionsManager.getOption("TASG") ~= "") and ImageManager.getImageControl(tokenCombatant) then
				TokenManager.autoTokenScale(tokenCombatant);
			end
		end
	end
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
	local sBaseSize = DB.getValue(nodeCombatant, "size", "");
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
		invokeSizeChangedHandlers();
	end
	return nSize;
end

function calculateSpace(nodeCombatant, nFromSize)
	local nDU = GameSystem.GameSystem.getDistanceUnitsPerGrid();
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
	local nDU = GameSystem.GameSystem.getDistanceUnitsPerGrid();
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

function swapSpaceReach(nodeCT)
	TokenManagerSM.stopHandlingSpaceReach();
	local nOriginalSpace, nOriginalReach;
	local nSpace = DB.getValue(nodeCT, "currentspace");
	local nReach = DB.getValue(nodeCT, "currentreach");
	if nSpace then
		nOriginalSpace = DB.getValue(nodeCT, "space");
		DB.setValue(nodeCT, "space", "number", nSpace);
	end
	if nReach then
		nOriginalReach = DB.getValue(nodeCT, "reach");
		DB.setValue(nodeCT, "reach", "number", nReach);
	end
	return nOriginalSpace, nOriginalReach;
end

function resetSpaceReach(nodeCT, nOriginalSpace, nOriginalReach)
	if nOriginalSpace then
		DB.setValue(nodeCT, "space", "number", nOriginalSpace);
	end
	if nOriginalReach then
		DB.setValue(nodeCT, "reach", "number", nOriginalReach);
	end
	TokenManagerSM.resumeHandlingSpaceReach();
end

function swapSize(rActor)
	local _,nodeActor = ActorManager.getTypeAndNode(rActor);
	local nodeCT = ActorManager.getCTNode(rActor);
	local sOriginalSize;
	local sSize = DB.getValue(nodeCT, "currentsize");
	if sSize then
		sOriginalSize = DB.getValue(nodeActor, "size");
		DB.setValue(nodeActor, "size", "string", sSize);
	end
	return sOriginalSize;
end

function resetSize(rActor, sOriginalSize)
	local _,nodeActor = ActorManager.getTypeAndNode(rActor);
	if sOriginalSize then
		DB.setValue(nodeActor, "size", "string", sOriginalSize);
	end
end