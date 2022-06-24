--Marmototem Colonia
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_SZONE,0,Duel.SendtoGrave,REASON_COST)
	--clear zones
	c:SummonedTrigger(false,false,true,false,0,CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION,true,{1,0},nil,nil,s.zntg,s.znop)
	--replace 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+100)
	e1:SetTarget(s.desreptg)
	e1:SetValue(s.desrepval)
	e1:SetOperation(s.desrepop)
	c:RegisterEffect(e1)
	--replace 1
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+200)
	e2:SetCondition(s.desrepcon2)
	e2:SetTarget(s.desreptg2)
	e2:SetValue(s.desrepval2)
	e2:SetOperation(s.desrepop2)
	c:RegisterEffect(e2)
end
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:GetType()&0x20004==0x20004 and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:GetOriginalRace()&RACES_BEASTS>0
end

function s.zcheck(c,i,tp)
	local zone=0x1<<i
	return aux.IsZone(c,zone,tp)
end
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
		local int={}
		for i=1,ct do
			table.insert(int,i)
		end
		ct=Duel.AnnounceNumber(tp,table.unpack(int))
	end
	local en=Duel.SelectField(tp,ct,LOCATION_MZONE,0,EXTRA_MONSTER_ZONE|(~zone),false)
	Duel.Hint(HINT_ZONE,tp,en)
	e:SetLabel(en)
	Duel.SetTargetParam(ct)
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
	local ct=Duel.GetTargetParam()
	local g=Duel.Group(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GB,0,nil)
	if g:CheckSubGroup(s.gcheck,ct,ct) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:SelectSubGroup(tp,s.gcheck,false,ct,ct)
		if #sg==ct then
			Duel.Search(sg,tp)
		end
	end
end
function s.spfilter(c)
	return c:NotBanishedOrFaceup() and c:IsMonster() and c:IsRace(RACES_BEASTS) and c:IsAbleToHand()
end
function s.gcheck(g)
	return g:GetClassCount(Card.GetAttribute)==#g
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
				Debug.Message(type(op))
				local zone=(type(op)=="number") and op or op(e,tp)
				return zone&e:GetLabel()
	end
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACES_BEASTS)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp) and not eg:IsContains(e:GetHandler()) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not e:GetHandler():IsForbidden()
		and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
	end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		return true
	end
	return false
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsImmuneToEffect(e) then
		Duel.Hint(HINT_CARD,0,id)
		if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			c:RegisterEffect(e1)
			if c:IsLocation(LOCATION_SZONE) and c:IsControler(tp) and c:GetType()&0x20004==0x20004
			and Duel.GetLocationCount(tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)+Duel.GetLocationCount(1-tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)>0 then
				local dis=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,EXTRA_MONSTER_ZONE)
				Duel.Hint(HINT_ZONE,tp,dis)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_DISABLE_FIELD)
				e1:SetLabel(dis)
				e1:SetOperation(s.disop0)
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.disop0(e,tp)
	return e:GetLabel()
end

function s.desrepcon2(e)
	return e:GetHandler():GetType()&0x20004==0x20004
end
function s.repfilter2(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:GetType()&0x20004==0x20004
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desreptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter2,1,nil,tp) and not eg:IsContains(e:GetHandler()) and e:GetHandler():IsAbleToGrave()
		and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
	end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		return true
	end
	return false
end
function s.desrepval2(e,c)
	return s.repfilter2(c,e:GetHandlerPlayer())
end
function s.desrepop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	Duel.SendtoGrave(c,REASON_EFFECT+REASON_REPLACE)
end