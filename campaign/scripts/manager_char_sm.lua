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
	SizeManager.swapSize();
	local result = getEncumbranceMultOriginal(nodeChar);
	SizeManager.resetSize();
	return result;
end