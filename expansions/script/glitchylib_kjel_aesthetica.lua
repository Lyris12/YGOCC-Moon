APPLY_FLAG_LEAVES_MZONE = 11110623

local _GetLocationCount, _GetLocationCountFromEx, _GetMZoneCount, _GetUsableMZoneCount, _IsExistingMatchingCard, _IsExistingTarget, _SelectMatchingCard, _SelectTarget, _GetMatchingGroup, _GroupFilter, _GroupSelect, _FilterSelect =
Duel.GetLocationCount, Duel.GetLocationCountFromEx, Duel.GetMZoneCount, Duel.GetUsableMZoneCount,
Duel.IsExistingMatchingCard, Duel.IsExistingTarget, Duel.SelectMatchingCard, Duel.SelectTarget, Duel.GetMatchingGroup, Group.Filter, Group.Select, Group.FilterSelect

function Auxiliary.LeavesMZoneFilter(c,tp,zone)
	return c:HasFlagEffect(APPLY_FLAG_LEAVES_MZONE) and c:GetZone(tp)&zone>0
end
function Auxiliary.LeavesMZoneFunctionFilter(f)
	return	function(c,...)
				return (not c:IsLocation(LOCATION_MZONE) or not c:HasFlagEffect(APPLY_FLAG_LEAVES_MZONE)) and (not f or f(c,...))
			end
end

Duel.GetLocationCount = function(tp,loc,...)
	local x={...}
	local ct=0
	local zone 	= #x>2 and x[3] or 0xff
	if loc&LOCATION_MZONE>0 then
		local g=_GetMatchingGroup(aux.LeavesMZoneFilter,tp,LOCATION_MZONE,0,nil,tp,zone)
		if #g>0 then
			ct=#g
		end
	end
	return _GetLocationCount(tp,loc,...)+ct
end

Duel.GetLocationCountFromEx = function(tp,...)
	local x={...}
	local excg	= #x>1 and x[2] or nil
	local zone 	= #x>3 and x[4] or 0xff
	
	local g=_GetMatchingGroup(aux.LeavesMZoneFilter,tp,LOCATION_MZONE,0,nil,tp,zone)
	if aux.GetValueType(excg)=="Card" then
		g:AddCard(excg)
	elseif aux.GetValueType(excg)=="Group" then
		g:Merge(excg)
	end
	
	if #x>0 then
		x[1]=g
	else
		table.insert(x,g)
	end
	
	return _GetLocationCountFromEx(tp,table.unpack(x))
end

Duel.GetMZoneCount = function(tp,...)
	local x={...}
	local excg	= #x>0 and x[1] or nil
	local zone 	= #x>3 and x[4] or 0xff
	
	local g=_GetMatchingGroup(aux.LeavesMZoneFilter,tp,LOCATION_MZONE,0,nil,tp,zone)
	if aux.GetValueType(excg)=="Card" then
		g:AddCard(excg)
	elseif aux.GetValueType(excg)=="Group" then
		g:Merge(excg)
	end
	
	if #x>0 then
		x[1]=g
	else
		table.insert(x,g)
	end
	
	return _GetMZoneCount(tp,table.unpack(x))
end

Duel.GetUsableMZoneCount = function(tp,...)
	local x={...}
	local ct=0
	
	local g=_GetMatchingGroup(aux.LeavesMZoneFilter,tp,LOCATION_MZONE,0,nil,tp,0xff)
	if #g>0 then
		ct=#g
	end
	
	return _GetUsableMZoneCount(tp,...)+ct
end

Duel.IsExistingMatchingCard = function(f,pov,loc1,loc2,min,exc,...)
	f = aux.LeavesMZoneFunctionFilter(f)
	return _IsExistingMatchingCard(f,pov,loc1,loc2,min,exc,...)
end
Duel.IsExistingTarget = function(f,pov,loc1,loc2,min,exc,...)
	f = aux.LeavesMZoneFunctionFilter(f)
	return _IsExistingTarget(f,pov,loc1,loc2,min,exc,...)
end
Duel.SelectMatchingCard = function(p,f,pov,loc1,loc2,min,max,exc,...)
	f = aux.LeavesMZoneFunctionFilter(f)
	return _SelectMatchingCard(p,f,pov,loc1,loc2,min,max,exc,...)
end
Duel.SelectTarget = function(p,f,pov,loc1,loc2,min,max,exc,...)
	f = aux.LeavesMZoneFunctionFilter(f)
	return _SelectTarget(p,f,pov,loc1,loc2,min,max,exc,...)
end
Duel.GetMatchingGroup = function(f,pov,loc1,loc2,exc,...)
	f = aux.LeavesMZoneFunctionFilter(f)
	return _GetMatchingGroup(f,pov,loc1,loc2,exc,...)
end
Group.Filter = function(g,f,exc,...)
	f = aux.LeavesMZoneFunctionFilter(f)
	return _GroupFilter(g,f,exc,...)
end
Group.Select = function(g,p,min,max,exc,...)
	f = aux.LeavesMZoneFunctionFilter(nil)
	return _FilterSelect(g,p,f,min,max,exc,...)
end
Group.FilterSelect = function(g,p,f,min,max,exc,...)
	f = aux.LeavesMZoneFunctionFilter(f)
	return _FilterSelect(g,p,f,min,max,exc,...)
end