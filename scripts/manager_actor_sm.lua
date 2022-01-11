-- 
-- Please see the license.txt file included with this distribution for 
-- attribution and copyright information.
--

local isSizeOriginal;

function onInit()
	if ActorManager5E then
		isSizeOriginal = ActorManager5E.isSize;
		ActorManager5E.isSize = isSize;
	end
end

function isSize(rActor, sSizeCheck)
	local _,nodeActor = ActorManager.getTypeAndNode(rActor);
	local sOriginalSize = SizeManager.swapSize(rActor);
	local result = isSizeOriginal(rActor, sSizeCheck);
	SizeManager.resetSize(rActor, sOriginalSize);
	return result;
end