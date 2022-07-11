--
-- Please see the license.txt file included with this distribution for
-- attribution and copyright information.
--

local getCreatureSizeDnD3Original;
local getCreatureSizeDnD5Original;

function onInit()
	getCreatureSizeDnD3Original = ActorCommonManager.getCreatureSizeDnD3;
	ActorCommonManager.getCreatureSizeDnD3 = getCreatureSizeDnD3;
	getCreatureSizeDnD5Original = ActorCommonManager.getCreatureSizeDnD5;
	ActorCommonManager.getCreatureSizeDnD5 = getCreatureSizeDnD5;
end

function getCreatureSizeDnD3(rActor, sParam)
	SizeManager.swapSize();
	local result = getCreatureSizeDnD3Original(rActor, sParam);
	SizeManager.resetSize();
	return result;
end

function getCreatureSizeDnD5(rActor, sParam)
	SizeManager.swapSize();
	local result = getCreatureSizeDnD5Original(rActor, sParam);
	SizeManager.resetSize();
	return result;
end