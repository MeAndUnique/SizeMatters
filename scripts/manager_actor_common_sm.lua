--
-- Please see the license.txt file included with this distribution for
-- attribution and copyright information.
--

local isCreatureSizeDnDOriginal;
local isCreatureSizeDnD5Original;

function onInit()
	isCreatureSizeDnDOriginal = ActorCommonManager.isCreatureSizeDnD;
	ActorCommonManager.isCreatureSizeDnD = isCreatureSizeDnD;
	isCreatureSizeDnD5Original = ActorCommonManager.isCreatureSizeDnD5;
	ActorCommonManager.isCreatureSizeDnD5 = isCreatureSizeDnD5;
end

function isCreatureSizeDnD(rActor, sParam)
	SizeManager.swapSize();
	local result = isCreatureSizeDnDOriginal(rActor, sParam);
	SizeManager.resetSize();
	return result;
end

function isCreatureSizeDnD5(rActor, sParam)
	SizeManager.swapSize();
	local result = isCreatureSizeDnD5Original(rActor, sParam);
	SizeManager.resetSize();
	return result;
end