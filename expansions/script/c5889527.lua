--Marmonk Grigia
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1x)
	--enable zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.zntg)
	e2:SetOperation(s.znop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2x)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCustomCategory(CATEGORY_PLACE_AS_CONTINUOUS_TRAP,CATEGORY_FLAG_SELF)
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--ATK/DEF
function s.zcheck(c,i,tp)
	local zone=0x1<<i
	return aux.IsZone(c,zone,tp)
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local ct=0
	local incr=(tp==0) and 1 or -1
	for p=tp,1-tp,incr do
		for i=0,4 do
			local index=(p==tp) and i or 4-i
			if not Duel.CheckLocation(p,LOCATION_MZONE,i) and not Duel.GetFieldGroup(p,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,p) then
				ct=ct+1
			end
		end
	end
	return ct*400
end
--ENABLE ZONE
function s.zntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local check=false
		for i=0,4 do
			if not Duel.CheckLocation(tp,LOCATION_MZONE,i) and not Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,tp) then
				check=true
				break
			end
		end
		return check
	end
	local zone=0
	local ct=0
	for i=0,4 do
		if not Duel.CheckLocation(tp,LOCATION_MZONE,i) and not Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,tp) then
			ct=ct+1
			zone=zone|(0x1<<i)
		end
	end
	if ct>1 then
		if ct>2 then ct=2 end
		local int={}
		for i=1,ct do
			table.insert(int,i)
		end
		ct=Duel.AnnounceNumber(tp,table.unpack(int))
	end
	local en=Duel.SelectField(tp,ct,LOCATION_MZONE,0,EXTRA_MONSTER_ZONE|(~zone),false)
	Duel.Hint(HINT_ZONE,tp,en)
	e:SetLabel(en)
end
function s.zdisfilter(c)
	if c:IsLocation(LOCATION_ONFIELD+LOCATION_REMOVED) and not c:IsFaceup() then return end
	local t=global_card_effect_table[c]
	if t and #t>0 then
		local fixct=#t
		for i=1,fixct do
			local ce=t[i]
			if ce and ce.SetLabelObject and (ce:GetCode()==EFFECT_DISABLE_FIELD or ce:GetCode()==EFFECT_USE_EXTRA_MZONE) then
				return true
			end
		end
	end
	return false
end
function s.znop(e,tp,eg,ep,ev,re,r,rp)
	local en=e:GetLabel()
	--handle card effect
	local g=Duel.GetMatchingGroup(s.zdisfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if #g>0 then
		local tc=g:GetFirst()
		while tc do
			local t=global_card_effect_table[tc]
			if t and #t>0 then
				local fixct=#t
				for i=1,fixct do
					local ce=t[i]
					if ce and ce.SetLabelObject and ce:GetCode()==EFFECT_DISABLE_FIELD and aux.GetValueType(ce:GetHandler())=="Card" then
						local con=ce:GetCondition()
						if not con or con(ce,tp,eg,ep,ev,re,r,rp) then
							local reset,rct=ce:GLGetReset()
							if not rct then rct=1 end
							reset=(reset&(~(RESET_EVENT+RESETS_STANDARD_DISABLE)))|(RESET_EVENT+RESETS_STANDARD_DISABLE)
							local val=ce:GetValue()
							if val then
								local zone=type(val)=="number" and val or val()
								if tp==1 then
									zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
								end
								Debug.Message(tostring(zone).." "..tostring(~en).." "..tostring(zone&(~en)))
								tc:RegisterFlagEffect(id,reset,0,rct)
								local newzone=(zone&(~en))
								if tp==1 then
									newzone=((newzone&0xffff)<<16)|((newzone>>16)&0xffff)
								end
								if newzone~=0 then
									local ne=ce:Clone()
									ne:SetValue(newzone)
									if ce:GetLabelObject() then ne:SetLabelObject(ce:GetLabelObject()) end
									tc:RegisterEffect(ne)
								end
								ce:SetCondition(s.zcond(con))
							end
						end
						
					elseif ce and ce.SetLabelObject and ce:GetCode()==EFFECT_USE_EXTRA_MZONE then
						local con=ce:GetCondition()
						if not con or con(ce,tp,eg,ep,ev,re,r,rp) then
							local reset,rct=ce:GLGetReset()
							if not rct then rct=1 end
							reset=(reset&(~(RESET_EVENT+RESETS_STANDARD_DISABLE)))|(RESET_EVENT+RESETS_STANDARD_DISABLE)
							local val=ce:GetValue()
							local zct=math.fmod(val,0x10)
							local zone=bit.rshift(val-zct,16)
							if zone&en~=0 then
								tc:RegisterFlagEffect(id,reset,0,rct)
								local ne=ce:Clone()
								ne:SetValue(bit.lshift(zone&(~en),16)+zct-1)
								ne:SetReset(reset,rct)
								tc:RegisterEffect(ne)
								ce:SetCondition(s.zcond(con))
							end
						end
					end
				end
			end
			tc=g:GetNext()
		end
	end
	--handle duel effect
	local incr=(tp==0) and 1 or -1
	for p=tp,1-tp,incr do
		local t=global_duel_effect_table[p]
		if t and #t>0 then
			local fixct=#t
			for i=1,fixct do
				local ce=t[i]
				if ce and aux.GetValueType(ce)=="Effect" and ce.SetLabelObject and ce:GetCode()==EFFECT_DISABLE_FIELD then
					local check=true
					if global_reset_duel_effect_table[ce] and global_reset_duel_effect_table[ce]==true then
						check=false
						for _,rce in ipairs({Duel.IsPlayerAffectedByEffect(p,GLOBAL_EFFECT_RESET)}) do
							if rce and rce.GetLabelObject and rce:GetLabelObject()==ce then
								--Debug.Message(ce:GetOwner():GetCode())
								check=true
								break
							end
						end
					end
					if check then
						--Debug.Message(ce:GetOwner():GetCode())
						local con=ce:GetCondition()
						if not con or con(ce,tp,eg,ep,ev,re,r,rp) then
							local reset,rct=ce:GLGetReset()
							if not rct then rct=1 end
							local val=ce:GetValue()
							if val then
								local zone=type(val)=="number" and val or val()
								if tp==1 then
									zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
								end
								Debug.Message(tostring(zone).." "..tostring(~en).." "..tostring(zone&(~en)))
								ce:GetOwner():RegisterFlagEffect(id,reset,0,rct)
								local newzone=(zone&(~en))
								if tp==1 then
									newzone=((newzone&0xffff)<<16)|((newzone>>16)&0xffff)
								end
								if newzone~=0 then
									local ne=ce:Clone()
									ne:SetValue(newzone)
									if ce:GetLabelObject() then ne:SetLabelObject(ce:GetLabelObject()) end
									Duel.RegisterEffect(ne,p)
								end
								ce:SetCondition(s.zcond2(con))
							end
						end
					end
				end
			end
		end
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.spfilter(c,e,tp)
	if c:IsCode(id) or not c:IsType(TYPE_MONSTER) or not c:IsRace(RACE_BEAST) or not c:IsLevelBelow(4) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local egroup=global_card_effect_table[c]
	for i=1,#egroup do
		local ce=egroup[i]
		if ce and aux.GetValueType(ce)=="Effect" and ce.SetLabelObject then
			local cat,flag=ce:GetCustomCategory()
			if cat&CATEGORY_PLACE_AS_CONTINUOUS_TRAP>0 and flag&CATEGORY_FLAG_SELF>0 then
				return true
			end
		end
	end
	return false
end
function s.zcond(con)
	return	function(e,...)
				return e:GetHandler():GetFlagEffect(id)<=0 and (not con or con(e,...))
			end
end
function s.zcond2(con)
	return	function(e,...)
				return e:GetOwner():GetFlagEffect(id)<=0 and (not con or con(e,...))
			end
end
function s.disop(e,tp)
	return e:GetLabel()
end
function s.disop2(op)
	return	function(e,tp)
				local zone=(type(op)=="number") and op or op(e,tp)
				return zone&e:GetLabel()
	end
end

--DRAW
function s.tfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:GetOriginalRace()&RACE_BEAST==RACE_BEAST
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.tfilter,tp,LOCATION_SZONE,0,nil)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not e:GetHandler():IsForbidden() and ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetCustomOperationInfo(0,CATEGORY_PLACE_AS_CONTINUOUS_TRAP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,ct-1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if not c:IsRelateToChain(0) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not c:IsImmuneToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		local ct=Duel.GetMatchingGroupCount(s.tfilter,tp,LOCATION_SZONE,0,nil)
		if ct>0 and Duel.Draw(p,ct,REASON_EFFECT)==ct then
			Duel.BreakEffect()
			local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
			if #g==0 then return end
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
			local sg=g:Select(p,ct-1,ct-1,nil)
			Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
		end
	end
end