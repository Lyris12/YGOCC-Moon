--created by Jake, coded by XGlitchy30
--Wrath at Dawn
if not global_override_reason_effect_check then
	global_override_reason_effect_check = true
end
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:HOPT(true)
	e1:SetLabel(0)
	e1:SetCost(aux.LabelCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.dawn_blader_monster_in_text = true
s.scapetoken = nil
function s.cfilter(c,e,tp)
	local rat=c:GetRating()
	local lv,rk=rat[1],rat[2]
	return c:IsMonster() and c:IsSetCard(0x613) and Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_MZONE,1,nil,lv,rk)
		and (c:IsLocation(LOCATION_HAND) and c:IsDiscardable() or (e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=3 and c:IsInGY() and c:IsAbleToRemoveAsCost()))
end
function s.disfilter(c,lv,rk)
	if (not lv or lv==0) and (not rk or rk==0) then return false end
	local val
	if lv and rk then
		val=math.max(lv,rk)
	elseif lv then
		val=lv
	else
		val=rk
	end
	return aux.NegateMonsterFilter(c) and ((c:HasLevel() and c:GetLevel()<=val) or (c:HasRank() and c:GetRank()<=val))
end
function s.filter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and (not c:IsRace(RACE_WARRIOR) or c:IsFacedown())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	local b1 = Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2 = (e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=3 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp))
	local opt=aux.Option(id,tp,1,b1,b2)
	if opt==0 then
		local ct=Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
		if ct>0 then
			local tc=Duel.GetOperatedGroup():GetFirst()
			if tc then
				local val=0
				if tc:HasLevel() then
					val=val|tc:GetLevel()
				end
				if tc:HasRank() then
					val=val|(tc:GetRank()<<16)
				end
				Duel.SetTargetParam(val)
				if e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
					if not s.scapetoken then
						local token=Duel.CreateToken(tp,GLITCHY_UNIVERSAL_TOKEN)
						token:SetStatus(STATUS_NO_LEVEL,true)
						s.scapetoken=token
					end
					s.scapetoken:Recreate(id,0,0x613,(s.scapetoken:GetType()&~TYPE_NORMAL)|c:GetType(),0,0,0,0)
					local fake_re=e:Clone()
					s.scapetoken:RegisterEffect(fake_re,true)
					fake_re:SetCheatCode(GECC_OVERRIDE_ACTIVE_TYPE)
					e:SetCheatCode(GECC_OVERRIDE_REASON_EFFECT,true)
					e:SetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT,fake_re)
					Duel.RaiseSingleEvent(tc,EVENT_DISCARD,fake_re,REASON_COST+REASON_DISCARD,tp,tp,0)
					Duel.RaiseEvent(tc,EVENT_DISCARD,fake_re,REASON_COST+REASON_DISCARD,tp,tp,0)
				end
			end
		end
	elseif opt==1 then
		Duel.HintMessage(tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_COST)>0 then
			local tc=Duel.GetOperatedGroup():GetFirst()
			local val=0
			if tc:HasLevel() then
				val=val|tc:GetLevel()
			end
			if tc:HasRank() then
				val=val|(tc:GetRank()<<16)
			end
			Duel.SetTargetParam(val)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	if not ct or ct<=0 then return end
	Duel.HintMessage(tp,HINTMSG_DISABLE)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil,ct&0xffff,ct>>16)
	if #g<=0 then return end
	Duel.HintSelection(g)
	Duel.Negate(g:GetFirst(),e,RESET_PHASE+PHASE_END)
end
