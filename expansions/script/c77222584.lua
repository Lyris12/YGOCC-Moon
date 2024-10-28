--Bigbang Turbo Juggernaut
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsNeutral,1,1,Card.IsNegative,1)
	aux.AddCodeList(c,177222514)
	--If this card was Bigbang Summoned using "Bigbang Turbo", it cannot be targeted or destroyed by your opponent's card effects.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
	--During your opponent's Main Phase (Quick Effect): You can target 1 Positive Monster your opponent controls; 
	--immesiately after this effect resolves, Bigbang Summon 1 Bigbang Monster, by using only that opponent's monster and this card you control as material.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.material_setcode=0xbba
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if not g then return end
	e:SetLabel(g:FilterCount(Card.IsCode,nil,177222514))
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG) and e:GetLabelObject():GetLabel()>0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if ct>=1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(aux.indoval)
		c:RegisterEffect(e2)
	end
end
function s.bbfilter(c,e,tp,mg)
	if not c:IsType(TYPE_BIGBANG) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local et=global_card_effect_table[c]
	for _,e in ipairs(et) do
		if e:GetCode()==EFFECT_SPSUMMON_PROC then
			local ev=e:GetValue()
			local ec=e:GetCondition()
			if ev and (aux.GetValueType(ev)=="function" and ev(ef,c)&340==340 or ev&340==340) and (not ec or ec(e,c,mg)) then return true end
		end
	end
	return false
end
function s.tgfilter(c,e,tp,ec)
	local mg=Group.FromCards(ec,c)
	return c:IsFaceup() and c:IsPositive() and not c:IsImmuneToEffect(e) and Duel.IsExistingMatchingCard(s.bbfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.IsMainPhase()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,e,tp,c) and not c:IsImmuneToEffect(e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e) and not c:IsImmuneToEffect(e) then
		local mg=Group.FromCards(c,tc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.bbfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
		local bc=g:GetFirst()
		if bc then
			bc:SetMaterial(mg)
			Duel.Destroy(mg,REASON_RULE+REASON_MATERIAL+REASON_BIGBANG+REASON_REPLACE)
			if Duel.SpecialSummonStep(bc,SUMMON_TYPE_BIGBANG,tp,tp,false,false,POS_FACEUP) then
				bc:CompleteProcedure()
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function s.limitmat(e,c)
	return c:GetFlagEffect(id)<=0 or c:GetFlagEffectLabel(id)~=e:GetLabel()
end