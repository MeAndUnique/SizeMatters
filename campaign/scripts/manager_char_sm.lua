-- 
-- Please see the license.txt file included with this distribution for 
-- attribution and copyright information.
--

local getEncumbranceMultOriginal;

function onInit()
	if CharManager then
		getEncumbranceMultOriginal = CharManager.getEncumbranceMult;
		CharManager.getEncumbranceMult = getEncumbranceMult;
	end
end

function getEncumbranceMult(nodeChar)
	local rActor = ActorManager.resolveActor(nodeChar);
	local sOriginalSize = SizeManager.swapSize(rActor);
	local result = getEncumbranceMultOriginal(nodeChar);
	SizeManager.resetSize(rActor, sOriginalSize);
	return result;
end