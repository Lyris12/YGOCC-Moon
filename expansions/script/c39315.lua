--Starforce Dimension Rift

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_TOEXTRA|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_FUSION) and c:IsSetCard(0x24f) and c:IsAbleToExtra()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.mgfilter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&(REASON_FUSION|REASON_MATERIAL)==REASON_FUSION|REASON_MATERIAL
		and c:GetReasonCard()==fusc and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fusc:CheckFusionMaterial(mg,c)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsControler(tp) and s.filter(tc) then
		local mg=tc:GetMaterial()
		local ct=#mg
		local sumtype=tc:GetSummonType()
		if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
			local code=tc:GetCode()
			if sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION and ct>0 and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE) then
				local matct=mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,tc,mg)
				if matct==ct and (ct<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.BreakEffect()
					Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.aclimit)
			e1:SetLabel(code)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetTargetRange(1,0)
			e2:SetLabel(code)
			e2:SetTarget(s.splimit)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
			Duel.RegisterHint(tp,id,PHASE_END,1,id,2)
		end
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
function s.splimit(e,c) 
	return c:IsCode(e:GetLabel())
end
