SCRIPT_AS_EQUIP = false

SUBJECT_THIS_CARD 			= 	0
SUBJECT_IT					=	1
SUBJECT_THEM				=	1
SUBJECT_THAT_TARGET			=	2
SUBJECT_THOSE_TARGETS		=	2
SUBJECT_ALL_THOSE_TARGETS	=	3
SUBJECT_ALL					=	4

-----------------------------------------------------------------------
function Card.SingleEffect(c,code,val,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	
	if not prop then prop=0 end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range and not SCRIPT_AS_EQUIP then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(code)
	if val then
		e:SetValue(val)
	end
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		if reset&RESET_EVENT==0 then
			reset=reset|RESET_EVENT|RESETS_STANDARD
		end
		e:SetReset(reset,rct)
	end
	
	if desc then
		prop=prop|EFFECT_FLAG_CLIENT_HINT
		e:SetDescription(desc)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end	
	
	return e
end

function Auxiliary.ForEach(f,loc1,loc2,exc,n)
	if not loc1 then loc1=0 end
	if not loc2 then loc2=0 end
	if not n then n=1 end
	return	function(e,c)
				local tp=e:GetHandlerPlayer()
				local exc= (type(exc)=="boolean" and exc) and e:GetHandler() or (exc) and exc or nil
				return Duel.GetMatchingGroupCount(f,tp,loc1,loc2,exc,e,tp)*n
			end
end

--Stats
function Auxiliary.UpdateStatsOperationTemplate(fn,subject,atk,reset,rc,range,cond,loc1,loc2,min,max,exc)
	if type(subject)=="function" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=Duel.SelectMatchingCard(tp,subject,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						Duel.HintSelection(g)
						local chk=0
						for tc in aux.Next(g) do
							local eff,diff=fn(tc,atk,reset,rc,range,cond)
							if not tc:IsImmuneToEffect(eff) and diff==atk then
								chk=chk+1
							end
						end
						return g,chk,chk>0
					end
					return g,0
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						aux.CheckSequentiality(conj)
						local eff,diff=fn(c,atk,reset,rc,range,cond)
						local chk = (not c:IsImmuneToEffect(eff) and diff==atk)
						return c,1,chk
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff,diff=fn(tc,atk,reset,rc,range,cond)
								if not tc:IsImmuneToEffect(eff) and diff==atk then
									chk=chk+1
								end
							end
							return g,chk,chk>0
						end
			return aux.TargetOperation(op)
		
		elseif subject==SUBJECT_THAT_TARGET or subject==SUBJECT_ALL_THOSE_TARGETS then
			local hardchk=(subject==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff,diff=fn(tc,atk,reset,rc,range,cond)
								if not tc:IsImmuneToEffect(eff) and diff==atk then
									chk=chk+1
								end
							end
							return g,chk,chk>0
						end
			return aux.TargetOperation(op,nil,hardchk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(truesub,tp,loc1,loc2,exc)
						if #g<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg)
							local chk=0
							for tc in aux.Next(sg) do
								local eff,diff=fn(tc,atk,reset,rc,range,cond)
								if not tc:IsImmuneToEffect(eff) and diff==atk then
									chk=chk+1
								end
							end
							return sg,chk,chk>0
						end
						return sg,0
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff,diff=fn(tc,atk,reset,rc,range,cond)
								if not tc:IsImmuneToEffect(eff) and diff==atk then
									chk=chk+1
								end
							end
							return g,chk,chk>0
						end
			return aux.TargetOperation(op,f,hardchk)
		end
	end
end
function Auxiliary.ChangeStatsOperationTemplate(fn,subject,atk,reset,rc,range,cond,loc1,loc2,min,max,exc)
	if type(subject)=="function" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=Duel.SelectMatchingCard(tp,subject,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						Duel.HintSelection(g)
						local chk=0
						for tc in aux.Next(g) do
							local eff,_,diff=fn(tc,atk,reset,rc,range,cond)
							if not tc:IsImmuneToEffect(eff) and diff==atk then
								chk=chk+1
							end
						end
						return g,chk,chk>0
					end
					return g,0
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						aux.CheckSequentiality(conj)
						local eff,_,diff=fn(c,atk,reset,rc,range,cond)
						local chk = (not c:IsImmuneToEffect(eff) and diff==atk)
						return c,1,chk
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff,_,diff=fn(tc,atk,reset,rc,range,cond)
								if not tc:IsImmuneToEffect(eff) and diff==atk then
									chk=chk+1
								end
							end
							return g,chk,chk>0
						end
			return aux.TargetOperation(op)
		
		elseif subject==SUBJECT_THAT_TARGET or subject==SUBJECT_ALL_THOSE_TARGETS then
			local hardchk=(subject==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff,_,diff=fn(tc,atk,reset,rc,range,cond)
								if not tc:IsImmuneToEffect(eff) and diff==atk then
									chk=chk+1
								end
							end
							return g,chk,chk>0
						end
			return aux.TargetOperation(op,nil,hardchk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(truesub,tp,loc1,loc2,exc)
						if #g<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg)
							local chk=0
							for tc in aux.Next(sg) do
								local eff,_,diff=fn(tc,atk,reset,rc,range,cond)
								if not tc:IsImmuneToEffect(eff) and diff==atk then
									chk=chk+1
								end
							end
							return sg,chk,chk>0
						end
						return sg,0
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff,_,diff=fn(tc,atk,reset,rc,range,cond)
								if not tc:IsImmuneToEffect(eff) and diff==atk then
									chk=chk+1
								end
							end
							return g,chk,chk>0
						end
			return aux.TargetOperation(op,f,hardchk)
		end
	end
end
----------------------------------------

function Card.UpdateATK(c,atk,reset,rc,range,cond,prop,desc,pause)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	
	if not prop then prop=0 end
	
	local att=c:GetAttack()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range and not SCRIPT_AS_EQUIP then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetValue(atk)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	if pause then return e end
	
	c:RegisterEffect(e)
	
	if reset then
		return e,c:GetAttack()-att
	else
		return e
	end
end
function Auxiliary.UpdateATKOperation(subject,atk,reset,rc,range,cond,loc1,loc2,min,max,exc)
	return aux.UpdateStatsOperationTemplate(Card.UpdateATK,subject,atk,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.UpdateDEF(c,def,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	
	if not prop then prop=0 end
	
	local df=c:GetDefense()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range and not SCRIPT_AS_EQUIP then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_DEFENSE)
	e:SetValue(def)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e)
	if reset then
		return e,c:GetDefense()-df
	else
		return e
	end
end
function Auxiliary.UpdateDEFOperation(subject,def,reset,rc,range,cond,loc1,loc2,min,max,exc)
	return aux.UpdateStatsOperationTemplate(Card.UpdateDEF,subject,def,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.UpdateATKDEF(c,atk,def,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	local rc = rc and rc or c
	
	if not atk then
		atk=def
	elseif not def then
		def=atk
	end
	
	if not prop then prop=0 end
	
	local oatk,odef=c:GetAttack(),c:GetDefense()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	
	if range and not SCRIPT_AS_EQUIP then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetValue(atk)
	
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e)
	
	local e1x=e:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	e1x:SetValue(def)
	
	c:RegisterEffect(e1x)
	
	if not reset then
		return e,e1x
	else
		return e,e1x,c:GetAttack()-oatk,c:GetDefense()-odef
	end
end
function Auxiliary.UpdateATKDEFOperation(subject,atk,def,reset,rc,range,cond,loc1,loc2,min,max,exc)
	if type(subject)=="function" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=Duel.SelectMatchingCard(tp,subject,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						Duel.HintSelection(g)
						local chk=0
						for tc in aux.Next(g) do
							local eff1,eff2,diff1,diff2=tc:UpdateATKDEF(atk,def,reset,rc,range,cond,prop,desc)
							if not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def then
								chk=chk+1
							end
						end
						return g,chk,chk>0
					end
					return g,0
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						aux.CheckSequentiality(conj)
						local eff1,eff2,diff1,diff2=tc:UpdateATKDEF(atk,def,reset,rc,range,cond,prop,desc)
						local chk = (not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def)
						return c,1,chk
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff1,eff2,diff1,diff2=tc:UpdateATKDEF(atk,def,reset,rc,range,cond,prop,desc)
								if not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def then
									chk=chk+1
								end
							end
							return chk,chk>0
						end
			return aux.TargetOperation(op)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(truesub,tp,loc1,loc2,exc)
						if #g<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg)
							local chk=0
							for tc in aux.Next(sg) do
								local eff1,eff2,diff1,diff2=tc:UpdateATKDEF(atk,def,reset,rc,range,cond,prop,desc)
								if not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def then
									chk=chk+1
								end
							end
							return sg,chk,chk>0
						end
						return sg,0
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff1,eff2,diff1,diff2=tc:UpdateATKDEF(atk,def,reset,rc,range,cond,prop,desc)
								if not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def then
									chk=chk+1
								end
							end
							return chk,chk>0
						end
			return aux.TargetOperation(op,f,hardchk)
		end
	end
end

function Card.ChangeATK(c,atk,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	local rc = rc and rc or c
	
	if not prop then prop=0 end
	
	local oatk=c:GetAttack()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	
	if range and not SCRIPT_AS_EQUIP then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	
	e:SetCode(EFFECT_SET_ATTACK_FINAL)
	e:SetValue(atk)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	c:RegisterEffect(e)
	if not reset then
		return e
	else
		local natk=c:GetAttack()
		return e,oatk,natk,natk-oatk
	end
end
function Auxiliary.ChangeATKOperation(subject,atk,reset,rc,range,cond,loc1,loc2,min,max,exc)
	return aux.ChangeStatsOperationTemplate(Card.ChangeATK,subject,atk,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.ChangeDEF(c,def,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	local rc = rc and rc or c
	
	if not prop then prop=0 end
	
	local odef=c:GetDefense()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	
	if range and not SCRIPT_AS_EQUIP then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	
	e:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e:SetValue(def)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e)
	if not reset then
		return e
	else
		local ndef=c:GetDefense()
		return e,odef,ndef,ndef-odef
	end
end

function Auxiliary.ChangeDEFOperation(subject,def,reset,rc,range,cond,loc1,loc2,min,max,exc)
	return aux.ChangeStatsOperationTemplate(Card.ChangeDEF,subject,def,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.ChangeATKDEF(c,atk,def,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	local rc = rc and rc or c
	
	if not prop then prop=0 end
	
	if not atk then
		atk=def
	elseif not def then
		def=atk
	end
	
	local oatk=c:GetAttack()
	local odef=c:GetDefense()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	
	if range and not SCRIPT_AS_EQUIP then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	
	e:SetCode(EFFECT_SET_ATTACK_FINAL)
	e:SetValue(atk)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	c:RegisterEffect(e)
	
	local e1x=e:Clone()
	e1x:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e1x:SetValue(def)
	c:RegisterEffect(e1x)
	if not reset then
		return e,e1x
	else
		local natk,ndef=c:GetAttack(),c:GetDefense()
		return e,e1x,oatk,natk,odef,ndef,natk-oatk,ndef-odef
	end
end
function Auxiliary.ChangeATKDEFOperation(subject,atk,def,reset,rc,range,cond,loc1,loc2,min,max,exc)
	if type(subject)=="function" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=Duel.SelectMatchingCard(tp,subject,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						Duel.HintSelection(g)
						local chk=0
						for tc in aux.Next(g) do
							local eff1,eff2,_1,diff1,_2,diff2=tc:ChangeATKDEF(atk,def,reset,rc,range,cond,prop,desc)
							if not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def then
								chk=chk+1
							end
						end
						return g,chk,chk>0
					end
					return g,0
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						aux.CheckSequentiality(conj)
						local eff1,eff2,_1,diff1,_2,diff2=tc:ChangeATKDEF(atk,def,reset,rc,range,cond,prop,desc)
						local chk = (not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def)
						return c,1,chk
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff1,eff2,_1,diff1,_2,diff2=tc:ChangeATKDEF(atk,def,reset,rc,range,cond,prop,desc)
								if not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def then
									chk=chk+1
								end
							end
							return chk,chk>0
						end
			return aux.TargetOperation(op)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(truesub,tp,loc1,loc2,exc)
						if #g<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg)
							local chk=0
							for tc in aux.Next(sg) do
								local eff1,eff2,_1,diff1,_2,diff2=tc:ChangeATKDEF(atk,def,reset,rc,range,cond,prop,desc)
								if not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def then
									chk=chk+1
								end
							end
							return sg,chk,chk>0
						end
						return sg,0
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							for tc in aux.Next(g) do
								local eff1,eff2,_1,diff1,_2,diff2=tc:ChangeATKDEF(atk,def,reset,rc,range,cond,prop,desc)
								if not tc:IsImmuneToEffect(eff1) and diff1==atk and not tc:IsImmuneToEffect(eff2) and diff2==def then
									chk=chk+1
								end
							end
							return chk,chk>0
						end
			return aux.TargetOperation(op,f,hardchk)
		end
	end
end

function Card.HalveATK(c,reset,rc,range,cond,prop,desc)
	local atk=math.floor(c:GetAttack()/2 + 0.5)
	return c:ChangeATK(atk,reset,rc,range,cond,prop,desc)
end
function Auxiliary.HalveATKOperation(subject,reset,rc,range,cond,loc1,loc2,min,max,exc)
	local atk=math.floor(c:GetAttack()/2)
	return aux.ChangeStatsOperationTemplate(Card.ChangeATK,subject,atk,reset,rc,range,cond,loc1,loc2,min,max,exc)
end
function Card.HalveDEF(c,reset,rc,range,cond,prop,desc)
	local def=math.floor(c:GetDefense()/2 + 0.5)
	return c:ChangeDEF(def,reset,rc,range,cond,prop,desc)
end
function Auxiliary.HalveDEFOperation(subject,reset,rc,range,cond,loc1,loc2,min,max,exc)
	local def=math.floor(c:GetDefense()/2)
	return aux.ChangeStatsOperationTemplate(Card.ChangeDEF,subject,def,reset,rc,range,cond,loc1,loc2,min,max,exc)
end
function Card.DoubleATK(c,reset,rc,range,cond,prop,desc)
	local atk=c:GetAttack()*2
	return c:ChangeATK(atk,reset,rc,range,cond,prop,desc)
end
function Auxiliary.DoubleATKOperation(subject,reset,rc,range,cond,loc1,loc2,min,max,exc)
	local atk=c:GetAttack()*2
	return aux.ChangeStatsOperationTemplate(Card.ChangeATK,subject,atk,reset,rc,range,cond,loc1,loc2,min,max,exc)
end
function Card.DoubleDEF(c,reset,rc,range,cond,prop,desc)
	local def=c:GetDefense()*2
	return c:ChangeDEF(def,reset,rc,range,cond,prop,desc)
end
function Auxiliary.DoubleDEFOperation(subject,reset,rc,range,cond,loc1,loc2,min,max,exc)
	local def=c:GetDefense()*2
	return aux.ChangeStatsOperationTemplate(Card.ChangeDEF,subject,def,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.AddType(c,ctyp,reset,rc,range,cond,prop,desc)
	local otyp=c:GetType()
	local e=c:SingleEffect(EFFECT_ADD_TYPE,ctyp,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,otyp,c:GetType()&ctyp
	else
		return e
	end
end
function Auxiliary.AddTypeOperation(subject,attr,reset,rc,range,cond,loc1,loc2,min,max,exc)
	return aux.ChangeStatsOperationTemplate(Card.AddType,subject,attr,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.ChangeAttribute(c,attr,reset,rc,range,cond,prop,desc)
	local oatt=c:GetAttribute()
	local e=c:SingleEffect(EFFECT_CHANGE_ATTRIBUTE,attr,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,oatt,c:GetAttribute()
	else
		return e
	end
end
function Auxiliary.ChangeAttributeOperation(subject,attr,reset,rc,range,cond,loc1,loc2,min,max,exc)
	return aux.ChangeStatsOperationTemplate(Card.ChangeAttribute,subject,attr,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.ChangeRace(c,race,reset,rc,range,cond,prop,desc)
	local orac=c:GetRace()
	local e=c:SingleEffect(EFFECT_CHANGE_RACE,race,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,orac,c:GetRace()
	else
		return e
	end
end
function Auxiliary.ChangeRaceOperation(subject,race,reset,rc,range,cond,loc1,loc2,min,max,exc)
	return aux.ChangeStatsOperationTemplate(Card.ChangeRace,subject,race,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.UpdateLevel(c,lv,reset,rc,range,cond,prop,desc)
	local olv=c:GetLevel()
	local e=c:SingleEffect(EFFECT_UPDATE_LEVEL,lv,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,c:GetLevel()-olv
	else
		return e
	end
end
function Auxiliary.UpdateLevelOperation(subject,lv,reset,rc,range,cond,loc1,loc2,min,max,exc)
	return aux.UpdateStatsOperationTemplate(Card.UpdateLevel,subject,lv,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.ChangeLevel(c,lv,reset,rc,range,cond,prop,desc)
	local olv=c:GetLevel()
	local e=c:SingleEffect(EFFECT_CHANGE_LEVEL,lv,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,c:GetLevel()-olv
	else
		return e
	end
end
function Auxiliary.ChangeLevelOperation(subject,lv,reset,rc,range,cond,loc1,loc2,min,max,exc)
	return aux.ChangeStatsOperationTemplate(Card.ChangeLevel,subject,lv,reset,rc,range,cond,loc1,loc2,min,max,exc)
end

function Card.UpdateRank(c,lv,reset,rc,range,cond,prop,desc)
	local olv=c:GetRank()
	local e=c:SingleEffect(EFFECT_UPDATE_RANK,lv,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,c:GetRank()-olv
	else
		return e
	end
end
function Card.ChangeRank(c,lv,reset,rc,range,cond,prop,desc)
	local olv=c:GetRank()
	local e=c:SingleEffect(EFFECT_CHANGE_RANK,lv,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,c:GetRank()-olv
	else
		return e
	end
end

--Battle Restrictions
function Card.CannotAttack(c,val,reset,rc,cond,prop,desc)
	if reset then
		if not desc then
			desc=STRING_CANNOT_ATTACK
		end
		if type(rc)~="table" then
			if not rc then rc=c end
			rc={rc,true}
		end
	end
	local e=c:SingleEffect(EFFECT_CANNOT_ATTACK,val,reset,rc,nil,cond,prop,desc)
	c:RegisterEffect(e)
	return e
end


--Battle Related

BATTLE_TIMING_BATTLES				= 1
BATTLE_TIMING_ATTACKS				= 2
BATTLE_TIMING_ATTACKS_DIRECTLY		= 3
BATTLE_TIMING_IS_ATTACKED			= 4

BATTLE_TIMING_FUNCTIONS_SINGLE={
[BATTLE_TIMING_BATTLES]=	function(f)
								return	function(e)
											local c=e:GetHandler()
											local d=c:GetBattleTarget()
											return not d or (not f or f(d,e,c))
										end
							end;
[BATTLE_TIMING_ATTACKS]=	function(f)
								return	function(e)
											local c=e:GetHandler()
											local a=Duel.GetAttacker()
											if not a or c~=a then return false end
											local d=c:GetBattleTarget()
											return not d or (not f or f(d,e,c))
										end
							end;
[BATTLE_TIMING_ATTACKS_DIRECTLY]=	function()
										return	function(e)
													local c=e:GetHandler()
													local a=Duel.GetAttacker()
													if not a or c~=a then return false end
													local d=c:GetBattleTarget()
													return not d
												end
									end;
[BATTLE_TIMING_IS_ATTACKED]=	function(f)
									return	function(e)
												local c=e:GetHandler()
												local a=Duel.GetAttackTarget()
												if not a or c~=a then return false end
												local d=c:GetBattleTarget()
												return (not f or f(d,e,c))
											end
								end;
}

function Card.CanAttackDirectly(c,val,reset,rc,cond,prop,desc)
	if not desc and reset then
		desc=STRING_DIRECT_ATTACK
	end
	local e=c:SingleEffect(EFFECT_DIRECT_ATTACK,val,reset,rc,nil,cond,prop,desc)
	c:RegisterEffect(e)
	return e
end
function Card.CanAttackWhileInDefensePosition(c,reset,rc,cond,prop,desc)
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_DEFENSE_ATTACK)
	e:SetValue(1)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset,rct)
	end
	c:RegisterEffect(e)
	return e
end
function Card.MustAttack(c,reset,rc,cond,prop,desc)
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_MUST_ATTACK)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset,rct)
	end
	c:RegisterEffect(e)
	return e
end
function Card.ArmadesEffect(c,timing,protection,self,oppo,reset,rc,cond,prop,desc)
	if not timing then timing=BATTLE_TIMING_BATTLES end
	if not self then self=0 end
	if not oppo then oppo=0 end
	local f
	if type(timing)=="table" then
		f=timing[2]
		timing=timing[1]
	end
	local battlecond=BATTLE_TIMING_FUNCTIONS_SINGLE[timing](f)
	local condition =	function(e)
							return (not battlecond or battlecond(e)) and (not cond or cond(e))
						end

	local val
	if not protection then
		val=1
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=8 do
				if protection&i==i then
					table.insert(list,PROTECTION_FUNCTIONS[i])
				end
				i=i*2
			end
			val =	function(eff,re,rp)
						for _,f in ipairs(list) do
							if not f(eff,re,rp) then
								return false
							end
						end
						return true
					end
		elseif type(protection)=="function" then
			val=protection
		else
			val=function(eff,re,rp) return rp~=eff:GetHandlerPlayer() end
		end
	end
	local e=c:FieldEffect(EFFECT_CANNOT_ACTIVATE,LOCATION_MZONE,self,oppo,nil,val,condition,reset,rc)
	e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	c:RegisterEffect(e)
	return e
end
function Card.SetMaximumNumberOfAttacks(c,ct,reset,rc,cond,prop,desc)
	if not ct then
		ct=1
	elseif type(ct)=="number" then
		ct=ct-1
	end
	local range
	if reset then
		range=LOCATION_MZONE
	end
	local e=c:SingleEffect(EFFECT_EXTRA_ATTACK,ct,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	return e
end
function Card.SetMaximumNumberOfAttacksOnMonsters(c,ct,reset,rc,cond,prop,desc)
	if not ct then
		ct=1
	elseif type(ct)=="number" then
		ct=ct-1
	end
	local range
	if reset then
		range=LOCATION_MZONE
	end
	local e=c:SingleEffect(EFFECT_EXTRA_ATTACK_MONSTER,ct,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	return e
end

--Protections
function Card.CannotBeDestroyedByBattle(c,val,cond,reset,rc,range,prop,desc,forced,typ)
	if not typ and c:IsOriginalType(TYPE_EQUIP) and not range then
		typ = EFFECT_TYPE_EQUIP
	else
		typ = typ or EFFECT_TYPE_SINGLE
	end
	
	if typ==EFFECT_TYPE_SINGLE and not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	
	if not prop then prop=0 end
	
	if not val then val=1 end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e:SetValue(val)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e,forced)
	
	return e
end

function Card.CannotBeDestroyedByEffects(c,val,cond,reset,rc,range,prop,desc,forced,typ)
	if not typ and c:IsOriginalType(TYPE_EQUIP) and not range then
		typ = EFFECT_TYPE_EQUIP
	else
		typ = typ or EFFECT_TYPE_SINGLE
	end
	
	if typ==EFFECT_TYPE_SINGLE and not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	
	if not prop then prop=0 end
	
	if not val then val=1 end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e:SetValue(val)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e,forced)
	
	return e
end

function Card.CannotBeTargetedByEffects(c,val,cond,reset,rc,range,prop,desc,forced,typ)
	if not typ and c:IsOriginalType(TYPE_EQUIP) and not range then
		typ = EFFECT_TYPE_EQUIP
	else
		typ = typ or EFFECT_TYPE_SINGLE
	end
	
	if typ==EFFECT_TYPE_SINGLE and not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	
	if not prop then prop=0 end
	
	if not val then val=1 end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e:SetValue(val)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e,forced)
	
	return e
end

--Protections: Immunity
UNAFFECTED_OTHER		= 0x1
UNAFFECTED_OPPO			= 0x2
UNAFFECTED_MONSTER		= 0x4
UNAFFECTED_SPELL		= 0x8
UNAFFECTED_TRAP			= 0x10
UNAFFECTED_OTHER_EQUIP	= 0x100

function Auxiliary.imother(e,te)
	return e:GetOwner()~=te:GetOwner()
end
function Auxiliary.imoval(e,te)
	return e:GetOwnerPlayer()~=te:GetOwnerPlayer()
end
function Auxiliary.imothereq(e,te)
	local owner,affecting_owner=e:GetOwner(),te:GetOwner()
	return owner~=affecting_owner and affecting_owner~=owner:GetEquipTarget()
end
function Auxiliary.imtype(typ)
	return	function(e,te)
				return te:IsActiveType(typ)
			end
end

Auxiliary.UnaffectedProtections={
	[UNAFFECTED_OTHER]			= aux.imother;
	[UNAFFECTED_OPPO]			= aux.imoval;
	[UNAFFECTED_MONSTER]		= aux.imtype(TYPE_MONSTER);
	[UNAFFECTED_SPELL]			= aux.imtype(TYPE_SPELL);
	[UNAFFECTED_TRAP]			= aux.imtype(TYPE_TRAP);
	[UNAFFECTED_OTHER_EQUIP]	= aux.imothereq;
	
}

function Card.Unaffected(c,immunity,cond,reset,rc,range,prop,desc,forced,typ)
	if not typ and c:IsOriginalType(TYPE_EQUIP) and not range then
		typ = EFFECT_TYPE_EQUIP
	else
		typ = typ or EFFECT_TYPE_SINGLE
	end
	
	if typ==EFFECT_TYPE_SINGLE and not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	
	if not prop then prop=0 end
	
	if type(immunity)=="number" then
		immunity=aux.UnaffectedProtections[immunity]
	end
	
	local e=Effect.CreateEffect(rc)
	if desc then
		e:SetDescription(desc)
		prop=prop|EFFECT_FLAG_CLIENT_HINT
	end
	e:SetType(typ)
	if range then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_IMMUNE_EFFECT)
	e:SetValue(immunity)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	local res=c:RegisterEffect(e,forced)
	
	return e,res
end

function Card.CannotBeTributed(c,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	local range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	--
	local e4=Effect.CreateEffect(c)
	e4:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(range)
	end
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetValue(1)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+reset,rct)
	end
	c:RegisterEffect(e4)
	--
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e5)
	return e4,e5
end

--Special conditions (not effects)
function Card.TrapCanBeActivatedFromHand(c,cond,desc,stop)
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:SetDescription(desc)
	end
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	if cond then
		e1:SetCondition(cond)
	end
	if not stop then
		c:RegisterEffect(e1)
	end
	return e1
end

--Restriction and Rules
function Card.MustBeSummoned(c,sumtype,rc)
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e:SetCode(EFFECT_SPSUMMON_CONDITION)
	e:SetValue(	function(eff,se,sp,st)
					return st&sumtype==sumtype
				end
			  )
	c:RegisterEffect(e)
	return e
end
function Card.MustFirstBeSummoned(c,sumtype,rc)
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e:SetCode(EFFECT_SPSUMMON_CONDITION)
	e:SetRange(LOCATION_EXTRA)
	e:SetValue(	function(eff,se,sp,st)
					return st&sumtype==sumtype
				end
			  )
	c:RegisterEffect(e)
	return e
end
function Card.MustBeSSedByOwnProcedure(c,rc)
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e)
end
function Card.CannotBeMaterial(c,ed_types,f,reset,rc,range,cond,prop,forced)
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	if not prop then prop=0 end
	if reset then prop=prop|EFFECT_FLAG_CLIENT_HINT end
	
	local effs={}
	local desclist={733,735,736,737,738,739}
	local elist={235,236,238,239,624,825}
	local list={TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK,TYPE_BIGBANG,TYPE_TIMELEAP}
	for i,typ in ipairs(list) do
		if ed_types&typ==typ then
			local e=Effect.CreateEffect(rc)
			e:SetDescription(desclist[i])
			e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|prop)
			e:SetType(EFFECT_TYPE_SINGLE)
			e:SetCode(elist[i])
			if type(f)=="function" then
				e:SetValue(function(eff,cc) if not cc then return false end return f(cc,eff) end)
			else
				e:SetValue(1)
			end
			if cond then
				e:SetCondition(cond)
			end
			if reset then
				if type(reset)~="number" then reset=0 end
				e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
			end
			c:RegisterEffect(e,forced)
			table.insert(effs,e)
		end
	end
	if #effs>0 then
		return table.unpack(effs)
	else
		return false
	end
end
function Card.CannotBeTributedForATributeSummon(c,forced,reset,rc,cond,prop,desc)
	if not prop then prop=0 end
	if desc then prop=prop|EFFECT_FLAG_CLIENT_HINT end
	local e=c:SingleEffect(EFFECT_UNRELEASABLE_SUM,1,reset,rc,nil,cond,prop,desc)
	c:RegisterEffect(e,forced)
	return e
end

function Card.CannotBeSet(c,reset,rc,cond,prop,desc)
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	local e=Effect.CreateEffect(rc)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_CANNOT_SSET)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset,rct)
	end
	c:RegisterEffect(e)
end

function Card.SetSummonLimit(c,sumtype,lim,flag)
	if type(sumtype)~="number" then sumtype=SUMMON_TYPE_SPECIAL end
	if type(lim)~="number" then lim=1 end
	local e=Effect.CreateEffect(c)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e:SetCode(EVENT_SPSUMMON_SUCCESS)
	e:SetCondition(function(eff) return eff:GetHandler():IsSummonType(sumtype) end)
	if not lim or lim==1 then
		e:SetOperation(
			function(eff,tp)
				local e1=Effect.CreateEffect(eff:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				if eff:GetHandler():GetSummonPlayer()==tp then
					e1:SetTargetRange(1,0)
				else
					e1:SetTargetRange(0,1)
				end
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetTarget(
					function(e,card,sump,styp,sumpos,targetp,se)
						return card:IsCode(c:GetCode()) and styp&sumtype==sumtype
					end
				)
				Duel.RegisterEffect(e1,tp)
			end
		)
	else
		if not flag then flag=c:GetOriginalCode() end
		e:SetOperation(
			function(eff,tp)
				local p=eff:GetHandler():GetSummonPlayer()
				Duel.RegisterFlagEffect(p,flag,RESET_PHASE+PHASE_END,0,1)
				if Duel.PlayerHasFlagEffect(p,flag) then
					local e1=Effect.CreateEffect(eff:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD)
					e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
					e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
					if p==tp then
						e1:SetTargetRange(1,0)
					else
						e1:SetTargetRange(0,1)
					end
					e1:SetReset(RESET_PHASE+PHASE_END)
					e1:SetTarget(
						function(e,c,sump,styp,sumpos,targetp,se)
							return c:IsCode(c:GetCode()) and styp&sumtype==sumtype
						end
					)
					Duel.RegisterEffect(e1,tp)
				end
			end
		)
	end
	c:RegisterEffect(e)
	return e
end

--Protections (OUTDATED: DO NOT USE - SOON TO BE DEPRECATED)
PROTECTION_FROM_OPPONENT 			= 0x1
PROTECTION_FROM_MONSTER_EFFECTS		= 0x2
PROTECTION_FROM_SPELL_EFFECTS		= 0x4
PROTECTION_FROM_TRAP_EFFECTS		= 0x8
PROTECTION_FROM_EFFECTS				= 0xe
PROTECTION_FROM_SPELLS_TRAPS		= 0xc
PROTECTION_MAX_VALUE				= 0x8

PROTECTION_FUNCTIONS={
[PROTECTION_FROM_OPPONENT]=function(eff,re,rp) return rp~=eff:GetHandlerPlayer() end;
[PROTECTION_FROM_MONSTER_EFFECTS]=function(eff,re,rp) return re:IsActiveType(TYPE_MONSTER) end;
[PROTECTION_FROM_SPELL_EFFECTS]=function(eff,re,rp) return re:IsActiveType(TYPE_SPELL) end;
[PROTECTION_FROM_TRAP_EFFECTS]=function(eff,re,rp) return re:IsActiveType(TYPE_TRAP) end;
}

UNAFFECTED_PROTECTION_FUNCTIONS={
[PROTECTION_FROM_OPPONENT]=function(eff,re) return re:GetOwnerPlayer()~=eff:GetOwnerPlayer() end;
[PROTECTION_FROM_MONSTER_EFFECTS]=function(eff,re) return re:IsActiveType(TYPE_MONSTER) end;
[PROTECTION_FROM_SPELL_EFFECTS]=function(eff,re) return re:IsActiveType(TYPE_SPELL) end;
[PROTECTION_FROM_TRAP_EFFECTS]=function(eff,re) return re:IsActiveType(TYPE_TRAP) end;
}
function Card.BattleProtection(c,reset,rc,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local prop = prop and prop or 0
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	local e=Effect.CreateEffect(c)
	if desc then
		e:Desc(desc)
		prop=prop|EFFECT_FLAG_CLIENT_HINT
	end
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE|prop)
		e:SetRange(LOCATION_MZONE)
	end
	e:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e:SetValue(1)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset,rct)
	end
	c:RegisterEffect(e)
	return e
end
function Card.EffectProtection(c,protection,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local prop = prop and prop or 0
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	local range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(c)
	if desc then
		e:Desc(desc)
		prop=prop|EFFECT_FLAG_CLIENT_HINT
	end
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE|prop)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	if not protection then
		e:SetValue(1)
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=PROTECTION_MAX_VALUE do
				if protection&i==i then
					table.insert(list,PROTECTION_FUNCTIONS[i])
				end
				i=i<<1
			end
			local func =	function(eff,re,rp)
								for _,f in ipairs(list) do
									if not f(eff,re,rp) then
										return false
									end
								end
								return true
							end
			e:SetValue(func)
		elseif type(protection)=="function" then
			e:SetValue(protection)
		else
			e:SetValue(function(eff,re,rp) return rp~=eff:GetHandlerPlayer() end)
		end
	end
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset,rct)
	end
	c:RegisterEffect(e)
	return e
end
function Card.TargetProtection(c,protection,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local prop = prop and prop or 0
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	local range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(c)
	if desc then
		e:Desc(desc)
		prop=prop|EFFECT_FLAG_CLIENT_HINT
	end
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE|prop)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	if not protection then
		e:SetValue(1)
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=PROTECTION_MAX_VALUE do
				if protection&i==i then
					table.insert(list,PROTECTION_FUNCTIONS[i])
				end
				i=i<<1
			end
			local func =	function(eff,re,rp)
								for _,f in ipairs(list) do
									if not f(eff,re,rp) then
										return false
									end
								end
								return true
							end
			e:SetValue(func)
		elseif type(protection)=="function" then
			e:SetValue(protection)
		else
			e:SetValue(aux.tgoval)
		end
	end
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	c:RegisterEffect(e)
	return e
end
function Card.UnaffectedProtection(c,protection,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local prop = prop and prop or 0
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	local range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(rc)
	if desc then
		e:Desc(desc)
		prop=prop|EFFECT_FLAG_CLIENT_HINT
	end
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE|prop)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_IMMUNE_EFFECT)
	if not protection then
		e:SetValue(1)
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=PROTECTION_MAX_VALUE do
				if protection&i==i then
					table.insert(list,UNAFFECTED_PROTECTION_FUNCTIONS[i])
				end
				i=i<<1
			end
			local func =	function(eff,re)
								for _,f in ipairs(list) do
									if not f(eff,re) then
										return false
									end
								end
								return true
							end
			e:SetValue(func)
		elseif type(protection)=="function" then
			e:SetValue(protection)
		else
			e:SetValue(function(eff,re,rp) return rp~=eff:GetOwnerPlayer() end)
		end
	end
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	c:RegisterEffect(e)
	return e
end

function Card.FirstTimeProtection(c,each_turn,battle,effect,protection,reset,rc,range,cond,prop,desc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local prop = prop and prop or 0
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	local range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(c)
	if desc then
		e:Desc(desc)
		prop=prop|EFFECT_FLAG_CLIENT_HINT
	end
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		if not each_turn then
			prop=prop|EFFECT_FLAG_NO_TURN_RESET
		end
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE|prop)
		e:SetRange(range)
	else
		if not each_turn then
			e:SetProperty(EFFECT_FLAG_NO_TURN_RESET|prop)
		end
	end
	e:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e:SetCountLimit(1)
	if not protection then
		e:SetValue(	function (eff,re,r,rp)
						return (battle and r&REASON_BATTLE>0) or (effect and r&REASON_EFFECT>0)
					end)
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=PROTECTION_MAX_VALUE do
				if protection&i==i then
					table.insert(list,PROTECTION_FUNCTIONS[i])
				end
				i=i<<1
			end
			local func =	function(eff,re,rp)
								if not ((battle and r&REASON_BATTLE>0) or (effect and r&REASON_EFFECT>0)) then return false end
								for _,f in ipairs(list) do
									if not f(eff,re,rp) then
										return false
									end
								end
								return true
							end
			e:SetValue(func)
		elseif type(protection)=="function" then
			e:SetValue(	function (eff,re,r,rp)
							return (battle and r&REASON_BATTLE>0) or (effect and r&REASON_EFFECT>0 and protection(eff,re,r,rp))
						end)
		else
			e:SetValue(	function (eff,re,r,rp)
							return (battle and r&REASON_BATTLE>0) or (effect and r&REASON_EFFECT>0 and rp~=eff:GetHandlerPlayer())
						end)
		end
	end
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	c:RegisterEffect(e)
	return e
end