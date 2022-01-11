-- 
-- Please see the license.txt file included with this distribution for 
-- attribution and copyright information.
--

local updateSizeHelperOriginal;
local getTokenSpaceOriginal;

function onInit()
	updateSizeHelperOriginal = TokenManager.updateSizeHelper;
	TokenManager.updateSizeHelper = updateSizeHelper;

	getTokenSpaceOriginal = TokenManager.getTokenSpace;
	TokenManager.getTokenSpace = getTokenSpace;
end

function updateSizeHelper(tokenCT, nodeCT)
	local nOriginalSpace, nOriginalReach = SizeManager.swapSpaceReach(nodeCT);
	updateSizeHelperOriginal(tokenCT, nodeCT);
	SizeManager.resetSpaceReach(nodeCT, nOriginalSpace, nOriginalReach);
end

function getTokenSpace(tokenMap)
	local nodeCT = CombatManager.getCTFromToken(tokenMap)
	local nOriginalSpace, nOriginalReach = SizeManager.swapSpaceReach(nodeCT);
	local nSpace = getTokenSpaceOriginal(tokenMap);
	SizeManager.resetSpaceReach(nodeCT, nOriginalSpace, nOriginalReach);
	return nSpace;
end

function stopHandlingSpaceReach()
	CombatManager.removeCombatantFieldChangeHandler("space", "onUpdate", TokenManager.updateSpaceReach);
	CombatManager.removeCombatantFieldChangeHandler("reach", "onUpdate", TokenManager.updateSpaceReach);
end

function resumeHandlingSpaceReach()
	CombatManager.addCombatantFieldChangeHandler("space", "onUpdate", TokenManager.updateSpaceReach);
	CombatManager.addCombatantFieldChangeHandler("reach", "onUpdate", TokenManager.updateSpaceReach);
end