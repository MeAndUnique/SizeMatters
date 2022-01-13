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
	SizeManager.swapSize();
	local result = isSizeOriginal(rActor, sSizeCheck);
	SizeManager.resetSize();
	return result;
end